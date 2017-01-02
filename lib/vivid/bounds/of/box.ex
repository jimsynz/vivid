defimpl Vivid.Bounds.Of, for: Vivid.Box do
  alias Vivid.Box
  def bounds(%Box{bottom_left: bl, top_right: tr}), do: {bl, tr}
end
