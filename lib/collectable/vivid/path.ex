defimpl Collectable, for: Vivid.Path do
  alias Vivid.{Path, Point}

  @doc """
  Collect an enumerable into a Path.

  ## Examples

      iex> [Vivid.Point.init(1,1)] |> Enum.into(Vivid.Path.init)
      %Vivid.Path{vertices: [%Vivid.Point{x: 1, y: 1}]}
  """

  def into(%Path{vertices: points}) do
    {[], fn
      list, {:cont, %Point{}=point} -> [ point | list ]
      list, :done                   -> Path.init(points ++ list)
      _,    :halt                   -> :ok
    end}
  end
end