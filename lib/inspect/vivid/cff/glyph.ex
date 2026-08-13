defimpl Inspect, for: Vivid.CFF.Glyph do
  alias Vivid.CFF.Glyph
  import Inspect.Algebra

  @moduledoc """
  Inspects a CFF glyph without its font.

  A glyph carries the whole parsed CFF table it came from, so inspecting one
  naively prints every charstring in the font.
  """

  @doc false
  @impl true
  def inspect(glyph, opts) do
    details = [index: glyph.index, advance: Glyph.advance(glyph)]
    concat(["#Vivid.CFF.Glyph<", to_doc(details, opts), ">"])
  end
end
