import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/string_tree
import splitter

/// Precondition for constructing one of these:
/// This string MUST have all its whitespace normalized
/// That is to say: no spaces at the start, no spaces at the end, 1 space between terms
pub opaque type Canonical {
  Canonical(canon: String)
}

fn lexer() -> splitter.Splitter {
  splitter.new(["(", ")", " "])
}

fn wordsplitter() -> splitter.Splitter {
  splitter.new([" "])
}

fn tokenize_rec(lexer, x: String) -> List(String) {
  let #(pre, split, post) = splitter.split(lexer, x)
  case pre, split {
    " ", "" | "", "" -> []
    tok, "" -> [tok]
    "", " " -> tokenize_rec(lexer, post)
    "", tok -> [tok, ..tokenize_rec(lexer, post)]
    term, " " -> [term, ..tokenize_rec(lexer, post)]
    term, tok -> [term, tok, ..tokenize_rec(lexer, post)]
  }
}

fn tokenize(x: String) -> List(String) {
  let lexer = lexer()
  tokenize_rec(lexer, x)
}

/// Take an input string and "canonicalize" it, AKA make sure every term only has 1 space between them,
/// and also make sure there are no spaces at the start or end of the input 
pub fn canonicalize(x: String) -> Canonical {
  x |> tokenize |> string.join(" ") |> Canonical
}

pub type Peeker {
  Peeker(token: String, rest: Canonical)
  NoMoreInput
}

/// Take a canonicalized input and pop a token off the front.
pub fn peek(x: Canonical) -> Peeker {
  let words = wordsplitter()
  let #(pre, split, post) = splitter.split(words, x.canon)
  // "hello ( )" ======> "hello" " " "( )"
  // "hello" ======> "hello" "" ""
  // ")" ========> ")" "" ""
  // " hello" ==========> "" " " "hello"
  // "" =========> "" "" ""
  case pre, split {
    "", "" -> NoMoreInput
    "", _ -> post |> Canonical |> peek
    _, _ -> Peeker(pre, Canonical(post))
  }
}

fn gaze_rec(
  x: Canonical,
  token_history: string_tree.StringTree,
  depth: Int,
) -> Option(#(string_tree.StringTree, Canonical)) {
  // TODO: these are expensive closures to put in a tight loop!
  let append = string_tree.append(token_history, _)
  let append_with_space = fn(tok: String) -> string_tree.StringTree {
    token_history
    |> string_tree.append(" ")
    |> string_tree.append(tok)
  }
  case peek(x) {
    NoMoreInput -> None
    Peeker(tok, rest) ->
      case tok {
        "(" -> gaze_rec(rest, append(tok), depth + 1)
        ")" if depth == 1 -> Some(#(append_with_space(tok), rest))
        ")" -> gaze_rec(rest, append_with_space(tok), depth - 1)
        _ if depth == 0 -> Some(#(string_tree.from_string(tok), rest))
        _ -> gaze_rec(rest, append_with_space(tok), depth)
      }
  }
}

/// Take a canonicalized input and pop a paren-delimited term off the front
pub fn gaze(x: Canonical) -> Peeker {
  case gaze_rec(x, string_tree.from_string(""), 0) {
    Some(#(term, rest)) -> Peeker(string_tree.to_string(term), rest)
    None -> NoMoreInput
  }
}
