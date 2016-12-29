defimpl Inspect, for: Vivid.Line do
  alias Vivid.Line
  import Inspect.Algebra

  def inspect(line, opts) do
    details = [
      origin:      Line.origin(line),
      termination: Line.termination(line)
    ]
    concat ["#Vivid.Line<", to_doc(details, opts), ">"]
  end
end