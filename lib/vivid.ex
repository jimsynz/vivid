defmodule Vivid do

  def example do
    polygon = [{1,1}, {1,4}, {4,4}, {4,1}]
      |> Enum.map(fn {x,y} -> Vivid.Point.init(x,y) end)
      |> Vivid.Polygon.init

    line = [{9,1}, {1,9}]
      |> Enum.map(fn {x,y} -> Vivid.Point.init(x,y) end)
      |> Vivid.Line.init

    Vivid.Frame.init(10,10)
      |> Vivid.Frame.push(polygon, 1)
      |> Vivid.Frame.push(line, 1)
      |> Vivid.Frame.puts
  end

end
