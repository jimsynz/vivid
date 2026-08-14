# Nx spike: measurements

All on one machine (AMD Ryzen 5 4500U, Elixir 1.20.3 / OTP 29), via
`bench/render.exs`. "scalar" is `bitmap-fonts`, the commit this branch was cut
from, running the same script. Each figure is the average of a 3s run, rendering
to `Buffer.to_binary/1`.

Reproduce with:

    mix run bench/render.exs                     # Nx.BinaryBackend
    VIVID_BACKEND=exla mix run bench/render.exs  # EXLA

## One sample per pixel

| scene          | size     |  scalar | Nx binary |    EXLA |
| -------------- | -------- | ------: | --------: | ------: |
| circle outline | 64x32    |  0.36ms |   14.67ms |       - |
| filled polygon | 64x32    |  0.60ms |   19.73ms |       - |
| 32 lines       | 64x32    |  1.61ms |   34.52ms |       - |
| circle outline | 256x128  |  5.31ms |  421.82ms | 17.87ms |
| filled polygon | 256x128  | 11.59ms |  517.07ms | 20.79ms |
| 32 lines       | 256x128  | 11.67ms |  869.27ms | 81.05ms |
| circle outline | 1024x512 |   217ms |         - |   195ms |
| filled polygon | 1024x512 |   248ms |         - |   213ms |
| 32 lines       | 1024x512 |   239ms |         - |   449ms |

## Two samples per pixel on each axis

| scene          | size     | scalar | EXLA    |
| -------------- | -------- | -----: | ------- |
| circle outline | 256x128  | 5.98ms | 19.64ms |
| filled polygon | 256x128  | 41.09ms | 25.03ms |
| 32 lines       | 256x128  | 28.07ms | 130.80ms |
| filled polygon | 1024x512 | 1.05s, 565MB | 256ms, 85MB |

## What the numbers say

**`Nx.BinaryBackend` is not a candidate.** It is 30-80x slower than the scalar
code at every size measured. It is a reference implementation and behaves like
one; it is only useful here for checking that the tensor formulations are
correct.

**EXLA wins where there is enough work per pixel to amortise dispatch.** Nothing
here is `defn`-compiled, so every `Nx` call is its own XLA execution, and that
fixed cost per operation is what the small frames are paying. The crossover is
somewhere around a quarter of a megapixel at one sample per pixel, and lower
than that as soon as sampling multiplies the work: a supersampled fill at
1024x512 is **4.1x faster and uses 6.7x less memory**, because the scalar
version builds a `MapSet` of four subpixel `Point` structs for every pixel it
eventually emits, and the tensor version never materialises them.

**Frame-sized unions are the thing to watch.** Rasterising a shape's segments
one at a time and unioning a coverage per segment costs the area of the frame
per segment, where the `MapSet` it replaced cost the length of the segment.
Batching the segments of a `Path`, `Polygon` border and `Region` into a single
placement (`Coverage.from_lines/2`) took the 1024x512 outline from 3656ms to
195ms - an 18.8x difference, and the line between losing badly and edging ahead.

`Vivid.Group` still has that shape: it unions one frame-sized coverage per
member, which is why "32 lines" is the one scene that loses at every size. A
`Group` is heterogeneous by design, so fixing it means partitioning members by
how they rasterise rather than a local change, and it hasn't been attempted
here.
