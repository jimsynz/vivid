defimpl Vivid.Font.Glyph, for: Vivid.Font.Char do
  alias Vivid.Font.Char

  @moduledoc """
  Lays out a Hershey glyph.

  Hershey glyphs carry their own left and right padding, which is what the
  format provides in place of an advance width.
  """

  @doc """
  Returns the left padding of `char`, scaled by `scale`.
  """
  @impl true
  def left_pad(char, scale), do: Char.left_pad(char, scale)

  @doc """
  Returns the right padding of `char`, scaled by `scale`.
  """
  @impl true
  def right_pad(char, scale), do: Char.right_pad(char, scale)

  @doc """
  Converts `char` into a `Vivid.Group` of paths, one per pen stroke.
  """
  @impl true
  def to_shape(char, center, scale), do: Char.to_shape(char, center, scale)
end
