defmodule Vivid.CFF.Charstring do
  alias Vivid.{Bezier, Point}

  @moduledoc ~S"""
  Interprets Type 2 charstrings, which is how a CFF font describes a glyph.

  A charstring is a little stack program: operands are pushed, an operator
  consumes them and draws something. Every coordinate is relative to the last
  one, and curves are cubic, unlike TrueType's quadratics.

  Two details account for most of the difficulty. Subroutines - which 92 of the
  94 CFF fonts surveyed on a development machine use - are called by an index
  biased by the size of the subroutine table, so the same call means different
  things in different fonts. And the first stack-clearing operator may carry one
  extra leading operand, the glyph's width; it's recognised by the argument count
  being odd where the operator expects an even number. Widths are ignored here,
  since `hmtx` carries them too and is easier to trust.

  ## Example

  A charstring which moves and draws a triangle: `100 100 rmoveto`, then
  `200 0 0 200 rlineto`, then `endchar`.

      iex> <<239, 239, 21, 247, 92, 139, 139, 247, 92, 5, 14>>
      ...> |> Vivid.CFF.Charstring.contours({}, {})
      [[Vivid.Point.init(100, 100), Vivid.Point.init(300, 100), Vivid.Point.init(300, 300)]]
  """

  @curve_steps 8
  @max_depth 10

  @doc """
  Interpret `charstring`, returning its contours as lists of points.

  * `subrs` the font's local subroutines.
  * `gsubrs` the font's global subroutines.
  """
  @spec contours(binary, tuple, tuple) :: [[Point.t()]]
  def contours(charstring, subrs, gsubrs) do
    state = %{
      x: 0,
      y: 0,
      stack: [],
      contours: [],
      current: [],
      stems: 0,
      subrs: subrs,
      gsubrs: gsubrs,
      depth: 0
    }

    charstring
    |> run(state)
    |> close()
    |> Map.fetch!(:contours)
    |> Enum.reverse()
  end

  defp close(%{current: []} = state), do: state

  defp close(%{current: current, contours: contours} = state),
    do: %{state | contours: [Enum.reverse(current) | contours], current: []}

  defp run(<<>>, state), do: state

  defp run(<<value::8, rest::binary>>, state) when value in 32..246,
    do: run(rest, push(state, value - 139))

  defp run(<<value::8, low::8, rest::binary>>, state) when value in 247..250,
    do: run(rest, push(state, (value - 247) * 256 + low + 108))

  defp run(<<value::8, low::8, rest::binary>>, state) when value in 251..254,
    do: run(rest, push(state, -(value - 251) * 256 - low - 108))

  defp run(<<28::8, value::16-signed, rest::binary>>, state),
    do: run(rest, push(state, value))

  defp run(<<255::8, whole::16-signed, fraction::16, rest::binary>>, state),
    do: run(rest, push(state, whole + fraction / 65_536))

  defp run(<<1::8, rest::binary>>, state), do: run(rest, stems(state))
  defp run(<<3::8, rest::binary>>, state), do: run(rest, stems(state))
  defp run(<<18::8, rest::binary>>, state), do: run(rest, stems(state))
  defp run(<<23::8, rest::binary>>, state), do: run(rest, stems(state))

  defp run(<<19::8, rest::binary>>, state), do: hint_mask(rest, state)
  defp run(<<20::8, rest::binary>>, state), do: hint_mask(rest, state)

  defp run(<<21::8, rest::binary>>, state) do
    [dx, dy] = trailing(state, 2)
    run(rest, state |> close() |> move(dx, dy))
  end

  defp run(<<22::8, rest::binary>>, state) do
    [dx] = trailing(state, 1)
    run(rest, state |> close() |> move(dx, 0))
  end

  defp run(<<4::8, rest::binary>>, state) do
    [dy] = trailing(state, 1)
    run(rest, state |> close() |> move(0, dy))
  end

  defp run(<<5::8, rest::binary>>, state), do: run(rest, lines(state, args(state)))

  defp run(<<6::8, rest::binary>>, state),
    do: run(rest, alternating_lines(state, args(state), :horizontal))

  defp run(<<7::8, rest::binary>>, state),
    do: run(rest, alternating_lines(state, args(state), :vertical))

  defp run(<<8::8, rest::binary>>, state), do: run(rest, curves(state, args(state)))

  defp run(<<24::8, rest::binary>>, state) do
    {curves, line} = Enum.split(args(state), -2)
    run(rest, state |> curves(curves) |> lines(line))
  end

  defp run(<<25::8, rest::binary>>, state) do
    {lines, curve} = Enum.split(args(state), -6)
    run(rest, state |> lines(lines) |> curves(curve))
  end

  defp run(<<26::8, rest::binary>>, state), do: run(rest, vv_curves(state, args(state)))
  defp run(<<27::8, rest::binary>>, state), do: run(rest, hh_curves(state, args(state)))

  defp run(<<30::8, rest::binary>>, state),
    do: run(rest, alternating_curves(state, args(state), :vertical))

  defp run(<<31::8, rest::binary>>, state),
    do: run(rest, alternating_curves(state, args(state), :horizontal))

  defp run(<<10::8, rest::binary>>, state), do: run(rest, call(state, :subrs))
  defp run(<<29::8, rest::binary>>, state), do: run(rest, call(state, :gsubrs))

  defp run(<<11::8, _rest::binary>>, state), do: state
  defp run(<<14::8, _rest::binary>>, state), do: %{state | stack: []}

  defp run(<<12::8, 35::8, rest::binary>>, state) do
    [a1, a2, a3, a4, a5, a6, b1, b2, b3, b4, b5, b6, _fd] = trailing(state, 13)
    run(rest, state |> curves([a1, a2, a3, a4, a5, a6]) |> curves([b1, b2, b3, b4, b5, b6]))
  end

  defp run(<<12::8, 34::8, rest::binary>>, state) do
    [dx1, dx2, dy2, dx3, dx4, dx5, dx6] = trailing(state, 7)

    run(
      rest,
      state
      |> curves([dx1, 0, dx2, dy2, dx3, 0])
      |> curves([dx4, 0, dx5, -dy2, dx6, 0])
    )
  end

  defp run(<<12::8, 36::8, rest::binary>>, state) do
    [dx1, dy1, dx2, dy2, dx3, dx4, dx5, dy5, dx6] = trailing(state, 9)

    run(
      rest,
      state
      |> curves([dx1, dy1, dx2, dy2, dx3, 0])
      |> curves([dx4, 0, dx5, dy5, dx6, -(dy1 + dy2 + dy5)])
    )
  end

  defp run(<<12::8, 37::8, rest::binary>>, state) do
    [dx1, dy1, dx2, dy2, dx3, dy3, dx4, dy4, dx5, dy5, d6] = trailing(state, 11)
    dx = dx1 + dx2 + dx3 + dx4 + dx5
    dy = dy1 + dy2 + dy3 + dy4 + dy5

    {dx6, dy6} = if abs(dx) > abs(dy), do: {d6, -dy}, else: {-dx, d6}

    run(
      rest,
      state
      |> curves([dx1, dy1, dx2, dy2, dx3, dy3])
      |> curves([dx4, dy4, dx5, dy5, dx6, dy6])
    )
  end

  defp run(<<12::8, _operator::8, rest::binary>>, state), do: run(rest, %{state | stack: []})
  defp run(<<_unknown::8, rest::binary>>, state), do: run(rest, %{state | stack: []})

  defp push(%{stack: stack} = state, value), do: %{state | stack: [value | stack]}

  defp args(%{stack: stack}), do: Enum.reverse(stack)

  defp trailing(%{stack: stack}, count), do: stack |> Enum.take(count) |> Enum.reverse()

  defp stems(%{stack: stack, stems: stems} = state),
    do: %{state | stems: stems + div(length(stack), 2), stack: []}

  defp hint_mask(rest, state) do
    %{stems: stems} = state = stems(state)
    skip = div(stems + 7, 8)
    run(binary_slice(rest, skip..-1//1), state)
  end

  defp move(%{x: x, y: y} = state, dx, dy) do
    x = x + dx
    y = y + dy
    %{state | x: x, y: y, stack: [], current: [Point.init(x, y)]}
  end

  defp lines(state, []), do: %{state | stack: []}

  defp lines(%{x: x, y: y, current: current} = state, [dx, dy | rest]) do
    x = x + dx
    y = y + dy
    lines(%{state | x: x, y: y, current: [Point.init(x, y) | current]}, rest)
  end

  defp lines(state, _odd), do: %{state | stack: []}

  defp alternating_lines(state, [], _direction), do: %{state | stack: []}

  defp alternating_lines(%{x: x, y: y, current: current} = state, [delta | rest], :horizontal) do
    x = x + delta

    %{state | x: x, current: [Point.init(x, y) | current]}
    |> alternating_lines(rest, :vertical)
  end

  defp alternating_lines(%{x: x, y: y, current: current} = state, [delta | rest], :vertical) do
    y = y + delta

    %{state | y: y, current: [Point.init(x, y) | current]}
    |> alternating_lines(rest, :horizontal)
  end

  defp curves(state, []), do: %{state | stack: []}

  defp curves(state, [dxa, dya, dxb, dyb, dxc, dyc | rest]),
    do: state |> curve(dxa, dya, dxb, dyb, dxc, dyc) |> curves(rest)

  defp curves(state, _partial), do: %{state | stack: []}

  defp vv_curves(state, args) do
    {dx1, args} = odd_leader(args)
    vv_curves(state, args, dx1)
  end

  defp vv_curves(state, [dya, dxb, dyb, dyc | rest], dx1),
    do: state |> curve(dx1, dya, dxb, dyb, 0, dyc) |> vv_curves(rest, 0)

  defp vv_curves(state, _remaining, _dx1), do: %{state | stack: []}

  defp hh_curves(state, args) do
    {dy1, args} = odd_leader(args)
    hh_curves(state, args, dy1)
  end

  defp hh_curves(state, [dxa, dxb, dyb, dxc | rest], dy1),
    do: state |> curve(dxa, dy1, dxb, dyb, dxc, 0) |> hh_curves(rest, 0)

  defp hh_curves(state, _remaining, _dy1), do: %{state | stack: []}

  defp odd_leader(args) when rem(length(args), 4) == 1, do: {hd(args), tl(args)}
  defp odd_leader(args), do: {0, args}

  defp alternating_curves(state, [dxa, dxb, dyb, dyc, dxd], :horizontal),
    do: state |> curve(dxa, 0, dxb, dyb, dxd, dyc) |> Map.put(:stack, [])

  defp alternating_curves(state, [dya, dxb, dyb, dxc, dyd], :vertical),
    do: state |> curve(0, dya, dxb, dyb, dxc, dyd) |> Map.put(:stack, [])

  defp alternating_curves(state, [dxa, dxb, dyb, dyc | rest], :horizontal),
    do: state |> curve(dxa, 0, dxb, dyb, 0, dyc) |> alternating_curves(rest, :vertical)

  defp alternating_curves(state, [dya, dxb, dyb, dxc | rest], :vertical),
    do: state |> curve(0, dya, dxb, dyb, dxc, 0) |> alternating_curves(rest, :horizontal)

  defp alternating_curves(state, _remaining, _direction), do: %{state | stack: []}

  defp curve(%{x: x, y: y, current: current} = state, dxa, dya, dxb, dyb, dxc, dyc) do
    from = Point.init(x, y)
    first = Point.init(x + dxa, y + dya)
    second = Point.init(Point.x(first) + dxb, Point.y(first) + dyb)
    to = Point.init(Point.x(second) + dxc, Point.y(second) + dyc)

    points =
      [from, first, second, to]
      |> Bezier.init(@curve_steps)
      |> Bezier.to_path()
      |> Enum.to_list()
      |> tl()
      |> Enum.reverse()

    %{state | x: Point.x(to), y: Point.y(to), current: points ++ current}
  end

  defp call(%{depth: depth} = state, _which) when depth >= @max_depth,
    do: %{state | stack: []}

  defp call(%{stack: [index | stack], depth: depth} = state, which) do
    subrs = Map.fetch!(state, which)
    at = trunc(index) + bias(tuple_size(subrs))

    if at >= 0 and at < tuple_size(subrs) do
      returned = run(elem(subrs, at), %{state | stack: stack, depth: depth + 1})
      %{returned | depth: depth}
    else
      %{state | stack: stack}
    end
  end

  defp call(state, _which), do: state

  defp bias(count) when count < 1240, do: 107
  defp bias(count) when count < 33_900, do: 1131
  defp bias(_count), do: 32_768
end
