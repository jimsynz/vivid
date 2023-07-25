defimpl Inspect, for: Vivid.Group do
  alias Vivid.Group
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Group`.
  """
  @impl true
  def inspect(%Group{shapes: shapes}, opts) do
    shapes = shapes |> Enum.to_list()
    concat(["Vivid.Group.new(", to_doc(shapes, opts), ")"])
  end
end
