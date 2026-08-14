defimpl Inspect, for: Vivid.Bitmap do
  alias Vivid.Bitmap
  import Inspect.Algebra

  @doc false
  @impl true
  def inspect(bitmap, opts) do
    details = [
      pixels: Enum.count(Bitmap.pixels(bitmap)),
      origin: Bitmap.origin(bitmap),
      size: Bitmap.size(bitmap)
    ]

    concat(["#Vivid.Bitmap<", to_doc(details, opts), ">"])
  end
end
