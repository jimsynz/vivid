defimpl Vivid.Rasterize, for: Vivid.Arc do
  alias Vivid.{Rasterize, Arc}

  @moduledoc """
  Rasterizes an Arc.
  """

  @doc ~S"""
  Convert an Arc into a rasterized points.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(5,5), 5, 270, 90, 3)
      ...> |> Vivid.Rasterize.rasterize({0, 0, 5, 5})
      #MapSet<[#Vivid.Point<{0, 5}>, #Vivid.Point<{1, 3}>, #Vivid.Point<{1, 4}>, #Vivid.Point<{2, 2}>, #Vivid.Point<{3, 1}>, #Vivid.Point<{4, 1}>, #Vivid.Point<{5, 0}>]>

  """
  def rasterize(arc, bounds) do
    arc
    |> Arc.to_path
    |> Rasterize.rasterize(bounds)
  end
end