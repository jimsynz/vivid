defmodule Vivid.Font do
  alias Vivid.{Font, Font.Glyph, Group, Hershey, Point, Shape}
  defstruct ~w(glyphs units_per_em vertical_offset)a

  @hershey_units_per_em 32
  @hershey_vertical_offset 10
  @default_size 32

  @moduledoc """
  Describes a font as a map of codepoints to glyphs, along with the metrics
  needed to lay them out.

  A font is data, so obtain one, hold onto it, and pass it to `line/3`:

      font = Vivid.Font.rowmans()
      Vivid.Font.line(font, "hello world", 24)

  `rowmans/0` is currently the only font available - it reads the Hershey vector
  font of that name from this library's `priv` directory via `Vivid.Hershey`.
  Since parsing a font costs a file read, prefer holding onto the result over
  calling `rowmans/0` for every line you render.

  Glyphs themselves are opaque to this module: anything implementing
  `Vivid.Font.Glyph` can be laid out, which is how stroke fonts and outline fonts
  coexist without this module knowing the difference.
  """

  @type t :: %Font{glyphs: %{char => Glyph.t()}, units_per_em: number, vertical_offset: number}

  @doc """
  Initialize a font from a map of codepoints to glyphs.

  * `glyphs` a map of codepoint to anything implementing `Vivid.Font.Glyph`.
  * `units_per_em` the size of this font's em square in the glyphs' own units,
    which is what makes a size in pixels mean the same thing across fonts.
  * `vertical_offset` how far above the origin to place the baseline.

  ## Example

      iex> Vivid.Font.init(%{}, 2048, 0)
      %Vivid.Font{glyphs: %{}, units_per_em: 2048, vertical_offset: 0}
  """
  @spec init(%{char => Glyph.t()}, number, number) :: Font.t()
  def init(glyphs, units_per_em, vertical_offset)
      when is_map(glyphs) and is_number(units_per_em) and is_number(vertical_offset),
      do: %Font{glyphs: glyphs, units_per_em: units_per_em, vertical_offset: vertical_offset}

  @doc """
  Returns the glyph for `codepoint` in `font`.

  ## Example

      iex> Vivid.Font.rowmans()
      ...> |> Vivid.Font.glyph(?A)
      ...> |> Vivid.Font.Char.width()
      18
  """
  @spec glyph(Font.t(), char) :: Glyph.t()
  def glyph(%Font{glyphs: glyphs} = _font, codepoint), do: Map.fetch!(glyphs, codepoint)

  @doc ~S"""
  Convert a String containing one or more characters into a shape.

  Can only handle characters defined in `font`, and raises a `KeyError` for any
  it doesn't contain. Carriage returns and line feeds are not supported.

  The third argument is the size to render at, in pixels per em. Defaults to
  `32`. Since it's measured against the font's em square rather than against the
  glyphs' own coordinates, the same size means the same thing whichever font
  it's given.

  ## Example

      iex> use Vivid
      ...> Font.line(Font.rowmans(), "hello world", 24)
      ...> |> to_string
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@ @\n" <>
      "@ @@@    @@@@@@@@@@    @@@@@@@ @@@@@ @@@@@@@@    @@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@ @@@@@@@    @@@@@@@@ @@    @@@ @@@@@@@@    @@ @\n" <>
      "@ @@ @@@@ @@@@@@@  @@@@ @@@@@@ @@@@@ @@@@@@  @@@@  @@@@@@@@@@@@@@@@@ @@@@@ @@@@@ @@@@@  @@@@  @@@@@@ @ @@@@@@@ @@@@@@  @@@@   @\n" <>
      "@   @@@@@@ @@@@@ @@@@@@@ @@@@@ @@@@@ @@@@@ @@@@@@@@ @@@@@@@@@@@@@@@@@ @@@ @ @@@ @@@@@ @@@@@@@@ @@@@@  @@@@@@@@ @@@@@ @@@@@@@@ @\n" <>
      "@ @@@@@@@@ @@@@@ @@@@@@@@ @@@@ @@@@@ @@@@@ @@@@@@@@ @@@@@@@@@@@@@@@@@ @@@ @ @@@ @@@@@ @@@@@@@@ @@@@@  @@@@@@@@ @@@@@ @@@@@@@@ @\n" <>
      "@ @@@@@@@@ @@@@@ @@@@@@@@ @@@@ @@@@@ @@@@@ @@@@@@@@ @@@@@@@@@@@@@@@@@ @@@ @ @@@ @@@@@ @@@@@@@@ @@@@@ @@@@@@@@@ @@@@@ @@@@@@@@ @\n" <>
      "@ @@@@@@@@ @@@@@          @@@@ @@@@@ @@@@@ @@@@@@@@ @@@@@@@@@@@@@@@@@ @@@ @ @@@ @@@@@ @@@@@@@@ @@@@@ @@@@@@@@@ @@@@@ @@@@@@@@ @\n" <>
      "@ @@@@@@@@ @@@@@ @@@@@@@@@@@@@ @@@@@ @@@@@ @@@@@@@@ @@@@@@@@@@@@@@@@@@ @ @@@ @ @@@@@@ @@@@@@@@ @@@@@ @@@@@@@@@ @@@@@ @@@@@@@@ @\n" <>
      "@ @@@@@@@@ @@@@@ @@@@@@@@@@@@@ @@@@@ @@@@@ @@@@@@@@ @@@@@@@@@@@@@@@@@@ @ @@@ @ @@@@@@ @@@@@@@@ @@@@@ @@@@@@@@@ @@@@@ @@@@@@@@ @\n" <>
      "@ @@@@@@@@ @@@@@ @@@@@@@@ @@@@ @@@@@ @@@@@ @@@@@@@@ @@@@@@@@@@@@@@@@@@ @ @@@ @ @@@@@@ @@@@@@@@ @@@@@ @@@@@@@@@ @@@@@ @@@@@@@@ @\n" <>
      "@ @@@@@@@@ @@@@@@ @@@@@@ @@@@@ @@@@@ @@@@@@ @@@@@@ @@@@@@@@@@@@@@@@@@@ @ @@@ @ @@@@@@@ @@@@@@ @@@@@@ @@@@@@@@@ @@@@@@ @@@@@@  @\n" <>
      "@ @@@@@@@@ @@@@@@@ @@@@ @@@@@@ @@@@@ @@@@@@@ @@@@ @@@@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@ @@@@ @@@@@@@ @@@@@@@@@ @@@@@@@ @@@@ @ @\n" <>
      "@ @@@@@@@@ @@@@@@@@    @@@@@@@ @@@@@ @@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@@    @@@@@@@@ @@@@@@@@@ @@@@@@@@    @@ @\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
  """
  @spec line(Font.t(), String.t(), number) :: Shape.t()
  def line(%Font{} = font, str, size \\ @default_size) do
    %Font{units_per_em: units_per_em, vertical_offset: vertical_offset} = font
    scale = size / units_per_em

    str
    |> String.to_charlist()
    |> Enum.reduce([], fn
      codepoint, [] ->
        char = glyph(font, codepoint)
        lpad = Glyph.left_pad(char, scale)
        [{char, lpad}]

      codepoint, [{lchar, lpad} | _] = letters ->
        char = glyph(font, codepoint)
        lpad = Glyph.left_pad(char, scale) + Glyph.right_pad(lchar, scale) + lpad
        [{char, lpad} | letters]
    end)
    |> Enum.map(fn {char, lpad} ->
      Glyph.to_shape(char, Point.init(lpad, vertical_offset), scale)
    end)
    |> Enum.into(Group.init())
  end

  @doc """
  Returns the `rowmans` Hershey font.

  ## Example

      iex> Vivid.Font.rowmans()
      ...> |> Vivid.Font.glyph(?V)
      ...> |> Vivid.Font.Char.rendered_width()
      16
  """
  @spec rowmans() :: Font.t()
  def rowmans do
    [
      " ",
      "!",
      "\"",
      "#",
      "$",
      "%",
      "&",
      "'",
      "(",
      ")",
      "*",
      "+",
      ",",
      "↑",
      ".",
      "/",
      "0",
      "1",
      "2",
      "3",
      "4",
      "5",
      "6",
      "7",
      "8",
      "9",
      ":",
      ";",
      "<",
      "=",
      ">",
      "?",
      "@",
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z",
      "[",
      "\\",
      "]",
      "↑",
      "-",
      "`",
      "a",
      "b",
      "c",
      "d",
      "e",
      "f",
      "g",
      "h",
      "i",
      "j",
      "k",
      "l",
      "m",
      "n",
      "o",
      "p",
      "q",
      "r",
      "s",
      "t",
      "u",
      "v",
      "w",
      "x",
      "y",
      "z",
      "{",
      "|",
      "}",
      "~"
    ]
    |> Enum.map(fn <<codepoint::utf8>> -> codepoint end)
    |> Enum.zip(font("rowmans"))
    |> Enum.into(%{})
    |> init(@hershey_units_per_em, @hershey_vertical_offset)
  end

  defp font(name) do
    name
    |> Hershey.definitions()
    |> Enum.to_list()
  end
end
