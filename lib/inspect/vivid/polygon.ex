defimpl Inspect, for: Vivid.Polygon do
  alias Vivid.Polygon
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Polygon`.
  """
  @impl true
  def inspect(%Polygon{vertices: points, fill: true}, opts) do
    concat(["Vivid.Polygon.new(", to_doc([:filled | points], opts), ")"])
  end

  def inspect(%Polygon{vertices: points}, opts) do
    concat(["Vivid.Polygon.new(", to_doc(points, opts), ")"])
  end
end
