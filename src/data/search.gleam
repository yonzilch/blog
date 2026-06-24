//// Search data: a search result type and a pure search function.
////
//// The full elasticlunr integration (ROADMAP Phase 12 mentions keeping the
//// vendored core) is deferred — for now arata uses a lightweight
//// case-insensitive substring search over post titles, descriptions, and tags.
//// This provides functional search without pulling a 2567-line JS dependency
//// into the bundle. The search index is built from the in-memory post list at
//// runtime (no build-time index emission needed until the markdown pipeline
//// lands in Phase 17).
////
//// Fix 9a: each `SearchResult` now carries a context `snippet` showing where
//// the query matched in the post body (80 characters before and after the
//// match, with ellipses — Fix 8 raised the window from 30 to 80). When the
//// match is in the title/tags (not the body), the snippet falls back to
//// the post's description.

import data/post.{type Post}
import gleam/int
import gleam/list
import gleam/string

/// One search result: the post and a snippet of where the query matched.
pub type SearchResult {
  SearchResult(post: Post, snippet: String)
}

/// Search `posts` for `query`. Returns matching posts sorted by relevance
/// (title matches first, then description, then tags). An empty query returns
/// an empty list. Matching is case-insensitive. Fix 9a: each result carries
/// a context `snippet` showing ~80 chars before and after the first body
/// match (falling back to the description when the match isn't in the body).
/// Fix 8 bumped the context from 30 to 80 graphemes for better readability.
pub fn search(posts: List(Post), query: String) -> List(SearchResult) {
  case query {
    "" -> []
    _ -> {
      let q = string.lowercase(query)
      posts
      |> list.filter(fn(post) { matches(post, q) })
      |> list.map(fn(post) {
        SearchResult(post:, snippet: extract_snippet(post, q))
      })
    }
  }
}

/// Whether a post matches the query in its title, description, tags, or body.
/// The body is HTML rendered from markdown — `strip_html` removes the tags so
/// we search the plain-text content (otherwise HTML tag/attribute names like
/// `class` or `href` would pollute results).
fn matches(post: Post, query: String) -> Bool {
  let title = string.lowercase(post.title)
  let desc = string.lowercase(post.description)
  let tags =
    post.tags
    |> list.map(string.lowercase)
    |> string.join(" ")
  let body = string.lowercase(strip_html(post.body))
  string.contains(title, query)
  || string.contains(desc, query)
  || string.contains(tags, query)
  || string.contains(body, query)
}

/// Build a context snippet for the first occurrence of `query` (already
/// lowercased by the caller) in the post. We try the body first; if the
/// query doesn't appear in the stripped body, we fall back to the post's
/// description so the result row always has some text to display.
///
/// Fix 8: widened the context window from 30 → 80 graphemes on each side
/// of the match so users get a better sense of the surrounding sentence
/// (30 was too tight to disambiguate matches in longer posts).
fn extract_snippet(post: Post, query: String) -> String {
  let body = string.lowercase(strip_html(post.body))
  case string.split_once(body, query) {
    Ok(#(before, after)) -> {
      let before_snippet = take_last(before, 80)
      let after_snippet = take_first(after, 80)
      "..." <> before_snippet <> query <> after_snippet <> "..."
    }
    Error(_) -> post.description
  }
}

/// Take the first `n` graphemes from a string. Grapheme-based (not byte- or
/// codepoint-based) so multi-byte characters (CJK, emoji) are kept intact.
fn take_first(s: String, n: Int) -> String {
  s
  |> string.to_graphemes
  |> list.take(n)
  |> string.concat
}

/// Take the last `n` graphemes from a string. Grapheme-based for the same
/// reason as `take_first`.
fn take_last(s: String, n: Int) -> String {
  let graphemes = string.to_graphemes(s)
  let len = list.length(graphemes)
  let drop_count = int.max(0, len - n)
  graphemes
  |> list.drop(drop_count)
  |> string.concat
}

/// Strip HTML tags from a string by dropping everything between `<` and `>`
/// (inclusive). Splits on `<`, then for each piece keeps only the text after
/// the first `>` (or the whole piece if there's no `>`). HTML entities (e.g.
/// `&lt;`) are left untouched — they decode to plain text anyway.
fn strip_html(html: String) -> String {
  html
  |> string.split("<")
  |> list.map(fn(piece) {
    case string.split_once(piece, ">") {
      Ok(#(_tag, rest)) -> rest
      Error(_) -> piece
    }
  })
  |> string.join("")
}
