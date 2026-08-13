defmodule Vivid.Frame do
  alias Vivid.{Buffer, Frame, RGBA, Shape}
  defstruct ~w(width height background_colour shapes samples)a

  @moduledoc ~S"""
  Frame represents a collection of colours and shapes.

  Frame implements both the `Enumerable` and `Collectable` protocols.

  ## Examples

        iex> use Vivid
        ...> Enum.map(1..5, fn i ->
        ...>   line = Line.init(Point.init(1,1), Point.init(20, i * 4))
        ...>   {line, RGBA.black}
        ...> end)
        ...> |> Enum.into(Frame.init(24, 21, RGBA.white))
        ...> |> to_string
        "@@@@@@@@@@@@@@@@@@@@ @@@\n" <>
        "@@@@@@@@@@@@@@@@@@@ @@@@\n" <>
        "@@@@@@@@@@@@@@@@@@ @@@@@\n" <>
        "@@@@@@@@@@@@@@@@@ @@@@@@\n" <>
        "@@@@@@@@@@@@@@@@ @@@ @@@\n" <>
        "@@@@@@@@@@@@@@@ @@@ @@@@\n" <>
        "@@@@@@@@@@@@@@ @@  @@@@@\n" <>
        "@@@@@@@@@@@@@ @@ @@@@@@@\n" <>
        "@@@@@@@@@@@@ @@ @@@@ @@@\n" <>
        "@@@@@@@@@@@ @@ @@@  @@@@\n" <>
        "@@@@@@@@@@ @  @@  @@@@@@\n" <>
        "@@@@@@@@@ @ @@  @@@@@@@@\n" <>
        "@@@@@@@@ @ @@ @@@@@  @@@\n" <>
        "@@@@@@@   @  @@@   @@@@@\n" <>
        "@@@@@@  @  @@@  @@@@@@@@\n" <>
        "@@@@@  @ @@   @@@@@@@@@@\n" <>
        "@@@@       @@@@@@    @@@\n" <>
        "@@@     @@@      @@@@@@@\n" <>
        "@@         @@@@@@@@@@@@@\n" <>
        "@    @@@@@@@@@@@@@@@@@@@\n" <>
        "@@@@@@@@@@@@@@@@@@@@@@@@\n"
  """

  @type t :: %Frame{
          width: pos_integer(),
          height: pos_integer(),
          background_colour: RGBA.t(),
          shapes: [{Shape.t(), RGBA.t()}],
          samples: pos_integer()
        }

  @doc """
  Initialize a frame buffer.

  * `width` the width of the frame, in pixels.
  * `height` the height of the frame, in pixels.
  * `colour` the default colour of the frame.

  ## Example

      iex> Vivid.Frame.init(4, 4)
      Vivid.Frame.init(4, 4, Vivid.RGBA.init(0, 0, 0, 0))
  """
  @spec init(pos_integer(), pos_integer(), RGBA.t()) :: Frame.t()
  def init(width \\ 128, height \\ 64, %RGBA{} = colour \\ RGBA.init(0, 0, 0, 0))
      when is_integer(width) and is_integer(height) and width > 0 and height > 0 do
    %Frame{width: width, height: height, background_colour: colour, shapes: [], samples: 1}
  end

  @doc ~S"""
  Add a shape to the frame buffer.

  * `frame` is the frame to modify.
  * `shape` is the shape to add.
  * `colour` is the colour of the shape being added.

  ## Examples

      iex> Vivid.Frame.init(5,5)
      ...> |> Vivid.Frame.push(Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(3,3)), Vivid.RGBA.white)
      ...> |> to_string
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
      ...> |> to_string
      "     \n" <>
      " @@@ \n" <>
      " @ @ \n" <>
      " @ @ \n" <>
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
      ...> |> to_string
      "     \n" <>
      " @@@ \n" <>
      " @ @ \n" <>
      " @@@ \n" <>
      "     \n"

      iex> circle = Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      ...> Vivid.Frame.init(11, 10)
      ...> |> Vivid.Frame.push(circle, Vivid.RGBA.white)
      ...> |> to_string
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
      ...> |> to_string
      "    @\n" <>
      "   @ \n" <>
      "  @  \n" <>
      " @   \n" <>
      "@    \n"
  """
  @spec push(Frame.t(), Shape.t(), RGBA.t()) :: Frame.t()
  def push(%Frame{shapes: shapes} = frame, shape, colour) do
    %{frame | shapes: [{shape, colour} | shapes]}
  end

  @doc """
  Clear the `frame` of any shapes.
  """
  @spec clear(Frame.t()) :: Frame.t()
  def clear(%Frame{} = frame) do
    %{frame | shapes: []}
  end

  @doc """
  Return the width of the `frame`.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.width
      80
  """
  @spec width(Frame.t()) :: integer()
  def width(%Frame{width: w}), do: w

  @doc """
  Return the height of the `frame`.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.height
      25
  """
  @spec height(Frame.t()) :: integer()
  def height(%Frame{height: h}), do: h

  @doc """
  Return the background colour of the `frame`.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.background_colour
      Vivid.RGBA.init(0, 0, 0, 0)
  """
  @spec background_colour(Frame.t()) :: RGBA.t()
  def background_colour(%Frame{background_colour: c}), do: c

  @doc """
  Return how many samples per pixel, on each axis, the `frame` is rendered with.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.samples
      1
  """
  @spec samples(Frame.t()) :: pos_integer()
  def samples(%Frame{samples: s}), do: s

  @doc ~S"""
  Render the `frame` with `samples` samples per pixel on each axis.

  Shapes are rasterized at `samples` times the frame's size, and each pixel takes
  its alpha from the proportion of its samples the shape covered. That's what
  softens the stepping on any edge which isn't horizontal or vertical.

  One sample per pixel - the default - is the aliased rendering this library has
  always done, and costs nothing extra. Anything higher costs `samples` squared
  as much rasterization, so 2 costs four times and 4 sixteen times.

  Shapes which approximate a curve with straight lines - `Vivid.Circle`,
  `Vivid.Arc`, `Vivid.Bezier`, and the glyphs of an outline font - choose how
  finely to do that from their nominal size, before they know they're being
  sampled. Sampling magnifies the line segments they already had rather than
  smoothing them into a curve, so raise their step count too if the flat spots
  show.

  ## Examples

  A diagonal line at the default one sample per pixel, stepping between rows.

      iex> use Vivid
      ...> line = Line.init(Point.init(0, 0), Point.init(11, 5))
      ...> Frame.init(12, 6, RGBA.white())
      ...> |> Frame.push(line, RGBA.black())
      ...> |> to_string()
      "@@@@@@@@@@  \n" <>
      "@@@@@@@@  @@\n" <>
      "@@@@@@  @@@@\n" <>
      "@@@@  @@@@@@\n" <>
      "@@  @@@@@@@@\n" <>
      "  @@@@@@@@@@\n"

  The same line with four samples per pixel. The ASCII renderer maps luminance
  onto ten characters, so partly covered pixels come out as the ones in between.

      iex> use Vivid
      ...> line = Line.init(Point.init(0, 0), Point.init(11, 5))
      ...> Frame.init(12, 6, RGBA.white())
      ...> |> Frame.push(line, RGBA.black())
      ...> |> Frame.samples(4)
      ...> |> to_string()
      "@@@@@@@@@@%%\n" <>
      "@@@@@@@@%+*@\n" <>
      "@@@@@@#+*@@@\n" <>
      "@@@@*+#@@@@@\n" <>
      "@@++%@@@@@@@\n" <>
      "++@@@@@@@@@@\n"
  """
  @spec samples(Frame.t(), pos_integer()) :: Frame.t()
  def samples(%Frame{} = frame, samples) when is_integer(samples) and samples > 0,
    do: %{frame | samples: samples}

  @doc """
  Change the background `colour` of the `frame`.

  ## Example

      iex> Vivid.Frame.init(80,25)
      ...> |> Vivid.Frame.background_colour(Vivid.RGBA.white)
      ...> |> Vivid.Frame.background_colour
      Vivid.RGBA.init(1, 1, 1, 1)
  """
  @spec background_colour(Frame.t(), RGBA.t()) :: Frame.t()
  def background_colour(%Frame{} = frame, %RGBA{} = colour),
    do: %{frame | background_colour: colour}

  @doc """
  Render a `frame` into a buffer for display horizontally.

  Returns a one-dimensional List of `RGBA` colours with alpha-compositing
  completed.
  """
  @spec buffer(Frame.t()) :: Buffer.t()
  def buffer(%Frame{} = frame), do: Buffer.horizontal(frame)

  @doc """
  Render a `frame` into a buffer for display.

  You can specify either `:horizontal` or `:vertical` mode, where in
  `:horizontal` mode the buffer is rendered row-by-row then column-by-column
  and in `:vertical` mode the buffer is rendered column-by-column then
  row-by-row.

  Returns a one-dimensional List of `RGBA` colours with alpha-compositing
  completed.
  """
  @spec buffer(Frame.t(), :horizontal | :vertical) :: Buffer.t()
  def buffer(%Frame{} = frame, :horizontal), do: Buffer.horizontal(frame)
  def buffer(%Frame{} = frame, :vertical), do: Buffer.vertical(frame)
end
