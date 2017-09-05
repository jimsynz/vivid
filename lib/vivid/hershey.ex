defmodule Vivid.Hershey do
  require Logger
  alias Vivid.Font.Char
  @mid_point 'R' |> List.first

  @moduledoc """
  Supports reading the Hershey Vector Font format and converting them into paths.
  """

  @doc """
  Returns a map of "character IDs" to %Char{} structs, which can
  be passed to `char_to_shape` to turn into renderable shapes.
  """
  @spec definitions(String.t) :: Enumerable.t
  def definitions(file) do
    file
    |> get_path
    |> File.stream!
    |> Stream.transform(nil, &fix_wrapped_lines(&1, &2))
    |> Stream.map(&parse_line(&1))
  end

  defp fix_wrapped_lines(next, nil), do: {[], String.replace(next, ~r/[\r\n]+/, "")}
  defp fix_wrapped_lines(next, last) do
    next = next |> String.replace(~r/[\n\r]+/, "")
    if Regex.match?(~r/^\ *[0-9]+/, next) do
      {[last], next}
    else
      next = last <> next
      {[], next}
    end
  end

  defp parse_line(<< char::binary-size(5), vertices::binary-size(3), l_pos::binary-size(1), r_pos::binary-size(1), coords::binary >>) do
    char     = char |> String.trim_leading |> String.to_integer
    vertices = vertices |> String.trim_leading |> String.to_integer
    l_pos    = l_pos |> String.to_charlist |> List.first
    r_pos    = r_pos |> String.to_charlist |> List.first
    coords   = parse_coords([], coords)

    %Char{
      character:   char,
      vertices:    vertices,
      left_pos:    l_pos - @mid_point,
      right_pos:   r_pos - @mid_point,
      coordinates: coords
    }
  end

  defp parse_coords(parsed, ""), do: parsed |> Enum.reverse
  defp parse_coords(parsed, " R" <> rest), do: parse_coords([:pen_up | parsed], rest)
  defp parse_coords(parsed, << xy::binary-size(2), rest::binary >>) do
    [y, x] = xy |> String.to_charlist
    normalized_x = @mid_point - x
    normalized_y = y - @mid_point
    parse_coords([{normalized_y, normalized_x} | parsed], rest)
  end

  defp get_path(file) do
    priv_dir()
    |> Path.join("hershey")
    |> Path.join("#{file}.jhf")
  end

  defp priv_dir do
    :vivid
    |> :code.priv_dir
    |> List.to_string
  end
end
