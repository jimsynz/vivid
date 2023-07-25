defimpl Vivid.Bounds.Of, for: Vivid.Path do
  alias Vivid.{Bounds, Path}

  @doc """
  Find the bounds of a `path`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @impl true
  def bounds(%Path{vertices: points} = _path), do: Bounds.Of.bounds(points)
end
