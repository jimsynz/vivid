defimpl Vivid.Transformable, for: Vivid.Path do
  alias Vivid.{Path, Transformable}

  @spec transform(Path.t, (Point.t -> Point.t)) :: Path.t
  def transform(path, fun) do
    path
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Path.init)
  end
end
