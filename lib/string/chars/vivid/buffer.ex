defimpl String.Chars, for: Vivid.Buffer do
  alias Vivid.Buffer
  import Vivid.Math, only: [round_half_away: 1]
  @ascii_luminance_map {" ", ".", ":", "-", "=", "+", "*", "#", "%", "@"}
  @ascii_luminance_map_length 10

  @moduledoc """
  Converts a buffer into a string of ASCII art.

  The luminance of every pixel is computed at once and mapped onto the same
  character ramp `Vivid.RGBA.to_ascii/1` uses, which is the one place the whole
  buffer is needed as numbers rather than as colours.
  """

  @doc """
  Convert a `buffer` into a `string` for `IO.puts`, etc.
  """
  @impl true
  def to_string(%Buffer{columns: columns} = buffer) do
    characters =
      buffer
      |> Buffer.luminance()
      |> Nx.reverse(axes: [0])
      |> Nx.multiply(@ascii_luminance_map_length - 1)
      |> round_half_away()
      |> Nx.as_type({:s, 64})
      |> Nx.to_flat_list()
      |> Enum.map(&elem(@ascii_luminance_map, &1))

    characters
    |> Enum.chunk_every(columns)
    |> Enum.map_join("\n", &Enum.join(&1))
    |> Kernel.<>("\n")
  end
end
