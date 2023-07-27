defimpl String.Chars, for: Vivid.Frame do
  alias Vivid.Frame

  @doc """
  Convert a `frame` into a `string` for `IO.puts`, etc.
  """
  @impl true
  def to_string(%Frame{} = frame) do
    frame
    |> Frame.buffer()
    |> Kernel.to_string()
  end
end
