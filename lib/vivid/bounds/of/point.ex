defimpl Vivid.Bounds.Of, for: Vivid.Point do
  def bounds(point), do: {point, point}
end
