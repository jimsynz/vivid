defimpl Vivid.Rasterize, for: Vivid.Line do
  alias Vivid.{Coverage, Line}

  @moduledoc """
  Generates points between the origin and termination point of the line
  for rendering using the Digital Differential Analyzer (DDA) algorithm.

  `Vivid.Line.pixels/1` does the stepping, all of it at once. Rasterizing a
  single line is the degenerate case of that - a shape built out of lines should
  hand them over together rather than one at a time.
  """

  @doc ~S"""
  Rasterize all points of `line` within `bounds`.

  ## Examples

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(3,3))
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 3, 3))
      ...> |> Vivid.Coverage.to_points()
      [Vivid.Point.init(1, 1), Vivid.Point.init(2, 2), Vivid.Point.init(3, 3)]

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,2))
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      ...> |> Vivid.Coverage.to_points()
      [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 2, y: 1},
        %Vivid.Point{x: 3, y: 2},
        %Vivid.Point{x: 4, y: 2}
      ]

      iex> Vivid.Line.init(Vivid.Point.init(4,4), Vivid.Point.init(4,1))
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      ...> |> Vivid.Coverage.to_points()
      [
        %Vivid.Point{x: 4, y: 1},
        %Vivid.Point{x: 4, y: 2},
        %Vivid.Point{x: 4, y: 3},
        %Vivid.Point{x: 4, y: 4}
      ]

  """
  @impl true
  def rasterize(%Line{} = line, bounds) do
    Coverage.from_lines(bounds, [line])
  end
end
