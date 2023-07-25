defmodule Vivid.Transform do
  alias Vivid.{Bounds, Point, Shape, Transform}
  alias Vivid.Transformable
  import Vivid.Math
  defstruct operations: [], shape: nil

  defmodule Operation do
    alias __MODULE__
    defstruct ~w(function name)a

    @moduledoc """
    An operation that can be applied to a shape.
    """

    @type t :: %Operation{function: function, name: String.t()}
  end

  @moduledoc ~S"""
  Creates and applies a "pipeline" of transformations to a shape.
  Transformation operations are collected up and only run once, when `apply` is called.

  ## Examples

  Take a square, rotate it 45°, scale it up 50% and center it within a frame.

      iex> use Vivid
      ...> frame = Frame.init(40, 40, RGBA.white)
      ...> box = Box.init(Point.init(0,0), Point.init(10,10))
      ...>   |> Transform.rotate(45)
      ...>   |> Transform.scale(1.5)
      ...>   |> Transform.center(frame)
      ...>   |> Transform.apply
      ...> Frame.push(frame, box, RGBA.black)
      ...> |> to_string
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@ @ @@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@ @@@ @@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@ @@@@@@@ @@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@  @@@@@@@@@ @@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@ @@@@@@@@@@@@ @@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@ @@@@@@@@@@@@@@ @@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@ @@@@@@@@@@@@@@@@ @@@@@@@@@@@\n" <>
      "@@@@@@@@@@ @@@@@@@@@@@@@@@@@@ @@@@@@@@@@\n" <>
      "@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@ @@@@@@@@@\n" <>
      "@@@@@@@@@@ @@@@@@@@@@@@@@@@@@ @@@@@@@@@@\n" <>
      "@@@@@@@@@@@ @@@@@@@@@@@@@@@@ @@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@ @@@@@@@@@@@@@@ @@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@ @@@@@@@@@@@@ @@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@ @@@@@@@@@@ @@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@ @@@@@@@@@ @@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@ @@@@@@@ @@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@ @@@@@ @@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@ @@@ @@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@ @ @@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
  """

  @type t :: %Transform{shape: Shape.t(), operations: [Operation.t()]}
  @type shape_or_transform :: Transform.t() | Shape.t()
  @type degrees :: number

  @doc """
  Translate (ie move) a shape by adding `x` and `y` to each Point.

  ## Example

      iex> Vivid.Box.init(Vivid.Point.init(5,5), Vivid.Point.init(10,10))
      ...> |> Vivid.Transform.translate(5, 5)
      ...> |> Vivid.Transform.apply
      Vivid.Polygon.init([Vivid.Point.init(15, 10), Vivid.Point.init(15, 15), Vivid.Point.init(10, 15), Vivid.Point.init(10, 10)])
  """
  @spec translate(shape_or_transform, number, number) :: Transform.t()
  def translate(shape, x, y) do
    fun = fn _shape ->
      &Transform.Point.translate(&1, x, y)
    end

    apply_transform(shape, fun, "translate-#{x}-#{y}")
  end

  @doc """
  Uniformly scale a `shape` around it's center point.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(5,5), Vivid.Point.init(10,10))
      ...> |> Vivid.Transform.scale(2)
      ...> |> Vivid.Transform.apply
      Vivid.Polygon.init([Vivid.Point.init(12.5, 2.5), Vivid.Point.init(12.5, 12.5), Vivid.Point.init(2.5, 12.5), Vivid.Point.init(2.5, 2.5)])
  """
  @spec scale(shape_or_transform, number) :: Transform.t()
  def scale(shape, uniform) do
    fun = fn shape ->
      origin = Bounds.center_of(shape)
      &Transform.Point.scale(&1, uniform, uniform, origin)
    end

    apply_transform(shape, fun, "scale-#{uniform}x")
  end

  @doc """
  Scale a `shape` around it's center point using the given `x` and `y` multipliers.

  ## Examples

      iex> Vivid.Box.init(Vivid.Point.init(5,5), Vivid.Point.init(10,10))
      ...> |> Vivid.Transform.scale(2, 4)
      ...> |> Vivid.Transform.apply
      Vivid.Polygon.init([Vivid.Point.init(12.5, -2.5), Vivid.Point.init(12.5, 17.5), Vivid.Point.init(2.5, 17.5), Vivid.Point.init(2.5, -2.5)])

  """
  @spec scale(shape_or_transform, number, number) :: Transform.t()
  def scale(shape, x, y) do
    fun = fn shape ->
      origin = Bounds.center_of(shape)
      &Transform.Point.scale(&1, x, y, origin)
    end

    apply_transform(shape, fun, "scale-#{x}x-#{y}x")
  end

  @doc ~S"""
  Rotate a shape around it's center point.

  ## Example

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.rotate(45)
      ...> |> Vivid.Transform.apply
      ...> |> to_string
      "@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@ @@@@@@@@\n" <>
      "@@@@@@@ @ @@@@@@@\n" <>
      "@@@@@@ @@@ @@@@@@\n" <>
      "@@@@@ @@@@@ @@@@@\n" <>
      "@@@@ @@@@@@@ @@@@\n" <>
      "@@@ @@@@@@@@@ @@@\n" <>
      "@@ @@@@@@@@@@@ @@\n" <>
      "@ @@@@@@@@@@@@@ @\n" <>
      "@@ @@@@@@@@@@@ @@\n" <>
      "@@@ @@@@@@@@@ @@@\n" <>
      "@@@@ @@@@@@@ @@@@\n" <>
      "@@@@@ @@@@@ @@@@@\n" <>
      "@@@@@@ @@@ @@@@@@\n" <>
      "@@@@@@@ @ @@@@@@@\n" <>
      "@@@@@@@@ @@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@\n"
  """
  @spec rotate(shape_or_transform, degrees) :: Transform.t()
  def rotate(shape, degrees) do
    radians = degrees_to_radians(degrees)

    fun = fn shape ->
      origin = Bounds.center_of(shape)
      &Transform.Point.rotate_radians(&1, origin, radians)
    end

    apply_transform(shape, fun, "rotate-#{degrees}-around-center")
  end

  @doc ~S"""
  Rotate a shape around an origin point.

  ## Example

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.rotate(45, Vivid.Point.init(5,5))
      ...> |> Vivid.Transform.apply
      ...> |> to_string
      "@@@@@@@@@@@@@@@@@\n" <>
      "@@@@@@@@ @@@@@@@@\n" <>
      "@@@@@@@ @ @@@@@@@\n" <>
      "@@@@@@ @@@ @@@@@@\n" <>
      "@@@@@ @@@@@ @@@@@\n" <>
      "@@@@ @@@@@@@ @@@@\n" <>
      "@@@ @@@@@@@@@ @@@\n" <>
      "@@ @@@@@@@@@@@ @@\n" <>
      "@ @@@@@@@@@@@@@ @\n" <>
      "@@ @@@@@@@@@@@ @@\n" <>
      "@@@ @@@@@@@@@ @@@\n" <>
      "@@@@ @@@@@@@ @@@@\n" <>
      "@@@@@ @@@@@ @@@@@\n" <>
      "@@@@@@ @@@ @@@@@@\n" <>
      "@@@@@@@ @ @@@@@@@\n" <>
      "@@@@@@@@ @@@@@@@@\n" <>
      "@@@@@@@@@@@@@@@@@\n"
  """
  @spec rotate(shape_or_transform, degrees, Point.t()) :: Transform.t()
  def rotate(shape, degrees, %Point{x: x, y: y} = origin) do
    radians = degrees_to_radians(degrees)

    fun = fn _shape ->
      &Transform.Point.rotate_radians(&1, origin, radians)
    end

    apply_transform(shape, fun, "rotate-#{degrees}-around-#{x}-#{y}")
  end

  @doc ~S"""
  Center a shape within the specified bounds.

  ## Examples

      iex> use Vivid
      ...> frame = Frame.init(13,13, RGBA.white)
      ...> box = Box.init(Point.init(10,10), Point.init(20,20))
      ...>   |> Vivid.Transform.center(Bounds.init(0, 0, 12, 12))
      ...>   |> Vivid.Transform.apply
      ...> Frame.push(frame, box, RGBA.black)
      ...> |> to_string
      "@@@@@@@@@@@@@\n" <>
      "@           @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@           @\n" <>
      "@@@@@@@@@@@@@\n"
  """
  @spec center(shape_or_transform, Shape.t()) :: Transform.t()
  def center(shape, bounds) do
    bounds = Bounds.bounds(bounds)
    bounds_width = Bounds.width(bounds)
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
      Vivid.Polygon.init([Vivid.Point.init(40.0, 0.0), Vivid.Point.init(40.0, 80.0), Vivid.Point.init(0.0, 80.0), Vivid.Point.init(0.0, 0.0)])
  """
  @spec stretch(shape_or_transform, Shape.t()) :: Transform.t()
  def stretch(shape, bounds) do
    bounds = Bounds.bounds(bounds)
    bounds_min = Bounds.min(bounds)
    bounds_width = Bounds.width(bounds)
    bounds_height = Bounds.height(bounds)

    fun = fn shape ->
      shape_bounds = Bounds.bounds(shape)
      shape_width = Bounds.width(shape_bounds)
      shape_height = Bounds.height(shape_bounds)
      shape_min = Bounds.min(shape_bounds)

      {tr_x, tr_y} = Point.vector(shape_min, bounds_min)

      scale_x = bounds_width / shape_width
      scale_y = bounds_height / shape_height

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
      Vivid.Polygon.init([Vivid.Point.init(40.0, 0.0), Vivid.Point.init(40.0, 40.0), Vivid.Point.init(0.0, 40.0), Vivid.Point.init(0.0, 0.0)])
  """
  @spec fill(shape_or_transform, Shape.t()) :: Transform.t()
  def fill(shape, bounds) do
    bounds = Bounds.bounds(bounds)
    bounds_min = Bounds.min(bounds)
    bounds_width = Bounds.width(bounds)
    bounds_height = Bounds.height(bounds)

    fun = fn shape ->
      shape_bounds = Bounds.bounds(shape)
      shape_width = Bounds.width(shape_bounds)
      shape_height = Bounds.height(shape_bounds)
      shape_min = Bounds.min(shape_bounds)

      {tr_x, tr_y} = Point.vector(shape_min, bounds_min)

      scale_x = bounds_width / shape_width
      scale_y = bounds_height / shape_height
      scale = if scale_x < scale_y, do: scale_x, else: scale_y

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
      Vivid.Polygon.init([Vivid.Point.init(80.0, 0.0), Vivid.Point.init(80.0, 80.0), Vivid.Point.init(0.0, 80.0), Vivid.Point.init(0.0, 0.0)])
  """
  @spec overflow(shape_or_transform, Shape.t()) :: Transform.t()
  def overflow(shape, bounds) do
    bounds = Bounds.bounds(bounds)
    bounds_min = Bounds.min(bounds)
    bounds_width = Bounds.width(bounds)
    bounds_height = Bounds.height(bounds)

    fun = fn shape ->
      shape_bounds = Bounds.bounds(shape)
      shape_width = Bounds.width(shape_bounds)
      shape_height = Bounds.height(shape_bounds)
      shape_min = Bounds.min(shape_bounds)

      {tr_x, tr_y} = Point.vector(shape_min, bounds_min)

      scale_x = bounds_width / shape_width
      scale_y = bounds_height / shape_height
      scale = if scale_x > scale_y, do: scale_x, else: scale_y

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
  passed-in, depending on where this transformation is in the transformation pipeline).

  The function must return another function which takes and manipulates a point.

  ## Example

  The example below translates a point right by half it's width.

      iex> Vivid.Box.init(Vivid.Point.init(10,10), Vivid.Point.init(20,20))
      ...> |> Vivid.Transform.transform(fn shape ->
      ...>   width = Vivid.Bounds.width(shape)
      ...>   fn point ->
      ...>     x = point |> Vivid.Point.x
      ...>     y = point |> Vivid.Point.y
      ...>     x = x + (width / 2) |> round
      ...>     Vivid.Point.init(x, y)
      ...>   end
      ...> end)
      ...> |> Vivid.Transform.apply
      Vivid.Polygon.init([Vivid.Point.init(25, 10), Vivid.Point.init(25, 20), Vivid.Point.init(15, 20), Vivid.Point.init(15, 10)])
  """
  @spec transform(shape_or_transform, function) :: Transform.t()
  def transform(shape, fun), do: apply_transform(shape, fun, inspect(fun))

  @doc """
  Apply a transformation pipeline returning the modified shape.
  """
  @spec apply(Transform.t()) :: Shape.t()
  def apply(%Transform{operations: operations, shape: shape}) do
    operations
    |> Enum.reverse()
    |> Enum.reduce(shape, fn %Operation{function: fun}, shape ->
      transform = fun.(shape)
      Transformable.transform(shape, transform)
    end)
  end

  defp apply_transform(%Transform{operations: operations} = transform, fun, name) do
    operations = [%Operation{function: fun, name: name} | operations]
    %{transform | operations: operations}
  end

  defp apply_transform(shape, fun, name) do
    %Transform{operations: [%Operation{function: fun, name: name}], shape: shape}
  end
end
