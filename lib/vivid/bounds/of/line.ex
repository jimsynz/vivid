defimpl Vivid.Bounds.Of, for: Vivid.Line do
  alias Vivid.{Line, Point}

  @doc """
  Find the bounds of a `line`.

  Returns a two-element tuple of the line-ends, left to right.
  """
  @spec bounds(Line.t()) :: {Point.t(), Point.t()}
  def bounds(%Line{origin: p0, termination: p1} = _line), do: Vivid.Bounds.Of.bounds([p0, p1])
end
