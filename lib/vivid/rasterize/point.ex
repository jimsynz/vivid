defimpl Vivid.Rasterize, for: Vivid.Point do
  alias Vivid.{Point, Bounds}

  @moduledoc """
  Rasterize a single point. i.e. do nothing.
  """

  @doc """
  Return a `MapSet` containing `point` if it is within `bounds`.

  ## Example

      iex> Vivid.Rasterize.rasterize(Vivid.Point.init(3,3), Vivid.Bounds.init(0, 0, 3, 3)) |> Enum.to_list
      [%Vivid.Point{x: 3, y: 3}]
  """
  @impl true
  def rasterize(point, bounds) do
    point = point |> Point.round()

    if Bounds.contains?(bounds, point) do
      MapSet.new([point])
    else
      MapSet.new()
    end
  end
end
