defmodule Vivid.Font do
  alias Vivid.{Point, Group}
  alias Vivid.Font.Char

  @font_vertical_offset 10

  def line(str, scale \\ 1.0) do
    font = rowmans
    str
      |> String.split("")
      |> Stream.reject(fn c -> c == "" end)
      |> Enum.reduce([], fn
        letter, [] ->
          char = Map.get(font, letter)
          lpad = Char.left_pad(char, scale)
          [{char, lpad}]
        letter, [{lchar, lpad} | _]=letters ->
          char = Map.get(font, letter)
          lpad =
            Char.left_pad(char, scale) +
            Char.right_pad(lchar, scale) +
            lpad
          [{char, lpad} | letters]
      end)
      |> Enum.map(fn {char, lpad} -> Char.to_shape(char, Point.init(@font_vertical_offset, lpad), scale) end)
      |> Enum.into(Group.init)
  end

  def rowmans do
    [
      " ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "↑", ".",
      "/", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">",
      "?", "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
      "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "↑",
      "-", "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
      "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", "|", "}", "~"
    ]
    |> Enum.zip(font("rowmans"))
    |> Enum.into(%{})
  end

  defp font(name) do
    name
    |> Vivid.Hershey.definitions
    |> Enum.to_list
  end
end