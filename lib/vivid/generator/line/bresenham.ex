defmodule Vivid.Generator.Line.Bresenham do
  alias Vivid.{Line, Point}

  @moduledoc """
  Generates points between the origin and termination point of the line
  for rendering using The Bresenham algorithm.
  """

  def generate(%Line{}=line) do
    origin   = line |> Line.origin
    origin_x = origin |> Point.x
    dx       = line |> Line.x_distance
    dy       = line |> Line.y_distance
    two_dy   = dy * 2
    two_dx   = dx * 2
    two_dy_minus_two_dx = two_dy - two_dx

    Enum.map(origin_x..(origin_x + dx), fn (xk)->
      case two_dy - dx
        (p) when p < 0 -> 
      end
    end)
  end
end