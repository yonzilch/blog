//// Routing: maps browser URLs to arata's internal `Route` type and back.
////
//// Patterned after the `01-routing` Lustre example, using `modem` for
//// client-side navigation over the History API. `parse_route` turns a `Uri`
//// into a typed `Route`, and `href` turns a `Route` back into an `href`
//// attribute for `<a>` elements. The two functions must stay in sync so every
//// internal link round-trips through `parse_route` to the same `Route`.
////
//// URL scheme (mirrors apollo's content layout):
////
////   `/`                  -> Home
////   `/posts`             -> Posts(1)        (section index, first page)
////   `/posts/page/{n}`    -> Posts(n)        (paginated section index)
////   `/posts/{slug}`      -> Post(slug)
////   `/projects`          -> Projects        (section index)
////   `/projects/{slug}`   -> Page(slug)      (project detail renders as a page)
////   `/links`             -> Links           (friend links index)
////   `/tags`              -> Tags            (taxonomy index)
////   `/tags/{name}`       -> Tag(name)
////   `/{slug}`            -> Page(slug)      (standalone page, e.g. /about)
////   anything else        -> NotFound(uri)
//// Routing: maps browser URLs to arata's internal `Route` type and back.
////
//// Important for non-root deployments:
//// GitHub Pages project sites are served under a base path such as `/arata`.
//// Browser URLs look like `/arata/posts/configuration`, but the internal
//// router must see `/posts/configuration`. Therefore `parse_route` strips the
//// configured base path before matching, while `href_url` prefixes generated
//// links with that base path.

import config
import gleam/int
import gleam/string
import gleam/uri.{type Uri}
import lustre/attribute.{type Attribute}

pub type Route {
  Home
  Posts(page: Int)
  Post(slug: String)
  Projects
  Links
  Tags
  Tag(name: String)
  Page(slug: String)
  NotFound(uri: Uri)
}

pub fn parse_route(uri: Uri) -> Route {
  let site_config = config.default()
  let path = strip_base_path(uri.path, site_config.base_path)

  case uri.path_segments(path) {
    [] | [""] -> Home

    ["posts"] -> Posts(1)

    ["posts", "page", page] ->
      case int.parse(page) {
        Ok(page) -> Posts(page)

        Error(_) -> NotFound(uri:)
      }

    ["posts", slug] -> Post(slug)

    ["projects"] -> Projects

    ["projects", slug] -> Page(slug:)

    ["links"] -> Links

    ["tags"] -> Tags

    ["tags", name] -> Tag(name:)

    ["atom.xml"]
    | ["rss.xml"]
    | ["robots.txt"]
    | ["llms.txt"]
    | ["sitemap.xml"]
    | ["content_index.json"]
    | ["search_index.json"]
    | ["app.mjs"]
    | ["arata.css"] -> NotFound(uri:)

    [slug] -> Page(slug:)

    _ -> NotFound(uri:)
  }
}

fn strip_base_path(path: String, base_path: String) -> String {
  let base_path = config.normalize_base_path(base_path)

  case base_path {
    "" -> path

    _ ->
      case path == base_path {
        True -> "/"

        False ->
          case string.starts_with(path, base_path <> "/") {
            True -> {
              let base_len = string.length(base_path)
              string.slice(path, base_len, string.length(path) - base_len)
            }

            False -> path
          }
      }
  }
}

pub fn href(route: Route) -> Attribute(message) {
  attribute.href(href_url(route))
}

pub fn href_url(route: Route) -> String {
  let site_config = config.default()
  config.with_base_path(site_config.base_path, raw_href_url(route))
}

fn raw_href_url(route: Route) -> String {
  case route {
    Home -> "/"

    Posts(1) -> "/posts"

    Posts(page) -> "/posts/page/" <> int.to_string(page)

    Post(slug) -> "/posts/" <> slug

    Projects -> "/projects"

    Links -> "/links"

    Tags -> "/tags"

    Tag(name) -> "/tags/" <> name

    Page(slug) -> "/" <> slug

    NotFound(_) -> "/404"
  }
}
