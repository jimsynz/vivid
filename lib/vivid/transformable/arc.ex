defimpl Vivid.Transformable, for: Vivid.Arc do
  alias Vivid.{Arc, Transformable, Path, Point}

  @doc """
  Apply an arbitrary transformation function to a arc.

  * `arc` - the arc to modify.
  * `fun` - the transformation function to apply.

  Many of the transformations can't be applied to an Arc, but we
  can convert it to a path and then use that to apply transformations.
  """
  @spec transform(Arc.t, (Point.t -> Point.t)) :: Path.t
  def transform(arc, fun) do
    arc
    |> Arc.to_path
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Path.init)
  end
end
