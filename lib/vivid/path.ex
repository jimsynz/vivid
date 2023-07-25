defmodule Vivid.Path do
  alias Vivid.{Line, Path, Point, Shape}
  defstruct vertices: []

  @moduledoc ~S"""
  Describes a path as a series of vertices.

  Path implements both the `Enumerable` and `Collectable` protocols.

  ## Example

      iex> use Vivid
      ...> 0..3
      ...> |> Stream.map(fn
      ...> i when rem(i, 2) == 0 -> Point.init(i * 3, i * 4)
      ...> i -> Point.init(i * 3, i * 2)
      ...> end)
      ...> |> Enum.into(Path.init())
      ...> |> to_string()
      "@@@@@@@@@@@@\n" <>
      "@@@@@@@ @@@@\n" <>
      "@@@@@@@   @@\n" <>
      "@@@@@@ @@@ @\n" <>
      "@@@@@@ @@@@@\n" <>
      "@@@@@ @@@@@@\n" <>
      "@@@@@ @@@@@@\n" <>
      "@@@@ @@@@@@@\n" <>
      "@@  @@@@@@@@\n" <>
      "@ @@@@@@@@@@\n" <>
      "@@@@@@@@@@@@\n"
  """

  @type t :: %Path{vertices: [Shape.t()]}

  @doc """
  Initialize an empty path.

  ## Example

      iex> Vivid.Path.init
      %Vivid.Path{vertices: []}
  """
  @spec init() :: Path.t()
  def init, do: %Path{vertices: []}

  @doc """
  Initialize a path from a list of points.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,2), Vivid.Point.init(2,2), Vivid.Point.init(2,1)])
      %Vivid.Path{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 1, y: 2},
        %Vivid.Point{x: 2, y: 2},
        %Vivid.Point{x: 2, y: 1}
      ]}
  """
  @spec init([Point.t()]) :: Path.t()
  def init(points) when is_list(points), do: %Path{vertices: points}

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
  @spec to_lines(Path.t()) :: [Line.t()]
  def to_lines(%Path{vertices: points}) do
    points_to_lines([], points)
  end

  @doc """
  Remove a vertex from a Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.delete(Vivid.Point.init(2,2))
      %Vivid.Path{vertices: [%Vivid.Point{x: 1, y: 1}]}
  """
  @spec delete(Path.t(), Point.t()) :: Path.t()
  def delete(%Path{vertices: points}, %Point{} = point) do
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
  @spec delete_at(Path.t(), integer) :: Path.t()
  def delete_at(%Path{vertices: points}, index) do
    points
    |> List.delete_at(index)
    |> init
  end

  @doc """
  Return the first vertex in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.first
      %Vivid.Point{x: 1, y: 1}
  """
  @spec first(Path.t()) :: Point.t()
  def first(%Path{vertices: points}) do
    points
    |> List.first()
  end

  @doc """
  Insert a vertex at a specific index in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.insert_at(1, Vivid.Point.init(3,3))
      %Vivid.Path{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 3, y: 3},
        %Vivid.Point{x: 2, y: 2}
      ]}
  """
  @spec insert_at(Path.t(), integer, Point.t()) :: Path.t()
  def insert_at(%Path{vertices: points}, index, %Point{} = point) do
    points
    |> List.insert_at(index, point)
    |> init
  end

  @doc """
  Return the last vertex in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Vivid.Path.last
      %Vivid.Point{x: 2, y: 2}
  """
  @spec last(Path.t()) :: Point.t()
  def last(%Path{vertices: points}) do
    points
    |> List.last()
  end

  @doc """
  Replace a vertex at a specific index in the Path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2), Vivid.Point.init(3,3)]) |> Vivid.Path.replace_at(1, Vivid.Point.init(4,4))
      %Vivid.Path{vertices: [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 4, y: 4},
        %Vivid.Point{x: 3, y: 3}
      ]}
  """
  @spec replace_at(Path.t(), integer, Point.t()) :: Path.t()
  def replace_at(%Path{vertices: points}, index, %Point{} = point) do
    points
    |> List.replace_at(index, point)
    |> init
  end

  defp points_to_lines(lines, []), do: lines

  defp points_to_lines([], [origin | [term | points]]) do
    line = Line.init(origin, term)
    points_to_lines([line], points)
  end

  defp points_to_lines(lines, [point | rest]) do
    origin = lines |> List.last() |> Line.termination()
    term = point
    lines = lines ++ [Line.init(origin, term)]
    points_to_lines(lines, rest)
  end
end
