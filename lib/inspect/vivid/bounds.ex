defimpl Inspect, for: Vivid.Bounds do
  alias Vivid.Bounds
  import Inspect.Algebra

  def inspect(%Bounds{min: min, max: max}, opts) do
    concat ["#Vivid.Bounds<", to_doc([min: min, max: max], opts), ">"]
  end
end