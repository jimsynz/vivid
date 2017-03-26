defmodule Vivid.Math do
  @moduledoc """
  I made this because I was constantly importing a small selection of
  Erlang's `:math` module, and then manually implementing
  `degrees_to_radians/1` which got pretty annoying after a while.
  """

  @doc """
  Delegates to `:math.pi/0`.
  """
  defdelegate pi(), to: :math

  @doc """
  Delegates to `:math.cos/1`.
  """
  defdelegate cos(x), to: :math

  @doc """
  Delegates to `:math.sin/1`.
  """
  defdelegate sin(x), to: :math

  @doc """
  Delegates to `:math.pow/2`.
  """
  defdelegate pow(x,y), to: :math

  @doc """
  Delegates to `:math.sqrt/1`.
  """
  defdelegate sqrt(x), to: :math

  @doc """
  Convert degrees into radians.

  ## Examples:

      iex> 180 |> Vivid.Math.degrees_to_radians
      :math.pi
  """
  @spec degrees_to_radians(number) :: float
  def degrees_to_radians(degrees), do: degrees / 180.0 * pi()
end
