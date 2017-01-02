defimpl String.Chars, for: Vivid.Frame do
  alias Vivid.Frame

  def to_string(%Frame{}=frame) do
    frame
    |> Frame.buffer
    |> Kernel.to_string
  end
end