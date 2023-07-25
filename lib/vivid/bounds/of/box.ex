defimpl Vivid.Bounds.Of, for: Vivid.Box do
  alias Vivid.Box

  @doc """
  Find the bounds of a `box`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @impl true
  def bounds(%Box{bottom_left: bl, top_right: tr} = _box), do: {bl, tr}
end
