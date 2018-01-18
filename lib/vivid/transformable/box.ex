defimpl Vivid.Transformable, for: Vivid.Box do
  alias Vivid.{Box, Transformable, Point}

  @doc """
  Apply an arbitrary transformation function to a box.

  * `box` - the box to modify.
  * `fun` - the transformation function to apply.
  """
  @spec transform(Box.t(), (Point.t() -> Point.t())) :: Box.t()
  def transform(box, fun) do
    box
    |> Box.to_polygon()
    |> Transformable.transform(fun)
  end
end
