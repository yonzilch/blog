//// Tests for the routing module: `parse_route` and `href_url` round-trips.
////
//// Deployment invariant:
////   - `parse_route` accepts both root paths (`/posts/x`) and configured
////     base-path paths (`/arata/posts/x`).
////   - `href_url` emits URLs prefixed with `config.default().base_path`.
////   - Round-trips still hold:
////       parse(href_url(route)) == route

import config
import gleam/uri
import gleeunit
import gleeunit/should

import route.{
  type Route, Home, Links, NotFound, Page, Post, Posts, Projects, Tag, Tags,
}

pub fn main() -> Nil {
  gleeunit.main()
}

// Helpers --------------------------------------------------------------------

fn parse(path: String) -> Route {
  let assert Ok(uri) = uri.parse("https://example.com" <> path)
  route.parse_route(uri)
}

fn expected(path: String) -> String {
  config.with_base_path(config.default().base_path, path)
}

fn assert_not_found(route: Route) -> Nil {
  case route {
    NotFound(_) -> Nil
    _ -> should.fail()
  }
}

// parse_route: root deployment paths -----------------------------------------

pub fn parse_root_test() {
  parse("/") |> should.equal(Home)
}

pub fn parse_empty_path_test() {
  parse("") |> should.equal(Home)
}

pub fn parse_posts_index_test() {
  parse("/posts") |> should.equal(Posts(1))
}

pub fn parse_posts_page_2_test() {
  parse("/posts/page/2") |> should.equal(Posts(2))
}

pub fn parse_posts_page_invalid_test() {
  parse("/posts/page/abc")
  |> assert_not_found
}

pub fn parse_single_post_test() {
  parse("/posts/hello-arata") |> should.equal(Post("hello-arata"))
}

pub fn parse_projects_test() {
  parse("/projects") |> should.equal(Projects)
}

pub fn parse_project_detail_test() {
  parse("/projects/some-project") |> should.equal(Page("some-project"))
}

pub fn parse_links_test() {
  parse("/links") |> should.equal(Links)
}

pub fn parse_tags_index_test() {
  parse("/tags") |> should.equal(Tags)
}

pub fn parse_single_tag_test() {
  parse("/tags/gleam") |> should.equal(Tag("gleam"))
}

pub fn parse_standalone_page_test() {
  parse("/about") |> should.equal(Page("about"))
}

pub fn parse_unknown_path_test() {
  parse("/unknown/deep/path")
  |> assert_not_found
}

// parse_route: configured base path ------------------------------------------

pub fn parse_base_path_root_test() {
  parse(expected("/")) |> should.equal(Home)
}

pub fn parse_base_path_posts_index_test() {
  parse(expected("/posts")) |> should.equal(Posts(1))
}

pub fn parse_base_path_posts_page_2_test() {
  parse(expected("/posts/page/2")) |> should.equal(Posts(2))
}

pub fn parse_base_path_single_post_test() {
  parse(expected("/posts/hello-arata"))
  |> should.equal(Post("hello-arata"))
}

pub fn parse_base_path_projects_test() {
  parse(expected("/projects")) |> should.equal(Projects)
}

pub fn parse_base_path_links_test() {
  parse(expected("/links")) |> should.equal(Links)
}

pub fn parse_base_path_tags_index_test() {
  parse(expected("/tags")) |> should.equal(Tags)
}

pub fn parse_base_path_single_tag_test() {
  parse(expected("/tags/gleam")) |> should.equal(Tag("gleam"))
}

pub fn parse_base_path_standalone_page_test() {
  parse(expected("/about")) |> should.equal(Page("about"))
}

// Static files must not be routed as pages -----------------------------------

pub fn parse_atom_xml_not_page_test() {
  parse("/atom.xml")
  |> assert_not_found
}

pub fn parse_rss_xml_not_page_test() {
  parse("/rss.xml")
  |> assert_not_found
}

pub fn parse_robots_txt_not_page_test() {
  parse("/robots.txt")
  |> assert_not_found
}

pub fn parse_llms_txt_not_page_test() {
  parse("/llms.txt")
  |> assert_not_found
}

pub fn parse_sitemap_xml_not_page_test() {
  parse("/sitemap.xml")
  |> assert_not_found
}

pub fn parse_content_index_json_not_page_test() {
  parse("/content_index.json")
  |> assert_not_found
}

pub fn parse_search_index_json_not_page_test() {
  parse("/search_index.json")
  |> assert_not_found
}

pub fn parse_app_mjs_not_page_test() {
  parse("/app.mjs")
  |> assert_not_found
}

pub fn parse_base_path_static_file_not_page_test() {
  parse(expected("/content_index.json"))
  |> assert_not_found
}

// Deep links -----------------------------------------------------------------

pub fn parse_deep_link_test() {
  parse("/posts/markdown") |> should.equal(Post("markdown"))
}

pub fn parse_base_path_deep_link_test() {
  parse(expected("/posts/markdown")) |> should.equal(Post("markdown"))
}

// href_url -------------------------------------------------------------------

pub fn href_home_test() {
  route.href_url(Home) |> should.equal(expected("/"))
}

pub fn href_posts_page_1_test() {
  route.href_url(Posts(1)) |> should.equal(expected("/posts"))
}

pub fn href_posts_page_2_test() {
  route.href_url(Posts(2)) |> should.equal(expected("/posts/page/2"))
}

pub fn href_post_test() {
  route.href_url(Post("hello")) |> should.equal(expected("/posts/hello"))
}

pub fn href_projects_test() {
  route.href_url(Projects) |> should.equal(expected("/projects"))
}

pub fn href_links_test() {
  route.href_url(Links) |> should.equal(expected("/links"))
}

pub fn href_tags_test() {
  route.href_url(Tags) |> should.equal(expected("/tags"))
}

pub fn href_tag_test() {
  route.href_url(Tag("gleam")) |> should.equal(expected("/tags/gleam"))
}

pub fn href_page_test() {
  route.href_url(Page("about")) |> should.equal(expected("/about"))
}

// Round-trip: parse(href_url(route)) == route --------------------------------

pub fn roundtrip_home_test() {
  parse(route.href_url(Home)) |> should.equal(Home)
}

pub fn roundtrip_posts_page_1_test() {
  parse(route.href_url(Posts(1))) |> should.equal(Posts(1))
}

pub fn roundtrip_posts_page_3_test() {
  parse(route.href_url(Posts(3))) |> should.equal(Posts(3))
}

pub fn roundtrip_post_test() {
  parse(route.href_url(Post("hello-arata")))
  |> should.equal(Post("hello-arata"))
}

pub fn roundtrip_projects_test() {
  parse(route.href_url(Projects)) |> should.equal(Projects)
}

pub fn roundtrip_links_test() {
  parse(route.href_url(Links)) |> should.equal(Links)
}

pub fn roundtrip_tags_test() {
  parse(route.href_url(Tags)) |> should.equal(Tags)
}

pub fn roundtrip_tag_test() {
  parse(route.href_url(Tag("gleam"))) |> should.equal(Tag("gleam"))
}

pub fn roundtrip_page_test() {
  parse(route.href_url(Page("about"))) |> should.equal(Page("about"))
}
