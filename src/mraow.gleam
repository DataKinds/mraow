import canonicalize as cnon
import gleam/list
import gleam/option
import runtime.{type Runtime}
import splitter

// type Recipe {
//   Recipe(List(Token), List(Token))
// }

// fn eatRecipe(stream: List(Token)) -> #(List(Token), option.Option(Recipe)) {
//   todo
// }

fn dbg_peek_all(c: cnon.Canonical) -> Nil {
  case cnon.peek(c) {
    cnon.NoMoreInput -> {
      echo "DONE!"
      Nil
    }
    cnon.Peeker(tok, rest) -> {
      echo tok
      dbg_peek_all(rest)
    }
  }
  Nil
}

pub fn main() -> Nil {
  echo "Hello from mraow!"
  let c =
    echo cnon.canonicalize(
      "(hello             world 1 2345(() ))) owo () () () owo",
    )
  echo cnon.gaze(c)
  echo dbg_peek_all(c)
  let r = echo runtime.new("hello (world (123 ))    ")
  use r1 <- runtime.step(r)
  use r2 <- runtime.step(r1)
  use _r3 <- runtime.step(r2)
  Nil
}
