defimpl Vivid.Transformable, for: Vivid.Group do
  alias Vivid.{Group, Transformable}

  @doc """
  Apply an arbitrary transformation function to a group.

  * `group` - the group to modify.
  * `fun` - the transformation function to apply.
  """
  @impl true
  def transform(group, fun) do
    group
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Group.init())
  end
end
