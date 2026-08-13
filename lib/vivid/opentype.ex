defmodule Vivid.OpenType do
  alias Vivid.{CFF, Font, OpenType.CMap}
  alias Vivid.CFF.Glyph, as: CFFGlyph
  alias Vivid.TrueType.Glyph, as: TrueTypeGlyph

  @moduledoc ~S"""
  Reads OpenType fonts - both the TrueType outlines in a `.ttf` and the
  PostScript ones in a `.otf` - and says clearly why it can't when it can't.

  ## Examples

      iex> Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf")
      ...> |> Vivid.OpenType.load!()
      ...> |> Vivid.Font.line("lo", 16)
      ...> |> to_string()
      "@@@@@@@@@@@@@@\n" <>
      "@  @@@@@@@@@@@\n" <>
      "@  @@@@@@@@@@@\n" <>
      "@  @@@@@@@@@@@\n" <>
      "@  @@@@   @@@@\n" <>
      "@  @@@      @@\n" <>
      "@  @@       @@\n" <>
      "@  @   @@@   @\n" <>
      "@  @   @@@   @\n" <>
      "@  @   @@@@  @\n" <>
      "@  @   @@@   @\n" <>
      "@  @@   @@   @\n" <>
      "@  @@       @@\n" <>
      "@  @@@     @@@\n" <>
      "@@@@@@@@@@@@@@\n"

  Text is where antialiasing earns its keep, and at this size it's the
  difference between legible and not. The same two letters again, drawn into a
  frame taking four samples per pixel, so a partly covered pixel comes out as
  something between ink and paper rather than having to choose.

      iex> font = Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf"))
      ...> frame = Vivid.Frame.init(14, 15, Vivid.RGBA.white())
      ...> text =
      ...>   font
      ...>   |> Vivid.Font.line("lo", 16)
      ...>   |> Vivid.Transform.center(frame)
      ...>   |> Vivid.Transform.apply()
      ...> frame
      ...> |> Vivid.Frame.push(text, Vivid.RGBA.black())
      ...> |> Vivid.Frame.samples(4)
      ...> |> to_string()
      "@@@@@@@@@@@@@@\n" <>
      "@+*@@@@@@@@@@@\n" <>
      "@  @@@@@@@@@@@\n" <>
      "@  @@@@@@@@@@@\n" <>
      "@  @@@@@@@@@@@\n" <>
      "@  @@@:   =@@@\n" <>
      "@  @@. .:  -@@\n" <>
      "@  @+ :@@%  @@\n" <>
      "@  @. *@@@: +@\n" <>
      "@  @  @@@@: +@\n" <>
      "@  @. #@@@: +@\n" <>
      "@  @- :@@@  @@\n" <>
      "@  @@. .=. :@@\n" <>
      "@  @@%.   :@@@\n" <>
      "@@@@@@@@@@@@@@\n"

  ## What's supported

  Glyph outlines from either the `glyf` table or a `CFF ` table, a character map
  from a format 4 `cmap` subtable, and advance widths from `hmtx`. TrueType
  composite glyphs - which is what every accented character is - are assembled
  from their components, and CFF charstrings are interpreted including their
  subroutines.

  A variable font loads and renders at its default instance, normally the regular
  weight, because a variable font is an ordinary font whose `glyf` table holds
  that instance. It can't be varied, but it isn't refused and doesn't look wrong.

  ## What isn't, and what happens instead

  CID-keyed CFF fonts, CFF2, bitmap-only fonts, and WOFF or WOFF2 containers are
  all detected and reported by name rather than failing on a bad match. WOFF2 in
  particular is compressed with Brotli, which can't be decompressed in pure
  Elixir, so it needs converting ahead of time.

  Kerning is not applied. Nearly all modern fonts keep their kerning in `GPOS`
  rather than in the legacy `kern` table - of 697 fonts surveyed, 88% had `GPOS`
  and 4% had `kern` - so reading `kern` would help almost nobody, and reading
  `GPOS` is a much larger job.
  """

  @doc """
  Read the font at `path`.

  Returns `{:error, reason}` with a reason worth showing a user, rather than
  raising, for anything from a missing file to a font this library can't read.

  ## Examples

      iex> {:ok, font} = Vivid.OpenType.load(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf"))
      ...> font.units_per_em
      2048

      iex> Vivid.OpenType.load("/no/such/font.ttf")
      {:error, "couldn't read /no/such/font.ttf: no such file or directory"}

      iex> Vivid.OpenType.load(Path.join(:code.priv_dir(:vivid), "hershey/rowmans.jhf"))
      {:error, "not a font this library recognises"}
  """
  @spec load(Path.t()) :: {:ok, Font.t()} | {:error, String.t()}
  def load(path) do
    with {:ok, data} <- read(path), {:ok, tables} <- tables(data) do
      build(tables)
    end
  end

  @doc """
  Read the font at `path`, raising `ArgumentError` if it can't be read.

  ## Example

      iex> Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf")
      ...> |> Vivid.OpenType.load!()
      ...> |> Vivid.Font.glyph(?A)
      ...> |> Vivid.TrueType.Glyph.advance()
      1336
  """
  @spec load!(Path.t()) :: Font.t()
  def load!(path) do
    case load(path) do
      {:ok, font} -> font
      {:error, reason} -> raise ArgumentError, reason
    end
  end

  defp read(path) do
    case File.read(path) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, "couldn't read #{path}: #{:file.format_error(reason)}"}
    end
  end

  defp tables(<<0, 1, 0, 0, _::binary>> = data), do: {:ok, directory(data, 0)}
  defp tables(<<"true", _::binary>> = data), do: {:ok, directory(data, 0)}
  defp tables(<<"OTTO", _::binary>> = data), do: {:ok, directory(data, 0)}

  defp tables(<<"ttcf", _version::32, _count::32, first::32, _::binary>> = data),
    do: {:ok, directory(data, first)}

  defp tables(<<"wOFF", _::binary>>),
    do:
      {:error,
       "WOFF fonts aren't supported yet; convert it to a TTF, or use the TTF it was made from"}

  defp tables(<<"wOF2", _::binary>>),
    do:
      {:error,
       "WOFF2 fonts are compressed with Brotli, which this library can't decompress; " <>
         "convert it with woff2_decompress or fonttools first"}

  defp tables(_data), do: {:error, "not a font this library recognises"}

  defp directory(data, offset) do
    case binary_slice(data, offset, byte_size(data)) do
      <<_version::32, count::16, _::binary-size(6), records::binary>> ->
        for <<tag::binary-size(4), _checksum::32, start::32,
              length::32 <-
                binary_slice(records, 0, count * 16)>>,
            into: %{},
            do: {tag, binary_slice(data, start, length)}

      _too_short ->
        %{}
    end
  end

  defp build(tables) do
    with {:ok, head} <- table(tables, "head"),
         {:ok, maxp} <- table(tables, "maxp"),
         {:ok, hhea} <- table(tables, "hhea"),
         {:ok, hmtx} <- table(tables, "hmtx"),
         {:ok, cmap} <- table(tables, "cmap"),
         {:ok, units_per_em, loca_format} <- head(head),
         {:ok, glyph_count} <- glyph_count(maxp),
         {:ok, glyph} <- glyph_source(tables, loca_format, glyph_count),
         {:ok, mappings} <- CMap.parse(cmap) do
      advances = advances(hmtx, metric_count(hhea))

      glyphs =
        Map.new(mappings, fn {codepoint, index} ->
          {codepoint, glyph.(index, advance(advances, index))}
        end)

      {:ok, Font.init(glyphs, units_per_em, 0)}
    end
  end

  defp glyph_source(%{"glyf" => glyf, "loca" => loca}, loca_format, glyph_count) do
    outlines = outlines(loca, loca_format, glyf, glyph_count)
    {:ok, &TrueTypeGlyph.init(&1, &2, outlines)}
  end

  defp glyph_source(%{"CFF " => cff}, _loca_format, _glyph_count) do
    with {:ok, parsed} <- CFF.parse(cff), do: {:ok, &CFFGlyph.init(&1, &2, parsed)}
  end

  defp glyph_source(%{"CFF2" => _}, _loca_format, _glyph_count),
    do: {:error, "this font uses CFF2 outlines, which aren't supported"}

  defp glyph_source(tables, _loca_format, _glyph_count) do
    if Enum.any?(~w[EBDT CBDT sbix], &Map.has_key?(tables, &1)) do
      {:error, "this font contains bitmap glyphs rather than outlines, which aren't supported"}
    else
      {:error, "this font has no glyph outlines this library can read"}
    end
  end

  defp table(tables, tag) do
    case Map.fetch(tables, tag) do
      {:ok, table} -> {:ok, table}
      :error -> {:error, "font is missing its #{tag} table"}
    end
  end

  defp head(
         <<_::binary-size(18), units_per_em::16, _::binary-size(30), loca_format::16-signed,
           _::binary>>
       )
       when units_per_em > 0,
       do: {:ok, units_per_em, loca_format}

  defp head(_head), do: {:error, "font's head table can't be read"}

  defp glyph_count(<<_version::32, count::16, _::binary>>), do: {:ok, count}
  defp glyph_count(_maxp), do: {:error, "font's maxp table can't be read"}

  defp metric_count(<<_::binary-size(34), count::16, _::binary>>), do: count
  defp metric_count(_hhea), do: 0

  defp advances(hmtx, count) do
    for(<<advance::16, _bearing::16-signed <- binary_slice(hmtx, 0, count * 4)>>, do: advance)
    |> List.to_tuple()
  end

  defp advance(advances, index) when tuple_size(advances) > 0,
    do: elem(advances, min(index, tuple_size(advances) - 1))

  defp advance(_advances, _index), do: 0

  defp outlines(loca, format, glyf, glyph_count) do
    loca
    |> offsets(format)
    |> Enum.take(glyph_count + 1)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.with_index()
    |> Map.new(fn {[start, next], index} ->
      {index, binary_slice(glyf, start, max(next - start, 0))}
    end)
  end

  defp offsets(loca, 0), do: for(<<offset::16 <- loca>>, do: offset * 2)
  defp offsets(loca, _long), do: for(<<offset::32 <- loca>>, do: offset)
end
