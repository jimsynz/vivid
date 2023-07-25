defimpl Enumerable, for: Vivid.Polygon do
  alias Vivid.{Polygon, Point}

  @moduledoc """
  Implements the Enumerable protocol for %Polygon{}
  """

  @doc """
  Returns the number of vertices in the Polygon.

  ## Example

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Enum.count
      2
  """
  @impl true
  def count(%Polygon{vertices: points}), do: {:ok, Enum.count(points)}

  @doc """
  Returns whether `point` is one of this `polygon`'s vertices.
  *note* not whether the point is *on or inside* the Polygon.

  ## Examples

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1)]) |> Enum.member?(Vivid.Point.init(1,1))
      true

      iex> Vivid.Polygon.init([Vivid.Point.init(1,1)]) |> Enum.member?(Vivid.Point.init(2,2))
      false
  """
  @impl true
  def member?(%Polygon{vertices: points}, %Point{} = point),
    do: {:ok, Enum.member?(points, point)}

  @doc """
  Reduces the Polygon's vertices into an accumulator.

  ## Examples

      iex> Vivid.Polygon.init([Vivid.Point.init(1,2), Vivid.Point.init(2,4)]) |> Enum.reduce(%{}, fn (%Vivid.Point{x: x, y: y}, acc) -> Map.put(acc, x, y) end)
      %{1 => 2, 2 => 4}
  """
  @impl true
  def reduce(%Polygon{vertices: points}, acc, fun), do: Enumerable.List.reduce(points, acc, fun)

  @doc """
  Slices the Polygon.
  """
  @impl true
  def slice(%Polygon{vertices: points}), do: Enumerable.List.slice(points)
end
