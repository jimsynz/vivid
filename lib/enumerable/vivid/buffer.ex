defimpl Enumerable, for: Vivid.Buffer do
  alias Vivid.Buffer

  @moduledoc """
  Implements the Enumerable protocol for Buffer.

  The buffer holds its pixels as a tensor, so enumerating one turns them back
  into `Vivid.RGBA` colours. Anything which wants the pixels as numbers should
  reach for the tensor instead.
  """

  @doc """
  Returns the number of pixels in a buffer.
  """
  @impl true
  def count(%Buffer{rows: rows, columns: columns}), do: {:ok, rows * columns}

  @doc """
  Returns whether a colour is a member of a buffer.
  This is mostly useless, but it's part of the Enumerable protocol.
  """
  @impl true
  def member?(%Buffer{} = buffer, colour), do: {:ok, Enum.member?(Buffer.colours(buffer), colour)}

  @doc """
  Reduce the buffer into an accumulator.
  """
  @impl true
  def reduce(%Buffer{} = buffer, acc, fun),
    do: Enumerable.List.reduce(Buffer.colours(buffer), acc, fun)

  @doc """
  Slice the buffer.
  """
  @impl true
  def slice(%Buffer{} = buffer), do: Enumerable.List.slice(Buffer.colours(buffer))
end
