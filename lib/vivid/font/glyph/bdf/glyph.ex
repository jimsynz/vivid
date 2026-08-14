defimpl Vivid.Font.Glyph, for: Vivid.BDF.Glyph do
  alias Vivid.{BDF.Glyph, Bitmap}

  @moduledoc """
  Lays out a bitmap glyph.

  Like an outline glyph, a bitmap one has an advance width and sits at the right
  distance from the pen already, so nothing moves before it is drawn and its
  whole advance moves afterwards.

  A glyph becomes a `Vivid.Bitmap`, whose cells cover an area rather than marking
  a position. Asking `Vivid.Font.line/3` for the size a bitmap font was drawn at
  gives one pixel per pixel; asking for twice that gives blocks of four, rather
  than the same pixels twice as far apart.
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
  Converts `glyph` into a `Vivid.Bitmap` whose cells are `scale` across, measured
  from `center`.
  """
  @impl true
  def to_shape(glyph, center, scale), do: Bitmap.init(Glyph.pixels(glyph), center, scale)
end
