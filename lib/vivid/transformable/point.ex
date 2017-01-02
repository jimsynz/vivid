defimpl Vivid.Transformable, for: Vivid.Point do
  def transform(point, fun), do: fun.(point)
end