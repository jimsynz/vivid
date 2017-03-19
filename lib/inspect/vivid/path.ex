defimpl Inspect, for: Vivid.Path do
  alias Vivid.Path
  import Inspect.Algebra

  @spec inspect(Path.t, any) :: String.t
  def inspect(%Path{vertices: points}, opts) do
    concat ["#Vivid.Path<", to_doc(points, opts), ">"]
  end
end
