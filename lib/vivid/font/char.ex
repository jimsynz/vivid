defmodule Vivid.Font.Char do
  alias __MODULE__
  alias Vivid.{Group, Path, Point}
  defstruct ~w(character vertices left_pos right_pos coordinates)a

  @doc """
  Returns the (documented) width of a specific character.
  This is not the maximum width of the character, as some go beyond or don't reach their documented bounds.
  I assume this is for kerning. I may be wrong.
  """
  def width(%Char{left_pos: l, right_pos: r}, scale \\ 1.0), do: (r - l) * scale |> round

  @doc """
  Rendered width of a character.
  """
  def rendered_width(%Char{}=char, scale \\ 1.0), do: rendered_dimension(char, scale, 0)

  @doc """
  Rendered height of a character.
  """
  def rendered_height(%Char{}=char, scale \\ 1.0), do: rendered_dimension(char, scale, 1)

  @doc """
  Convert a %Char{} into a shape which can be rendered.

  * `char` is a `%Char{}` struct.
  * `center` the center `%Point{}` around which to render the character.
  * `scale` how much to scale the character by.
  """
  def to_shape(%Char{coordinates: coords}, %Point{}=center, scale \\ 1.0) do
    x_center = center |> Point.x
    y_center = center |> Point.y
    coords
    |> Enum.reduce([[]], fn
      :pen_up, acc -> [[] | acc]
      {x,y}, [last | rest] ->
        x = x_center + (x * scale) |> round
        y = y_center + (y * scale) |> round
        [[ Point.init(x,y) | last] | rest]
      end)
    |> Enum.map(&Path.init(&1))
    |> Group.init
  end

  defp rendered_dimension(%Char{coordinates: coords}, scale, i) do
    coords = coords
      |> Enum.reject(fn c -> c == :pen_up end)
      |> Enum.map(&elem(&1, i))

    if (coords == []) do
      0
    else
      max = coords |> Enum.max
      min = coords |> Enum.min
      (max - min) * scale |> round
    end
  end
end
