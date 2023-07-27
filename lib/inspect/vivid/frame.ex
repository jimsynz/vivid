defimpl Inspect, for: Vivid.Frame do
  alias Vivid.Frame
  import Inspect.Algebra

  @doc """
  Defines the inspect protocol for `Frame`.
  """
  @impl true
  def inspect(frame, opts) do
    width = Frame.width(frame)
    height = Frame.height(frame)
    colour = Frame.background_colour(frame)

    concat([
      "Vivid.Frame.new(",
      to_doc([width: width, height: height, background_colour: colour], opts),
      ")"
    ])
  end
end
