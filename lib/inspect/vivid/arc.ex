defimpl Inspect, for: Vivid.Arc do
  alias Vivid.Arc
  import Inspect.Algebra

  @doc false
  @spec inspect(Art.t, any) :: String.t
  def inspect(arc, opts) do
    center      = arc |> Arc.center
    radius      = arc |> Arc.radius
    start_angle = arc |> Arc.start_angle
    range       = arc |> Arc.range
    steps       = arc |> Arc.steps
    details = [
      center:      center,
      radius:      radius,
      start_angle: start_angle,
      range:       range,
      steps:       steps
    ]
    concat ["#Vivid.Arc<", to_doc(details, opts), ">"]
  end
end
