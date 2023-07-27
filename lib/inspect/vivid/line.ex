defimpl Inspect, for: Vivid.Line do
  alias Vivid.Line
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Line`.
  """
  @impl true
  def inspect(line, opts) do
    details = [
      origin: Line.origin(line),
      termination: Line.termination(line)
    ]

    concat(["Vivid.Line.new(", to_doc(details, opts), ")"])
  end
end
