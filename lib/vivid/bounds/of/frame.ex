defimpl Vivid.Bounds.Of, for: Vivid.Frame do
  alias Vivid.{Frame, Point}

  @spec bounds(Frame.t) :: {Point.t, Point.t}
  def bounds(%Frame{width: w, height: h}) do
    {Point.init(0, 0), Point.init(w - 1, h - 1)}
  end
end
