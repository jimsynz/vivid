defmodule Vivid.Transform do
  alias Vivid.{Point, Transform, Bounds}
  alias Vivid.Transformable
  import Vivid.Math
  defstruct [operations: [], shape: nil]

  defmodule Operation do
    defstruct ~w(function name)a
  end

  @moduledoc """
  Creates and applies a "pipeline" of transformations to a shape.
  Transformation operations are collected up and only run once, when `apply` is called.

  ## Examples

  Take a square, rotate it 45°, scale it up 50% and center it within a frame.

      iex> frame = Vivid.Frame.init(40,40)
      ...> Vivid.Box.init(Vivid.Point.init(0,0), Vivid.Point.init(10,10))
      ...> |> Vivid.Transform.rotate(45)
      ...> |> Vivid.Transform.scale(1.5)
      ...> |> Vivid.Transform.center(frame)
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{30.106601717798213, 21.696699141100893}>, #Vivid.Point<{19.5, 24.803300858899107}>, #Vivid.Point<{8.893398282201787, 17.303300858899107}>, #Vivid.Point<{19.5, 14.196699141100893}>]>
  """

  @doc """
  Translate (ie move) a shape by adding `x` and `y` to each Point.

  ## Example

      iex> Vivid.Box.init(Vivid.Point.init(5,5), Vivid.Point.init(10,10))
      ...> |> Vivid.Transform.translate(5, 5)
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{15, 10}>, #Vivid.Point<{15, 15}>, #Vivid.Point<{10, 15}>, #Vivid.Point<{10, 10}>]>
  """
  def translate(shape, x, y) do
    fun = fn _shape ->
      &Transform.Point.translate(&1, x, y)
    end

    apply_transform(shape, fun, "translate-#{x}-#{y}")
  end

  @doc """
  Scale a shape around it's center point.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(5,5), Vivid.Point.init(10,10))
      ...> |> Vivid.Transform.scale(2)
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{12.5, 2.5}>, #Vivid.Point<{12.5, 12.5}>, #Vivid.Point<{2.5, 12.5}>, #Vivid.Point<{2.5, 2.5}>]>

      iex> Vivid.Box.init(Vivid.Point.init(5,5), Vivid.Point.init(10,10))
      ...> |> Vivid.Transform.scale(2, 4)
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{12.5, -2.5}>, #Vivid.Point<{12.5, 17.5}>, #Vivid.Point<{2.5, 17.5}>, #Vivid.Point<{2.5, -2.5}>]>

  """
  def scale(shape, uniform) do
    fun = fn shape ->
      origin = Bounds.center_of(shape)
      &Transform.Point.scale(&1, uniform, uniform, origin)
    end

    apply_transform(shape, fun, "scale-#{uniform}x")
  end

  def scale(shape, x, y) do
    fun = fn shape ->
      origin = Bounds.center_of(shape)
      &Transform.Point.scale(&1, x, y, origin)
    end

    apply_transform(shape, fun, "scale-#{x}x-#{y}x")
  end

  @doc """
  Rotate a shape around an origin point. The default point the shape's center.

  ## Example

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.rotate(45)
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{22.071067811865476, 16.464466094067262}>, #Vivid.Point<{15.0, 18.535533905932738}>, #Vivid.Point<{7.9289321881345245, 13.535533905932738}>, #Vivid.Point<{15.0, 11.464466094067262}>]>

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.rotate(45, Vivid.Point.init(5,5))
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{12.071067811865476, 13.535533905932738}>, #Vivid.Point<{5.000000000000002, 15.606601717798215}>, #Vivid.Point<{-2.0710678118654737, 10.606601717798215}>, #Vivid.Point<{5.0, 8.535533905932738}>]>
  """
  def rotate(shape, degrees) do
    radians = degrees_to_radians(degrees)
    fun = fn shape ->
      origin = Bounds.center_of(shape)
      &Transform.Point.rotate_radians(&1, origin, radians)
    end

    apply_transform(shape, fun, "rotate-#{degrees}-around-center")
  end
  def rotate(shape, degrees, %Point{x: x, y: y}=origin) do
    radians = degrees_to_radians(degrees)
    fun = fn _shape ->
      &Transform.Point.rotate_radians(&1, origin, radians)
    end

    apply_transform(shape, fun, "rotate-#{degrees}-around-#{x}-#{y}")
  end

  @doc """
  Center a shape within the specified bounds.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.center(Vivid.Bounds.init(0, 0, 12, 12))
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{11.0, 1.0}>, #Vivid.Point<{11.0, 11.0}>, #Vivid.Point<{1.0, 11.0}>, #Vivid.Point<{1.0, 1.0}>]>
  """
  def center(shape, bounds) do
    bounds        = Bounds.bounds(bounds)
    bounds_width  = Bounds.width(bounds)
    bounds_height = Bounds.height(bounds)
    bounds_center = Bounds.center_of(bounds)
    fun = fn shape ->
      shape_center = Bounds.center_of(shape)
      {tr_x, tr_y} = Point.vector(shape_center, bounds_center)

      &Transform.Point.translate(&1, tr_x, tr_y)
    end
    apply_transform(shape, fun, "center-within-#{bounds_width}-#{bounds_height}")
  end

  @doc """
  Stretch a shape to the maximum size within bounds, ignoring the shape's original aspect ratio.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.stretch(Vivid.Bounds.init(0, 0, 40, 80))
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{40.0, 0.0}>, #Vivid.Point<{40.0, 80.0}>, #Vivid.Point<{0.0, 80.0}>, #Vivid.Point<{0.0, 0.0}>]>
  """
  def stretch(shape, bounds) do
    bounds        = Bounds.bounds(bounds)
    bounds_min    = Bounds.min(bounds)
    bounds_width  = Bounds.width(bounds)
    bounds_height = Bounds.height(bounds)
    fun = fn shape ->
      shape_bounds  = Bounds.bounds(shape)
      shape_width   = Bounds.width(shape_bounds)
      shape_height  = Bounds.height(shape_bounds)
      shape_min     = Bounds.min(shape_bounds)

      {tr_x, tr_y}  = Point.vector(shape_min, bounds_min)

      scale_x       = bounds_width / shape_width
      scale_y       = bounds_height / shape_height

      fn point ->
        point
        |> Transform.Point.translate(tr_x, tr_y)
        |> Transform.Point.scale(scale_x, scale_y)
      end
    end
    apply_transform(shape, fun, "stretch-to-#{bounds_width}-#{bounds_height}")
  end

  @doc """
  Scale a shape to the maximum size within bounds, respecting the shape's aspect ratio.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.fill(Vivid.Bounds.init(0, 0, 40, 80))
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{40.0, 0.0}>, #Vivid.Point<{40.0, 40.0}>, #Vivid.Point<{0.0, 40.0}>, #Vivid.Point<{0.0, 0.0}>]>
  """
  def fill(shape, bounds) do
    bounds        = Bounds.bounds(bounds)
    bounds_min    = Bounds.min(bounds)
    bounds_width  = Bounds.width(bounds)
    bounds_height = Bounds.height(bounds)
    fun = fn shape ->
      shape_bounds  = Bounds.bounds(shape)
      shape_width   = Bounds.width(shape_bounds)
      shape_height  = Bounds.height(shape_bounds)
      shape_min     = Bounds.min(shape_bounds)

      {tr_x, tr_y}  = Point.vector(shape_min, bounds_min)

      scale_x       = bounds_width / shape_width
      scale_y       = bounds_height / shape_height
      scale         = if scale_x < scale_y, do: scale_x, else: scale_y

      fn point ->
        point
        |> Transform.Point.translate(tr_x, tr_y)
        |> Transform.Point.scale(scale, scale)
      end
    end
    apply_transform(shape, fun, "fill-to-#{bounds_width}-#{bounds_height}")
  end

  @doc """
  Scale a shape to completely fill bounds, respecting the shape's aspect ratio.
  Thus overflowing the bounds if the shape's aspect ratio doesn't match that of the bounds.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.overflow(Vivid.Bounds.init(0, 0, 40, 80))
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{80.0, 0.0}>, #Vivid.Point<{80.0, 80.0}>, #Vivid.Point<{0.0, 80.0}>, #Vivid.Point<{0.0, 0.0}>]>
  """
  def overflow(shape, bounds) do
    bounds        = Bounds.bounds(bounds)
    bounds_min    = Bounds.min(bounds)
    bounds_width  = Bounds.width(bounds)
    bounds_height = Bounds.height(bounds)
    fun = fn shape ->
      shape_bounds  = Bounds.bounds(shape)
      shape_width   = Bounds.width(shape_bounds)
      shape_height  = Bounds.height(shape_bounds)
      shape_min     = Bounds.min(shape_bounds)

      {tr_x, tr_y}  = Point.vector(shape_min, bounds_min)

      scale_x       = bounds_width / shape_width
      scale_y       = bounds_height / shape_height
      scale         = if scale_x > scale_y, do: scale_x, else: scale_y

      fn point ->
        point
        |> Transform.Point.translate(tr_x, tr_y)
        |> Transform.Point.scale(scale, scale)
      end
    end
    apply_transform(shape, fun, "overflow-#{bounds_width}-#{bounds_height}")
  end

  @doc """
  Create an arbitrary transformation.

  Takes a shape and a function which is called with a shape argument (not necessarily the shape
  passed-in, depending on where this transformation is in the transformation pipeline.

  The function must return another function which takes and manipulates a point.

  ## Example

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.transform(fn shape ->
      ...>   # Translate a point right by half it's width
      ...>   width = Vivid.Bounds.width(shape)
      ...>   fn point ->
      ...>     x = point |> Vivid.Point.x
      ...>     y = point |> Vivid.Point.y
      ...>     x = x + (width / 2) |> round
      ...>     Vivid.Point.init(x, y)
      ...>   end
      ...> end)
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{25, 10}>, #Vivid.Point<{25, 20}>, #Vivid.Point<{15, 20}>, #Vivid.Point<{15, 10}>]>
  """
  def transform(shape, fun), do: apply_transform(shape, fun, inspect(fun))

  @doc """
  Apply a transformation pipeline returning the modified shape.
  """
  def apply(%Transform{operations: operations, shape: shape}) do
    operations
    |> Enum.reverse
    |> Enum.reduce(shape, fn %Operation{function: fun}, shape ->
      transform = fun.(shape)
      Transformable.transform(shape, transform)
    end)
  end

  defp apply_transform(%Transform{operations: operations}=transform, fun, name) do
    operations = [ %Operation{function: fun, name: name} | operations ]
    %{transform | operations: operations}
  end
  defp apply_transform(shape, fun, name) do
    %Transform{operations: [ %Operation{function: fun, name: name} ], shape: shape}
  end
end