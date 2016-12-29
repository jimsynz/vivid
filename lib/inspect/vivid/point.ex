defimpl Inspect, for: Vivid.Point do
  alias Vivid.Point
  import Inspect.Algebra

  def inspect(point, opts) do
    x = point |> Point.x
    y = point |> Point.y
    concat ["#Vivid.Point<", to_doc({x,y}, opts), ">"]
  end
end