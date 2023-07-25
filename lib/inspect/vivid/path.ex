defimpl Inspect, for: Vivid.Path do
  alias Vivid.Path
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Path`.
  """
  @impl true
  def inspect(%Path{vertices: points}, opts) do
    concat(["Vivid.Path.new(", to_doc(points, opts), ")"])
  end
end
