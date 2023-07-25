defimpl Vivid.Bounds.Of, for: Vivid.Point do
  @doc """
  Find the bounds of a `point`.

  Since the bounds of a point are simply the point, it returns the point
  twice.
  """
  @impl true
  def bounds(point), do: {point, point}
end
