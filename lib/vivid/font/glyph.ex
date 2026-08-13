defprotocol Vivid.Font.Glyph do
  @moduledoc """
  Everything laying out a line of text needs to know about a single glyph.

  Stroke fonts and outline fonts describe a glyph completely differently - a
  Hershey glyph is a series of pen movements, whereas a TrueType glyph is a set
  of closed contours to be filled - but both can say how far the pen moves and
  turn themselves into a shape, which is all `Vivid.Font.line/3` requires.

  `scale` is a plain multiplier applied to the glyph's own coordinates.
  `Vivid.Font.line/3` derives it from the requested size and the font's units per
  em, so that an implementation never needs to know either.
  """

  @doc """
  How far the pen advances before drawing `glyph`, scaled by `scale`.
  """
  @spec left_pad(t, number) :: number
  def left_pad(glyph, scale)

  @doc """
  How far the pen advances after drawing `glyph`, scaled by `scale`.
  """
  @spec right_pad(t, number) :: number
  def right_pad(glyph, scale)

  @doc """
  Convert `glyph` into a shape which can be rendered, positioned around `center`
  and scaled by `scale`.
  """
  @spec to_shape(t, Vivid.Point.t(), number) :: Vivid.Shape.t()
  def to_shape(glyph, center, scale)
end
