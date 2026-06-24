//// Taxonomy views: the `/tags` index and the `/tags/<tag>` single-tag page,
//// mirroring apollo's `templates/taxonomy_list.html` and
//// `templates/taxonomy_single.html`.
////
//// The index lists every tag with its post count (apollo sorts by name by
//// default; `[extra.taxonomies] sort_by = "page_count"` is also supported —
//// arata sorts by name for now). The single-tag page reuses the post-list
//// item rendering from `view/post_list` with an "Entries tagged :: <tag>"
//// header.

import data/post.{type Post, type TagEntry}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import route
import view/post_list

/// Render the `/tags` index page: a `.page-header` "Tags" followed by a
/// `<main class="tag-list"><ul>` of `.post-header` rows. Each row links to
/// the single-tag page and shows the post count.
pub fn view_list(entries: List(TagEntry)) -> Element(msg) {
  html.div([], [
    html.div([attribute.class("page-header")], [html.text("Tags")]),
    html.main([attribute.class("tag-list")], [
      html.ul([], list.map(entries, view_tag_entry)),
    ]),
  ])
}

/// Render the `/tags/<tag>` single-tag page: a `.page-header`
/// "Entries tagged :: <tag>" followed by the post list (reusing
/// `post_list.view_items` for the per-item rendering).
pub fn view_single(tag: String, posts: List(Post)) -> Element(msg) {
  html.div([], [
    html.div([attribute.class("page-header")], [
      html.text("Entries tagged :: "),
      html.text(tag),
    ]),
    post_list.view_items(posts),
  ])
}

/// One row in the tag index: the tag name as a link to the single-tag page,
/// plus the post count. Mirrors apollo's `.post-header` structure:
///   <div class="post-header">
///     <h1 class="title"><a href="...">{name}</a></h1>
///     <small class="meta">{n} pages</small>
///   </div>
fn view_tag_entry(entry: TagEntry) -> Element(msg) {
  let count = list.length(entry.posts)
  html.div([attribute.class("post-header")], [
    html.h1([attribute.class("title")], [
      html.a([route.href(route.Tag(entry.name))], [html.text(entry.name)]),
    ]),
    html.small([attribute.class("meta")], [
      html.text(int.to_string(count)),
      html.text(" page"),
      html.text(plural_suffix(count)),
    ]),
  ])
}

/// Empty string for 1 item, "s" otherwise (apollo's `pluralize` filter).
fn plural_suffix(count: Int) -> String {
  case count == 1 {
    True -> ""
    False -> "s"
  }
}
