use Vivid

# Runs unchanged on `main` and on the Nx spike, so the two can be compared
# directly. Nothing here may reference anything the scalar version doesn't have.
#
#     mix run bench/render.exs                    # whatever Nx defaults to
#     VIVID_BACKEND=exla mix run bench/render.exs # ... or XLA, on the spike
#
# `VIVID_SIZES` and `VIVID_SAMPLES` narrow it down while iterating.

backend = System.get_env("VIVID_BACKEND", "default")

if backend == "exla" do
  unless Code.ensure_loaded?(EXLA.Backend), do: raise("EXLA is not available")
  Nx.global_default_backend(EXLA.Backend)
end

sizes =
  System.get_env("VIVID_SIZES", "64x32,256x128,1024x512")
  |> String.split(",")
  |> Enum.map(fn size ->
    [w, h] = size |> String.split("x") |> Enum.map(&String.to_integer/1)
    {size, w, h}
  end)

samples =
  System.get_env("VIVID_SAMPLES", "1,2")
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

outline = fn w, h ->
  Circle.init(Point.init(w / 2, h / 2), min(w, h) / 2.2)
end

filled = fn w, h ->
  Polygon.init(
    [
      Point.init(w * 0.1, h * 0.1),
      Point.init(w * 0.9, h * 0.2),
      Point.init(w * 0.5, h * 0.95),
      Point.init(w * 0.3, h * 0.4),
      Point.init(w * 0.7, h * 0.4)
    ],
    true
  )
end

strokes = fn w, h ->
  Group.init(
    for i <- 0..31 do
      Line.init(Point.init(0, i * h / 32), Point.init(w, h - i * h / 32))
    end
  )
end

scenes =
  [
    {"circle outline", outline},
    {"filled polygon", filled},
    {"32 lines", strokes}
  ]
  |> Enum.filter(fn {scene, _} ->
    case System.get_env("VIVID_SCENES") do
      nil -> true
      wanted -> String.contains?(wanted, scene)
    end
  end)

frame = fn w, h, sample_count, shape ->
  Frame.init(w, h, RGBA.white())
  |> Frame.samples(sample_count)
  |> Frame.push(shape.(w, h), RGBA.black())
end

jobs =
  for {scene, shape} <- scenes,
      {size, w, h} <- sizes,
      sample_count <- samples,
      into: %{} do
    label = "#{scene} #{size} @#{sample_count}x"
    {label, fn -> frame.(w, h, sample_count, shape) |> Frame.buffer() |> Buffer.to_binary() end}
  end

IO.puts("backend: #{backend}")

Benchee.run(jobs,
  warmup: 1,
  time: 3,
  memory_time: 1,
  print: [fast_warning: false]
)
