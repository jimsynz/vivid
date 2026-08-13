defimpl Vivid.Font.Glyph, for: Vivid.TrueType.Glyph do
  alias Vivid.{Point, Transformable, TrueType.Glyph}

  @moduledoc """
  Lays out a TrueType glyph.

  TrueType has no notion of left and right padding: a glyph has an advance width,
  and its outline already sits at the correct distance from the pen. So the pen
  moves nothing before the glyph is drawn and its whole advance afterwards, which
  puts each glyph's outline exactly one advance further along than the last.
  """

  @doc """
  Returns zero: a TrueType outline carries its own left side bearing.
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
