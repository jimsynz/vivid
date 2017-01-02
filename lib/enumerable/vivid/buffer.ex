defimpl Enumerable, for: Vivid.Buffer do
  alias Vivid.Buffer

  @moduledoc """
  Implements the Enumerable protocol for Buffer.
  """

  @doc """
  Returns the number of pixels in a buffer.
  """
  def count(%Buffer{buffer: buffer}), do: {:ok, Enum.count(buffer) }

  @doc """
  Returns whether a colour is a member of a buffer.
  This is mostly useless, but it's part of the Enumerable protocol.
  """
  def member?(%Buffer{buffer: buffer}, colour), do: {:ok, Enum.member?(buffer, colour) }

  @doc """
  Reduce the buffer into an accumulator.
  """
  def reduce(%Buffer{buffer: buffer}, acc, fun), do: Enumerable.List.reduce(buffer, acc, fun)
end