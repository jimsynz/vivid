defprotocol Vivid.Bounds.Of do
  alias Vivid.{Shape, Point}
  @moduledoc """
  This protocol is used to calculate the bounds of a given shape.

  Implement this protocol if you are defining any new shape types.
  """

  @doc """
  Return the bounds of a Shape as a two element tuple of bottom-left and
  top-right points.
  """
  @spec bounds(Shape.t) :: {Point.t, Point.t}
  def bounds(shape)
end
