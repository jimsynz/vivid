defimpl Vivid.Bounds.Of, for: Vivid.Bezier do
  alias Vivid.{Bezier, Bounds}

  @doc """
  Find the bounds of a `bezier` curve.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @impl true
  def bounds(bezier) do
    bezier
    |> Bezier.to_path()
    |> Bounds.Of.bounds()
  end
end
