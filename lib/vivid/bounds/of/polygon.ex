defimpl Vivid.Bounds.Of, for: Vivid.Polygon do
  alias Vivid.{Bounds, Polygon}

  @doc """
  Find the bounds of a `polygon`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @impl true
  def bounds(%Polygon{vertices: points} = _polygon), do: Bounds.Of.bounds(points)
end
