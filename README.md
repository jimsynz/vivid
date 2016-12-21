# Vivid

Vivid is a simple 2D rendering library.

I plan to use it to render polygons for display on a
[monochrome 128x64 OLED display from Adafruit](https://www.adafruit.com/products/938).

I've never done any graphics programming before, so I'm working my way through the 2D
portions of [this tutorial](https://www.tutorialspoint.com/computer_graphics/index.htm)
and implementing them in Elixir as I go.

Expect this library to take a while to stabilise.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `vivid` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:vivid, "~> 0.1.0"}]
    end
    ```

  2. Ensure `vivid` is started before your application:

    ```elixir
    def application do
      [applications: [:vivid]]
    end
    ```

