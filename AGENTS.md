# Vivid

A 2D vector rendering library in pure Elixir. Shapes are composed, optionally
run through a transform pipeline, rasterised into a point set, and written into
a frame buffer. An ASCII renderer is built in, so almost any struct can be piped
to `IO.puts`.

Published on Hex. Source of truth is https://harton.dev/james/vivid, mirrored to
GitHub. PNG output lives in a separate package, `vivid_png`.

## Commands

    mix test              # fast: ~0.2s, 173 tests
    mix check --no-retry  # full verification: compiler, format, credo, dialyzer, doctor, mix_audit, ex_unit
    mix format

Always use `mix check` rather than the individual tools. `sobelow` is disabled in
`.check.exs` — there is no web surface here.

## The test suite is doctests, and only doctests

Every file in `test/` is three lines:

```elixir
defmodule Vivid.CircleTest do
  use ExUnit.Case
  doctest Vivid.Circle
end
```

All 173 tests come from `@doc` and `@moduledoc` examples. This is deliberate:
the expected output of a doctest is usually an ASCII rendering, so the docs and
the visual regression tests are the same artefact. Consequences:

- **Write tests by writing docs.** A new public function needs a `## Example`
  with an `iex>` block, not a new `test` block in `test/`.
- **A new module needs a matching test file** whose only job is the `doctest`
  line, or its examples never run.
- Protocol implementations are tested through their generated module names —
  `doctest Vivid.Rasterize.Vivid.Circle`, not `Vivid.Rasterize`.
- Doctests with multi-line ASCII output are written as explicit
  `"...\n" <> "...\n"` concatenations. Match that style; `mix format` will not
  reflow it for you.
- Use `~S"""` for any docstring containing `\n`, or the escape is interpreted at
  compile time and the doctest compares against the wrong string.

`doctor` runs as part of `mix check` and enforces documentation coverage, so
missing `@moduledoc`/`@doc` fails CI regardless.

## Architecture: five protocols, one impl per shape

Shapes are dumb structs. All behaviour is in protocols, which is what makes the
shape set extensible without touching the renderer.

| Protocol | Purpose |
| --- | --- |
| `Vivid.Rasterize` | shape → `MapSet` of `Point`s within given bounds |
| `Vivid.Transformable` | apply a point-mapping function to a shape |
| `Vivid.Bounds.Of` | shape → `{bottom_left, top_right}` |
| `Vivid.Shape` | not a protocol — a typespec union, marks what counts as a shape |

Plus `Enumerable`, `Collectable`, `Inspect` and `String.Chars` for the shapes
where they make sense.

Implementations live in a directory tree mirroring the protocol's module path,
one file per shape:

    lib/vivid/rasterize/circle.ex      defimpl Vivid.Rasterize,    for: Vivid.Circle
    lib/vivid/transformable/circle.ex  defimpl Vivid.Transformable, for: Vivid.Circle
    lib/vivid/bounds/of/circle.ex      defimpl Vivid.Bounds.Of,     for: Vivid.Circle
    lib/inspect/vivid/circle.ex        defimpl Inspect,             for: Vivid.Circle
    lib/enumerable/vivid/polygon.ex    defimpl Enumerable,          for: Vivid.Polygon

Note the two namespaces: `Vivid.*` protocols nest under `lib/vivid/`, whereas
Elixir/Kernel protocols get a top-level directory named after the protocol
(`lib/inspect/`, `lib/enumerable/`, `lib/collectable/`, `lib/string/chars/`).

Most shapes delegate rather than implement geometry twice — `Circle` rasterises
by converting to a `Polygon`, `Box` by converting to a `Polygon`. Prefer adding
a `to_polygon/1` and delegating over writing a new rasteriser.

### Adding a shape

1. `lib/vivid/<shape>.ex` with an `init/n` constructor.
2. Impls for `Bounds.Of`, `Rasterize`, `Transformable`, `Inspect`.
3. Add the type to the union in `lib/vivid/shape.ex`.
4. Add the alias to the `__using__` list in `lib/vivid.ex`.
5. Add it to the shape list at the bottom of `lib/string/chars/vivid/shape.ex`
   if it should be `IO.puts`-able directly.
6. Add `test/vivid/<shape>_test.exs` with the `doctest` lines.

## Conventions and gotchas

- **No runtime dependencies, and it stays that way.** Everything in `deps` is
  `only: [:dev, :test], runtime: false`. "100% pure Elixir with no dependencies"
  is a feature in the README. Don't add one without asking.
- **Y is up.** Coordinates are mathematical, not screen-space. `String.Chars`
  for `Buffer` reverses the buffer before chunking to flip it for display
  (`lib/string/chars/vivid/buffer.ex`). Off-by-one and inverted output almost
  always traces back to this.
- **`Vivid.Math`** wraps the bits of Erlang's `:math` this library needs plus
  `degrees_to_radians/1`. Angles in the public API are degrees. `import
  Vivid.Math` rather than reaching for `:math` directly.
- **`Vivid.Transform` is lazy.** Operations accumulate in a struct and nothing
  runs until `Transform.apply/1`. Forgetting the `apply` yields a `%Transform{}`
  where a shape was expected.
- **Version and changelog are generated.** `git_ops` manages the version in
  `mix.exs` and writes `CHANGELOG.md` below the `<!-- changelog -->` marker.
  Don't hand-edit either. Conventional commit messages drive the release.
- `mix.exs` declares `elixir: "~> 1.3"` for the widest possible support range,
  while `.tool-versions` pins the development toolchain (currently Elixir 1.20.3
  / Erlang 29). Don't use syntax or stdlib functions newer than the floor
  without raising the requirement deliberately.
- The project is in maintenance mode — dependency bumps and warning fixes. Small
  targeted diffs, not refactors.

## Fonts

`Vivid.Hershey` parses Hershey vector fonts from `priv/hershey/*.jhf` (32 files:
Gothic, cursive, Cyrillic, Greek, Japanese, plus astrology, meteorology and
music symbol sets). `Vivid.Font` and `Vivid.Font.Char` wrap it. The `.jhf` files
are third-party public-domain data — treat them as read-only.

## Polygon filling

`Vivid.Polygon.Fill` computes the filled area by scanline conversion: intersect
the edges with each scanline, sort by `x`, fill the spans between them under the
**non-zero winding rule** (as PostScript, PDF, SVG and Canvas do). Two details
carry the correctness and shouldn't be "tidied":

- Edges are tested over the **half-open interval** `y_min <= y < y_max`. This
  counts a pass-through vertex once and a local extremum not at all, so vertices
  sitting exactly on a scanline need no special case, and horizontal edges are
  excluded by the same test. Closing that interval reintroduces double-counted
  vertices.
- Intersections are computed in **floats** from unrounded vertices. Rounding
  vertices before filling makes the fill disagree with the Bresenham border and
  produces 1px gaps.

`fill/1` returns the *whole* area including the pixels the edges pass through,
and `Vivid.Rasterize` unions it with the rasterised border. An earlier version
returned the interior only, which required the excluded pixels to exactly equal
the border rasterisation — impossible in general, since Bresenham paints a run
of pixels per scanline on a shallow slope while the fill excludes one. Don't go
back to that contract; for a border-less fill use
`MapSet.difference(fill, border)` against the actual rasterised border.

Because winding direction decides what is inside, `Polygon` vertex order is
semantically meaningful for self-intersecting polygons. Don't normalise edge
direction anywhere in the fill path — it destroys the winding information.

Any change here needs doctests covering sloped edges of **both** slope signs, a
concave shape and a self-intersecting one. The rectilinear example alone
exercises none of the interpolation code.
