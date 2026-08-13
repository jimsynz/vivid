defmodule Vivid.TrueType.Glyph do
  alias Vivid.{Bezier, Point, Polygon, Region, TrueType.Glyph}
  import Bitwise
  defstruct ~w(index advance outlines)a

  @on_curve 0x01
  @x_short 0x02
  @y_short 0x04
  @repeat 0x08
  @same_x 0x10
  @same_y 0x20

  @args_are_words 0x0001
  @args_are_xy 0x0002
  @have_scale 0x0008
  @more_components 0x0020
  @have_x_and_y_scale 0x0040
  @have_two_by_two 0x0080

  @curve_steps 8
  @max_component_depth 8

  @moduledoc """
  A single glyph read from a font's `glyf` table.

  A glyph holds the slice of `glyf` describing it rather than its parsed
  outlines, so that loading a font doesn't pay to expand thousands of glyphs
  which will never be drawn. Slices are sub-binaries, which the runtime shares
  with the font they were read from rather than copying.

  It carries the whole table's slices, not only its own, because a composite
  glyph - which is what every accented character is - is described in terms of
  other glyphs, and needs to find them at the point it's drawn.

  Coordinates are in font units, and `Vivid.Font.line/3` supplies the multiplier
  which turns them into pixels.
  """

  @type t :: %Glyph{
          index: non_neg_integer,
          advance: number,
          outlines: %{non_neg_integer => binary}
        }

  @doc """
  Initialize a glyph.

  * `index` this glyph's index in the font.
  * `advance` how far the pen moves after drawing it, in font units.
  * `outlines` every glyph slice in the font's `glyf` table, keyed by index.
  """
  @spec init(non_neg_integer, number, %{non_neg_integer => binary}) :: Glyph.t()
  def init(index, advance, outlines)
      when is_integer(index) and is_number(advance) and is_map(outlines),
      do: %Glyph{index: index, advance: advance, outlines: outlines}

  @doc """
  Returns how far the pen advances after drawing `glyph`, in font units.

  ## Example

      iex> Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf"))
      ...> |> Vivid.Font.glyph(?l)
      ...> |> Vivid.TrueType.Glyph.advance()
      497
  """
  @spec advance(Glyph.t()) :: number
  def advance(%Glyph{advance: advance} = _glyph), do: advance

  @doc """
  Returns the contours of `glyph` as lists of points in font units, with any
  curves already flattened into line segments.

  ## Examples

  `l` is a single straight-sided contour.

      iex> Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf"))
      ...> |> Vivid.Font.glyph(?l)
      ...> |> Vivid.TrueType.Glyph.contours()
      ...> |> Enum.count()
      1

  `o` is two: the outside, and the counter inside it wound the other way.

      iex> Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf"))
      ...> |> Vivid.Font.glyph(?o)
      ...> |> Vivid.TrueType.Glyph.contours()
      ...> |> Enum.count()
      2

  A space has none at all.

      iex> Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf"))
      ...> |> Vivid.Font.glyph(?\\s)
      ...> |> Vivid.TrueType.Glyph.contours()
      []
  """
  @spec contours(Glyph.t()) :: [[Point.t()]]
  def contours(%Glyph{index: index, outlines: outlines} = _glyph),
    do: outline_contours(index, outlines, 0)

  @doc """
  Converts `glyph` into a `Vivid.Region` in font units, one contour per contour.

  ## Example

      iex> Vivid.OpenType.load!(Path.join(:code.priv_dir(:vivid), "fonts/roboto-subset.ttf"))
      ...> |> Vivid.Font.glyph(?o)
      ...> |> Vivid.TrueType.Glyph.to_region()
      ...> |> Vivid.Region.contours()
      ...> |> Enum.count()
      2
  """
  @spec to_region(Glyph.t()) :: Region.t()
  def to_region(%Glyph{} = glyph) do
    glyph
    |> contours()
    |> Enum.map(&Polygon.init(&1))
    |> Region.init()
  end

  defp outline_contours(index, outlines, depth) when depth <= @max_component_depth do
    case Map.get(outlines, index) do
      <<count::16-signed, _bounds::binary-size(8), data::binary>> when count > 0 ->
        simple_contours(count, data)

      <<count::16-signed, _bounds::binary-size(8), data::binary>> when count < 0 ->
        composite_contours(data, outlines, depth)

      _empty_or_missing ->
        []
    end
  end

  defp outline_contours(_index, _outlines, _depth), do: []

  defp simple_contours(count, data) do
    case end_points(count, data) do
      {:ok, end_points, data} ->
        {flags, data} = flags(data, List.last(end_points) + 1)
        {xs, data} = coordinates(data, flags, @x_short, @same_x)
        {ys, _data} = coordinates(data, flags, @y_short, @same_y)

        [xs, ys, Enum.map(flags, &((&1 &&& @on_curve) != 0))]
        |> Enum.zip()
        |> split(end_points)
        |> Enum.map(&spline(&1))
        |> Enum.reject(&(&1 == []))

      :error ->
        []
    end
  end

  defp end_points(count, data) when byte_size(data) >= count * 2 + 2 do
    end_points = for <<point::16 <- binary_part(data, 0, count * 2)>>, do: point
    <<instructions::16>> = binary_part(data, count * 2, 2)
    skip = count * 2 + 2 + instructions

    if byte_size(data) >= skip,
      do: {:ok, end_points, binary_part(data, skip, byte_size(data) - skip)},
      else: :error
  end

  defp end_points(_count, _data), do: :error

  defp flags(data, count), do: flags(data, count, [])

  defp flags(data, 0, acc), do: {Enum.reverse(acc), data}

  defp flags(<<flag::8, repeat::8, rest::binary>>, count, acc)
       when (flag &&& @repeat) != 0 do
    taken = min(repeat + 1, count)
    flags(rest, count - taken, List.duplicate(flag, taken) ++ acc)
  end

  defp flags(<<flag::8, rest::binary>>, count, acc), do: flags(rest, count - 1, [flag | acc])

  defp flags(<<>>, count, acc), do: {Enum.reverse(List.duplicate(0, count) ++ acc), <<>>}

  defp coordinates(data, flags, short, same) do
    {deltas, data} =
      Enum.reduce(flags, {[], data}, fn flag, {deltas, data} ->
        {delta, data} = delta(data, flag, short, same)
        {[delta | deltas], data}
      end)

    {deltas |> Enum.reverse() |> Enum.scan(0, &(&1 + &2)), data}
  end

  defp delta(<<value::8, rest::binary>>, flag, short, same) when (flag &&& short) != 0,
    do: {if((flag &&& same) != 0, do: value, else: -value), rest}

  defp delta(data, flag, _short, same) when (flag &&& same) != 0, do: {0, data}

  defp delta(<<value::16-signed, rest::binary>>, _flag, _short, _same), do: {value, rest}

  defp delta(data, _flag, _short, _same), do: {0, data}

  defp split(points, end_points) do
    end_points
    |> Enum.reduce({[], 0, points}, fn last, {contours, first, remaining} ->
      {contour, remaining} = Enum.split(remaining, last - first + 1)
      {[contour | contours], last + 1, remaining}
    end)
    |> elem(0)
    |> Enum.reverse()
  end

  defp spline([]), do: []

  defp spline(points) do
    case Enum.find_index(points, fn {_x, _y, on_curve} -> on_curve end) do
      nil ->
        {x, y, _} = midpoint(List.last(points), hd(points))
        walk(points ++ [{x, y, true}], Point.init(x, y), [Point.init(x, y)])

      index ->
        [{x, y, _} | _] = rotated = rotate(points, index)
        walk(tl(rotated) ++ [{x, y, true}], Point.init(x, y), [Point.init(x, y)])
    end
  end

  defp walk([], _from, acc), do: Enum.reverse(acc)

  defp walk([{x, y, true} | rest], _from, acc),
    do: walk(rest, Point.init(x, y), [Point.init(x, y) | acc])

  defp walk([{cx, cy, false}, {x, y, true} | rest], from, acc) do
    to = Point.init(x, y)
    walk(rest, to, curve(from, Point.init(cx, cy), to) ++ acc)
  end

  defp walk([{cx, cy, false} = control, {_, _, false} = next | rest], from, acc) do
    {mx, my, _} = midpoint(control, next)
    to = Point.init(mx, my)
    walk([next | rest], to, curve(from, Point.init(cx, cy), to) ++ acc)
  end

  defp walk([{cx, cy, false}], from, acc) do
    to = Point.init(cx, cy)
    walk([], to, curve(from, Point.init(cx, cy), to) ++ acc)
  end

  defp curve(from, control, to) do
    [from, control, to]
    |> Bezier.init(@curve_steps)
    |> Bezier.to_path()
    |> Enum.to_list()
    |> tl()
    |> Enum.reverse()
  end

  defp midpoint({x0, y0, _}, {x1, y1, _}), do: {(x0 + x1) / 2, (y0 + y1) / 2, true}

  defp rotate(points, index) do
    {before, rest} = Enum.split(points, index)
    rest ++ before
  end

  defp composite_contours(data, outlines, depth),
    do: composite_contours(data, outlines, depth, [])

  defp composite_contours(<<flags::16, index::16, rest::binary>>, outlines, depth, acc) do
    {offset, rest} = component_offset(rest, flags)
    {transform, rest} = component_transform(rest, flags)

    contours =
      index
      |> outline_contours(outlines, depth + 1)
      |> Enum.map(&transform_contour(&1, transform, offset))

    if (flags &&& @more_components) != 0 do
      composite_contours(rest, outlines, depth, contours ++ acc)
    else
      Enum.reverse(contours ++ acc)
    end
  end

  defp composite_contours(_data, _outlines, _depth, acc), do: Enum.reverse(acc)

  defp component_offset(<<x::16-signed, y::16-signed, rest::binary>>, flags)
       when (flags &&& @args_are_words) != 0 and (flags &&& @args_are_xy) != 0,
       do: {{x, y}, rest}

  defp component_offset(<<x::8-signed, y::8-signed, rest::binary>>, flags)
       when (flags &&& @args_are_words) == 0 and (flags &&& @args_are_xy) != 0,
       do: {{x, y}, rest}

  defp component_offset(<<_::32, rest::binary>>, flags)
       when (flags &&& @args_are_words) != 0,
       do: {{0, 0}, rest}

  defp component_offset(<<_::16, rest::binary>>, _flags), do: {{0, 0}, rest}

  defp component_offset(data, _flags), do: {{0, 0}, data}

  defp component_transform(
         <<a::16-signed, b::16-signed, c::16-signed, d::16-signed, rest::binary>>,
         flags
       )
       when (flags &&& @have_two_by_two) != 0,
       do: {{f2dot14(a), f2dot14(b), f2dot14(c), f2dot14(d)}, rest}

  defp component_transform(<<a::16-signed, d::16-signed, rest::binary>>, flags)
       when (flags &&& @have_x_and_y_scale) != 0,
       do: {{f2dot14(a), 0.0, 0.0, f2dot14(d)}, rest}

  defp component_transform(<<a::16-signed, rest::binary>>, flags)
       when (flags &&& @have_scale) != 0,
       do: {{f2dot14(a), 0.0, 0.0, f2dot14(a)}, rest}

  defp component_transform(data, _flags), do: {{1.0, 0.0, 0.0, 1.0}, data}

  defp f2dot14(value), do: value / 16_384

  defp transform_contour(contour, {a, b, c, d}, {dx, dy}) do
    Enum.map(contour, fn point ->
      x = Point.x(point)
      y = Point.y(point)
      Point.init(a * x + c * y + dx, b * x + d * y + dy)
    end)
  end
end
