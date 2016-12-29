defimpl Vivid.Bounds, for: Vivid.Circle do
  def bounds(circle) do
    circle
    |> Vivid.Circle.to_polygon
    |> Vivid.Bounds.bounds
  end
end
