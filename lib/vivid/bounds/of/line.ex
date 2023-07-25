defimpl Vivid.Bounds.Of, for: Vivid.Line do
  alias Vivid.{Bounds, Line}

  @doc """
  Find the bounds of a `line`.

  Returns a two-element tuple of the line-ends, left to right.
  """
  @impl true
  def bounds(%Line{origin: p0, termination: p1} = _line), do: Bounds.Of.bounds([p0, p1])
end
