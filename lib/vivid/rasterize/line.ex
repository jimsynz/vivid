defimpl Vivid.Rasterize, for: Vivid.Line do
  alias Vivid.{Point, Line}

  @moduledoc """
  Generates points between the origin and termination point of the line
  for rendering using the Digital Differential Analyzer (DDA) algorithm.
  """

  @doc ~S"""
  Generate points along a line and return them as an enumerable.

  ## Examples

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(3,3)) |> Vivid.Rasterize.rasterize
      MapSet.new([
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 2, y: 2},
        %Vivid.Point{x: 3, y: 3}
      ])

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,2)) |> Vivid.Rasterize.rasterize
      MapSet.new([
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 2, y: 1},
        %Vivid.Point{x: 3, y: 2},
        %Vivid.Point{x: 4, y: 2}
      ])

      iex> Vivid.Line.init(Vivid.Point.init(4,4), Vivid.Point.init(4,1)) |> Vivid.Rasterize.rasterize
      MapSet.new([
        %Vivid.Point{x: 4, y: 4},
        %Vivid.Point{x: 4, y: 3},
        %Vivid.Point{x: 4, y: 2},
        %Vivid.Point{x: 4, y: 1}
      ])

  """
  def rasterize(%Line{}=line) do
    origin = line |> Line.origin
    dx = line |> Line.x_distance
    dy = line |> Line.y_distance

    steps = choose_largest_of(abs(dx), abs(dy))

    if steps == 0 do
      MapSet.new([origin])
    else
      x_increment = dx / steps
      y_increment = dy / steps


      points = MapSet.new([origin])
      current_x = origin |> Point.x
      current_y = origin |> Point.y

      reduce_points(points, steps, current_x, current_y, x_increment, y_increment)
    end
  end

  defp reduce_points(points, 0, _, _, _, _), do: points

  defp reduce_points(points, steps, current_x, current_y, x_increment, y_increment) do
    next_x = current_x + x_increment
    next_y = current_y + y_increment
    steps  = steps - 1
    points = MapSet.put(points, Point.init(round(next_x), round(next_y)))
    reduce_points(points, steps, next_x, next_y, x_increment, y_increment)
  end

  defp choose_largest_of(a, b) when a > b, do: a
  defp choose_largest_of(_, b), do: b

end