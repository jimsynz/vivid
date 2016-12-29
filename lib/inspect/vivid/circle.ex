defimpl Inspect, for: Vivid.Circle do
  alias Vivid.Circle
  import Inspect.Algebra

  def inspect(circle, opts) do
    details = [
      center: Circle.center(circle),
      radius: Circle.radius(circle)
    ]
    concat ["#Vivid.Circle<", to_doc(details, opts), ">"]
  end
end