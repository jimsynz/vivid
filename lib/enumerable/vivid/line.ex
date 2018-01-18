defimpl Enumerable, for: Vivid.Line do
  alias Vivid.{Line, Point}

  @moduledoc """
  Implements the Enumerable protocol for %Line{}
  """

  @doc """
  Returns the number of points on the line.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(1,1), Point.init(2,2))
      ...> |> Enum.count
      2
  """
  @spec count(Line.t) :: non_neg_integer
  def count(%Line{}), do: {:ok, 2}

  @doc """
  Returns whether a point is one of this line's end points.
  *note* not whether the point is *on* the line.

  ## Examples

      iex> use Vivid
      ...> Line.init(Point.init(1,1), Point.init(2,2))
      ...> |> Enum.member?(Point.init(3,3))
      false

      iex> use Vivid
      ...> Line.init(Point.init(1,1), Point.init(2,2))
      ...> |> Enum.member?(Point.init(2,2))
      true
  """
  @spec member?(Line.t, Point.t) :: boolean
  def member?(%Line{origin: p0}, point) when p0 == point, do: {:ok, true}
  def member?(%Line{termination: p0}, point) when p0 == point, do: {:ok, true}
  def member?(_line, _point), do: {:ok, false}

  @doc """
  Reduces the line's points into an accumulator

  ## Examples

      iex> use Vivid
      ...> Line.init(Point.init(1,2), Point.init(2,4))
      ...> |> Enum.reduce(%{}, fn point, points -> Map.put(points, Point.x(point), Point.y(point)) end)
      %{1 => 2, 2 => 4}
  """
  @spec reduce(Line.t, Collectable.t, (Point.t, Collectable.t -> Collectable.t)) :: Collectable.t
  def reduce(%Line{origin: p0, termination: p1}, acc, fun), do: Enumerable.List.reduce([p0, p1], acc, fun)

  @doc """
  Slices the line.
  """
  @spec slice(Line.t) :: {:ok, size :: non_neg_integer(), Enumerable.slicing_fun()} | {:error, module()}
  def slice(%Line{origin: p0, termination: p1}), do: Enumerable.List.slice([p0, p1])
end
