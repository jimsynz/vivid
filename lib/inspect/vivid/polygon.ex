defimpl Inspect, for: Vivid.Polygon do
  alias Vivid.Polygon
  import Inspect.Algebra

  def inspect(%Polygon{vertices: points, fill: true}, opts) do
    concat ["#Vivid.Polygon<", to_doc([:filled | points], opts), ">"]
  end

  def inspect(%Polygon{vertices: points}, opts) do
    concat ["#Vivid.Polygon<", to_doc(points, opts), ">"]
  end
end