defimpl String.Chars, for: Vivid.Buffer do
  alias Vivid.Frame

  def to_string(%Frame{}=frame) do
    frame
    |> Frame.buffer
    |> to_string
  end
end