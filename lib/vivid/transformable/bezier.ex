defimpl Vivid.Transformable, for: Vivid.Bezier do
  alias Vivid.{Bezier, Path, Transformable}

  @doc """
  Apply an arbitrary transformation function to a Bézier curve.

  * `bezier` - the curve to modify.
  * `fun` - the transformation function to apply.

  The function is applied to the flattened curve rather than to its control
  points, because an arbitrary transformation isn't guaranteed to be affine,
  and only affine transformations leave a Bézier curve a Bézier curve.
  """
  @impl true
  def transform(bezier, fun) do
    bezier
    |> Bezier.to_path()
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Path.init())
  end
end
