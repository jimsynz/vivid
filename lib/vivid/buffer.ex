defmodule Vivid.Buffer do
  alias Vivid.{Buffer, Frame, Rasterize, Bounds, Point, RGBA}
  defstruct ~w(buffer rows columns)a

  @moduledoc """
  Used to convert a Frame into a buffer for display.
  """

  @doc """
  Render the buffer horizontally, ie across rows then up columns.
  """
  def horizontal(%Frame{shapes: shapes, width: w, height: h}=frame) do
    buffer = allocate(frame)
    bounds = Bounds.bounds(frame)
    buffer = Enum.reduce(shapes, buffer, &horizontal_reducer(&1, &2, bounds, w))
    %Buffer{buffer: buffer, rows: h, columns: w}
  end

  @doc """
  Render the buffer vertically, ie up columns then across rows.
  """
  def vertical(%Frame{shapes: shapes, width: w, height: h}=frame) do
    bounds = Bounds.bounds(frame)
    buffer = allocate(frame)
    buffer = Enum.reduce(shapes, buffer, &vertical_reducer(&1, &2, bounds, h))
    %Buffer{buffer: buffer, rows: w, columns: h}
  end

  defp horizontal_reducer({shape, colour}, buffer, bounds, width) do
    points = Rasterize.rasterize(shape, bounds)
    Enum.reduce(points, buffer, fn(%Point{x: x, y: y}, buf) ->
      pos = (y * width) + x
      existing = Enum.at(buf, pos)
      List.replace_at(buf, pos, RGBA.over(existing, colour))
    end)
  end

  defp vertical_reducer({shape, colour}, buffer, bounds, width) do
    points = Rasterize.rasterize(shape, bounds)
    Enum.reduce(points, buffer, fn(point, buf) ->
      point = Point.swap_xy(point)
      pos = (point.y * width) + point.x
      existing = Enum.at(buf, pos)
      List.replace_at(buf, pos, RGBA.over(existing, colour))
    end)
  end

  defp allocate(%Frame{width: w, height: h, background_colour: bg}), do: generate_buffer([], w * h, bg)

  defp generate_buffer(buffer, 0, _colour), do: buffer
  defp generate_buffer(buffer, i, colour), do: generate_buffer([ colour | buffer ], i - 1, colour)
end