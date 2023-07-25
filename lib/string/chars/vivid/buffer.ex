defimpl String.Chars, for: Vivid.Buffer do
  alias Vivid.{Buffer, RGBA}

  @doc """
  Convert a `buffer` into a `string` for `IO.puts`, etc.
  """
  @impl true
  def to_string(%Buffer{buffer: buffer, columns: columns} = _buffer) do
    s =
      buffer
      |> Enum.reverse()
      |> Enum.chunk_every(columns)
      |> Enum.map_join("\n", fn row ->
        row
        |> Enum.reverse()
        |> Enum.map_join(&RGBA.to_ascii(&1))
      end)

    s <> "\n"
  end
end
