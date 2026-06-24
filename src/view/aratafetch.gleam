//// aratafetch: a neofetch-style homepage summary component.
////
//// This module is intentionally view-only plus small runtime aggregation
//// helpers. It does not fetch data and does not depend on config directly.
//// The caller decides whether the component is enabled and passes the loaded
//// content lists in after `content_index.json` is ready.
////
//// Invariants:
////   - draft posts are excluded from post count, word count, and tag count
////   - total words reuse `Post.word_count`; markdown is not reparsed
////   - tags are counted uniquely, case-insensitively
////   - comments and maintenance duration are optional because arata currently
////     has no reliable runtime comment-count source

import data/link.{type Link}
import data/post.{type Post}
import data/project.{type Project}
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import lustre/attribute
import lustre/element.{type Element, none}
import lustre/element/html

pub type Stats {
  Stats(
    site_title: String,
    post_count: Int,
    word_count: Int,
    tag_count: Int,
    link_count: Int,
    project_count: Int,
    maintain_for: Option(String),
  )
}

/// Build aratafetch stats from already-loaded runtime content.
///
/// `maintain_for` is deliberately a display string instead of a date because
/// Gleam/JS date parsing would add complexity and timezone edge cases. The
/// caller can pass values like:
///
///   Some("since 2024-11-05")
///   Some("2 years")
///   None
///
pub fn from_content(
  site_title: String,
  posts: List(Post),
  links: List(Link),
  projects: List(Project),
  maintain_for: Option(String),
) -> Stats {
  let published_posts = list.filter(posts, fn(post) { !post.draft })

  Stats(
    site_title: site_title,
    post_count: list.length(published_posts),
    word_count: total_words(published_posts),
    tag_count: unique_tag_count(published_posts),
    link_count: list.length(links),
    project_count: list.length(projects),
    maintain_for: maintain_for,
  )
}

/// Render the aratafetch block.
///
/// When disabled, returns `none()` so the homepage is identical to the old
/// rendering path.
pub fn view(enabled: Bool, stats: Stats) -> Element(msg) {
  case enabled {
    False -> none()

    True ->
      html.section(
        [
          attribute.class("aratafetch"),
          attribute.attribute("aria-label", "Site summary"),
        ],
        [
          html.pre([attribute.class("aratafetch-pre")], [
            html.text(render(stats)),
          ]),
        ],
      )
  }
}

fn total_words(posts: List(Post)) -> Int {
  list.fold(posts, 0, fn(total, post) { total + post.word_count })
}

fn unique_tag_count(posts: List(Post)) -> Int {
  posts
  |> list.fold(dict.new(), fn(tags, post) {
    list.fold(post.tags, tags, fn(tags, tag) {
      dict.insert(tags, string.lowercase(tag), Nil)
    })
  })
  |> dict.to_list
  |> list.length
}

fn render(stats: Stats) -> String {
  string.join(
    [
      "        /\\        " <> row("site", stats.site_title),
      "       /  \\       " <> row("posts", int.to_string(stats.post_count)),
      "      / /\\ \\      " <> row("words", int.to_string(stats.word_count)),
      "     / ____ \\     " <> row("tags", int.to_string(stats.tag_count)),
      "    /_/    \\_\\    " <> row("links", int.to_string(stats.link_count)),
      "                  "
        <> row("projects", int.to_string(stats.project_count)),
      "                  " <> row("maintain", optional_text(stats.maintain_for)),
    ],
    "\n",
  )
}

fn row(label: String, value: String) -> String {
  label <> repeat(" ", int.max(1, 11 - string.length(label))) <> value
}

fn optional_text(value: Option(String)) -> String {
  case value {
    Some(text) -> text

    None -> "n/a"
  }
}

fn repeat(chunk: String, times: Int) -> String {
  case times <= 0 {
    True -> ""

    False -> chunk <> repeat(chunk, times - 1)
  }
}
