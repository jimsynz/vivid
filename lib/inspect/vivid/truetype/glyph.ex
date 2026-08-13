defimpl Inspect, for: Vivid.TrueType.Glyph do
  alias Vivid.TrueType.Glyph
  import Inspect.Algebra

  @moduledoc """
  Inspects a TrueType glyph without its font.

  A glyph carries every glyph slice in the font it came from, so inspecting one
  naively prints the whole font - which is what happens in an error message
  about a glyph a font doesn't have.
  """

  @doc false
  @impl true
  def inspect(glyph, opts) do
    details = [index: glyph.index, advance: Glyph.advance(glyph)]
    concat(["#Vivid.TrueType.Glyph<", to_doc(details, opts), ">"])
  end
end
