defimpl Vivid.Bounds.Of, for: Vivid.Arc do
  def bounds(arc) do
    arc
    |> Vivid.Arc.to_path
    |> Vivid.Bounds.Of.bounds
  end
end
