defimpl Inspect, for: Vivid.Bezier do
  alias Vivid.Bezier
  import Inspect.Algebra

  @doc false
  @impl true
  def inspect(bezier, opts) do
    details = [
      control_points: Bezier.control_points(bezier),
      steps: Bezier.steps(bezier)
    ]

    concat(["Vivid.Bezier.new(", to_doc(details, opts), ")"])
  end
end
