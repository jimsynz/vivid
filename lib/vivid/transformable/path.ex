defimpl Vivid.Transformable, for: Vivid.Path do
  alias Vivid.{Path, Transformable}

  @doc """
  Apply an arbitrary transformation function to a path.

  * `path` - the path to modify.
  * `fun` - the transformation function to apply.
  """
  @spec transform(Path.t, (Point.t -> Point.t)) :: Path.t
  def transform(path, fun) do
    path
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Path.init)
  end
end
