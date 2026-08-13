defmodule Vivid.Region do
  alias Vivid.{Polygon, Region}
  defstruct contours: []

  @moduledoc ~S"""
  A filled area bounded by one or more closed contours.

  Every contour is filled in a single pass under the non-zero winding rule, so a
  contour wound against the one enclosing it cuts a hole rather than filling
  solid. That's the difference between a Region and a `Vivid.Group` of filled
  polygons, where each polygon is filled without knowing about the others.

  Since winding direction decides what's a hole, the vertex order of the contours
  is significant.

  ## Example

  A square with a square hole in it, the hole wound against the outside.

      iex> use Vivid
      ...> outside = Polygon.init([Point.init(1, 1), Point.init(12, 1), Point.init(12, 12), Point.init(1, 12)])
      ...> inside = Polygon.init([Point.init(4, 4), Point.init(4, 9), Point.init(9, 9), Point.init(9, 4)])
      ...> Region.init([outside, inside])
      ...> |> to_string()
      "@@@@@@@@@@@@@@\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@    @@@@    @\n" <>
      "@    @@@@    @\n" <>
      "@    @@@@    @\n" <>
      "@    @@@@    @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@@@@@@@@@@@@@@\n"
  """

  @type t :: %Region{contours: [Polygon.t()]}

  @doc ~S"""
  Initialize a region from a list of contours.

  ## Example

  The same two squares as above, but with the inner one wound the same way as the
  outer. Both contours now wind in the same direction, so the middle is enclosed
  twice rather than not at all, and it fills solid.

      iex> use Vivid
      ...> outside = Polygon.init([Point.init(1, 1), Point.init(12, 1), Point.init(12, 12), Point.init(1, 12)])
      ...> inside = Polygon.init([Point.init(4, 4), Point.init(9, 4), Point.init(9, 9), Point.init(4, 9)])
      ...> Region.init([outside, inside])
      ...> |> to_string()
      "@@@@@@@@@@@@@@\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@            @\n" <>
      "@@@@@@@@@@@@@@\n"
  """
  @spec init([Polygon.t()]) :: Region.t()
  def init(contours) when is_list(contours), do: %Region{contours: contours}

  @doc """
  Returns the contours of `region`.

  ## Example

      iex> Vivid.Region.init([])
      ...> |> Vivid.Region.contours()
      []
  """
  @spec contours(Region.t()) :: [Polygon.t()]
  def contours(%Region{contours: contours} = _region), do: contours
end
