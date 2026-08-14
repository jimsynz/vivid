defmodule Vivid.OpenType.CMap do
  @moduledoc ~S"""
  Reads a font's character map: the table which says which glyph draws which
  codepoint.

  Formats 4 and 12 are read. Format 4 reaches essentially every font in
  circulation - of 697 fonts surveyed on a development machine, 696 carried a
  format 4 subtable at platform 3, encoding 1 - but it can only address the basic
  multilingual plane, because its codepoints are sixteen bits. Format 12 uses
  thirty two, which is what emoji and the rarer CJK characters need.

  A font usually carries both, describing the same glyphs twice, so a format 12
  subtable is preferred wherever there is one: it's a superset, and choosing the
  format 4 subtable would silently lose every codepoint above `U+FFFF`.

  Failing that, subtables are preferred in the order Windows Unicode, Unicode,
  then Windows symbol. Symbol subtables are format 4 like the others, and are how
  icon fonts address their glyphs, generally somewhere in the `U+F000` private
  use area.
  """

  @preferred_encodings [{3, 10}, {0, 6}, {0, 4}, {3, 1}, {0, 3}, {0, 2}, {0, 1}, {0, 0}, {3, 0}]
  @max_codepoint 0x10FFFF

  @doc ~S"""
  Parse a `cmap` table, returning a map of codepoint to glyph index.

  Codepoints which map to glyph zero are left out, since glyph zero is the
  `.notdef` glyph every font uses to mean "no glyph for this".

  ## Examples

  A single segment mapping `A`, `B` and `C` to glyphs 2, 3 and 4 by adding a
  delta to the codepoint.

      iex> subtable = <<4::16, 32::16, 0::16, 4::16, 4::16, 1::16, 0::16,
      ...>              0x43::16, 0xFFFF::16, 0::16, 0x41::16, 0xFFFF::16,
      ...>              -63::16-signed, 1::16-signed, 0::16, 0::16>>
      ...> Vivid.OpenType.CMap.parse(<<0::16, 1::16, 3::16, 1::16, 12::32>> <> subtable)
      {:ok, %{65 => 2, 66 => 3, 67 => 4}}

  A segment which indexes the glyph array instead of adding a delta, which is
  what a font does when its glyphs aren't in codepoint order.

      iex> subtable = <<4::16, 36::16, 0::16, 4::16, 4::16, 1::16, 0::16,
      ...>              0x42::16, 0xFFFF::16, 0::16, 0x41::16, 0xFFFF::16,
      ...>              0::16-signed, 1::16-signed, 4::16, 0::16, 7::16, 9::16>>
      ...> Vivid.OpenType.CMap.parse(<<0::16, 1::16, 3::16, 1::16, 12::32>> <> subtable)
      {:ok, %{65 => 7, 66 => 9}}

  A format 12 subtable, whose thirty two bit codepoints can reach the emoji.
  Each group maps a run of codepoints onto a run of glyphs.

      iex> subtable = <<12::16, 0::16, 28::32, 0::32, 1::32,
      ...>              0x1F600::32, 0x1F602::32, 5::32>>
      ...> Vivid.OpenType.CMap.parse(<<0::16, 1::16, 3::16, 10::16, 12::32>> <> subtable)
      {:ok, %{0x1F600 => 5, 0x1F601 => 6, 0x1F602 => 7}}

  A font carrying both - which most do - is read through the format 12 subtable,
  since taking the format 4 one would silently lose everything above `U+FFFF`.
  Here the two disagree about `A` on purpose, so you can tell which was used.

      iex> format_4 = <<4::16, 32::16, 0::16, 4::16, 4::16, 1::16, 0::16,
      ...>              0x41::16, 0xFFFF::16, 0::16, 0x41::16, 0xFFFF::16,
      ...>              -64::16-signed, 1::16-signed, 0::16, 0::16>>
      ...> format_12 = <<12::16, 0::16, 40::32, 0::32, 2::32,
      ...>               0x41::32, 0x41::32, 9::32, 0x1F600::32, 0x1F600::32, 5::32>>
      ...> records = <<3::16, 1::16, 20::32, 3::16, 10::16, 52::32>>
      ...> Vivid.OpenType.CMap.parse(<<0::16, 2::16>> <> records <> format_4 <> format_12)
      {:ok, %{0x41 => 9, 0x1F600 => 5}}
  """
  @spec parse(binary) :: {:ok, %{char => non_neg_integer}} | {:error, String.t()}
  def parse(<<_version::16, count::16, records::binary>> = cmap) do
    with {:ok, subtable} <- best_subtable(cmap, records, count) do
      mappings(subtable)
    end
  end

  def parse(_cmap), do: {:error, "font's character map is too short to be read"}

  defp best_subtable(cmap, records, count) do
    encodings =
      for <<platform::16, encoding::16, offset::32 <- binary_slice(records, 0, count * 8)>>,
        into: %{},
        do: {{platform, encoding}, offset}

    @preferred_encodings
    |> Enum.with_index()
    |> Enum.flat_map(&readable_subtable(&1, encodings, cmap))
    |> Enum.min_by(fn {preference, _subtable} -> preference end, fn -> nil end)
    |> case do
      nil -> {:error, "font has no character map this library can read"}
      {_preference, subtable} -> {:ok, subtable}
    end
  end

  defp readable_subtable({encoding, index}, encodings, cmap) do
    with offset when is_integer(offset) <- Map.get(encodings, encoding),
         {:ok, subtable} <- subtable_at(cmap, offset),
         rank when is_integer(rank) <- format_rank(subtable) do
      [{{rank, index}, subtable}]
    else
      _unreadable -> []
    end
  end

  defp format_rank(<<12::16, _::binary>>), do: 0
  defp format_rank(<<4::16, _::binary>>), do: 1
  defp format_rank(_subtable), do: nil

  defp subtable_at(cmap, offset) when byte_size(cmap) > offset,
    do: {:ok, binary_slice(cmap, offset..-1//1)}

  defp subtable_at(_cmap, _offset),
    do: {:error, "font's character map points outside itself"}

  defp mappings(<<4::16, _::binary>> = subtable), do: segments(subtable)
  defp mappings(<<12::16, _::binary>> = subtable), do: groups(subtable)

  defp mappings(<<format::16, _::binary>>),
    do: {:error, "font's character map is in format #{format}, which isn't supported yet"}

  defp mappings(_subtable), do: {:error, "font's character map is too short to be read"}

  defp groups(<<12::16, _reserved::16, _length::32, _language::32, count::32, groups::binary>>) do
    {:ok,
     for <<first::32, last::32, glyph::32 <- binary_slice(groups, 0, count * 12)>>, reduce: %{} do
       mapped -> group_mappings(mapped, first, last, glyph)
     end}
  end

  defp groups(_subtable), do: {:error, "font's character map is too short to be read"}

  defp group_mappings(mapped, first, last, _glyph)
       when last < first or first > @max_codepoint,
       do: mapped

  defp group_mappings(mapped, first, last, glyph) do
    Enum.reduce(first..min(last, @max_codepoint)//1, mapped, fn codepoint, mapped ->
      case glyph + (codepoint - first) do
        0 -> mapped
        glyph -> Map.put(mapped, codepoint, glyph)
      end
    end)
  end

  defp segments(
         <<4::16, _length::16, _language::16, seg_count_x2::16, _::binary-size(6),
           arrays::binary>>
       ) do
    case arrays do
      <<end_codes::binary-size(^seg_count_x2), _pad::16, start_codes::binary-size(^seg_count_x2),
        deltas::binary-size(^seg_count_x2), range_offsets::binary-size(^seg_count_x2),
        glyph_ids::binary>> ->
        {:ok,
         segment_map(
           end_codes,
           start_codes,
           deltas,
           range_offsets,
           glyph_ids,
           div(seg_count_x2, 2)
         )}

      _short ->
        {:error, "font's character map ends part way through a segment"}
    end
  end

  defp segments(_subtable), do: {:error, "font's character map is too short to be read"}

  defp segment_map(end_codes, start_codes, deltas, range_offsets, glyph_ids, seg_count) do
    [
      for(<<code::16 <- end_codes>>, do: code),
      for(<<code::16 <- start_codes>>, do: code),
      for(<<delta::16-signed <- deltas>>, do: delta),
      for(<<offset::16 <- range_offsets>>, do: offset),
      0..(seg_count - 1)
    ]
    |> Enum.zip()
    |> Enum.reduce(%{}, &segment_mappings(&1, &2, glyph_ids, seg_count))
  end

  defp segment_mappings({last, first, delta, range_offset, index}, mappings, glyph_ids, seg_count) do
    Enum.reduce(first..last//1, mappings, fn codepoint, mappings ->
      case glyph(codepoint, first, delta, range_offset, index, glyph_ids, seg_count) do
        0 -> mappings
        glyph -> Map.put(mappings, codepoint, glyph)
      end
    end)
  end

  defp glyph(codepoint, _first, delta, 0, _index, _glyph_ids, _seg_count),
    do: Integer.mod(codepoint + delta, 65_536)

  defp glyph(codepoint, first, delta, range_offset, index, glyph_ids, seg_count) do
    at = (div(range_offset, 2) + (codepoint - first) + index - seg_count) * 2

    case at >= 0 && binary_slice(glyph_ids, at, 2) do
      <<0::16>> -> 0
      <<glyph::16>> -> Integer.mod(glyph + delta, 65_536)
      _outside -> 0
    end
  end
end
