# Vivid

[![Build Status](https://travis-ci.org/jamesotron/vivid.ex.svg?branch=master)](https://travis-ci.org/jamesotron/vivid.ex)
[![Inline docs](https://inch-ci.org/github/jamesotron/vivid.ex.svg)](https://inch-ci.org/github/jamesotron/vivid.ex)

Vivid is a simple 2D rendering library.

## Features

  * Supports drawing and manipulating a number of basic 2D primitives.
  * Supports filling arbitrary polygons.
  * Supports arbitrary transformations shape transformations.
  * Renders shapes onto a buffer.
  * 100% pure Elixir with no dependencies.
  * Render to PNG using [vivid_png](https://github.com/jamesotron/vivid_png.ex).

## Demo

I implemented a simple ASCII renderer for debugging and testing purposes, so at
any time you can pipe almost any Vivid struct to `IO.puts` and the contents of
the buffer will be rendered and printed onto the screen.

### Basic drawing

Frames behave as a simple collection of shapes and colours, which you can simply
push on to.

```elixir
use Vivid
Frame.init(10,10, RGBA.white)
|> Frame.push(Circle.init(Point.init(5,5), 4), RGBA.black)
|> IO.puts
```

```
@@@@   @@@
@@  @@@  @
@@ @@@@@ @
@ @@@@@@@
@ @@@@@@@
@ @@@@@@@
@@ @@@@@ @
@@  @@@  @
@@@@   @@@
@@@@@@@@@@
```

### Transformations

Vivid supports a number of standards transforms which can be applied to a shape
before it is added to a frame. It also makes provision for you to write your own.

```elixir
use Vivid
frame = Frame.init(20, 20, RGBA.white)
shape = Box.init(Point.init(0,0), Point.init(5,5))
  |> Transform.rotate(45)
  |> Transform.fill(frame)
  |> Transform.center(frame)
  |> Transform.apply
Frame.push(frame, shape, RGBA.black)
|> IO.puts
```

```
@@@@@@@@@@ @@@@@@@@@
@@@@@@@@@ @ @@@@@@@@
@@@@@@@@ @@@ @@@@@@@
@@@@@@@ @@@@@ @@@@@@
@@@@@  @@@@@@@ @@@@@
@@@@ @@@@@@@@@@ @@@@
@@@ @@@@@@@@@@@@ @@@
@@ @@@@@@@@@@@@@@ @@
@ @@@@@@@@@@@@@@@@ @
 @@@@@@@@@@@@@@@@@@
@ @@@@@@@@@@@@@@@@ @
@@ @@@@@@@@@@@@@@ @@
@@@ @@@@@@@@@@@@ @@@
@@@@ @@@@@@@@@@ @@@@
@@@@@ @@@@@@@@@ @@@@
@@@@@@ @@@@@@@ @@@@@
@@@@@@@ @@@@@ @@@@@@
@@@@@@@@ @@@ @@@@@@@
@@@@@@@@@ @ @@@@@@@@
@@@@@@@@@@ @@@@@@@@@
```

## License

Source code is licensed under the terms of the MIT license, the text of which
is included in the `LICENSE` file in this distribution.

This distribution includes the Hershey vector font from
[The Hershey Fonts](http://sol.gfxile.net/hershey/index.html).

Font use restrictions:

```
 This distribution of the Hershey Fonts may be used by anyone for
  any purpose, commercial or otherwise, providing that:
    1. The following acknowledgements must be distributed with
      the font data:
      - The Hershey Fonts were originally created by Dr.
        A. V. Hershey while working at the U. S.
        National Bureau of Standards.
      - The format of the Font data in this distribution
        was originally created by
          James Hurt
          Cognition, Inc.
          900 Technology Park Drive
          Billerica, MA 01821
          (mit-eddie!ci-dandelion!hurt)
    2. The font data in this distribution may be converted into
      any other format *EXCEPT* the format distributed by
      the U.S. NTIS (which organization holds the rights
      to the distribution and use of the font data in that
      particular format). Not that anybody would really
      *want* to use their format... each point is described
      in eight bytes as "xxx yyy:", where xxx and yyy are
      the coordinate values as ASCII numbers.
```

## Status

This library is now in use in several projects and seems to work well.

Future improvements include:

  - Improve `Vivid.SLPFA`.
  - Add transformations which can apply rotation matrices directly.
  - Add ability to composit multiple frames together.
  - Support bitmaps as a shape.
