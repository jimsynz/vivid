defimpl Vivid.Rasterize, for: Vivid.Line do
  alias Vivid.{Coverage, Line, Point}

  @moduledoc """
  Generates points between the origin and termination point of the line
  for rendering using the Digital Differential Analyzer (DDA) algorithm.

  Every step of the line is taken at once: the parameter runs from zero to one
  as a tensor, and both axes are interpolated across it in a single operation
  rather than an increment being accumulated a step at a time.
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
    %Point{x: x0, y: y0} = line |> Line.origin() |> Point.round()
    %Point{x: x1, y: y1} = line |> Line.termination() |> Point.round()

    case max(abs(x1 - x0), abs(y1 - y0)) do
      0 ->
        Coverage.from_points(bounds, [Point.init(x0, y0)])

      steps ->
        Coverage.from_pixels(
          bounds,
          interpolate(x0, (x1 - x0) / steps, steps),
          interpolate(y0, (y1 - y0) / steps, steps)
        )
    end
  end

  # Every step's position is the increment multiplied by how many steps in it
  # is, so they can all be computed at once. Note that this is not quite what
  # accumulating the increment a step at a time arrives at: the accumulated
  # version drifts by an ulp or two along a long line, and can land on the wrong
  # side of a half pixel because of it. Evaluating the parameter has no such
  # drift, so a line here is occasionally a pixel away from where the scalar
  # version put it, on the side the exact arithmetic says it belongs.
  defp interpolate(from, increment, steps) do
    {steps + 1}
    |> Nx.iota(type: {:f, 64})
    |> Nx.multiply(increment)
    |> Nx.add(from)
    |> Nx.round()
    |> Nx.as_type({:s, 64})
  end
end
