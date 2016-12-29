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
  def member?(%Frame{shapes: shapes}, shape), do: {:ok, Enum.member?(shapes, shape)}

  @doc """
  Reduce's the Path's shapes into an accumulator

  ## Examples

      iex> Vivid.Frame.init([Vivid.Point.init(1,2), Vivid.Point.init(2,4)]) |> Enum.reduce(%{}, fn (%Vivid.Point{x: x, y: y}, acc) -> Map.put(acc, x, y) end)
      %{1 => 2, 2 => 4}
  """
  def reduce(%Frame{shapes: shapes}, acc, fun), do: Enumerable.MapSet.reduce(shapes, acc, fun)
end