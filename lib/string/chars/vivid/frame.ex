defimpl String.Chars, for: Vivid.Frame do
  alias Vivid.Frame

  @spec to_string(Frame.t) :: String.t
  def to_string(%Frame{} = frame) do
    frame
    |> Frame.buffer
    |> Kernel.to_string
  end
end
