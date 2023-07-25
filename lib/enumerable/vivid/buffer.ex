defimpl Enumerable, for: Vivid.Buffer do
  alias Vivid.Buffer

  @moduledoc """
  Implements the Enumerable protocol for Buffer.
  """

  @doc """
  Returns the number of pixels in a buffer.
  """
  @impl true
  def count(%Buffer{buffer: buffer}), do: {:ok, Enum.count(buffer)}

  @doc """
  Returns whether a colour is a member of a buffer.
  This is mostly useless, but it's part of the Enumerable protocol.
  """
  @impl true
  def member?(%Buffer{buffer: buffer}, colour), do: {:ok, Enum.member?(buffer, colour)}

  @doc """
  Reduce the buffer into an accumulator.
  """
  @impl true
  def reduce(%Buffer{buffer: buffer}, acc, fun), do: Enumerable.List.reduce(buffer, acc, fun)

  @doc """
  Slice the buffer.
  """
  @impl true
  def slice(%Buffer{buffer: buffer}), do: Enumerable.List.slice(buffer)
end
