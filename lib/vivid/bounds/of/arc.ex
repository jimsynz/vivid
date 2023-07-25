defimpl Vivid.Bounds.Of, for: Vivid.Arc do
  alias Vivid.{Arc, Bounds}

  @doc """
  Find the bounds of a `arc`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @impl true
  def bounds(arc) do
    arc
    |> Arc.to_path()
    |> Bounds.Of.bounds()
  end
end
