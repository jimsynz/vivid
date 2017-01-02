defimpl Vivid.Bounds.Of, for: Vivid.Circle do
  def bounds(circle) do
    circle
    |> Vivid.Circle.to_polygon
    |> Vivid.Bounds.Of.bounds
  end
end
