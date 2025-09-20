import gleam/option.{type Option, None, Some}
import parser as cnon

type Recipe {
  Recipe(pattern: cnon.Canonical, effect: cnon.Canonical)
}

pub opaque type Runtime {
  Runtime(input: cnon.Canonical, focus: cnon.Canonical, recipes: List(Recipe))
}

/// Given an input string, return a Runtime ready to process this string
pub fn new(s: String) -> Runtime {
  let canon = cnon.canonicalize(s)
  Runtime(canon, canon, [])
}

/// Add a recipe
fn remember(
  r: Runtime,
  pattern: cnon.Canonical,
  effect: cnon.Canonical,
) -> Runtime {
  Runtime(..r, recipes: [Recipe(pattern, effect), ..r.recipes])
}

/// Refocus the runtime on a different part of the input
fn refocus(r: Runtime, foc: cnon.Canonical) {
  Runtime(..r, focus: foc)
}

/// Eat a recipe under the focus, or fail and return None
pub fn eat_recipe(r: Runtime) -> Option(Runtime) {
  use #(tok1, rest1) <- cnon.gaze_then(r.focus)
  case cnon.uncanon(tok1) {
    "<>" -> {
      use #(pattern, rest2) <- cnon.gaze_then(rest1)
      use #(effect, _rest3) <- cnon.gaze_then(rest2)
      r |> remember(pattern, effect) |> refocus(r.input) |> Some
    }
    _ -> Some(r)
  }
}

/// Step the runtime forward 1 execution step
pub fn step(r0: Runtime) -> Runtime {
  let r1 = eat_recipe(r0) |> option.unwrap(or: r0)
  let new_focus = case cnon.gaze(r1.focus) {
    cnon.NoMoreInput -> r1.input
    cnon.Peeker(_, rest) -> {
      rest
    }
  }
  r1 |> refocus(new_focus)
}
