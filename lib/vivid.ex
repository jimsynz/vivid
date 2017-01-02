defmodule Vivid do
  defmacro __using__(_opts) do
    quote do
      alias Vivid.{Arc, Bounds, Buffer, Circle, Font, Frame, Group, Font, Frame,
                   Group, Line, Path, Point, Polygon, Rasterize, RGBA}
    end
  end
end
