defimpl Inspect, for: Vivid.Point do
  alias Vivid.Point
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Point`.
  """
  @spec inspect(Point.t(), any) :: String.t()
  def inspect(point, opts) do
    x = point |> Point.x()
    y = point |> Point.y()
    concat(["#Vivid.Point<", to_doc({x, y}, opts), ">"])
  end
end
