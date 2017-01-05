defimpl Collectable, for: Vivid.Frame do
  alias Vivid.Frame

  @doc """
  Collect an enumerable into a Frame.
  """

  def into(%Frame{shapes: shapes}=frame) do
    {shapes, fn
      [],         {:cont, {_shape,_colour}=shape} -> [shape]
      new_shapes, {:cont, {_shape,_colour}=shape} -> [shape | new_shapes]
      new_shapes, :done                           -> %{frame | shapes: shapes ++ Enum.reverse(new_shapes)}
      _,          :halt                           -> :ok
    end}
  end
end