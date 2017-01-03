defmodule Vivid.Box do
  alias Vivid.{Box, Point, Polygon, Bounds}
  defstruct ~w(bottom_left top_right fill)a

  def init(%Point{}=bl, %Point{}=tr), do: init(bl, tr, false)
  def init(%Point{}=bl, %Point{}=tr, fill) when is_boolean(fill), do: %Box{bottom_left: bl, top_right: tr, fill: fill}

  def init_from_bounds(shape, fill \\ false) do
    bounds = shape |> Bounds.bounds
    min    = bounds |> Bounds.min
    max    = bounds |> Bounds.max
    init(min, max, fill)
  end

  def bottom_left(%Box{bottom_left: bl}), do: bl
  def top_left(%Box{bottom_left: bl, top_right: tr}), do: Point.init(bl.x, tr.y)
  def top_right(%Box{top_right: tr}), do: tr
  def bottom_right(%Box{bottom_left: bl, top_right: tr}), do: Point.init(tr.x, bl.y)

  def to_polygon(box) do
    Polygon.init([
      bottom_left(box),
      top_left(box),
      top_right(box),
      bottom_right(box)
    ])
  end
end