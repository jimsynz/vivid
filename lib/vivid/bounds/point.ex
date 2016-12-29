defimpl Vivid.Bounds, for: Vivid.Point do
  def bounds(point), do: {point, point}
end
