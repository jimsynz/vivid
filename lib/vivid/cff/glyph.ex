defmodule Vivid.CFF.Glyph do
  alias Vivid.{CFF, CFF.Charstring, CFF.Glyph, Point, Polygon, Region}
  defstruct ~w(index advance cff)a

  @moduledoc """
  A single glyph from a CFF font.

  Like its TrueType counterpart, a glyph holds the charstring describing it
  rather than its parsed outline, and interprets on demand. It carries the whole
  parsed table because a charstring can call subroutines, which live alongside
  the charstrings rather than inside them.

  Coordinates are in font units, and `Vivid.Font.line/3` supplies the multiplier
  which turns them into pixels.
  """

  @type t :: %Glyph{index: non_neg_integer, advance: number, cff: CFF.t()}

  @doc """
  Initialize a glyph.

  * `index` this glyph's index in the font.
  * `advance` how far the pen moves after drawing it, in font units.
  * `cff` the font's parsed CFF table.
  """
  @spec init(non_neg_integer, number, CFF.t()) :: Glyph.t()
  def init(index, advance, %CFF{} = cff)
      when is_integer(index) and is_number(advance),
      do: %Glyph{index: index, advance: advance, cff: cff}

  @doc """
  Returns how far the pen advances after drawing `glyph`, in font units.

  ## Example

      iex> Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.otf"))
      ...> |> Vivid.Font.glyph(?A)
      ...> |> Vivid.CFF.Glyph.advance()
      1336
  """
  @spec advance(Glyph.t()) :: number
  def advance(%Glyph{advance: advance} = _glyph), do: advance

  @doc """
  Returns the contours of `glyph` as lists of points in font units, with any
  curves already flattened into line segments.

  ## Example

  `o` is two contours: the outside, and the counter inside it.

      iex> Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.otf"))
      ...> |> Vivid.Font.glyph(?o)
      ...> |> Vivid.CFF.Glyph.contours()
      ...> |> Enum.count()
      2
  """
  @spec contours(Glyph.t()) :: [[Point.t()]]
  def contours(%Glyph{index: index, cff: cff} = _glyph) do
    %CFF{charstrings: charstrings, subrs: subrs, gsubrs: gsubrs} = cff

    if index < tuple_size(charstrings) do
      charstrings
      |> elem(index)
      |> Charstring.contours(subrs, gsubrs)
    else
      []
    end
  end

  @doc """
  Converts `glyph` into a `Vivid.Region` in font units, one contour per contour.

  ## Example

      iex> Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.otf"))
      ...> |> Vivid.Font.glyph(?B)
      ...> |> Vivid.CFF.Glyph.to_region()
      ...> |> Vivid.Region.contours()
      ...> |> Enum.count()
      3
  """
  @spec to_region(Glyph.t()) :: Region.t()
  def to_region(%Glyph{} = glyph) do
    glyph
    |> contours()
    |> Enum.map(&Polygon.init(&1))
    |> Region.init()
  end
end
