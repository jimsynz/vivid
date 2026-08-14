defimpl Vivid.Transformable, for: Vivid.Bitmap do
  alias Vivid.{Bitmap, Point}

  @doc """
  Apply an arbitrary transformation function to a bitmap.

  * `bitmap` - the bitmap to modify.
  * `fun` - the transformation function to apply.

  A bitmap's cells are axis-aligned squares, so only moving it and resizing it
  leave it one. The function is applied to the bitmap's origin and to the far
  corner of a single cell, and the distance between the results is the new cell
  size, which is exact for a translation or a scale and an approximation of
  anything else - much as a `Vivid.Circle` can only really be moved and resized.

  Keeping a scaled bitmap a bitmap is what lets a frame sampled more than once
  per pixel find a cell wherever it looks inside one, rather than finding the
  same few points it would have found anyway.
  """
  @impl true
  def transform(%Bitmap{origin: origin, size: size} = bitmap, fun) do
    moved = fun.(origin)
    far = fun.(Point.init(Point.x(origin) + size, Point.y(origin) + size))

    %{bitmap | origin: moved, size: Point.x(far) - Point.x(moved)}
  end
end
