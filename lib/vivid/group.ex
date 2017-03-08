defmodule Vivid.Group do
  alias Vivid.{Group, Shape}
  defstruct ~w(shapes)a

  @moduledoc """
  Represents a collection of shapes which can be Rasterized in a single pass.

  Group implements both the `Enumerable` and `Collectable` protocols.
  """

  @opaque t :: %Group{shapes: [Shape.t]}

  @doc """
  Initialize an empty group.

  ## Examples

      iex> Vivid.Group.init
      #Vivid.Group<[]>
  """
  @spec init() :: Group.t
  def init, do: %Group{shapes: MapSet.new()}

  @doc """
  Initialize a group from a list of shapes.

  ## Example

      iex> circle = Vivid.Circle.init(Vivid.Point.init(5,5), 5)
      ...> line   = Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(10,10))
      ...> Vivid.Group.init([circle, line])
      #Vivid.Group<[#Vivid.Line<[origin: #Vivid.Point<{1, 1}>, termination: #Vivid.Point<{10, 10}>]>, #Vivid.Circle<[center: #Vivid.Point<{5, 5}>, radius: 5]>]>
  """
  @spec init([Shape.t]) :: Group.t
  def init(shapes) do
    %Group{shapes: Enum.into(shapes, MapSet.new)}
  end

  @doc """
  Remove a shape from a Group

  ## Example

      iex> line = Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(10,10))
      ...> Vivid.Group.init([line])
      ...> |> Vivid.Group.delete(line)
      %Vivid.Group{shapes: MapSet.new()}
  """
  @spec delete(Group.t, Shape.t) :: Group.t
  def delete(%Group{shapes: shapes}, shape), do: shapes |> MapSet.delete(shape) |> init

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
  @spec put(Group.t, Shape.t) :: Group.t
  def put(%Group{shapes: shapes}, shape), do: shapes |> MapSet.put(shape) |> init
end
