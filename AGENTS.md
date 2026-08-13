# Vivid

A 2D vector rendering library in pure Elixir. Shapes are composed, optionally
run through a transform pipeline, rasterised into a point set, and written into
a frame buffer. An ASCII renderer is built in, so almost any struct can be piped
to `IO.puts`.

Published on Hex. Source of truth is https://harton.dev/james/vivid, mirrored to
GitHub. PNG output lives in a separate package, `vivid_png`.

## Commands

    mix test              # fast: ~0.2s, 219 tests
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

All 219 tests come from `@doc` and `@moduledoc` examples. This is deliberate:
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
- `mix.exs` declares `elixir: "~> 1.18"`, while `.tool-versions` pins the
  development toolchain (currently Elixir 1.20.3 / Erlang 29). Don't use syntax
  or stdlib functions newer than the floor without raising the requirement
  deliberately.
- The project is in maintenance mode — dependency bumps and warning fixes. Small
  targeted diffs, not refactors.

## Antialiasing

Opt-in, per frame, and off by default: `Frame.samples/2` sets how many samples
per pixel on each axis. **Leave the default at 1.** Every ASCII doctest in the
suite is an aliased rendering, so turning it on globally would rewrite all of
them.

`Vivid.Buffer` implements it by scaling the shape through `Transformable`,
rasterising into correspondingly magnified bounds, then counting how many
subpixels landed in each real pixel and scaling the colour's alpha by that
fraction. Coverage shows up in ASCII output because `RGBA.to_ascii/1` maps
luminance onto a ten character ramp.

That means it needs **no change to the `Vivid.Rasterize` contract**, which still
returns a plain `MapSet` of `Point`s, and no change to any shape.

It works only because shape geometry keeps unrounded float coordinates all the
way to the rasteriser. **Don't round in a `to_shape`, `to_polygon` or
`to_path`** — a shape that rounds its own coordinates has already thrown away
what a sample would have measured, and can't be antialiased. Rounding belongs in
the `Rasterize` impls, which is where geometry becomes pixels; `Point.round/1`
is there for them. Integer counts and sizes — `Circle.to_polygon/1`'s step
count, a frame's dimensions, a byte value — are a different thing and stay
rounded.

Cost is `samples` squared. The known limitation is that shapes tessellating a
curve into line segments (`Circle`, `Arc`, `Bezier`, outline glyphs) pick their
step count from their nominal size, so sampling magnifies the segments instead
of smoothing them.

## Fonts

A font is data: `%Vivid.Font{}` is a map of codepoint to glyph, plus the metrics
to lay them out. `Vivid.Font.line/3` is the only thing that lays text out, and it
asks a glyph three questions through the `Vivid.Font.Glyph` protocol — pen
movement before, pen movement after, and the shape to draw. That protocol is the
only thing keeping stroke fonts and outline fonts from having to know about each
other; a new format needs an impl and nothing else.

`line/3`'s size is in **pixels per em**, not a multiplier, which only works
because each font carries its own `units_per_em`. A Hershey em is defined as 32
units so that its cap height lands at a realistic 0.66 em.

| Module | |
| --- | --- |
| `Vivid.Hershey` | Hershey stroke fonts from `priv/hershey/*.jhf` (32 files: Gothic, cursive, Cyrillic, Greek, Japanese, plus symbol sets). Third-party public-domain data — read-only |
| `Vivid.Font.Char` | a Hershey glyph: pen up/down movements, drawn as `Path`s |
| `Vivid.OpenType` | the sfnt container — magic sniffing, `head`/`maxp`/`loca`/`hhea`/`hmtx`, and dispatch on which outline table a font actually has |
| `Vivid.OpenType.CMap` | `cmap` format 4 only. Reaches 696 of 697 fonts surveyed |
| `Vivid.TrueType.Glyph` | a `glyf` glyph: quadratic contours, plus composites |
| `Vivid.CFF` / `.Charstring` / `.Glyph` | PostScript outlines: INDEX and DICT structures, and the Type 2 charstring interpreter |

**OpenType is the container; TrueType and CFF are the two outline formats it can
carry.** That's why `Vivid.OpenType.load/1` reads `.ttf`, `.otf` and `.ttc`
alike, and why the glyph modules keep the outline format's name. Which parser
runs is decided by the tables present, not by the file's magic number.

Both glyph kinds hold a slice of their font and parse outlines **on demand**;
they carry the whole font because composites and subroutines refer to other
glyphs. Both therefore need an `Inspect` impl, or one missing character prints
an entire font.

Outline glyphs rasterise as `Vivid.Region`, so counters come out as holes under
the winding rule rather than as filled blobs.

A font that can't be read is reported with a reason worth showing a user —
never a `MatchError`. Two fixtures in `priv/fonts` are the same ten Roboto
glyphs in both outline formats, so the two parsers can be diffed against each
other. Format variants they can't reach (`cmap`'s `idRangeOffset` path, CFF's
INDEX and DICT) are doctested against hand-built binaries instead, which
documents the format better than a fixture does.

Not supported, deliberately: WOFF/WOFF2 (Brotli can't be decompressed in pure
Elixir), variable font axes (a variable font still renders at its default
instance), CID-keyed CFF, CFF2, `cmap` format 12, GPOS/GSUB shaping, and
kerning — 88% of fonts keep kerning in `GPOS` and only 4% in the legacy `kern`
table, so `kern` alone would buy almost nothing.

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

`fill/2` also takes a **list** of polygons, which puts every contour's edges on
the same scanline and into the same winding count. A contour wound against the
one enclosing it therefore cuts a hole with no special handling, which is what
`Vivid.Region` is built on and what makes the counter in an `o` come out empty.
A `Group` of filled polygons is *not* the same thing: it fills each ring in
ignorance of the others.

Any change here needs doctests covering sloped edges of **both** slope signs, a
concave shape and a self-intersecting one. The rectilinear example alone
exercises none of the interpolation code.
