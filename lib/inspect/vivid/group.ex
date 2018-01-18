defimpl Inspect, for: Vivid.Group do
  alias Vivid.Group
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Group`.
  """
  @spec inspect(Group.t(), any) :: String.t()
  def inspect(%Group{shapes: shapes}, opts) do
    shapes = shapes |> Enum.to_list()
    concat(["#Vivid.Group<", to_doc(shapes, opts), ">"])
  end
end
