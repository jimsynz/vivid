defimpl Inspect, for: Vivid.RGBA do
  alias Vivid.RGBA
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `RGBA`.
  """
  @spec inspect(RGBA.t(), any) :: String.t()
  def inspect(colour, opts) do
    red = RGBA.red(colour)
    green = RGBA.green(colour)
    blue = RGBA.blue(colour)
    alpha = RGBA.alpha(colour)
    concat(["#Vivid.RGBA<", to_doc({red, green, blue, alpha}, opts), ">"])
  end
end
