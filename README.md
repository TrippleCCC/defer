# defer

A simple library for adding defer functionality to gleam.

[![Package Version](https://img.shields.io/hexpm/v/defer)](https://hex.pm/packages/defer)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/defer/)

## Installation
```sh
gleam add defer
```

## Usage

defer is easy to use! (ha, ha get it?)
```gleam
import defer

pub fn main() {
  use <- defer(fn() { io.println("1") })
  use <- defer(fn() { io.println("2") })
  use <- defer(fn() { io.println("3") })
  io.println("4")
}
```
```sh
4
3
2
1
```

Note that the defers execute in reverse! If you don't care about the order of your defers then
this is fine. However, If you would like the defers to execute in order then use `start_defer`
instead.
```gleam
import defer

pub fn main() {
  use ctx <- start_defer(fn() { io.println("1") })
  use ctx <- add_defer(ctx, fn() { io.println("2") })
  use ctx <- add_defer(ctx, fn() { io.println("3") })
  #(ctx, io.println("4"))
}
```
```sh
4
1
2
3
```

Further documentation can be found at <https://hexdocs.pm/defer>.

## Development

This library is still a work in progress so feel free to suggest ways to make the api more
ergonomic and features that should be added.

```sh
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```