defimpl Vivid.Font.Glyph, for: Vivid.CFF.Glyph do
  alias Vivid.{CFF.Glyph, Point, Transformable}

  @moduledoc """
  Lays out a CFF glyph.

  Identical to laying out a TrueType one: a PostScript outline also sits at the
  right distance from the pen already, so the pen moves nothing before the glyph
  and its whole advance afterwards.
  """

  @doc """
  Returns zero: a CFF outline carries its own left side bearing.
  """
  @impl true
  def left_pad(_glyph, _scale), do: 0

  @doc """
  Returns the advance width of `glyph`, scaled by `scale`.
  """
  @impl true
  def right_pad(glyph, scale), do: Glyph.advance(glyph) * scale

  @doc """
  Converts `glyph` into a `Vivid.Region`, scaled by `scale` and positioned
  relative to `center`.
  """
  @impl true
  def to_shape(glyph, center, scale) do
    x = Point.x(center)
    y = Point.y(center)

    glyph
    |> Glyph.to_region()
    |> Transformable.transform(fn point ->
      Point.init(x + Point.x(point) * scale, y + Point.y(point) * scale)
    end)
  end
end
