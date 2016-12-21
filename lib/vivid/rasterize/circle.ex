defimpl Vivid.Rasterize, for: Vivid.Circle do
  alias Vivid.{Circle, Point}
  import :math, only: [pow: 2, sqrt: 1]

  @moduledoc """
  Rasterizes a circle into points.


  x^2 + y^2 = r^2

  y = sqrt(pow(r,2) - pow(x)2)
  """

  @doc ~S"""
  Rasterizes a circle

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      ...> |> Vivid.Rasterize.rasterize
      MapSet.new([
        %Vivid.Point{x: 1, y: 5}, %Vivid.Point{x: 2, y: 2},
        %Vivid.Point{x: 2, y: 8}, %Vivid.Point{x: 3, y: 2},
        %Vivid.Point{x: 3, y: 8}, %Vivid.Point{x: 4, y: 1},
        %Vivid.Point{x: 4, y: 9}, %Vivid.Point{x: 5, y: 1},
        %Vivid.Point{x: 5, y: 9}, %Vivid.Point{x: 6, y: 1},
        %Vivid.Point{x: 6, y: 9}, %Vivid.Point{x: 7, y: 2},
        %Vivid.Point{x: 7, y: 8}, %Vivid.Point{x: 8, y: 2},
        %Vivid.Point{x: 8, y: 8}, %Vivid.Point{x: 9, y: 5}
      ])
  """

  def rasterize(%Circle{center: point, radius: radius}) do
    x_center  = point |> Point.x
    y_center  = point |> Point.y
    r_squared = pow(radius, 2)

    Enum.reduce(0-radius..radius, MapSet.new, fn (x, points) ->
      y = sqrt(r_squared - pow(x, 2)) |> round

      x = x_center + x
      y0 = y_center + y
      y1 = y_center - y

      points
      |> MapSet.put(Point.init(x, y0))
      |> MapSet.put(Point.init(x, y1))
    end)
  end
end