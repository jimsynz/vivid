defimpl Vivid.Bounds.Of, for: List do
  alias Vivid.Point

  @doc """
  Find the bounds of a List of `points`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @impl true
  def bounds(points) do
    Enum.reduce(points, nil, fn
      point, nil ->
        {point, point}

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
