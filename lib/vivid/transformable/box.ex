defimpl Vivid.Transformable, for: Vivid.Box do
  alias Vivid.{Box, Transformable}

  @doc """
  Apply an arbitrary transformation function to a box.

  * `box` - the box to modify.
  * `fun` - the transformation function to apply.
  """
  @impl true
  def transform(box, fun) do
    box
    |> Box.to_polygon()
    |> Transformable.transform(fun)
  end
end
