//// Links page view: renders friend links as an ordered list.
////
//// Ordering rule:
////   - smaller `weight` appears earlier
////   - equal weight falls back to title ordering for deterministic output
////
//// The view sorts defensively so the UI stays stable even if the build-time
//// loader or JSON decoder receives links from an unordered filesystem listing.

import data/link.{type Link}
import gleam/int
import gleam/list
import gleam/option
import gleam/order.{type Order, Eq}
import gleam/string
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

/// Render the links page: a `.page-header` and a `.links-list` of link items.
pub fn view(links: List(Link)) -> Element(msg) {
  let ordered_links = sort_links(links)

  html.div([], [
    html.div([attribute.class("page-header")], [html.text("Links")]),
    html.main([], [
      html.ul(
        [attribute.class("links-list")],
        list.map(ordered_links, view_link),
      ),
    ]),
  ])
}

/// Sort friend links by frontmatter `weight`.
///
/// This mirrors Zola's convention: smaller weight means higher priority.
/// Ties are sorted by lowercased title so output stays deterministic across
/// platforms and filesystem order.
fn sort_links(links: List(Link)) -> List(Link) {
  list.sort(links, compare_links)
}

fn compare_links(a: Link, b: Link) -> Order {
  case int.compare(a.weight, b.weight) {
    Eq -> string.compare(string.lowercase(a.title), string.lowercase(b.title))

    order -> order
  }
}

/// Render one friend-link card.
///
/// The card itself (`<li class="link-item">`) is not one giant link. Only the
/// title is interactive, while avatar and description remain normal content.
fn view_link(link: Link) -> Element(msg) {
  let avatar = case link.image {
    option.Some(url) -> [
      html.img([
        attribute.src(url),
        attribute.alt(link.title),
        attribute.class("link-avatar"),
      ]),
    ]

    option.None -> []
  }

  html.li([attribute.class("link-item")], [
    html.div(
      [attribute.class("link-content")],
      list.append(avatar, [
        html.div([attribute.class("link-text")], [
          html.div([attribute.class("link-title")], [
            html.a(
              [
                attribute.href(link.url),
                attribute.target("_blank"),
                attribute.rel("noopener"),
              ],
              [html.text(link.title)],
            ),
          ]),
          html.p([attribute.class("link-description")], [
            html.text(link.description),
          ]),
        ]),
      ]),
    ),
  ])
}
