defimpl Inspect, for: Vivid.Bounds do
  alias Vivid.Bounds
  import Inspect.Algebra

  @spec inspect(Bounds.t, any) :: String.t
  def inspect(%Bounds{min: min, max: max}, opts) do
    concat ["#Vivid.Bounds<", to_doc([min: min, max: max], opts), ">"]
  end
end
