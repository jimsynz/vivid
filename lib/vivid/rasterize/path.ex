defimpl Vivid.Rasterize, for: Vivid.Path do
  alias Vivid.{Rasterize, Path}

  @moduledoc """
  Rasterizes the path into a sequence of points.
  """

  @doc """
  Rasterize all points of `path` within `bounds` into a `MapSet`.

  ## Example

      iex> Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,3), Vivid.Point.init(3,3), Vivid.Point.init(3,1)])
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 3, 3))
      MapSet.new([
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 1, y: 2},
        %Vivid.Point{x: 1, y: 3},
        %Vivid.Point{x: 2, y: 3},
        %Vivid.Point{x: 3, y: 1},
        %Vivid.Point{x: 3, y: 2},
        %Vivid.Point{x: 3, y: 3}
      ])
  """
  @impl true
  def rasterize(%Path{} = path, bounds) do
    lines = path |> Path.to_lines()

    Enum.reduce(lines, MapSet.new(), fn line, acc ->
      MapSet.union(acc, Rasterize.rasterize(line, bounds))
    end)
  end
end
