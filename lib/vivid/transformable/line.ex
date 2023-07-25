defimpl Vivid.Transformable, for: Vivid.Line do
  alias Vivid.{Line, Transformable}

  @doc """
  Apply an arbitrary transformation function to a line.

  * `line` - the line to modify.
  * `fun` - the transformation function to apply.
  """
  @impl true
  def transform(line, fun) do
    origin = line |> Line.origin() |> Transformable.transform(fun)
    term = line |> Line.termination() |> Transformable.transform(fun)
    Line.init(origin, term)
  end
end
