defmodule Vivid.BDF.Glyph do
  alias Vivid.BDF.Glyph

  defstruct ~w(advance pixels)a

  @moduledoc """
  A single glyph from a bitmap font: how far the pen advances, and which pixels
  are lit.

  Pixels are `{x, y}` pairs relative to the glyph's origin, with Y pointing up
  like everything else in this library, so a descender has negative coordinates.
  Unlike an outline glyph there's nothing to parse on demand - a bitmap is
  already as decoded as it gets - so they're expanded when the font is read.
  """

  @type t :: %Glyph{advance: number, pixels: [{integer, integer}]}

  @doc """
  Initialize a glyph from its advance width and lit pixels.
  """
  @spec init(number, [{integer, integer}]) :: Glyph.t()
  def init(advance, pixels) when is_number(advance) and is_list(pixels),
    do: %Glyph{advance: advance, pixels: pixels}

  @doc """
  Returns how far the pen advances after drawing `glyph`, in pixels.

  ## Example

      iex> Path.join(:code.priv_dir(:vivid), "fonts/misc-fixed-4x6.bdf")
      ...> |> Vivid.BDF.load!()
      ...> |> Vivid.Font.glyph(?W)
      ...> |> Vivid.BDF.Glyph.advance()
      4
  """
  @spec advance(Glyph.t()) :: number
  def advance(%Glyph{advance: advance} = _glyph), do: advance

  @doc """
  Returns the lit pixels of `glyph` as `{x, y}` pairs.

  ## Example

  A full stop is a single pixel, sitting on the baseline.

      iex> Path.join(:code.priv_dir(:vivid), "fonts/misc-fixed-4x6.bdf")
      ...> |> Vivid.BDF.load!()
      ...> |> Vivid.Font.glyph(?.)
      ...> |> Vivid.BDF.Glyph.pixels()
      [{1, 0}]
  """
  @spec pixels(Glyph.t()) :: [{integer, integer}]
  def pixels(%Glyph{pixels: pixels} = _glyph), do: pixels
end
