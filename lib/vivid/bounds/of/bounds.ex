defimpl Vivid.Bounds.Of, for: Vivid.Bounds do
  alias Vivid.Bounds

  @doc """
  Find the bounds of a `bounds`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @impl true
  def bounds(%Bounds{min: min, max: max} = _bounds), do: {min, max}
end
