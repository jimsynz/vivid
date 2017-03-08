defimpl Vivid.Bounds.Of, for: Vivid.Bounds do
  alias Vivid.{Bounds, Point}

  @spec bounds(Bounds.t) :: {Point.t, Point.t}
  def bounds(%Bounds{min: min, max: max}), do: {min, max}
end
