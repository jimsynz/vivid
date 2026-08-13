defmodule Vivid.CFF do
  alias Vivid.CFF
  defstruct ~w(charstrings subrs gsubrs)a

  @moduledoc ~S"""
  Reads the Compact Font Format table carried by OpenType fonts with PostScript
  outlines - the ones whose files begin with `OTTO`.

  Roughly one font in seven uses these rather than TrueType outlines: of 697
  fonts surveyed on a development machine, 94 were CFF, which is every
  Adobe-derived family among them.

  CFF stores almost everything in two structures. An INDEX is a count, a table of
  offsets, and the data those offsets divide up. A DICT is a run of operands
  followed by the operator they belong to, which is backwards from most formats
  and the main thing to keep in mind when reading this module.

  Glyphs themselves are Type 2 charstrings, interpreted by
  `Vivid.CFF.Charstring`.
  """

  @type t :: %CFF{charstrings: tuple, subrs: tuple, gsubrs: tuple}

  @charstrings_op 17
  @private_op 18
  @subrs_op 19
  @ros_op {12, 30}

  @doc ~S"""
  Parse a `CFF ` table.

  ## Example

  A minimal font, built up a piece at a time. The Top DICT is the only part
  carrying anything: operand 21, then operator 17, meaning "the charstrings are
  21 bytes in" - which is exactly where they land once the four INDEXes before
  them are counted.

      iex> header = <<1, 0, 4, 1>>
      ...> name_index = <<0::16>>
      ...> top_dict = <<29::8, 21::32, 17::8>>
      ...> top_dict_index = <<1::16, 1::8, 1::8, byte_size(top_dict) + 1::8>> <> top_dict
      ...> string_index = <<0::16>>
      ...> gsubr_index = <<0::16>>
      ...> charstring = <<139, 139, 21, 14>>
      ...> charstrings = <<1::16, 1::8, 1::8, byte_size(charstring) + 1::8>> <> charstring
      ...> {:ok, parsed} =
      ...>   Vivid.CFF.parse(
      ...>     header <> name_index <> top_dict_index <> string_index <> gsubr_index <> charstrings
      ...>   )
      ...> tuple_size(parsed.charstrings)
      1
  """
  @spec parse(binary) :: {:ok, CFF.t()} | {:error, String.t()}
  def parse(<<_major::8, _minor::8, header_size::8, _offset_size::8, _::binary>> = cff)
      when byte_size(cff) > header_size do
    {_names, rest} = index(binary_slice(cff, header_size..-1//1))
    {top_dicts, rest} = index(rest)
    {_strings, rest} = index(rest)
    {gsubrs, _rest} = index(rest)

    with {:ok, top} <- top_dict(top_dicts),
         :ok <- not_cid_keyed(top),
         {:ok, charstrings} <- charstrings(top, cff) do
      {:ok,
       %CFF{
         charstrings: charstrings,
         subrs: subrs(top, cff),
         gsubrs: List.to_tuple(gsubrs)
       }}
    end
  end

  def parse(_cff), do: {:error, "font's CFF table is too short to be read"}

  defp top_dict([top | _]), do: {:ok, dict(top)}
  defp top_dict([]), do: {:error, "font's CFF table has no top dictionary"}

  defp not_cid_keyed(top) do
    if Map.has_key?(top, @ros_op) do
      {:error, "this font is CID-keyed, which isn't supported yet"}
    else
      :ok
    end
  end

  defp charstrings(top, cff) do
    case Map.get(top, @charstrings_op) do
      [offset] when is_integer(offset) and offset > 0 and offset < byte_size(cff) ->
        {charstrings, _rest} = index(binary_slice(cff, offset..-1//1))
        {:ok, List.to_tuple(charstrings)}

      _missing ->
        {:error, "font's CFF table doesn't say where its glyphs are"}
    end
  end

  defp subrs(top, cff) do
    with [size, offset] when is_integer(size) and is_integer(offset) <-
           Map.get(top, @private_op),
         private when byte_size(private) > 0 <- binary_slice(cff, offset, size),
         [subrs_offset] when is_integer(subrs_offset) <- Map.get(dict(private), @subrs_op) do
      {subrs, _rest} = index(binary_slice(cff, (offset + subrs_offset)..-1//1))
      List.to_tuple(subrs)
    else
      _none -> {}
    end
  end

  @doc ~S"""
  Split an INDEX into its objects, returning them and whatever follows.

  ## Examples

      iex> Vivid.CFF.index(<<2::16, 1::8, 1::8, 3::8, 5::8, "ab", "cd", "rest">>)
      {["ab", "cd"], "rest"}

  An empty INDEX is just a zero count.

      iex> Vivid.CFF.index(<<0::16, "rest">>)
      {[], "rest"}
  """
  @spec index(binary) :: {[binary], binary}
  def index(<<0::16, rest::binary>>), do: {[], rest}

  def index(<<count::16, offset_size::8, rest::binary>>)
      when offset_size in 1..4 and byte_size(rest) >= (count + 1) * offset_size do
    table_size = (count + 1) * offset_size
    <<table::binary-size(^table_size), data::binary>> = rest
    offsets = for <<offset::size(^offset_size)-unit(8) <- table>>, do: offset

    objects =
      offsets
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [from, to] -> binary_slice(data, from - 1, max(to - from, 0)) end)

    {objects, binary_slice(data, (List.last(offsets) - 1)..-1//1)}
  end

  def index(rest), do: {[], rest}

  @doc ~S"""
  Parse a DICT into a map of operator to its operands.

  Operands come *before* the operator they belong to. Operators are a single
  byte, except that a byte of 12 escapes into a second byte, in which case the
  key is a two element tuple.

  ## Example

  `139` encodes zero, and `17` is the operator saying where the charstrings are.

      iex> Vivid.CFF.dict(<<139, 17>>)
      %{17 => [0]}
  """
  @spec dict(binary) :: %{(integer | {integer, integer}) => [number]}
  def dict(binary), do: dict(binary, [], %{})

  defp dict(<<>>, _operands, parsed), do: parsed

  defp dict(<<12::8, operator::8, rest::binary>>, operands, parsed),
    do: dict(rest, [], Map.put(parsed, {12, operator}, Enum.reverse(operands)))

  defp dict(<<operator::8, rest::binary>>, operands, parsed) when operator <= 21,
    do: dict(rest, [], Map.put(parsed, operator, Enum.reverse(operands)))

  defp dict(<<28::8, value::16-signed, rest::binary>>, operands, parsed),
    do: dict(rest, [value | operands], parsed)

  defp dict(<<29::8, value::32-signed, rest::binary>>, operands, parsed),
    do: dict(rest, [value | operands], parsed)

  defp dict(<<30::8, rest::binary>>, operands, parsed) do
    {value, rest} = real(rest, [])
    dict(rest, [value | operands], parsed)
  end

  defp dict(<<value::8, rest::binary>>, operands, parsed) when value in 32..246,
    do: dict(rest, [value - 139 | operands], parsed)

  defp dict(<<value::8, low::8, rest::binary>>, operands, parsed) when value in 247..250,
    do: dict(rest, [(value - 247) * 256 + low + 108 | operands], parsed)

  defp dict(<<value::8, low::8, rest::binary>>, operands, parsed) when value in 251..254,
    do: dict(rest, [-(value - 251) * 256 - low - 108 | operands], parsed)

  defp dict(<<_reserved::8, rest::binary>>, operands, parsed), do: dict(rest, operands, parsed)

  defp real(<<high::4, low::4, rest::binary>>, digits) do
    case {nibble(high), nibble(low)} do
      {:end, _} -> {to_float(digits), rest}
      {first, :end} -> {to_float([first | digits]), rest}
      {first, second} -> real(rest, [second, first | digits])
    end
  end

  defp real(<<>>, digits), do: {to_float(digits), <<>>}

  defp nibble(value) when value in 0..9, do: Integer.to_string(value)
  defp nibble(0xA), do: "."
  defp nibble(0xB), do: "E"
  defp nibble(0xC), do: "E-"
  defp nibble(0xE), do: "-"
  defp nibble(0xF), do: :end
  defp nibble(_reserved), do: ""

  defp to_float(digits) do
    digits
    |> Enum.reverse()
    |> Enum.join()
    |> Float.parse()
    |> case do
      {value, _rest} -> value
      :error -> 0.0
    end
  end
end
