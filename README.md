# Vivid

Vivid is a simple 2D rendering library.

I plan to use it to render polygons for display on a
[monochrome 128x64 OLED display from Adafruit](https://www.adafruit.com/products/938).

## Features

  * Supports drawing and manipulating a number of basic 2D primimives.
  * Supports arbitrary transformations shape transformations.
  * Renders shapes onto a buffer.
  * 100% pure Elixir with no dependencies.

## Demo

I implemented a simple ASCII renderer for debugging and testing purposes, so at
any time you can pipe a `Frame` to `IO.puts` and the contents of the buffer will
be rendered and printed onto the screen.

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
@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@  @@@@@@@
@@@@@@@@@@ @@   @@@@
@@@@@@@@@ @@@@@@  @@
@@@@@@@@ @@@@@@@@@
@@@@@@@ @@@@@@@@@@ @
@@@@@@ @@@@@@@@@@ @@
@@@@@ @@@@@@@@@@ @@@
@@@@ @@@@@@@@@@ @@@@
@@@ @@@@@@@@@@ @@@@@
@@ @@@@@@@@@@ @@@@@@
@ @@@@@@@@@@ @@@@@@@
  @@@@@@@@@ @@@@@@@@
@@   @@@@@ @@@@@@@@@
@@@@@  @@ @@@@@@@@@@
@@@@@@@  @@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@
```

## Status

This library is still experimental, but what few features it has work well.