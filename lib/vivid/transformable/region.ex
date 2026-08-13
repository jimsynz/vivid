defimpl Vivid.Transformable, for: Vivid.Region do
  alias Vivid.{Region, Transformable}

  @doc """
  Apply an arbitrary transformation function to a region.

  * `region` - the region to modify.
  * `fun` - the transformation function to apply.

  Each contour is transformed independently, which leaves their winding
  directions - and so which of them are holes - as they were.
  """
  @impl true
  def transform(%Region{contours: contours} = _region, fun) do
    contours
    |> Enum.map(&Transformable.transform(&1, fun))
    |> Region.init()
  end
end
