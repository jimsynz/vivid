defimpl Inspect, for: Vivid.Buffer do
  alias Vivid.Buffer
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Buffer`.
  """
  @spec inspect(Buffer.t, any) :: String.t
  def inspect(%Buffer{rows: r, columns: c}, opts) do
    concat ["#Vivid.Buffer<", to_doc([rows: r, columns: c, size: r * c], opts), ">"]
  end
end
