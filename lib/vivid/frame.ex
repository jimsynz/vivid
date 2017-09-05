defmodule Vivid.Frame do
  alias Vivid.{Frame, RGBA, Buffer, Shape}
  defstruct ~w(width height background_colour shapes)a

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

  @opaque t :: %Frame{width: integer, height: integer,
                      background_colour: RGBA.t, shapes: []}

  @doc """
  Initialize a frame buffer.

  * `width` the width of the frame, in pixels.
  * `height` the height of the frame, in pixels.
  * `colour` the default colour of the frame.

  ## Example

      iex> Vivid.Frame.init(4, 4)
      #Vivid.Frame<[width: 4, height: 4, background_colour: #Vivid.RGBA<{0, 0, 0, 0}>]>
  """
  @spec init(integer(), integer(), Range.t) :: Frame.t
  def init(width \\ 128, height \\ 64, %RGBA{} = colour \\ RGBA.init(0, 0, 0, 0))
  when is_integer(width) and is_integer(height) and width > 0 and height > 0
  do
    %Frame{width: width, height: height, background_colour: colour, shapes: []}
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
  @spec push(Frame.t, Shape.t, RGBA.t) :: Frame.t
  def push(%Frame{shapes: shapes} = frame, shape, colour) do
    %{frame | shapes: [{shape, colour} | shapes]}
  end

  @doc """
  Clear the `frame` of any shapes.
  """
  @spec clear(Frame.t) :: Frame.t
  def clear(%Frame{} = frame) do
    %{frame | shapes: []}
  end

  @doc """
  Return the width of the `frame`.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.width
      80
  """
  @spec width(Frame.t) :: integer()
  def width(%Frame{width: w}), do: w

  @doc """
  Return the height of the `frame`.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.height
      25
  """
  @spec height(Frame.t) :: integer()
  def height(%Frame{height: h}), do: h

  @doc """
  Return the background colour of the `frame`.

  ## Example

      iex> Vivid.Frame.init(80, 25) |> Vivid.Frame.background_colour
      #Vivid.RGBA<{0, 0, 0, 0}>
  """
  @spec background_colour(Frame.t) :: RGBA.t
  def background_colour(%Frame{background_colour: c}), do: c

  @doc """
  Change the background `colour` of the `frame`.

  ## Example

      iex> Vivid.Frame.init(80,25)
      ...> |> Vivid.Frame.background_colour(Vivid.RGBA.white)
      ...> |> Vivid.Frame.background_colour
      #Vivid.RGBA<{1, 1, 1, 1}>
  """
  @spec background_colour(Frame.t, RGBA.t) :: Frame.t
  def background_colour(%Frame{} = frame, %RGBA{} = colour), do: %{frame | background_colour: colour}

  @doc """
  Render a `frame` into a buffer for display horizontally.

  Returns a one-dimensional List of `RGBA` colours with alpha-compositing
  completed.
  """
  @spec buffer(Frame.t) :: [RGBA.t]
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
  @spec buffer(Frame.t, :horizontal | :vertical) :: [RGBA.t]
  def buffer(%Frame{} = frame, :horizontal), do: Buffer.horizontal(frame)
  def buffer(%Frame{} = frame, :vertical),   do: Buffer.vertical(frame)
end
