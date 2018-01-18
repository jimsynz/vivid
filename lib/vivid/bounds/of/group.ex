defimpl Vivid.Bounds.Of, for: Vivid.Group do
  alias Vivid.Point

  @doc """
  Find the bounds of a `group`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @spec bounds(Group.t()) :: {Point.t(), Point.t()}
  def bounds(%Vivid.Group{shapes: shapes} = _group) do
    shapes
    |> Enum.map(&Vivid.Bounds.Of.bounds(&1))
    |> Enum.reduce(fn
      {min, max}, nil ->
        {min, max}

      {pmin, pmax}, {min, max} ->
        min = if pmin.x < min.x, do: Point.init(pmin.x, min.y), else: min
        min = if pmin.y < min.y, do: Point.init(min.x, pmin.y), else: min
        max = if pmax.x > max.x, do: Point.init(pmax.x, max.y), else: max
        max = if pmax.y > max.y, do: Point.init(max.x, pmax.y), else: max
        {min, max}
    end)
  end
end
