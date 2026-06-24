//// SEO head builder: produces `<title>`, `<meta>` description, OpenGraph,
//// and Fediverse `<meta>` elements, mirroring apollo's
//// `partials/header.html` SEO section.
////
//// In a server-rendered `index.html` (Phase 17), these elements would be
//// emitted in the `<head>`. For now (client-only SPA), Lustre manages the
//// `<head>` via side effects — this module produces the element list so a
//// future SSR step or the analytics FFI can inject them.
////
//// apollo deduplicates against `page.extra.meta` using `page_has_og_title`
//// / `page_has_og_description` / `page_has_description` flags. arata does
//// the same: if the caller passes custom `meta` entries, the auto-generated
//// ones are suppressed.

import data/site.{type SiteMeta}
import gleam/list
import gleam/option.{type Option}
import lustre/attribute
import lustre/element.{type Element, fragment, none}
import lustre/element/html

/// One custom `<meta>` entry from frontmatter (apollo's `page.extra.meta`).
/// Each becomes `<meta key="value">`.
pub type MetaEntry {
  MetaEntry(key: String, value: String)
}

/// Build the head elements for a page.
///
/// - `site`: the site-level metadata.
/// - `page_title`: the title of the current page (or `None` for the site root).
/// - `page_description`: the page description (or `None` to use the site default).
/// - `page_path`: the URL path (for `og:url`).
/// - `custom_meta`: user-supplied meta entries from frontmatter; these override
///   the auto-generated `og:title` / `og:description` / `description` when
///   their keys match.
pub fn view(
  site: SiteMeta,
  page_title: Option(String),
  page_description: Option(String),
  page_path: String,
  custom_meta: List(MetaEntry),
) -> Element(msg) {
  let title = option.unwrap(page_title, site.title)
  let description = option.unwrap(page_description, site.description)
  let url = site.base_url <> page_path

  // Check for custom overrides.
  let has_og_title = list.any(custom_meta, fn(e) { e.key == "og:title" })
  let has_og_description =
    list.any(custom_meta, fn(e) { e.key == "og:description" })
  let has_description = list.any(custom_meta, fn(e) { e.key == "description" })

  let auto_desc = case has_description {
    False -> [MetaEntry("description", description)]
    True -> []
  }
  let auto_og_title = case has_og_title {
    False -> [MetaEntry("og:title", title)]
    True -> []
  }
  let auto_og_desc = case has_og_description {
    False -> [MetaEntry("og:description", description)]
    True -> []
  }
  let auto_meta =
    list.flatten([
      auto_desc,
      auto_og_title,
      auto_og_desc,
      [MetaEntry("og:url", url), MetaEntry("og:type", "website")],
    ])

  let all_meta = list.append(auto_meta, custom_meta)

  fragment([
    html.title([], title),
    fragment(
      list.map(all_meta, fn(entry) {
        html.meta([
          attribute.attribute("property", entry.key),
          attribute.attribute("content", entry.value),
        ])
      }),
    ),
    fediverse_meta(site.fediverse_creator),
  ])
}

/// The Fediverse creator `<meta>` tag, or `none()` if not configured.
fn fediverse_meta(creator: Option(String)) -> Element(msg) {
  case creator {
    option.Some(handle) ->
      html.meta([
        attribute.attribute("name", "fediverse:creator"),
        attribute.attribute("content", handle),
      ])
    option.None -> none()
  }
}
