defimpl String.Chars, for: Vivid.Buffer do
  alias Vivid.{Buffer, RGBA}

  @doc """
  Convert a `buffer` into a `string` for `IO.puts`, etc.
  """
  @spec to_string(Buffer.t) :: String.t
  def to_string(%Buffer{buffer: buffer, columns: columns} = _buffer) do
    s = buffer
      |> Enum.reverse
      |> Enum.chunk(columns)
      |> Enum.map(fn (row) ->
        row
        |> Enum.reverse
        |> Enum.map(&RGBA.to_ascii(&1))
        |> Enum.join
      end)
      |> Enum.join("\n")
    s <> "\n"
  end
end
