defmodule Vivid.Shape do
  alias Vivid.{Arc, Bounds, Box, Circle, Group, Line, Path, Point, Polygon}

  @moduledoc """
  Doesn't do anything - is merely a type to represent an arbitrary shape in typespecs.
  """

  @type t ::
          Arc.t()
          | Bounds.t()
          | Box.t()
          | Circle.t()
          | Group.t()
          | Line.t()
          | Path.t()
          | Point.t()
          | Polygon.t()
end
