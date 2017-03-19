defimpl Vivid.Bounds.Of, for: Vivid.Line do
  alias Vivid.{Line, Point}

  @spec bounds(Line.t) :: {Point.t, Point.t}
  def bounds(%Line{origin: p0, termination: p1}), do: Vivid.Bounds.Of.bounds([p0, p1])
end
