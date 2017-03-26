# Getting Started with Vivid

Vivid is designed to be as straightforward to use as possible whilst still providing enough features to be useful.  It was originally concieved for displaying graphics and text on [Monochrome 1.3" 128x64 OLED graphic display from Adafruit](https://www.adafruit.com/products/938), which it does.

![4 x OLED display clock using Hershey vector fonts](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/vivid_clock.jpg)

The scope quickly expanded to include arbitrary transforms, basic colour compositing and alpha channels.  I even added [`vivid_png`](https://github.com/jamesotron/vivid_png.ex) for writing out PNG files.

## Adding `vivid` to your app

Edit your `mix.exs` and add [the current version of `vivid`](https://hex.pm/packages/vivid) to your `dependencies` list.

If you want to be able to render PNG files then you also want to add
[`vivid_png`](https://hex.pm/packages/vivid_png).

## General principals

Vivid tries to consistently reuse a bunch of principals thoughout the code base;

  * All "shape" types, e.g. boxes, circles and polygons have an `init` function which will generate the shape with as many sane defaults as possible.  The corresponding modules also contain functions for manipulating the contents of the shape without needing to know the internal structure of the type.  Vivid discourages the use of type structs directly as these are subject to change.

  * Most of the stuff you want to *do* with shapes, like render, transform or measure are implemented with Elixir protocols, meaning you can define your own shape types as required.

  * The `String.Chars` protocol has been implemented everywhere it makes sense, so that you can easily debug by just calling `to_string/1` or `IO.puts/1` on almost any type.

  * If you `use Vivid` at the top of your module it will automatically add aliases for all the core Vivid types into your local namespace. This can save a lot of typing, but otherwise doesn't do much.

## Basic shapes

Vivid implements a number of basic geometric primitives upon which you can compose your own shapes as needed.

### Point

The most basic type is the [`Point`](https://hexdocs.pm/vivid/Vivid.Point.html#content), which represents a location in 2 dimensional cartesian space (ie `x` and `y` offset).

    iex> use Vivid
    ...> Point.init(13, 27)
    #Vivid.Point<{13, 27}>
![point example](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/point_example.png)

### Line

A [Line](https://hexdocs.pm/vivid/Vivid.Line.html#content) represents a straight line between to points, called `origin` and `termination` in Vivid parlance.

    iex> use Vivid
    ...> Line.init(Point.init(13,27), Point.init(2,3))
    #Vivid.Line<[origin: #Vivid.Point<{13, 27}>, termination: #Vivid.Point<{2, 3}>]>
![line example](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/line_example.png)

### Path

A [Path](https://hexdocs.pm/vivid/Vivid.Path.html#content) represents an aribitrary number of vertices (points) with lines connecting them.  A Path is different to a Polygon in that a Polygon is closed and a Path is open.

A Path must consist of at least two vertices.

    iex> use Vivid
    ...> Path.init([Point.init(13,27), Point.init(2,3), Point.init(27,13)])
    #Vivid.Path<[#Vivid.Point<{13, 27}>, #Vivid.Point<{2, 3}>, #Vivid.Point<{27, 13}>]>

![path example](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/path_example.png)

### Polygon

A [Polygon](https://hexdocs.pm/vivid/Vivid.Polygon.html#content) also represents an arbitrary number of vertices (points) with lines connecting them, however a Polygon is a closed shape.  As such, polygon's must have at least three vertices.

    iex> use Vivid
    ...> Polygon.init([Point.init(13,27), Point.init(2,3), Point.init(27,13)])
    #Vivid.Polygon<[#Vivid.Point<{13, 27}>, #Vivid.Point<{2, 3}>, #Vivid.Point<{27, 13}>]>

![polygon example](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/polygon_example.png)

### Box

A [Box](https://hexdocs.pm/vivid/Vivid.Box.html#content) is a special kind of Polygon where there are exactly four vertices and two lines are horizontal and two lines are vertical, i.e. a rectangle. But you knew that.

Because of the regular nature of rectangles they can be defined with only two points.  The first being the lower left corner and the second being the top right corner.

    iex> use Vivid
    ...> Box.init(Point.init(2,3), Point.init(13,27))
    #Vivid.Box<[bottom_left: #Vivid.Point<{2, 3}>, top_right: #Vivid.Point<{13, 27}>]>

![box example](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/box_example.png)

### Circle

I'm sure you know what a [Circle](https://hexdocs.pm/vivid/Vivid.Circle.html#content) is.  It is initialised using a center point and a radius.

Circles are converted to polygons when transforming or rendering, so you can't always rely on being able to use the `Circle` API to manipulate existing shapes.

Often it may be necessary to convert it to a polygon manually before rendering so that you can control the number of vertices in the generated polygon.

    iex> use Vivid
    ...> Circle.init(Point.init(15,15), 10)
    #Vivid.Circle<[center: #Vivid.Point<{15, 15}>, radius: 10]>

![circle example](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/circle_example.png)

### Arc

An [Arc](https://hexdocs.pm/vivid/Vivid.Arc.html#content), also known as a circle segment is a slice of a circle and initialised with a center point and radius much like a circle, however you also provide a start angle and a range (both in degrees) of arc that you wish to render.

Arcs are converted to paths when transforming or rendering, so you can't always rely on being able to use the `Arc` API to manipulate existing shapes.

You can optionally also specify the number of steps used during path generation in the initialiser.

    iex> use Vivid
    ...> Arc.init(Point.init(15,15), 45, 90)
    #Vivid.Arc<[center: #Vivid.Point<{15, 15}>, radius: 10, start_angle: 45, range: 90, steps: 12]>

![arc example](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/arc_example.png)

### Group

A [Group](https://hexdocs.pm/vivid/Vivid.Group.html#content) allows for arbitrary composition of shapes into a single data structure.  It's not so much a shape itself, as a collection of other shapes.

    iex> use Vivid
    ...> box = Box.init(Point.init(2,3), Point.init(13,27))
    ...> circle = Circle.init(Point.init(15,15), 10)
    ...> Group.init([box, circle])
    #Vivid.Group<[#Vivid.Box<[bottom_left: #Vivid.Point<{2, 3}>, top_right: #Vivid.Point<{13, 27}>]>, #Vivid.Circle<[center: #Vivid.Point<{15, 15}>, radius: 10]>]>

![group example](https://raw.githubusercontent.com/jamesotron/vivid.ex/add-extra-docs/guides/images/group_example.png)
