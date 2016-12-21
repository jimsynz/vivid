defmodule Vivid.Path do
  alias Vivid.{Path, Point, Line}
  defstruct vertices: []

  @moduledoc """
  Describes a path as a series of vertices.
  """

  @doc """
  Initialize a path either empty or from a list of points.

  ## Examples

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,2), Vivid.Point.init(2,2), Vivid.Point.init(2,1)])
      %Vivid.Path{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 1, y: 2},
        %Vivid.Point{x: 2, y: 2},
        %Vivid.Point{x: 2, y: 1}
      ]}

      iex> Vivid.Path.init
      %Vivid.Path{vertices: []}
  """

  def init(points) when is_list(points), do: %Path{vertices: points}
  def init, do: %Path{vertices: []}

  @doc """
  Convert a path into a list of lines joined by the vertices.

  ## Examples

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,2), Vivid.Point.init(2,2), Vivid.Point.init(2,1)]) |> Vivid.Path.to_lines
      [%Vivid.Line{origin: %Vivid.Point{x: 1, y: 1},
         termination: %Vivid.Point{x: 1, y: 2}},
       %Vivid.Line{origin: %Vivid.Point{x: 1, y: 2},
         termination: %Vivid.Point{x: 2, y: 2}},
       %Vivid.Line{origin: %Vivid.Point{x: 2, y: 2},
         termination: %Vivid.Point{x: 2, y: 1}}]
  """
  def to_lines(%Path{vertices: points}) do
    points_to_lines([], points)
  end

  @doc """
  Remove a vertex from a Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.delete(Vivid.Point.init(2,2))
      %Vivid.Path{vertices: [%Vivid.Point{x: 1, y: 1}]}
  """
  def delete(%Path{vertices: points}, %Point{}=point) do
    points
    |> List.delete(point)
    |> init
  end

  @doc """
  Remove a vertex at a specific index in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.delete_at(1)
      %Vivid.Path{vertices: [%Vivid.Point{x: 1, y: 1}]}
  """
  def delete_at(%Path{vertices: points}, index) do
    points
    |> List.delete_at(index)
    |> init
  end

  @doc """
  Remove a vertex at a specific index in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.first
      %Vivid.Point{x: 1, y: 1}
  """
  def first(%Path{vertices: points}) do
    points
    |> List.first
  end

  @doc """
  Remove a vertex at a specific index in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.insert_at(1, Vivid.Point.init(3,3))
      %Vivid.Path{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 3, y: 3},
        %Vivid.Point{x: 2, y: 2}
      ]}
  """
  def insert_at(%Path{vertices: points}, index, %Point{}=point) do
    points
    |> List.insert_at(index, point)
    |> init
  end

  @doc """
  Remove a vertex at a specific index in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.last
      %Vivid.Point{x: 2, y: 2}
  """
  def last(%Path{vertices: points}) do
    points
    |> List.last
  end

  @doc """
  Remove a vertex at a specific index in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2), Vivid.Point.init(3,3)]) |> Vivid.Path.replace_at(1, Vivid.Point.init(4,4))
      %Vivid.Path{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 4, y: 4},
        %Vivid.Point{x: 3, y: 3}
      ]}
  """
  def replace_at(%Path{vertices: points}, index, %Point{}=point) do
    points
    |> List.replace_at(index, point)
    |> init
  end

  def points_to_lines(lines, []), do: lines

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