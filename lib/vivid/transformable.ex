defprotocol Vivid.Transformable do
  alias Vivid.Shape
  @moduledoc """
  This protocol is used to apply *point* transformations to a shape.
  """

  @doc """
  Transform all of a shape's points using `fun`.
  """
  @spec transform(Shape.t, function) :: Shape.t
  def transform(shape, fun)
end