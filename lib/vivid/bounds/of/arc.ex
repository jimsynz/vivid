defimpl Vivid.Bounds.Of, for: Vivid.Arc do
  alias Vivid.{Arc, Bounds, Point}

  @spec bounds(Arc.t) :: {Point.t, Point.t}
  def bounds(arc) do
    arc
    |> Arc.to_path
    |> Bounds.Of.bounds
  end
end
