defmodule Vivid.Arc do
  alias Vivid.{Arc, Point, Path}
  import Vivid.Math
  defstruct ~w(center radius start_angle range steps)a

  @moduledoc ~S"""
  This module represents an Arc, otherwise known as a circle segment.

  ## Example

      iex> use Vivid
      ...> Arc.init(Point.init(10,10), 10, 0, 45)
      ...> |> to_string()
      "@@@@@@\n" <>
      "@@@  @\n" <>
      "@@@ @@\n" <>
      "@@ @@@\n" <>
      "@@ @@@\n" <>
      "@  @@@\n" <>
      "@ @@@@\n" <>
      "@ @@@@\n" <>
      "@ @@@@\n" <>
      "@@@@@@\n"

  """

  @opaque t :: %Arc{center: Point.t, radius: number, start_angle: number, steps: integer}

  @doc ~S"""
  Creates an Arc.

  * `center` is a Point definining the center point of the arc's parent circle.
  * `radius` is the radius of the parent circle.
  * `start_angle` is the angle at which to start drawing the arc, `0` is the parallel to the X axis, to the left.
  * `range` is the number of degrees to draw the arc.
  * `steps` the arc is drawn by dividing it into a number of lines. Defaults to 12.

  ## Examples

      iex> Vivid.Arc.init(Vivid.Point.init(5,5), 4, 45, 15)
      %Vivid.Arc{
        center:      %Vivid.Point{x: 5, y: 5},
        radius:      4,
        start_angle: 45,
        range:       15,
        steps:       12
      }
  """
  @spec init(Point.t, number, number, number, integer) :: Arc.t
  def init(%Point{} = center, radius, start_angle, range, steps \\ 12)
    when is_number(radius)
     and is_number(start_angle)
     and is_number(range)
     and is_integer(steps)
  do
    %Arc{
      center:      center,
      radius:      radius,
      start_angle: start_angle,
      range:       range,
      steps:       steps
    }
  end

  @doc """
  Returns the center point of an `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.center
      #Vivid.Point<{10, 10}>
  """
  @spec center(Arc.t) :: Point.t
  def center(%Arc{center: p} = _arc), do: p

  @doc """
  Changes the center `point` of `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.center(Vivid.Point.init(15,15))
      ...> |> Vivid.Arc.center
      #Vivid.Point<{15, 15}>
  """
  @spec center(Arc.t, Point.t) :: Arc.t
  def center(%Arc{} = arc, %Point{} = point), do: %{arc | center: point}

  @doc """
  Returns the radius of an `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.radius
      5
  """
  @spec radius(Arc.t) :: number
  def radius(%Arc{radius: r} = _arc), do: r

  @doc """
  Change the `radius` of `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.radius(10)
      ...> |> Vivid.Arc.radius
      10
  """
  @spec radius(Arc.t, number) :: Arc.t
  def radius(%Arc{} = arc, radius) when is_number(radius), do: %{arc | radius: radius}

  @doc """
  Returns the start angle of an `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.start_angle
      0
  """
  @spec start_angle(Arc.t) :: number
  def start_angle(%Arc{start_angle: a} = _arc), do: a

  @doc """
  Change the start angle of an `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.start_angle(45)
      ...> |> Vivid.Arc.start_angle
      45
  """
  @spec start_angle(Arc.t, number) :: Arc.t
  def start_angle(%Arc{} = arc, theta), do: %{arc | start_angle: theta}

  @doc """
  Returns the range of the `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.range
      90
  """
  @spec range(Arc.t) :: number
  def range(%Arc{range: r} = _arc), do: r

  @doc """
  Change the range of an `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.range(270)
      ...> |> Vivid.Arc.range
      270
  """
  @spec range(Arc.t, number) :: Arc.t
  def range(%Arc{} = arc, theta) when is_number(theta), do: %{arc | range: theta}

  @doc """
  Returns the number of steps in the `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.steps
      12
  """
  @spec steps(Arc.t) :: integer
  def steps(%Arc{steps: s} = _arc), do: s

  @doc """
  Changes the number of `steps` in `arc`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 12)
      ...> |> Vivid.Arc.steps(19)
      ...> |> Vivid.Arc.steps
      19
  """
  @spec steps(Arc.t, integer) :: Arc.t
  def steps(%Arc{} = arc, steps) when is_integer(steps), do: %{arc | steps: steps}

  @doc """
  Converts the `arc` into a Path, which is used for a bunch of things like
  Transforms, Bounds calculation, Rasterization, etc.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(10,10), 5, 0, 90, 3)
      ...> |> Vivid.Arc.to_path
      #Vivid.Path<[#Vivid.Point<{5, 10}>, #Vivid.Point<{6, 13}>, #Vivid.Point<{8, 14}>, #Vivid.Point<{10, 15}>]>
  """
  @spec to_path(Arc.t) :: Path.t
  def to_path(%Arc{center: center, radius: radius, start_angle: start_angle, range: range, steps: steps} = _arc) do
    h = center |> Point.x
    k = center |> Point.y

    step_degree = range / steps
    start_angle = start_angle - 180

    points = Enum.map(0..steps, fn(step) ->
      theta = (step_degree * step) + start_angle
      theta = degrees_to_radians(theta)

      x = round(h + radius * cos(theta))
      y = round(k - radius * sin(theta))

      Point.init(x, y)
    end)

    points
    |> Path.init
  end
end
