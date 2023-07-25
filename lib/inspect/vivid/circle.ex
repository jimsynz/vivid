defimpl Inspect, for: Vivid.Circle do
  alias Vivid.Circle
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Circle`.
  """
  @impl true
  def inspect(%Circle{center: c, radius: r, fill: true}, opts) do
    details = [center: c, radius: r, fill: true]
    concat(["Vivid.Circle.new(", to_doc(details, opts), ")"])
  end

  def inspect(%Circle{center: c, radius: r}, opts) do
    details = [center: c, radius: r]
    concat(["Vivid.Circle.new(", to_doc(details, opts), ")"])
  end
end
