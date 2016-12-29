defmodule Vivid.Frame do
  alias Vivid.{Frame, Point, RGBA}
  defstruct ~w(width height background_colour buffer)a

  @moduledoc """
  A frame buffer or something.
  """

  @doc """
  Initialize a frame buffer.

  * `width` the width of the frame, in pixels.
  * `height` the height of the frame, in pixels.
  * `colour` the default colour of the frame.

  ## Example

      iex> Vivid.Frame.init(4, 4)
      #Vivid.Frame<[width: 4, height: 4, background_colour: #Vivid.RGBA<{0, 0, 0, 0}>]>
  """
  def init(width \\ 128, height \\ 64, colour \\ RGBA.init(0,0,0,0)) do
    %Frame{width: width, height: height, background_colour: colour, buffer: allocate_buffer(width * height, colour)}
  end

  @doc ~S"""
  Add a shape to the frame buffer.

  ## Examples

      iex> Vivid.Frame.init(5,5)
      ...> |> Vivid.Frame.push(Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(3,3)), Vivid.RGBA.white)
      ...> |> Vivid.Frame.to_string
      "     \n" <>
      "   @ \n" <>
      "  @  \n" <>
      " @   \n" <>
      "     \n"

      iex> Vivid.Frame.init(5,5)
      ...> |> Vivid.Frame.push(
      ...>      Vivid.Path.init([
      ...>        Vivid.Point.init(1,1),
      ...>        Vivid.Point.init(1,3),
      ...>        Vivid.Point.init(3,3),
      ...>        Vivid.Point.init(3,1),
      ...>      ]), Vivid.RGBA.white
      ...>    )
      ...> |> Vivid.Frame.to_string
      "     \n" <>
      " @@@ \n" <>
      "   @ \n" <>
      " @@@ \n" <>
      "     \n"

      iex> Vivid.Frame.init(5,5)
      ...> |> Vivid.Frame.push(
      ...>      Vivid.Polygon.init([
      ...>        Vivid.Point.init(1,1),
      ...>        Vivid.Point.init(1,3),
      ...>        Vivid.Point.init(3,3),
      ...>        Vivid.Point.init(3,1),
      ...>      ]), Vivid.RGBA.white
      ...>    )
      ...> |> Vivid.Frame.to_string
      "     \n" <>
      " @@@ \n" <>
      " @ @ \n" <>
      " @@@ \n" <>
      "     \n"

      iex> circle = Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      ...> Vivid.Frame.init(11, 10)
      ...> |> Vivid.Frame.push(circle, Vivid.RGBA.white)
      ...> |> Vivid.Frame.to_string
      "    @@@    \n" <>
      "  @@   @@  \n" <>
      "  @     @  \n" <>
      " @       @ \n" <>
      " @       @ \n" <>
      " @       @ \n" <>
      "  @     @  \n" <>
      "  @@   @@  \n" <>
      "    @@@    \n" <>
      "           \n"

      iex> line = Vivid.Line.init(Vivid.Point.init(0,0), Vivid.Point.init(50,50))
      ...> Vivid.Frame.init(5,5)
      ...> |> Vivid.Frame.push(line, Vivid.RGBA.white)
      ...> |> Vivid.Frame.to_string
      "    @\n" <>
      "   @ \n" <>
      "  @  \n" <>
      " @   \n" <>
      "@    \n"
  """
  def push(%Frame{buffer: buffer, width: w}=frame, shape, colour) do
    points = Vivid.Rasterize.rasterize(shape)
    buffer = Enum.reduce(points, buffer, fn(point, buffer) ->
      if point_inside_bounds?(point, frame) do
        x = point |> Point.x
        y = point |> Point.y
        List.replace_at(buffer, (x * w) + y, colour)
      else
        buffer
      end
    end)
    %{frame | buffer: buffer}
  end

  @doc """
  Return the width of the frame.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.width
      80
  """
  def width(%Frame{width: w}), do: w

  @doc """
  Return the height of the frame.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.height
      25
  """
  def height(%Frame{height: h}), do: h

  @doc """
  Return the colour depth of the frame.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.background_colour
      #Vivid.RGBA<{0, 0, 0, 0}>
  """
  def background_colour(%Frame{background_colour: c}), do: c

  @doc ~S"""
  Convert a frame buffer to a string for debugging.

  ## Examples

      iex> Vivid.Frame.init(4, 4) |> Vivid.Frame.to_string
      "    \n" <>
      "    \n" <>
      "    \n" <>
      "    \n"
  """
  def to_string(%Frame{buffer: buffer, width: width}) do
    s = buffer
    |> Enum.reverse
    |> Enum.chunk(width)
    |> Enum.map(fn (row) ->
      row
      |> Enum.reverse
      |> Enum.map(fn(colour) -> RGBA.to_ascii(colour) end)
      |> Enum.join
    end)
    |> Enum.join("\n")
    s <> "\n"
  end

  @doc """
  Print the frame buffer to stdout for debugging.
  """
  def puts(%Frame{}=frame) do
    frame
    |> Frame.to_string
    |> IO.write
    :ok
  end

  defp allocate_buffer(size, colour) do
    Enum.map((1..size), fn(_) -> colour end)
  end

  defp point_inside_bounds?(%Point{x: x}, _frame) when x < 0, do: false
  defp point_inside_bounds?(%Point{y: y}, _frame) when y < 0, do: false
  defp point_inside_bounds?(%Point{x: x}, %Frame{width: w}) when x >= w, do: false
  defp point_inside_bounds?(%Point{y: y}, %Frame{height: h}) when y >= h, do: false
  defp point_inside_bounds?(_point, _frame), do: true
end