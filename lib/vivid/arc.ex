defmodule Vivid.Arc do
  alias Vivid.{Arc, Point}
  defstruct ~w(center radius start_angle range steps)a

  @moduledoc """
  This module represents an Arc, otherwise known as a circle segment.
  """

  @doc ~S"""
  Creates an Arc.

  `center` is a Point definining the center point of the arc's parent circle.
  `radius` is the radius of the parent circle.
  `start_angle` is the angle at which to start drawing the arc, `0` is vertical.
  `range` is the number of degrees to draw the arc.
  `steps` the arc is drawn by dividing it into a number of lines. Defaults to 12.

      iex> Vivid.Arc.init(Vivid.Point.init(5,5), 4, 45, 15)
      %Vivid.Arc{
        center:      %Vivid.Point{x: 5, y: 5},
        radius:      4,
        start_angle: 45,
        range:       15,
        steps:       12
      }
  """
  def init(%Point{}=center, radius, start_angle, range, steps \\ 12)
    when is_number(radius)
     and is_number(start_angle)
     and is_number(range)
     and is_number(steps)
  do
    %Vivid.Arc{
      center:      center,
      radius:      radius,
      start_angle: start_angle,
      range:       range,
      steps:       steps
    }
  end
end