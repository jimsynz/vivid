defmodule Vivid.BDF do
  alias Vivid.{BDF.Glyph, Font}

  @moduledoc ~S"""
  Reads bitmap fonts in Adobe's Glyph Bitmap Distribution Format.

  A BDF file is plain text, which makes it the most approachable font format
  there is. A header describes the font, and then each glyph is a block naming
  its codepoint, its box, how far the pen advances, and its rows of pixels in
  hexadecimal:

      STARTCHAR A
      ENCODING 65
      DWIDTH 4 0
      BBX 4 6 0 -1
      BITMAP
      40
      A0
      E0
      A0
      A0
      00
      ENDCHAR

  `ENCODING` is a real codepoint, which is a step up on the Hershey fonts, where
  the mapping from character to glyph is positional and has to be supplied
  separately.

  Rows are listed from the top of the glyph down, and each is padded to a whole
  number of bytes, so a glyph 4 pixels wide still spends 8 bits per row and uses
  only the high 4. `BBX` gives the size of the box and where it sits relative to
  the origin, and its vertical offset is normally negative, since it starts below
  the baseline to leave room for descenders. Vivid's Y axis points up, so rows
  are read in reverse.

  ## Example

      iex> Path.join(:code.priv_dir(:vivid), "fonts/misc-fixed-4x6.bdf")
      ...> |> Vivid.BDF.load!()
      ...> |> Vivid.Font.glyph(?A)
      ...> |> Vivid.BDF.Glyph.pixels()
      [{1, 4}, {0, 3}, {2, 3}, {0, 2}, {1, 2}, {2, 2}, {0, 1}, {2, 1}, {0, 0}, {2, 0}]
  """

  @doc """
  Read the BDF font at `path`.

  Returns `{:error, reason}` with a reason worth showing a user rather than
  raising.

  ## Examples

      iex> {:ok, font} = Vivid.BDF.load(Path.join(:code.priv_dir(:vivid), "fonts/misc-fixed-4x6.bdf"))
      ...> {font.units_per_em, map_size(font.glyphs)}
      {6, 95}

      iex> Vivid.BDF.load("/no/such/font.bdf")
      {:error, "couldn't read /no/such/font.bdf: no such file or directory"}

      iex> Vivid.BDF.load(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf"))
      {:error, "not a BDF font"}
  """
  @spec load(Path.t()) :: {:ok, Font.t()} | {:error, String.t()}
  def load(path) do
    with {:ok, data} <- read(path) do
      parse(data)
    end
  end

  @doc """
  Read the BDF font at `path`, raising `ArgumentError` if it can't be read.

  ## Example

      iex> Path.join(:code.priv_dir(:vivid), "fonts/misc-fixed-4x6.bdf")
      ...> |> Vivid.BDF.load!()
      ...> |> Vivid.Font.glyph(?A)
      ...> |> Vivid.BDF.Glyph.advance()
      4
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

  defp parse("STARTFONT" <> _ = data) do
    lines = data |> String.split(~r/\r?\n/) |> Enum.map(&String.trim/1)

    case pixel_size(lines) do
      nil -> {:error, "BDF font doesn't say what size it is"}
      size -> {:ok, Font.init(glyphs(lines), size, 0)}
    end
  end

  defp parse(_data), do: {:error, "not a BDF font"}

  defp pixel_size(lines) do
    Enum.find_value(lines, fn
      "SIZE " <> rest -> rest |> integers() |> List.first()
      "FONTBOUNDINGBOX " <> rest -> rest |> integers() |> Enum.at(1)
      _line -> nil
    end)
  end

  defp glyphs(lines) do
    lines
    |> Enum.chunk_by(&(&1 == "ENDCHAR"))
    |> Enum.reject(&(&1 == ["ENDCHAR"]))
    |> Enum.flat_map(&glyph/1)
    |> Map.new()
  end

  defp glyph(block) do
    with codepoint when is_integer(codepoint) <- property(block, "ENCODING", 0),
         true <- codepoint >= 0,
         [width, height, x, y] <- properties(block, "BBX", 4) do
      advance = property(block, "DWIDTH", 0) || width
      rows = block |> Enum.drop_while(&(&1 != "BITMAP")) |> Enum.drop(1)
      [{codepoint, Glyph.init(advance, pixels(rows, width, height, x, y))}]
    else
      _incomplete -> []
    end
  end

  defp pixels(rows, width, height, x_offset, y_offset) do
    rows
    |> Enum.take(height)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, index} ->
      row
      |> row_bits(width)
      |> Enum.filter(fn {_column, set} -> set end)
      |> Enum.map(fn {column, _set} ->
        {x_offset + column, y_offset + height - 1 - index}
      end)
    end)
  end

  defp row_bits(row, width) do
    row
    |> Base.decode16(case: :mixed)
    |> case do
      {:ok, bytes} -> for <<bit::1 <- bytes>>, do: bit == 1
      :error -> []
    end
    |> Enum.take(width)
    |> Enum.with_index()
    |> Enum.map(fn {set, column} -> {column, set} end)
  end

  defp property(block, name, index) do
    block
    |> Enum.find_value(fn line ->
      case String.split(line, " ", parts: 2) do
        [^name, rest] -> integers(rest)
        _other -> nil
      end
    end)
    |> case do
      nil -> nil
      values -> Enum.at(values, index)
    end
  end

  defp properties(block, name, count) do
    case property_list(block, name) do
      values when length(values) >= count -> Enum.take(values, count)
      _short -> nil
    end
  end

  defp property_list(block, name) do
    Enum.find_value(block, [], fn line ->
      case String.split(line, " ", parts: 2) do
        [^name, rest] -> integers(rest)
        _other -> nil
      end
    end)
  end

  defp integers(text) do
    text
    |> String.split(~r/\s+/, trim: true)
    |> Enum.flat_map(fn value ->
      case Integer.parse(value) do
        {integer, _rest} -> [integer]
        :error -> []
      end
    end)
  end
end
