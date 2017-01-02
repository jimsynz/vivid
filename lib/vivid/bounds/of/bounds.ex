defimpl Vivid.Bounds.Of, for: Vivid.Bounds do
  alias Vivid.Bounds
  def bounds(%Bounds{min: min, max: max}), do: {min, max}
end
