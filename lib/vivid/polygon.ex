defmodule Vivid.Polygon do
  alias Vivid.{Polygon, Point, Line}
  defstruct vertices: [], fill: false

  @moduledoc """
  Describes a Polygon as a series of vertices.

  Polygon implements both the `Enumerable` and `Collectable` protocols.
  """

  @opaque t :: %Polygon{vertices: [Point.t], fill: boolean}

  @doc """
  Initialize an empty Polygon.

  ## Example

      iex> Vivid.Polygon.init
      %Vivid.Polygon{vertices: []}
  """
  @spec init() :: Polygon.t
  def init, do: %Polygon{vertices: [], fill: false}

  @doc """
  Initialize a Polygon from a list of points.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(1,2), Vivid.Point.init(2,2), Vivid.Point.init(2,1)])
      %Vivid.Polygon{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 1, y: 2},
        %Vivid.Point{x: 2, y: 2},
        %Vivid.Point{x: 2, y: 1}
      ]}
  """
  @spec init([Point.t]) :: Polygon.t
  def init(points) when is_list(points), do: %Polygon{vertices: points, fill: false}

  @doc false
  @spec init([Point.t], boolean) :: Polygon.t
  def init(points, fill) when is_list(points) and is_boolean(fill), do: %Polygon{vertices: points, fill: fill}

  @doc """
  Convert a Polygon into a list of lines joined by the vertices.

  ## Examples

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(1,2), Vivid.Point.init(2,2), Vivid.Point.init(2,1)]) |> Vivid.Polygon.to_lines
      [%Vivid.Line{origin: %Vivid.Point{x: 1, y: 1},
         termination: %Vivid.Point{x: 1, y: 2}},
       %Vivid.Line{origin: %Vivid.Point{x: 1, y: 2},
         termination: %Vivid.Point{x: 2, y: 2}},
       %Vivid.Line{origin: %Vivid.Point{x: 2, y: 2},
         termination: %Vivid.Point{x: 2, y: 1}},
       %Vivid.Line{origin: %Vivid.Point{x: 2, y: 1},
         termination: %Vivid.Point{x: 1, y: 1}}]
  """
  @spec to_lines(Polygon.t) :: [Line.t]
  def to_lines(%Polygon{vertices: points}) do
    points_to_lines([], points)
  end

  @doc """
  Remove a vertex from a Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.delete(Vivid.Point.init(2,2))
      %Vivid.Polygon{vertices: [%Vivid.Point{x: 1, y: 1}]}
  """
  @spec delete(Polygon.t, Point.t) :: Polygon.t
  def delete(%Polygon{vertices: points}, %Point{}=point) do
    points
    |> List.delete(point)
    |> init
  end

  @doc """
  Remove a vertex at a specific index in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.delete_at(1)
      %Vivid.Polygon{vertices: [%Vivid.Point{x: 1, y: 1}]}
  """
  @spec delete_at(Polygon.t, integer) :: Polygon.t
  def delete_at(%Polygon{vertices: points}, index) do
    points
    |> List.delete_at(index)
    |> init
  end

  @doc """
  Return the first vertex in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.first
      %Vivid.Point{x: 1, y: 1}
  """
  @spec first(Polygon.t) :: Point.t
  def first(%Polygon{vertices: points}) do
    points
    |> List.first
  end

  @doc """
  Insert a vertex at a specific index in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.insert_at(1, Vivid.Point.init(3,3))
      %Vivid.Polygon{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 3, y: 3},
        %Vivid.Point{x: 2, y: 2}
      ]}
  """
  @spec insert_at(Polygon.t, integer, Point.t) :: Polygon.t
  def insert_at(%Polygon{vertices: points}, index, %Point{}=point) do
    points
    |> List.insert_at(index, point)
    |> init
  end

  @doc """
  Return the last vertext in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.last
      %Vivid.Point{x: 2, y: 2}
  """
  @spec last(Polygon.t) :: Point.t
  def last(%Polygon{vertices: points}) do
    points
    |> List.last
  end

  @doc """
  Replace a vertex at a specific index in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2), Vivid.Point.init(3,3)]) |> Vivid.Polygon.replace_at(1, Vivid.Point.init(4,4))
      %Vivid.Polygon{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 4, y: 4},
        %Vivid.Point{x: 3, y: 3}
      ]}
  """
  @spec replace_at(Polygon.t, integer, Point.t) :: Polygon.t
  def replace_at(%Polygon{vertices: points}, index, %Point{}=point) do
    points
    |> List.replace_at(index, point)
    |> init
  end

  defp points_to_lines(lines, []) do
    origin = lines |> List.last |> Line.termination
    term   = lines |> List.first |> Line.origin
    lines ++ [Line.init(origin, term)]
  end

  defp points_to_lines([], [origin | [term | points]]) do
    line = Line.init(origin, term)
    points_to_lines([line], points)
  end

  defp points_to_lines(lines, [point | rest]) do
    origin = lines |> List.last |> Line.termination
    term   = point
    lines  = lines ++ [Line.init(origin, term)]
    points_to_lines(lines, rest)
  end
end