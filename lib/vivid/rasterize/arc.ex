defimpl Vivid.Rasterize, for: Vivid.Arc do
  alias Vivid.{Rasterize, Arc, Bounds}

  @moduledoc """
  Rasterizes an Arc.
  """

  @doc ~S"""
  Rasterize all points of `arc` within `bounds` into a `MapSet`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(5,5), 5, 270, 90, 3)
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 5, 5))
      #MapSet<[#Vivid.Point<{0, 5}>, #Vivid.Point<{1, 3}>, #Vivid.Point<{1, 4}>, #Vivid.Point<{2, 2}>, #Vivid.Point<{3, 1}>, #Vivid.Point<{4, 1}>, #Vivid.Point<{5, 0}>]>

  """
  @spec rasterize(Arc.t(), Bounds.t()) :: MapSet.t()
  def rasterize(arc, bounds) do
    arc
    |> Arc.to_path()
    |> Rasterize.rasterize(bounds)
  end
end
