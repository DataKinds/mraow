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
pub fn step(r: Runtime) -> Runtime {
  let new_focus = case cnon.gaze(r.focus) {
    cnon.NoMoreInput -> r.input
    cnon.Peeker(_, rest) -> {
      rest
    }
  }
  Runtime(..r, focus: new_focus)
}
