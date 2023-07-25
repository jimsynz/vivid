defimpl Inspect, for: Vivid.Buffer do
  alias Vivid.Buffer
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Buffer`.
  """
  @impl true
  def inspect(%Buffer{rows: r, columns: c}, opts) do
    concat(["Vivid.Buffer.new(", to_doc([rows: r, columns: c, size: r * c], opts), ")"])
  end
end
