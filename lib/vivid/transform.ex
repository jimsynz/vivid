defmodule Vivid.Transform do
  alias Vivid.{Point, Transform}
  alias Vivid.Transformable
  import Vivid.Bounds
  import :math, only: [pi: 0]
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
      #Vivid.Polygon<[#Vivid.Point<{17, 11}>, #Vivid.Point<{28, 22}>, #Vivid.Point<{23, 29}>, #Vivid.Point<{12, 19}>]>
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
      #Vivid.Polygon<[#Vivid.Point<{13, 3}>, #Vivid.Point<{13, 13}>, #Vivid.Point<{3, 13}>, #Vivid.Point<{3, 3}>]>

      iex> Vivid.Box.init(Vivid.Point.init(5,5), Vivid.Point.init(10,10))
      ...> |> Vivid.Transform.scale(2, 4)
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{13, -3}>, #Vivid.Point<{13, 18}>, #Vivid.Point<{3, 18}>, #Vivid.Point<{3, -3}>]>

  """
  def scale(shape, uniform) do
    fun = fn shape ->
      origin = center_of(shape)
      &Transform.Point.scale(&1, uniform, uniform, origin)
    end

    apply_transform(shape, fun, "scale-#{uniform}x")
  end

  def scale(shape, x, y) do
    fun = fn shape ->
      origin = center_of(shape)
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
      #Vivid.Polygon<[#Vivid.Point<{13, 9}>, #Vivid.Point<{20, 16}>, #Vivid.Point<{17, 21}>, #Vivid.Point<{10, 14}>]>

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.rotate(45, Vivid.Point.init(5,5))
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{13, 2}>, #Vivid.Point<{20, 9}>, #Vivid.Point<{17, 14}>, #Vivid.Point<{10, 6}>]>
  """
  def rotate(shape, degrees) do
    radians = degrees_to_radians(degrees)
    fun = fn shape ->
      origin = center_of(shape)
      &Transform.Point.rotate(&1, origin, radians)
    end

    apply_transform(shape, fun, "rotate-#{degrees}-around-center")
  end
  def rotate(shape, degrees, %Point{x: x, y: y}=origin) do
    radians = degrees_to_radians(degrees)
    fun = fn _shape ->
      &Transform.Point.rotate(&1, origin, radians)
    end

    apply_transform(shape, fun, "rotate-#{degrees}-around-#{x}-#{y}")
  end

  @doc """
  Center a shape within the specified bounds.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.center(Vivid.Bounds.init(0, 0, 12, 12))
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{11, 1}>, #Vivid.Point<{11, 11}>, #Vivid.Point<{1, 11}>, #Vivid.Point<{1, 1}>]>
  """
  def center(shape, bounds) do
    bounds        = bounds(bounds)
    bounds_width  = width(bounds)
    bounds_height = height(bounds)
    bounds_center = center_of(bounds)
    fun = fn shape ->
      shape_center = center_of(shape)
      {tr_x, tr_y} = Point.vector(shape_center, bounds_center)

      &Transform.Point.translate(&1, round(tr_x), round(tr_y))
    end
    apply_transform(shape, fun, "center-within-#{bounds_width}-#{bounds_height}")
  end

  @doc """
  Stretch a shape to the maximum size within bounds, ignoring the shape's original aspect ratio.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.stretch(Vivid.Bounds.init(0, 0, 40, 80))
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{40, 0}>, #Vivid.Point<{40, 80}>, #Vivid.Point<{0, 80}>, #Vivid.Point<{0, 0}>]>
  """
  def stretch(shape, bounds) do
    bounds        = bounds(bounds)
    bounds_min    = min(bounds)
    bounds_width  = width(bounds)
    bounds_height = height(bounds)
    fun = fn shape ->
      shape_bounds  = bounds(shape)
      shape_width   = width(shape_bounds)
      shape_height  = height(shape_bounds)
      shape_min     = min(shape_bounds)

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
      #Vivid.Polygon<[#Vivid.Point<{40, 0}>, #Vivid.Point<{40, 40}>, #Vivid.Point<{0, 40}>, #Vivid.Point<{0, 0}>]>
  """
  def fill(shape, bounds) do
    bounds        = bounds(bounds)
    bounds_min    = min(bounds)
    bounds_width  = width(bounds)
    bounds_height = height(bounds)
    fun = fn shape ->
      shape_bounds  = bounds(shape)
      shape_width   = width(shape_bounds)
      shape_height  = height(shape_bounds)
      shape_min     = min(shape_bounds)

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
      #Vivid.Polygon<[#Vivid.Point<{80, 0}>, #Vivid.Point<{80, 80}>, #Vivid.Point<{0, 80}>, #Vivid.Point<{0, 0}>]>
  """
  def overflow(shape, bounds) do
       bounds        = bounds(bounds)
    bounds_min    = min(bounds)
    bounds_width  = width(bounds)
    bounds_height = height(bounds)
    fun = fn shape ->
      shape_bounds  = bounds(shape)
      shape_width   = width(shape_bounds)
      shape_height  = height(shape_bounds)
      shape_min     = min(shape_bounds)

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
      ...>     x = x - (width / 2) |> round
      ...>     Vivid.Point.init(x, y)
      ...>   end
      ...> end)
      ...> |> Vivid.Transform.apply
      #Vivid.Polygon<[#Vivid.Point<{15, 10}>, #Vivid.Point<{15, 20}>, #Vivid.Point<{5, 20}>, #Vivid.Point<{5, 10}>]>
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

  # Just because I sometimes do this while debugging
  def apply(shape), do: shape

  defp apply_transform(%Transform{operations: operations}=transform, fun, name) do
    operations = [ %Operation{function: fun, name: name} | operations ]
    %{transform | operations: operations}
  end
  defp apply_transform(shape, fun, name) do
    %Transform{operations: [ %Operation{function: fun, name: name} ], shape: shape}
  end

  defp degrees_to_radians(degrees), do: degrees / 360.0 * 2.0 * pi
end