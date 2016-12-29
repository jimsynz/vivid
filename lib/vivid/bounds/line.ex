defimpl Vivid.Bounds, for: Vivid.Line do
  alias Vivid.Point
  def bounds(%Vivid.Line{origin: point0, termination: point1}) do
    Enum.reduce([point0, point1], nil, fn
      point, nil        -> {point, point}
      point, {min, max} ->
        x = Point.x(point)
        y = Point.y(point)
        min = if x < Point.x(min), do: Point.init(x, min.y), else: min
        min = if y < Point.y(min), do: Point.init(min.x, y), else: min
        max = if x > Point.x(max), do: Point.init(x, max.y), else: max
        max = if y > Point.y(max), do: Point.init(max.x, y), else: max
        {min, max}
    end)
  end
end
