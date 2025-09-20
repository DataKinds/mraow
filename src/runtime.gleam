import canonicalize as cnon

pub opaque type Runtime {
  Runtime(input: cnon.Canonical, focus: cnon.Canonical)
}

/// Given an input string, return a Runtime ready to process this string
pub fn new(s: String) -> Runtime {
  let canon = cnon.canonicalize(s)
  Runtime(canon, canon)
}

/// Step the runtime forward 1 execution step
pub fn step(r: Runtime, callback: fn(Runtime) -> Nil) -> Nil {
  let new_focus = case cnon.peek(r.focus) {
    cnon.NoMoreInput -> r.input
    cnon.Peeker(tok, rest) -> {
      echo tok
      rest
    }
  }
  let r_upd = Runtime(..r, focus: new_focus)
  callback(r_upd)
}
