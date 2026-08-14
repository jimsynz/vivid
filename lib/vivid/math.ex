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
  defdelegate pow(x, y), to: :math

  @doc """
  Delegates to `:math.sqrt/1`.
  """
  defdelegate sqrt(x), to: :math

  @doc ~S"""
  Round a tensor to the nearest integer, with ties going away from zero.

  `Nx.round/1` does not specify which way it breaks a tie, and the backends
  disagree: `Nx.BinaryBackend` and EXLA round away from zero, matching
  `Kernel.round/1`, while Torchx rounds to even, so `2.5` comes back as `2`.
  Pixel coordinates and colour channels are rounded all over this library and a
  tie is not rare, so relying on that would make a rendering depend on which
  backend drew it.

  ## Examples

      iex> Nx.tensor([0.5, 1.5, 2.5, -0.5, -2.5])
      ...> |> Vivid.Math.round_half_away()
      ...> |> Nx.to_flat_list()
      [1.0, 2.0, 3.0, -1.0, -3.0]
  """
  @spec round_half_away(Nx.Tensor.t()) :: Nx.Tensor.t()
  def round_half_away(tensor) do
    tensor
    |> Nx.abs()
    |> Nx.add(0.5)
    |> Nx.floor()
    |> Nx.multiply(Nx.sign(tensor))
  end

  @doc """
  Convert degrees into radians.

  ## Examples:

      iex> 180 |> Vivid.Math.degrees_to_radians
      :math.pi
  """
  @spec degrees_to_radians(number) :: float
  def degrees_to_radians(degrees), do: degrees / 180.0 * pi()
end
