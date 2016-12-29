defimpl Vivid.Bounds, for: Vivid.Arc do
  def bounds(arc) do
    arc
    |> Vivid.Arc.to_path
    |> Vivid.Bounds.bounds
  end
end
