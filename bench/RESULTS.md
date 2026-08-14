# Nx spike: measurements

All on one machine (AMD Ryzen 5 4500U, Elixir 1.20.3 / OTP 29), via
`bench/render.exs`. "scalar" is `bitmap-fonts`, the commit this branch was cut
from, running the same script unchanged. Each figure is the average of a 3s run
rendering to `Buffer.to_binary/1`.

Reproduce with:

    mix run bench/render.exs                     # Nx.BinaryBackend
    VIVID_BACKEND=exla mix run bench/render.exs  # EXLA, with `defn` compiled

`VIVID_SIZES`, `VIVID_SAMPLES` and `VIVID_SCENES` narrow it down.

## One sample per pixel

| scene              |   scalar | Nx binary |    EXLA | EXLA vs scalar |
| ------------------ | -------: | --------: | ------: | -------------: |
| **256x128**        |          |           |         |                |
| circle outline     |   5.98ms |   422.5ms |  4.91ms |          1.2x  |
| transform pipeline |   6.47ms |   414.4ms |  5.53ms |          1.2x  |
| stroke text        |   6.36ms |   421.8ms | 16.35ms |          0.4x  |
| outline text       |   9.81ms |   706.8ms | 33.93ms |          0.3x  |
| filled polygon     |  10.07ms |   609.1ms |  8.16ms |          1.2x  |
| 32 lines           |  11.25ms |   427.1ms | 25.82ms |          0.4x  |
| **1024x512**       |          |           |         |                |
| circle outline     |  251.4ms |         - | 30.34ms |          8.3x  |
| transform pipeline |  194.2ms |         - | 30.95ms |          6.3x  |
| stroke text        |  223.3ms |         - | 45.84ms |          4.9x  |
| outline text       |  235.8ms |         - | 86.04ms |          2.7x  |
| filled polygon     |  250.7ms |         - | 44.03ms |          5.7x  |
| 32 lines           |  221.1ms |         - | 54.23ms |          4.1x  |

## Supersampled

| scene                       |       scalar |    EXLA |
| --------------------------- | -----------: | ------: |
| filled polygon 1024x512 @2x | 960ms, 566MB | 85.62ms |

**11.2x faster.** Sampling multiplies the work per pixel, which is exactly what
the tensor version absorbs for free and the scalar version pays for in `Point`
structs it never keeps.

## Backends

The doctests are the visual regression suite, so running them against a backend
is how a backend is checked. `test/test_helper.exs` reads `VIVID_BACKEND` and
`VIVID_COMPILER`:

| configuration                                   | result       |
| ----------------------------------------------- | ------------ |
| `Nx.BinaryBackend`, `Nx.Defn.Evaluator`         | 258 passed   |
| `EXLA.Backend`, `Nx.Defn.Evaluator`             | 258 passed   |
| `EXLA.Backend`, `compiler: EXLA`                | 258 passed   |
| `Torchx.Backend`, `Nx.Defn.Evaluator`           | 258 passed   |

Torchx has no `defn` compiler, so it runs under the evaluator; the `defn` in
`Vivid.Buffer` is written so that it works either way. EMLX was not tested - it
is macOS only. Neither was EXLA on a GPU client, for want of one.

### Torchx rounds ties differently, and it mattered

`Nx.round/1` does not specify which way it breaks a tie, and the backends
disagree:

| input   | `Kernel.round/1` | BinaryBackend | EXLA | Torchx |
| ------- | ---------------: | ------------: | ---: | -----: |
| `0.5`   |                1 |             1 |    1 |  **0** |
| `2.5`   |                3 |             3 |    3 |  **2** |
| `-2.5`  |               -3 |            -3 |   -3 | **-2** |

Torchx rounds half to even. Pixel coordinates and colour channels are rounded
throughout, and a tie is not a rare accident - the DDA lands on one whenever a
segment's length divides evenly into an odd multiple of a half pixel. Eleven
doctests rendered differently under Torchx before this was fixed.

`Vivid.Math.round_half_away/1` implements the `Kernel.round/1` behaviour out of
`abs`, `floor` and `sign`, none of which have any tie to break, so it agrees
everywhere. Every place that rounds a tensor goes through it.

It is a `defn`, which is worth 1.59x on a whole render over the same function
left as plain `Nx` calls - five operations each materialising an intermediate,
where `Nx.round/1` had been one. Measured interleaved in a single run, because a
sequential A/B of the two got the answer backwards: an unrelated job started on
the machine between the two runs and swamped the difference.

Everything else the rasteriser leans on agreed across all three: f64 is honoured
rather than silently downcast, `indexed_put` with duplicate indices writes
rather than accumulating, `indexed_add` with duplicate indices accumulates, and
`cumulative_sum` runs left to right.

## What moved the numbers

Three changes, in the order they were made and worth:

**1. Batching line rasterisation.** Unioning a frame-sized coverage per line
segment made an outline O(edges x area) where the point set it replaced was
O(perimeter). Placing a shape's segments together took the 1024x512 outline from
3656ms to 195ms - **18.8x**.

**2. `Buffer.over/3` as a `defn`.** The single largest win, and the surprise: the
dominant cost was never rasterisation, it was compositing. As plain `Nx` it was a
dozen operations each materialising a whole frame; fused into one kernel it is
**4-6x** on every scene, and it is what takes the shape scenes from losing to
winning. It cost about twenty lines.

**3. Coverage as unmaterialised placements.** `union/2` concatenates pixel
placements instead of combining grids, so a deep shape (text is a group of
glyphs, each a group of contours) writes its grid once rather than once per
primitive. Worth **2.8x** on stroke text and **3.0x** on `32 lines`.

Plus restoring the fill's scanline clipping, which the first vectorisation had
dropped: a fill now computes a winding number only over the part of the bounds
its contours reach, and pads the rest. Worth 1.3x on outline text.

## Where the remaining time goes

`Nx.BinaryBackend` is **40-70x slower** than the scalar code and is not a
candidate for anything but checking correctness. `defn` does not help it - with
no compiler configured it runs under `Nx.Defn.Evaluator`, which has nothing to
fuse. This approach is EXLA or nothing.

The crossover is around a quarter of a megapixel. Below it EXLA's per-operation
dispatch is not amortised and the scalar code is competitive or better; above it
the tensor version wins by 3-8x, and by 11x once sampling is on.

`outline text` is the weakest case because eight glyphs mean eight separate
fills, each contributing a grid that has to be combined rather than a placement
that can be concatenated. Batching fills across a group is the obvious next
move and has not been attempted.

## Why the shapes were not rewritten to hold tensors

This was the third change planned, and measurement says not to. Once
rasterisation and compositing were vectorised, building the geometry is a
rounding error in every workload measured:

| workload                       | build shape |  render | build as % |
| ------------------------------ | ----------: | ------: | ---------: |
| transform pipeline, 256 points |       277us |  5.53ms |       5.0% |
| stroke text, 8 glyphs          |        34us | 16.35ms |       0.2% |
| outline text, 8 glyphs         |       565us | 33.93ms |       1.7% |
| stroke text, 200 glyphs @1024x512 |    1.15ms |   257ms |       0.4% |

Making that free buys at most 5%, against a change that would break `Enumerable`,
`Collectable`, `Inspect`, the `%Point{}` API and a large number of doctests.

The one thing tensor-backed vertices were supposed to unlock - folding a
transform pipeline's affine matrices into a single matmul - turns out to be
blocked by something else entirely. `Transform.scale/2`, `rotate/2`, `center/2`,
`fill/2`, `stretch/2` and `overflow/2` all derive their origin from
`Bounds.center_of(shape)` **as the shape stands at that point in the pipeline**,
and the axis-aligned bounds of a rotated shape are not the rotation of its
bounds. So the intermediate shape genuinely has to exist between operations, and
the passes cannot be collapsed without changing what the operations mean. That
is a property of the transform API, not of the representation, and no amount of
tensor backing fixes it.
