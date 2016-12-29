defimpl Inspect, for: Vivid.Path do
  alias Vivid.Path
  import Inspect.Algebra

  def inspect(%Path{vertices: points}, opts) do
    concat ["#Vivid.Path<", to_doc(points, opts), ">"]
  end
end