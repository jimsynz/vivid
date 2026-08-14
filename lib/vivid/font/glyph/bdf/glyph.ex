defimpl Vivid.Font.Glyph, for: Vivid.BDF.Glyph do
  alias Vivid.{BDF.Glyph, Group, Point}

  @moduledoc """
  Lays out a bitmap glyph.

  Like an outline glyph, a bitmap one has an advance width and sits at the right
  distance from the pen already, so nothing moves before it is drawn and its
  whole advance moves afterwards.

  A lit pixel becomes a `Vivid.Point`, which is exact at the font's design size -
  pass `Vivid.Font.line/3` the size the font was drawn at and every pixel lands
  on one of its own. It is **only** correct at that size: a point has no area, so
  asking for twice the size moves the points twice as far apart rather than
  making them twice as big, and the glyph comes out as a dotted grid. Sampling a
  frame more than once per pixel has the same problem from the other direction,
  and draws bitmap text faintly.

  Drawing a bitmap at a size other than the one it was drawn for needs a shape
  which covers an area rather than a position, which this library doesn't have
  yet.
  """

  @doc """
  Returns zero: a bitmap glyph's pixels are already placed relative to the pen.
  """
  @impl true
  def left_pad(_glyph, _scale), do: 0

  @doc """
  Returns the advance width of `glyph`, scaled by `scale`.
  """
  @impl true
  def right_pad(glyph, scale), do: Glyph.advance(glyph) * scale

  @doc """
  Converts `glyph` into a `Vivid.Group` of points, one per lit pixel, scaled by
  `scale` and positioned relative to `center`.
  """
  @impl true
  def to_shape(glyph, center, scale) do
    x = Point.x(center)
    y = Point.y(center)

    glyph
    |> Glyph.pixels()
    |> Enum.map(fn {column, row} -> Point.init(x + column * scale, y + row * scale) end)
    |> Group.init()
  end
end
