defmodule Vivid.Group do
  alias Vivid.{Group, Shape}
  defstruct ~w(shapes)a

  @moduledoc ~S"""
  Represents a collection of shapes which can be Rasterized in a single pass.

  Group implements both the `Enumerable` and `Collectable` protocols.

  ## Example

    iex> use Vivid
    ...> circle = Circle.init(Point.init(10, 10), 10)
    ...> line   = Line.init(Point.init(0,0), Point.init(20,20))
    ...> Group.init([circle, line])
    ...> |> to_string()
    "@@@@@@@@@@@@@@@@@@@@@@@\n" <>
    "@@@@@@@@       @@@@@@ @\n" <>
    "@@@@@@  @@@@@@@  @@@ @@\n" <>
    "@@@@@ @@@@@@@@@@@ @ @@@\n" <>
    "@@@@ @@@@@@@@@@@@@ @@@@\n" <>
    "@@@ @@@@@@@@@@@@@ @ @@@\n" <>
    "@@ @@@@@@@@@@@@@ @@@ @@\n" <>
    "@@ @@@@@@@@@@@@ @@@@ @@\n" <>
    "@ @@@@@@@@@@@@ @@@@@@ @\n" <>
    "@ @@@@@@@@@@@ @@@@@@@ @\n" <>
    "@ @@@@@@@@@@ @@@@@@@@ @\n" <>
    "@ @@@@@@@@@ @@@@@@@@@ @\n" <>
    "@ @@@@@@@@ @@@@@@@@@@ @\n" <>
    "@ @@@@@@@ @@@@@@@@@@@ @\n" <>
    "@ @@@@@@ @@@@@@@@@@@@ @\n" <>
    "@@ @@@@ @@@@@@@@@@@@ @@\n" <>
    "@@ @@@ @@@@@@@@@@@@@ @@\n" <>
    "@@@ @ @@@@@@@@@@@@@ @@@\n" <>
    "@@@@ @@@@@@@@@@@@@ @@@@\n" <>
    "@@@ @ @@@@@@@@@@@ @@@@@\n" <>
    "@@ @@@  @@@@@@@  @@@@@@\n" <>
    "@ @@@@@@       @@@@@@@@\n" <>
    "@@@@@@@@@@@@@@@@@@@@@@@\n"
  """

  @type t :: %Group{shapes: MapSet.t(Shape.t())}

  @doc """
  Initialize an empty group.

  ## Examples

      iex> Vivid.Group.init
      %Vivid.Group{shapes: MapSet.new([])}
  """
  @spec init() :: Group.t()
  def init, do: %Group{shapes: MapSet.new()}

  @doc """
  Initialize a group from a list of shapes.

  ## Example

      iex> circle = Vivid.Circle.init(Vivid.Point.init(5,5), 5)
      ...> line   = Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(10,10))
      ...> Vivid.Group.init([circle, line])
      Vivid.Group.init([Vivid.Line.init(Vivid.Point.init(1, 1), Vivid.Point.init(10, 10)), Vivid.Circle.init(Vivid.Point.init(5, 5), 5)])
  """
  @spec init(Enumerable.t(Shape.t())) :: Group.t()
  def init(shapes) do
    %Group{shapes: MapSet.new(shapes)}
  end

  @doc """
  Remove a shape from a Group

  ## Example

      iex> line = Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(10,10))
      ...> Vivid.Group.init([line])
      ...> |> Vivid.Group.delete(line)
      %Vivid.Group{shapes: MapSet.new()}
  """
  @spec delete(Group.t(), Shape.t()) :: Group.t()
  def delete(%Group{shapes: shapes}, shape), do: shapes |> MapSet.delete(shape) |> init()

  @doc """
  Add a shape to a Group

  ## Example

      iex> line = Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(10,10))
      ...> Vivid.Group.init()
      ...> |> Vivid.Group.put(line)
      %Vivid.Group{shapes: MapSet.new([
        %Vivid.Line{origin: %Vivid.Point{x: 1, y: 1}, termination: %Vivid.Point{x: 10, y: 10}}
      ])}
  """
  @spec put(Group.t(), Shape.t()) :: Group.t()
  def put(%Group{shapes: shapes}, shape), do: shapes |> MapSet.put(shape) |> init()
end
