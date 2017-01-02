defimpl Inspect, for: Vivid.Box do
  alias Vivid.Box
  import Inspect.Algebra

  def inspect(%Box{bottom_left: bl, top_right: tr}, opts) do
    concat ["#Vivid.Box<", to_doc([bottom_left: bl, top_right: tr], opts), ">"]
  end
end