defmodule Vivid.Frame do
  alias Vivid.{Frame, Point, RGBA}
  defstruct ~w(width height background_colour shapes)a

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
    %Frame{width: width, height: height, background_colour: colour, shapes: []}
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
  def push(%Frame{shapes: shapes}=frame, shape, colour) do
    %{frame | shapes: [{shape, colour} | shapes]}
  end

  @doc """
  Clear the frame of any shapes.
  """
  def clear(%Frame{}=frame) do
    %{frame | shapes: []}
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

  def buffer(%Frame{shapes: shapes, width: w, height: h, background_colour: bg}, direction \\ :horizontal) do
    {w,h} = case direction do
      :horizontal -> {w, h}
      :vertical   -> {h, w}
    end
    Enum.reduce(shapes, allocate_buffer(w * h, bg), fn({shape, colour}, buffer)->
      points = Vivid.Rasterize.rasterize(shape, {0, 0, w-1, h-1})
      Enum.reduce(points, buffer, fn(point, buffer) ->
        point = translate_point(point, direction)
        x = point |> Point.x
        y = point |> Point.y
        pos = (x * w) + y
        existing = Enum.at(buffer, pos)
        List.replace_at(buffer, pos, RGBA.over(existing, colour))
      end)
    end)
  end

  @doc ~S"""
  Convert a frame buffer to a string for debugging.

  ## Examples

      iex> Vivid.Frame.init(4, 4) |> Vivid.Frame.to_string
      "    \n" <>
      "    \n" <>
      "    \n" <>
      "    \n"
  """
  def to_string(%Frame{width: width}=frame) do
    s = frame
      |> buffer
      |> Enum.reverse
      |> Enum.chunk(width)
      |> Enum.map(fn (row) ->
        row
        |> Enum.reverse
        |> Enum.map(&RGBA.to_ascii(&1))
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


  defp translate_point(point, :horizontal), do: point
  defp translate_point(point, :vertical), do: Point.swap_xy(point)

  defp allocate_buffer(size, colour) do
    Enum.map((1..size), fn(_) -> colour end)
  end
end