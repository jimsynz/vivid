defmodule Vivid.Bezier do
  alias Vivid.{Bezier, Path, Point}
  defstruct ~w(control_points steps)a

  @moduledoc ~S"""
  This module represents a Bézier curve of arbitrary degree, defined by a list
  of control points.

  Three control points describe a quadratic curve, four a cubic one, and any
  number greater than two is evaluated by de Casteljau's algorithm. The curve
  passes through the first and last control points and is pulled towards the
  ones between.

  ## Example

      iex> use Vivid
      ...> Bezier.init([Point.init(0,0), Point.init(0,10), Point.init(10,0), Point.init(10,10)])
      ...> |> to_string()
      "@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@ @\n" <>
      "@@@@@@@@@@@ @\n" <>
      "@@@@@@@@@@@ @\n" <>
      "@@@@@@@@@@@ @\n" <>
      "@@@@@@@@@  @@\n" <>
      "@@@@     @@@@\n" <>
      "@@  @@@@@@@@@\n" <>
      "@@ @@@@@@@@@@\n" <>
      "@ @@@@@@@@@@@\n" <>
      "@ @@@@@@@@@@@\n" <>
      "@ @@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@\n"
  """

  @type t :: %Bezier{control_points: [Point.t()], steps: integer}

  @doc """
  Creates a Bézier curve.

  * `control_points` is a list of at least two `Point`s.
  * `steps` the curve is drawn by dividing it into a number of lines. Defaults to 12.

  ## Examples

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)])
      %Vivid.Bezier{
        control_points: [
          %Vivid.Point{x: 0, y: 0},
          %Vivid.Point{x: 5, y: 10},
          %Vivid.Point{x: 10, y: 0}
        ],
        steps: 12
      }
  """
  @spec init([Point.t()], integer) :: Bezier.t()
  def init([_, _ | _] = control_points, steps \\ 12) when is_integer(steps) and steps > 0,
    do: %Bezier{control_points: control_points, steps: steps}

  @doc """
  Returns the control points of a `bezier` curve.

  ## Example

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)])
      ...> |> Vivid.Bezier.control_points
      [Vivid.Point.init(0, 0), Vivid.Point.init(5, 10), Vivid.Point.init(10, 0)]
  """
  @spec control_points(Bezier.t()) :: [Point.t()]
  def control_points(%Bezier{control_points: points} = _bezier), do: points

  @doc """
  Changes the `control_points` of `bezier`.

  ## Example

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)])
      ...> |> Vivid.Bezier.control_points([Vivid.Point.init(0, 0), Vivid.Point.init(10, 10)])
      ...> |> Vivid.Bezier.control_points
      [Vivid.Point.init(0, 0), Vivid.Point.init(10, 10)]
  """
  @spec control_points(Bezier.t(), [Point.t()]) :: Bezier.t()
  def control_points(%Bezier{} = bezier, [_, _ | _] = control_points),
    do: %{bezier | control_points: control_points}

  @doc """
  Returns the point on `bezier` at position `t`, where `t` is a number between
  `0` (the first control point) and `1` (the last).

  ## Examples

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)])
      ...> |> Vivid.Bezier.point_at(0.5)
      Vivid.Point.init(5.0, 5.0)

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)])
      ...> |> Vivid.Bezier.point_at(0)
      Vivid.Point.init(0, 0)
  """
  @spec point_at(Bezier.t(), number) :: Point.t()
  def point_at(%Bezier{control_points: points} = _bezier, t) when is_number(t),
    do: de_casteljau(points, t)

  @doc """
  Returns the number of steps in the `bezier` curve.

  ## Example

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)])
      ...> |> Vivid.Bezier.steps
      12
  """
  @spec steps(Bezier.t()) :: integer
  def steps(%Bezier{steps: s} = _bezier), do: s

  @doc """
  Changes the number of `steps` in `bezier`.

  ## Example

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)])
      ...> |> Vivid.Bezier.steps(24)
      ...> |> Vivid.Bezier.steps
      24
  """
  @spec steps(Bezier.t(), integer) :: Bezier.t()
  def steps(%Bezier{} = bezier, steps) when is_integer(steps) and steps > 0,
    do: %{bezier | steps: steps}

  @doc """
  Converts the `bezier` curve into a Path, which is used for a bunch of things
  like Transforms, Bounds calculation, Rasterization, etc.

  The vertices are deliberately left unrounded, so that the flattened curve
  agrees with the rasterized border when it's used as part of a filled shape.

  ## Example

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)], 4)
      ...> |> Vivid.Bezier.to_path
      Vivid.Path.init([
        Vivid.Point.init(0.0, 0.0),
        Vivid.Point.init(2.5, 3.75),
        Vivid.Point.init(5.0, 5.0),
        Vivid.Point.init(7.5, 3.75),
        Vivid.Point.init(10.0, 0.0)
      ])
  """
  @spec to_path(Bezier.t()) :: Path.t()
  def to_path(%Bezier{control_points: points, steps: steps} = _bezier) do
    0..steps
    |> Enum.map(&de_casteljau(points, &1 / steps))
    |> Path.init()
  end

  defp de_casteljau([point], _t), do: point

  defp de_casteljau(points, t) do
    points
    |> Enum.zip(tl(points))
    |> Enum.map(fn {a, b} -> interpolate(a, b, t) end)
    |> de_casteljau(t)
  end

  defp interpolate(a, b, t) do
    x = Point.x(a)
    y = Point.y(a)

    Point.init(x + (Point.x(b) - x) * t, y + (Point.y(b) - y) * t)
  end
end
