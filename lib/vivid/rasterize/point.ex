defimpl Vivid.Rasterize, for: Vivid.Point do
  alias Vivid.Point

  @moduledoc """
  Rasterize a single point. i.e. do nothing.
  """

  @doc """
  Rasterize an individual point.

  ## Example

      iex> Vivid.Rasterize.rasterize(Vivid.Point.init(3,3)) |> Enum.to_list
      [%Vivid.Point{x: 3, y: 3}]
  """
  def rasterize(%Point{}=point) do
    MapSet.new([point])
  end
end