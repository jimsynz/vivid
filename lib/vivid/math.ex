defmodule Vivid.Math do
  defdelegate pi(), to: :math
  defdelegate cos(x), to: :math
  defdelegate sin(x), to: :math
  defdelegate pow(x,y), to: :math
  defdelegate sqrt(x), to: :math
  def degrees_to_radians(degrees), do: degrees / 360.0 * 2.0 * pi
end