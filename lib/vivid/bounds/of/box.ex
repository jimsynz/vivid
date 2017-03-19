defimpl Vivid.Bounds.Of, for: Vivid.Box do
  alias Vivid.{Box, Point}

  @spec bounds(Box.t) :: {Point.t, Point.t}
  def bounds(%Box{bottom_left: bl, top_right: tr}), do: {bl, tr}
end
