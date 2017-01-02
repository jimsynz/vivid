defimpl Vivid.Transformable, for: Vivid.Box do
  alias Vivid.{Box, Transformable}

  def transform(box, fun) do
    box
    |> Box.to_polygon
    |> Transformable.transform(fun)
  end
end