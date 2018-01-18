defimpl Inspect, for: Vivid.Line do
  alias Vivid.Line
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Line`.
  """
  @spec inspect(Line.t(), any) :: String.t()
  def inspect(line, opts) do
    details = [
      origin: Line.origin(line),
      termination: Line.termination(line)
    ]

    concat(["#Vivid.Line<", to_doc(details, opts), ">"])
  end
end
