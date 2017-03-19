defimpl Inspect, for: Vivid.Box do
  alias Vivid.Box
  import Inspect.Algebra

  @spec inspect(Box.t, any) :: String.t
  def inspect(%Box{bottom_left: bl, top_right: tr, fill: true}, opts) do
    concat ["#Vivid.Box<", to_doc([:filled, bottom_left: bl, top_right: tr], opts), ">"]
  end

  def inspect(%Box{bottom_left: bl, top_right: tr}, opts) do
    concat ["#Vivid.Box<", to_doc([bottom_left: bl, top_right: tr], opts), ">"]
  end
end
