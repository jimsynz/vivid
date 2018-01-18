defimpl Vivid.Bounds.Of, for: Vivid.Frame do
  alias Vivid.{Frame, Point}

  @doc """
  Find the bounds of a `frame`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @spec bounds(Frame.t()) :: {Point.t(), Point.t()}
  def bounds(%Frame{width: w, height: h} = _frame) do
    {Point.init(0, 0), Point.init(w - 1, h - 1)}
  end
end
