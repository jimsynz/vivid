defmodule Vivid.Math do
  @moduledoc """
  I made this because I was constantly importing a small selection of
  Erlang's `:math` module, and then manually implementing
  `degrees_to_radians/1` which got pretty annoying after a while.
  """

  defdelegate pi(), to: :math
  defdelegate cos(x), to: :math
  defdelegate sin(x), to: :math
  defdelegate pow(x,y), to: :math
  defdelegate sqrt(x), to: :math

  @doc """
  Convert degrees into radians.

  ## Examples:

      iex> 180 |> Vivid.Math.degrees_to_radians
      :math.pi
  """
  def degrees_to_radians(degrees), do: degrees / 360.0 * 2.0 * pi
end