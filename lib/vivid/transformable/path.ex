defimpl Vivid.Transformable, for: Vivid.Path do
  alias Vivid.{Path, Transformable}

  def transform(path, fun) do
    path
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Path.init)
  end
end