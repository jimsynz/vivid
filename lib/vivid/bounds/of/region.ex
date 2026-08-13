defimpl Vivid.Bounds.Of, for: Vivid.Region do
  alias Vivid.{Bounds, Polygon, Region}

  @doc """
  Find the bounds of a `region`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @impl true
  def bounds(%Region{contours: contours} = _region) do
    contours
    |> Enum.flat_map(fn %Polygon{vertices: vertices} -> vertices end)
    |> Bounds.Of.bounds()
  end
end
