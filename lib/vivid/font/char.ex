defmodule Vivid.Font.Char do
  alias __MODULE__
  alias Vivid.{Group, Path, Point}
  defstruct ~w(character vertices left_pos right_pos coordinates)a

  @moduledoc """
  Describes an individual character defined by a Hershey font file.
  """

  @opaque t :: %Char{}

  @doc """
  Returns the (documented) width of a specific character.
  This is not the maximum width of the character, as some go beyond or don't reach their documented bounds.
  I assume this is for kerning. I may be wrong.
  """
  @spec width(Char.t, number) :: number
  def width(%Char{left_pos: l, right_pos: r}, scale \\ 1.0), do: round((abs(l) + abs(r)) * scale)

  @spec left_pad(Char.t, number) :: number
  def left_pad(%Char{left_pos: l}, scale \\ 1.0), do: round(abs(l) * scale)

  @spec right_pad(Char.t, number) :: number
  def right_pad(%Char{right_pos: r}, scale \\ 1.0), do: round(abs(r) * scale)

  @doc """
  Rendered width of a character.
  """
  @spec rendered_width(Char.t, number) :: number
  def rendered_width(%Char{} = char, scale \\ 1.0), do: rendered_dimension(char, scale, 0)

  @doc """
  Rendered height of a character.
  """
  @spec rendered_height(Char.t, number) :: number
  def rendered_height(%Char{} = char, scale \\ 1.0), do: rendered_dimension(char, scale, 1)

  @doc """
  Convert a %Char{} into a shape which can be rendered.

  * `char` is a `%Char{}` struct.
  * `center` the center `%Point{}` around which to render the character.
  * `scale` how much to scale the character by.
  """
  @spec to_shape(Char.t, Point.t, number) :: Shape.t
  def to_shape(%Char{coordinates: coords}, %Point{} = center, scale \\ 1.0) do
    x_center = center |> Point.x
    y_center = center |> Point.y
    coords
    |> Enum.reduce([[]], fn
      :pen_up, acc -> [[] | acc]
      {x,y}, [last | rest] ->
        x = round(x_center + (x * scale))
        y = round(y_center + (y * scale))
        [[Point.init(x,y) | last] | rest]
      end)
    |> Enum.map(&Path.init(&1))
    |> Group.init
  end

  defp rendered_dimension(%Char{coordinates: coords}, scale, i) do
    coords = coords
      |> Enum.reject(fn c -> c == :pen_up end)
      |> Enum.map(&elem(&1, i))

    if coords == [] do
      0
    else
      max = coords |> Enum.max
      min = coords |> Enum.min
      round((max - min) * scale)
    end
  end
end
