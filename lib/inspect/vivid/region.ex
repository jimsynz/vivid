defimpl Inspect, for: Vivid.Region do
  alias Vivid.Region
  import Inspect.Algebra

  @doc false
  @impl true
  def inspect(region, opts),
    do: concat(["Vivid.Region.new(", to_doc(Region.contours(region), opts), ")"])
end
