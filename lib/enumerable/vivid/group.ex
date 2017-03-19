defimpl Enumerable, for: Vivid.Group do
  alias Vivid.Group

  @moduledoc """
  Implements the Enumerable protocol for %Group{}
  """

  @doc """
  Returns the number of Shapes in a group.

  ## Example

      iex> Vivid.Group.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)])
      ...> |> Enum.count
      2
  """
  @spec count(Group.t) :: {:ok, non_neg_integer}
  def count(%Group{shapes: shapes}), do: {:ok, Enum.count(shapes)}

  @doc """
  Returns whether the shape is a member of a group.

  ## Examples

      iex> Vivid.Group.init([Vivid.Point.init(1,1)])
      ...> |> Enum.member?(Vivid.Point.init(1,1))
      true

      iex> Vivid.Group.init([Vivid.Point.init(1,1)])
      ...> |> Enum.member?(Vivid.Point.init(2,2))
      false
  """
  @spec member?(Group.t, Shape.t) :: {:ok, boolean}
  def member?(%Group{shapes: shapes}, shape), do: {:ok, Enum.member?(shapes, shape)}

  @doc """
  Reduce's the Path's shapes into an accumulator

  ## Examples

      iex> Vivid.Group.init([Vivid.Point.init(1,2), Vivid.Point.init(2,4)]) |> Enum.reduce(%{}, fn (%Vivid.Point{x: x, y: y}, acc) -> Map.put(acc, x, y) end)
      %{1 => 2, 2 => 4}
  """
  @spec reduce(Group.t, Collectable.t, (Shape.t, Collectable.t -> Collectable.t)) :: Collectable.t
  def reduce(%Group{shapes: shapes}, acc, fun), do: Enumerable.MapSet.reduce(shapes, acc, fun)
end
