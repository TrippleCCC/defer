import gleam/erlang/process.{type Subject}
import gleam/otp/actor

import defer.{add_defer, defer, start_defer}
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

type Message(element) {
  Push(push: element)
  Get(reply_with: Subject(Result(List(element), Nil)))
}

fn handle_message(
  message: Message(e),
  stack: List(e),
) -> actor.Next(Message(e), List(e)) {
  case message {
    Push(value) -> {
      let new_state = [value, ..stack]
      actor.continue(new_state)
    }

    Get(client) -> {
      process.send(client, Ok(stack))
      actor.continue(stack)
    }
  }
}

pub fn defer_test() {
  let assert Ok(actor) = actor.start([], handle_message)

  {
    use <- defer(fn() { process.send(actor, Push(1)) })
    use <- defer(fn() { process.send(actor, Push(2)) })
    use <- defer(fn() { process.send(actor, Push(3)) })
    process.send(actor, Push(4))
  }

  let assert Ok(res) = process.call(actor, Get, 10)

  res |> should.equal([1, 2, 3, 4])
}

pub fn defer_context_test() {
  let assert Ok(actor) = actor.start([], handle_message)

  {
    use ctx <- start_defer(fn() { process.send(actor, Push(1)) })
    use ctx <- add_defer(ctx, fn() { process.send(actor, Push(2)) })
    use ctx <- add_defer(ctx, fn() { process.send(actor, Push(3)) })
    #(ctx, process.send(actor, Push(4)))
  }

  let assert Ok(res) = process.call(actor, Get, 10)

  res |> should.equal([3, 2, 1, 4])
}

pub fn defer_context_with_inner_statements_test() {
  let assert Ok(actor) = actor.start([], handle_message)

  {
    use ctx <- start_defer(fn() { process.send(actor, Push(1)) })
    process.send(actor, Push(4))
    use ctx <- add_defer(ctx, fn() { process.send(actor, Push(2)) })
    process.send(actor, Push(4))
    use ctx <- add_defer(ctx, fn() { process.send(actor, Push(3)) })
    #(ctx, process.send(actor, Push(4)))
  }

  let assert Ok(res) = process.call(actor, Get, 10)

  res |> should.equal([3, 2, 1, 4, 4, 4])
}
