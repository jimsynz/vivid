defimpl Inspect, for: Vivid.Transform do
  alias Vivid.Transform
  alias Vivid.Transform.Operation
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Transform`.
  """
  @spec inspect(Transform.t(), any) :: String.t()
  def inspect(%Transform{operations: operations, shape: shape}, opts) do
    operations =
      operations
      |> Stream.map(fn %Operation{name: name} -> name end)
      |> Enum.reverse()

    concat(["#Vivid.Transform<", to_doc([operations: operations, shape: shape], opts), ">"])
  end
end
