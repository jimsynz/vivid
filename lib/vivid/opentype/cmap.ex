defmodule Vivid.OpenType.CMap do
  @moduledoc ~S"""
  Reads a font's character map: the table which says which glyph draws which
  codepoint.

  Only format 4 subtables are read, which is enough for essentially every font in
  circulation - of 697 fonts surveyed on a development machine, 696 carried a
  format 4 subtable at platform 3, encoding 1. Format 12, which is what a font
  needs to reach codepoints outside the basic multilingual plane, isn't read yet.

  Subtables are preferred in the order Windows Unicode, Unicode, then Windows
  symbol. Symbol subtables are format 4 like the others, and are how icon fonts
  address their glyphs, generally somewhere in the `U+F000` private use area.
  """

  @preferred_encodings [{3, 1}, {0, 6}, {0, 4}, {0, 3}, {0, 2}, {0, 1}, {0, 0}, {3, 0}]

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
  """
  @spec parse(binary) :: {:ok, %{char => non_neg_integer}} | {:error, String.t()}
  def parse(<<_version::16, count::16, records::binary>> = cmap) do
    with {:ok, offset} <- best_subtable(records, count),
         {:ok, subtable} <- subtable_at(cmap, offset) do
      segments(subtable)
    end
  end

  def parse(_cmap), do: {:error, "font's character map is too short to be read"}

  defp best_subtable(records, count) do
    encodings =
      for <<platform::16, encoding::16, offset::32 <- binary_slice(records, 0, count * 8)>>,
        into: %{},
        do: {{platform, encoding}, offset}

    @preferred_encodings
    |> Enum.find_value(&Map.get(encodings, &1))
    |> case do
      nil -> {:error, "font has no character map this library can read"}
      offset -> {:ok, offset}
    end
  end

  defp subtable_at(cmap, offset) when byte_size(cmap) > offset,
    do: {:ok, binary_slice(cmap, offset..-1//1)}

  defp subtable_at(_cmap, _offset),
    do: {:error, "font's character map points outside itself"}

  defp segments(
         <<4::16, _length::16, _language::16, seg_count_x2::16, _::binary-size(6),
           arrays::binary>>
       ) do
    case arrays do
      <<end_codes::binary-size(^seg_count_x2), _pad::16, start_codes::binary-size(^seg_count_x2),
        deltas::binary-size(^seg_count_x2), range_offsets::binary-size(^seg_count_x2),
        glyph_ids::binary>> ->
        {:ok,
         mappings(
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

  defp segments(<<format::16, _::binary>>),
    do: {:error, "font's character map is in format #{format}, which isn't supported yet"}

  defp segments(_subtable), do: {:error, "font's character map is too short to be read"}

  defp mappings(end_codes, start_codes, deltas, range_offsets, glyph_ids, seg_count) do
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
