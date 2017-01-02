defimpl Vivid.Transformable, for: Vivid.Group do
  alias Vivid.{Group, Transformable}

  def transform(group, fun) do
    group
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Group.init)
  end
end