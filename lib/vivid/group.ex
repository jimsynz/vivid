defmodule Vivid.Group do
  alias Vivid.Group
  defstruct ~w(shapes)a

  @moduledoc """
  Represents a collection of shapes which can be Rasterized in a single pass.
  """

  @doc """
  Initialize a group either empty or from a list of shapes.

  ## Examples

      iex> circle = Vivid.Circle.init(Vivid.Point.init(5,5), 5)
      ...> line   = Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(10,10))
      ...> Vivid.Group.init([circle, line])
      %Vivid.Group{shapes: MapSet.new([
        %Vivid.Circle{center: %Vivid.Point{x: 5, y: 5}, radius: 5},
        %Vivid.Line{origin: %Vivid.Point{x: 1, y: 1}, termination: %Vivid.Point{x: 10, y: 10}}
      ])}

      iex> Vivid.Group.init
      %Vivid.Group{shapes: MapSet.new()}
  """

  def init, do: %Group{shapes: MapSet.new()}
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
  def put(%Group{shapes: shapes}, shape), do: shapes |> MapSet.put(shape) |> init
end