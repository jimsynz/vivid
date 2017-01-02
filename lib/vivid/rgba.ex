defmodule Vivid.RGBA do
  alias __MODULE__
  import :math, only: [pow: 2]
  defstruct ~w(red green blue alpha a_red a_green a_blue)a
  @ascii_luminance_map {" ", ".", ":", "-", "=", "+", "*", "#", "%", "@"}
  @ascii_luminance_map_length 10

  @moduledoc """
  Defines a colour in RGBA colour space.
  """

  @doc """
  Create a colour. Like magic.

  ## Example

      iex> Vivid.RGBA.init(0.1, 0.2, 0.3, 0.4)
      #Vivid.RGBA<{0.1, 0.2, 0.3, 0.4}>
  """

  def init(red, green, blue), do: init(red, green, blue, 1)

  def init(red, green, blue, 1)
  when is_number(red) and is_number(green) and is_number(blue)
   and red >= 0 and red <= 1
   and green >= 0 and green <= 1
   and blue >= 0 and blue <= 1
  do
    %RGBA{
      red:     red,
      green:   green,
      blue:    blue,
      alpha:   1,
      a_red:   red,
      a_green: green,
      a_blue:  blue
    }
  end

  def init(red, green, blue, 0)
  when is_number(red) and is_number(green) and is_number(blue)
   and red >= 0 and red <= 1
   and green >= 0 and green <= 1
   and blue >= 0 and blue <= 1
 do
    %RGBA{
      red:     red,
      green:   green,
      blue:    blue,
      alpha:   0,
      a_red:   0,
      a_green: 0,
      a_blue:  0
    }
  end

  def init(red, green, blue, alpha)
  when is_number(red) and is_number(green) and is_number(blue) and is_number(alpha)
   and red >= 0 and red <= 1
   and green >= 0 and green <= 1
   and blue >= 0 and blue <= 1
   and alpha >= 0 and alpha <= 1
  do
    %RGBA{
      red:     red,
      green:   green,
      blue:    blue,
      alpha:   alpha,
      a_red:   red   * alpha,
      a_green: green * alpha,
      a_blue:  blue  * alpha
    }
  end

  @doc """
  Shorthand for white.

  ## Example

      iex> Vivid.RGBA.white
      #Vivid.RGBA<{1, 1, 1, 1}>
  """
  def white, do: RGBA.init(1,1,1)

  @doc """
  Shorthand for black.

  ## Example

      iex> Vivid.RGBA.black
      #Vivid.RGBA<{0, 0, 0, 1}>
  """
  def black, do: RGBA.init(0,0,0)

  @doc """
  Return the red component of the colour.

  ## Example

      iex> Vivid.RGBA.init(0.7, 0.6, 0.5, 0.4)
      ...> |> Vivid.RGBA.red
      0.7
  """
  def red(%RGBA{red: r}),     do: r

  @doc """
  Return the green component of the colour.

  ## Example

      iex> Vivid.RGBA.init(0.7, 0.6, 0.5, 0.4)
      ...> |> Vivid.RGBA.green
      0.6
  """
  def green(%RGBA{green: g}), do: g

  @doc """
  Return the blue component of the colour.

  ## Example

      iex> Vivid.RGBA.init(0.7, 0.6, 0.5, 0.4)
      ...> |> Vivid.RGBA.blue
      0.5
  """
  def blue(%RGBA{blue: b}),   do: b

  @doc """
  Return the alpha component of the colour.

  ## Example

      iex> Vivid.RGBA.init(0.7, 0.6, 0.5, 0.4)
      ...> |> Vivid.RGBA.alpha
      0.4
  """
  def alpha(%RGBA{alpha: a}), do: a

  @doc """
  Convert a colour to HTML style hex.

  ## Example

      iex> Vivid.RGBA.init(0.7, 0.6, 0.5)
      ...> |> Vivid.RGBA.to_hex
      "#B39980"
  """
  def to_hex(%RGBA{red: r, green: g, blue: b, alpha: 1}) do
    r = r |> f2h
    g = g |> f2h
    b = b |> f2h
    "#" <> r <> g <> b
  end

  def to_hex(%RGBA{red: r, green: g, blue: b, alpha: a}) do
    r = r |> f2h
    g = g |> f2h
    b = b |> f2h
    a = a |> f2h
    "#" <> r <> g <> b <> a
  end

  @doc """
  Blend two colours together using their alpha information using the "over" algorithm.

  ## Examples

      iex> Vivid.RGBA.over(Vivid.RGBA.black, Vivid.RGBA.init(1,1,1, 0.5))
      #Vivid.RGBA<{0.5, 0.5, 0.5, 1.0}>
  """

  def over(nil, %RGBA{}=colour), do: colour
  def over(%RGBA{}, %RGBA{alpha: 1}=visible), do: visible
  def over(%RGBA{}=visible, %RGBA{alpha: 0}), do: visible
  def over(%RGBA{a_red: r0, a_green: g0, a_blue: b0, alpha: a0}, %RGBA{a_red: r1, a_green: g1, a_blue: b1, alpha: a1}) do
    a = a0 + a1 * (1 - a0)

    [r, g, b] = [{r0, r1}, {g0, g1}, {b0, b1}]
      |> Enum.map(fn {c0, c1}-> c1 + c0 * (1 - a1) end)

    RGBA.init(r, g, b, a)
  end

  @doc """
  Return the luminance of a colour, using some colour mixing ratios I found
  on stack exchange.

  ## Examples

      iex> Vivid.RGBA.init(1,0,0) |> Vivid.RGBA.luminance
      0.2128

      iex> Vivid.RGBA.white |> Vivid.RGBA.luminance
      1.0

      iex> Vivid.RGBA.black |> Vivid.RGBA.luminance
      0.0
  """
  def luminance(%RGBA{a_red: r, a_green: g, a_blue: b}) do
    [rl, gl, bl] = [r, g, b ] |> Enum.map(&pow(&1, 2.2))
    0.2128 * rl + 0.7150 * gl + 0.0722 * bl
  end

  def to_ascii(%RGBA{}=colour) do
    l = luminance(colour)
    c = l * (@ascii_luminance_map_length - 1) |> round
    elem(@ascii_luminance_map, c)
  end

  defp f2h(f) do
    h = f * 0xff
      |> round
      |> Integer.to_string(16)

    case h |> String.length do
      1 -> "0" <> h
      2 -> h
    end
  end

end