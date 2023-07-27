defimpl Enumerable, for: Vivid.Path do
  alias Vivid.{Path, Point}

  @moduledoc """
  Implements the Enumerable protocol for %Path{}
  """

  @doc """
  Returns the number of vertices in the path.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(2,2)]) |> Enum.count
      2
  """
  @impl true
  def count(%Path{vertices: points}), do: {:ok, Enum.count(points)}

  @doc """
  Returns whether a point is one of this path's vertices.
  *note* not whether the point is *on* the path.

  ## Examples

      iex> Vivid.Path.init([Vivid.Point.init(1,1)]) |> Enum.member?(Vivid.Point.init(1,1))
      true

      iex> Vivid.Path.init([Vivid.Point.init(1,1)]) |> Enum.member?(Vivid.Point.init(2,2))
      false
  """
  @impl true
  def member?(%Path{vertices: points}, %Point{} = point), do: {:ok, Enum.member?(points, point)}

  @doc """
  Reduces the Path's vertices into an accumulator.

  ## Examples

      iex> Vivid.Path.init([Vivid.Point.init(1,2), Vivid.Point.init(2,4)]) |> Enum.reduce(%{}, fn (%Vivid.Point{x: x, y: y}, acc) -> Map.put(acc, x, y) end)
      %{1 => 2, 2 => 4}
  """
  @impl true
  def reduce(%Path{vertices: points}, acc, fun), do: Enumerable.List.reduce(points, acc, fun)

  @doc """
  Slices the Path.
  """
  @impl true
  def slice(%Path{vertices: points}), do: Enumerable.List.slice(points)
end
