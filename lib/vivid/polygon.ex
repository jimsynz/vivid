defmodule Vivid.Polygon do
  alias Vivid.{Polygon, Point, Line}
  defstruct vertices: []

  @moduledoc """
  Describes a Polygon as a series of vertices.
  """

  @doc """
  Initialize a Polygon either empty or from a list of points.

  ## Examples

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(1,2), Vivid.Point.init(2,2), Vivid.Point.init(2,1)])
      %Vivid.Polygon{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 1, y: 2},
        %Vivid.Point{x: 2, y: 2},
        %Vivid.Point{x: 2, y: 1}
      ]}

      iex> Vivid.Polygon.init
      %Vivid.Polygon{vertices: []}
  """

  def init(points) when is_list(points), do: %Polygon{vertices: points}
  def init, do: %Polygon{vertices: []}

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
  def to_lines(%Polygon{vertices: points}) do
    points_to_lines([], points)
  end

  @doc """
  Remove a vertex from a Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.delete(Vivid.Point.init(2,2))
      %Vivid.Polygon{vertices: [%Vivid.Point{x: 1, y: 1}]}
  """
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
  def delete_at(%Polygon{vertices: points}, index) do
    points
    |> List.delete_at(index)
    |> init
  end

  @doc """
  Remove a vertex at a specific index in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.first
      %Vivid.Point{x: 1, y: 1}
  """
  def first(%Polygon{vertices: points}) do
    points
    |> List.first
  end

  @doc """
  Remove a vertex at a specific index in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.insert_at(1, Vivid.Point.init(3,3))
      %Vivid.Polygon{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 3, y: 3},
        %Vivid.Point{x: 2, y: 2}
      ]}
  """
  def insert_at(%Polygon{vertices: points}, index, %Point{}=point) do
    points
    |> List.insert_at(index, point)
    |> init
  end

  @doc """
  Remove a vertex at a specific index in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Polygon.last
      %Vivid.Point{x: 2, y: 2}
  """
  def last(%Polygon{vertices: points}) do
    points
    |> List.last
  end

  @doc """
  Remove a vertex at a specific index in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2), Vivid.Point.init(3,3)]) |> Vivid.Polygon.replace_at(1, Vivid.Point.init(4,4))
      %Vivid.Polygon{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 4, y: 4},
        %Vivid.Point{x: 3, y: 3}
      ]}
  """
  def replace_at(%Polygon{vertices: points}, index, %Point{}=point) do
    points
    |> List.replace_at(index, point)
    |> init
  end

  def points_to_lines(lines, []) do
    origin = lines |> List.last |> Line.termination
    term   = lines |> List.first |> Line.origin
    lines ++ [Line.init(origin, term)]
  end

  def points_to_lines([], [origin | [term | points]]) do
    line = Line.init(origin, term)
    points_to_lines([line], points)
  end

  def points_to_lines(lines, [point | rest]) do
    origin = lines |> List.last |> Line.termination
    term   = point
    lines  = lines ++ [Line.init(origin, term)]
    points_to_lines(lines, rest)
  end
end