defimpl Vivid.Bounds.Of, for: Vivid.Arc do
  alias Vivid.{Arc, Bounds, Point}

  @doc """
  Find the bounds of a `arc`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @spec bounds(Arc.t()) :: {Point.t(), Point.t()}
  def bounds(arc) do
    arc
    |> Arc.to_path()
    |> Bounds.Of.bounds()
  end
end
