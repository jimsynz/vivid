defimpl Vivid.Transformable, for: Vivid.Point do
  @doc """
  Apply an arbitrary transformation function to a point.

  * `point` - the point to modify.
  * `fun` - the transformation function to apply.
  """
  @impl true
  def transform(point, fun), do: fun.(point)
end
