defimpl Vivid.Rasterize, for: Vivid.Arc do
  import :math, only: [cos: 1, sin: 1, pi: 0]
  alias Vivid.{Rasterize, Arc, Path, Point}

  @moduledoc """
  Rasterizes an Arc.
  """

  @doc ~S"""
  Convert an Arc into a rasterized points.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(5,5), 5, 270, 90, 3)
      ...> |> Vivid.Rasterize.rasterize
      MapSet.new([
        %Vivid.Point{x: 0, y: 5}, %Vivid.Point{x: 1, y: 3},
        %Vivid.Point{x: 1, y: 4}, %Vivid.Point{x: 2, y: 2},
        %Vivid.Point{x: 3, y: 1}, %Vivid.Point{x: 4, y: 1},
        %Vivid.Point{x: 5, y: 0}
      ])
  """
  def rasterize(%Arc{center: center, radius: radius, start_angle: start_angle, range: range, steps: steps}) do
    h = center |> Point.x
    k = center |> Point.y

    step_degree = range / steps
    start_angle = start_angle - 180

    Enum.map(0..steps, fn(step) ->
      theta = (step_degree * step) + start_angle
      theta = degrees_to_radians(theta)

      x = round(h + radius * cos(theta))
      y = round(k - radius * sin(theta))

      Point.init(x, y)
    end)
    |> Path.init
    |> Rasterize.rasterize
  end

  defp degrees_to_radians(degrees), do: degrees / 360.0 * 2.0 * pi
end