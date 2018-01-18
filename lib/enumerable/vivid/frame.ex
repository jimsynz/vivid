defimpl Enumerable, for: Vivid.Frame do
  alias Vivid.Frame

  @moduledoc """
  Implements the Enumerable protocol for %Frame{}
  """

  @doc """
  Returns the number of Shapes in a Frame.

  ## Example

      iex> Vivid.Frame.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)])
      ...> |> Enum.count
      2
  """
  @spec count(Frame.t) :: {:ok, non_neg_integer}
  def count(%Frame{shapes: shapes}), do: {:ok, Enum.count(shapes)}

  @doc """
  Returns whether the shape is a member of a Frame.

  ## Examples

      iex> Vivid.Frame.init([Vivid.Point.init(1,1)])
      ...> |> Enum.member?(Vivid.Point.init(1,1))
      true

      iex> Vivid.Frame.init([Vivid.Point.init(1,1)])
      ...> |> Enum.member?(Vivid.Point.init(2,2))
      false
  """
  @spec member?(Frame.t, Shape.t) :: {:ok, boolean}
  def member?(%Frame{shapes: shapes}, shape), do: {:ok, Enum.member?(shapes, shape)}

  @doc """
  Reduce's the Frames's shapes into an accumulator

  ## Examples

      iex> Vivid.Frame.init([Vivid.Point.init(1,2), Vivid.Point.init(2,4)]) |> Enum.reduce(%{}, fn (%Vivid.Point{x: x, y: y}, acc) -> Map.put(acc, x, y) end)
      %{1 => 2, 2 => 4}
  """
  @spec reduce(Frame.t, Collectable.t, (any, Collectable.t -> Collectable.t)) :: Collectable.t
  def reduce(%Frame{shapes: shapes}, acc, fun), do: Enumerable.List.reduce(shapes, acc, fun)

  @doc """
  Slice the frame.
  """
  @spec slice(Frame.t) :: {:ok, size :: non_neg_integer(), Enumerable.slicing_fun()} | {:error, module()}
  def slice(%Frame{shapes: shapes}), do: Enumerable.List.slice(shapes)
end
