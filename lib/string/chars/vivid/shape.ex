defmodule Vivid.ShapeToString do
  alias Vivid.{Bounds, Frame, Transform, RGBA}

  @moduledoc false

  def to_string(shape) do
    bounds = Bounds.bounds(shape)
    width  = Bounds.width(bounds) + 3 |> round
    height = Bounds.height(bounds) + 3 |> round
    frame = Frame.init(width, height, RGBA.white)

    shape = shape
      |> Transform.center(frame)
      |> Transform.apply

    frame
    |> Frame.push(shape, RGBA.black)
    |> Kernel.to_string
  end
end

Enum.each(~w(Arc Box Circle Group Line Path Polygon), fn mod ->
  mod = Module.concat(Vivid, mod)
  defimpl String.Chars, for: mod do
    def to_string(shape), do: Vivid.ShapeToString.to_string(shape)
  end
end)
