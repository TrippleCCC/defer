// Defers a function to be called after a given callback.
//
// ## Examples
//
// It can be used like a regular function call
// ```gleam
// defer(
//   fn() -> { io.print("last")},
//   fn() -> { io.print("first")},
// )
// ```
//
// Or it can be used with the "use" syntax
// ```gleam
// use <- defer(fn() -> { io.print("last")})
// io.print("first")
// ```
//
// You can also do multiple defers with the "use" syntax.
// ```gleam
// use <- defer(fn() -> { io.print("third")})
// use <- defer(fn() -> { io.print("second")})
// io.print("first")
// ```
//
// Note that when using defer like this, the defered functions will execute
// in the reverse order that they were specified. If you would like defered functions
// to execute in order, consider using `start_defer`.
//
pub fn defer(
  last defer_func: fn() -> something,
  first rest: fn() -> anything,
) -> anything {
  let result = rest()
  defer_func()
  result
}

// Type that holds defered callbacks
pub opaque type DeferContext {
  DeferContext(List(fn() -> Nil))
}

fn new_context() -> DeferContext {
  DeferContext([])
}

fn append_to_context(
  context: DeferContext,
  new_defer_func: fn() -> _,
) -> DeferContext {
  let DeferContext(previous) = context
  DeferContext([new_defer_func, ..previous])
}

fn run_defers(defers: List(fn() -> Nil)) {
  case defers {
    [] -> Nil
    [one] -> one()
    [one, ..rest] -> {
      run_defers(rest)
      one()
    }
  }
}

// Creates a `DeferContext` that can be used to schedule other defers.
//
// By using a `DeferContext`, defered functions can be ran in the order that they are writen in.
// ```gleam
// use ctx <- start_defer(fn() -> { io.print("second")})
// use ctx2 <- add_defer(ctx, fn() -> { io.print("third")})
// use ctx3 <- add_defer(ctx2, fn() -> { io.print("fourth")})
// #(ctx3, io.print("first"))
// ```
// As you can see, the LAST produced context MUST be returned at the end of the block
// along with the type that the block should return
//
// To increase readibility and consiceness, variable shadowing can be used to 
// avoid renaming the context after each call to `add_defer`.
// ```gleam
// use ctx <- start_defer(fn() -> { io.print("second")})
// use ctx <- add_defer(ctx, fn() -> { io.print("third")})
// use ctx <- add_defer(ctx, fn() -> { io.print("fourth")})
// #(ctx3, io.print("first"))
// ```
//
pub fn start_defer(
  defer_func: fn() -> Nil,
  rest: fn(DeferContext) -> #(DeferContext, b),
) -> b {
  let context = new_context() |> append_to_context(defer_func)
  let #(DeferContext(defers), result) = rest(context)
  run_defers(defers)
  result
}

pub fn add_defer(
  context: DeferContext,
  defer_func: fn() -> Nil,
  first: fn(DeferContext) -> #(DeferContext, b),
) -> #(DeferContext, b) {
  let context = append_to_context(context, defer_func)
  first(context)
}
