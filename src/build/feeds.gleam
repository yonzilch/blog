//// Feed and sitemap generators: pure functions that produce XML strings for
//// `atom.xml`, `rss.xml`, and `sitemap.xml`, mirroring Zola's built-in feed
//// and sitemap emission.
////
//// These are normally called by the build pipeline to write the files to
//// `dist/`. The feed generators can attach an XML stylesheet processing
//// instruction so browsers render a readable feed preview while feed readers
//// continue consuming the raw Atom/RSS XML normally.

import data/post.{type Post}
import data/site.{type SiteMeta}
import gleam/list
import gleam/string

/// Generate an Atom 1.0 feed (`atom.xml`) from the site metadata and posts.
///
/// `stylesheet_href` is the public href of the XSL stylesheet used when a human
/// opens the feed directly in a browser. Feed readers ignore the processing
/// instruction and consume the XML as usual.
///
/// Pass `""` to omit the stylesheet processing instruction.
pub fn atom_feed(
  site: SiteMeta,
  posts: List(Post),
  stylesheet_href: String,
) -> String {
  let entries =
    posts
    |> list.map(fn(post) {
      let post_url = site_url(site, "/posts/" <> post.slug)

      "    <entry>
        <title>" <> xml_escape(post.title) <> "</title>
        <link href=\"" <> xml_escape(post_url) <> "\"/>
        <id>" <> xml_escape(post_url) <> "</id>
        <updated>" <> xml_escape(post.date) <> "T00:00:00Z</updated>
        <summary>" <> xml_escape(post.description) <> "</summary>
    </entry>"
    })
    |> string.join("\n")

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> xml_stylesheet_pi(stylesheet_href)
  <> "<feed xmlns=\"http://www.w3.org/2005/Atom\">\n"
  <> "    <title>"
  <> xml_escape(site.title)
  <> "</title>\n"
  <> "    <subtitle>"
  <> xml_escape(site.description)
  <> "</subtitle>\n"
  <> "    <link href=\""
  <> xml_escape(site_url(site, "/atom.xml"))
  <> "\" rel=\"self\"/>\n"
  <> "    <link href=\""
  <> xml_escape(trim_trailing_slashes(site.base_url))
  <> "\"/>\n"
  <> "    <id>"
  <> xml_escape(trim_trailing_slashes(site.base_url))
  <> "</id>\n"
  <> "    <updated>"
  <> case list.first(posts) {
    Ok(post) -> xml_escape(post.date)
    Error(_) -> "2026-01-01"
  }
  <> "T00:00:00Z</updated>\n"
  <> entries
  <> "\n</feed>"
}

/// Generate an RSS 2.0 feed (`rss.xml`) from the site metadata and posts.
///
/// `stylesheet_href` is the public href of the XSL stylesheet used when a human
/// opens the feed directly in a browser. Feed readers ignore the processing
/// instruction and consume the XML as usual.
///
/// Pass `""` to omit the stylesheet processing instruction.
pub fn rss_feed(
  site: SiteMeta,
  posts: List(Post),
  stylesheet_href: String,
) -> String {
  let items =
    posts
    |> list.map(fn(post) {
      let post_url = site_url(site, "/posts/" <> post.slug)

      "        <item>
            <title>" <> xml_escape(post.title) <> "</title>
            <link>" <> xml_escape(post_url) <> "</link>
            <guid>" <> xml_escape(post_url) <> "</guid>
            <pubDate>" <> xml_escape(post.date) <> "T00:00:00Z</pubDate>
            <description>" <> xml_escape(post.description) <> "</description>
        </item>"
    })
    |> string.join("\n")

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> xml_stylesheet_pi(stylesheet_href)
  <> "<rss version=\"2.0\" xmlns:atom=\"http://www.w3.org/2005/Atom\">\n"
  <> "    <channel>\n"
  <> "        <title>"
  <> xml_escape(site.title)
  <> "</title>\n"
  <> "        <link>"
  <> xml_escape(trim_trailing_slashes(site.base_url))
  <> "</link>\n"
  <> "        <description>"
  <> xml_escape(site.description)
  <> "</description>\n"
  <> "        <atom:link href=\""
  <> xml_escape(site_url(site, "/rss.xml"))
  <> "\" rel=\"self\" type=\"application/rss+xml\"/>\n"
  <> items
  <> "\n    </channel>\n</rss>"
}

/// Generate a `sitemap.xml` from the site metadata and all known URLs.
pub fn sitemap(
  site: SiteMeta,
  posts: List(Post),
  pages: List(String),
) -> String {
  let post_urls =
    posts
    |> list.map(fn(post) { "    <url>
      <loc>" <> site_url(site, "/posts/" <> post.slug) <> "</loc>
        <lastmod>" <> post.date <> "</lastmod>
    </url>" })

  let page_urls =
    pages
    |> list.map(fn(slug) { "    <url>
      <loc>" <> site_url(site, "/" <> slug) <> "</loc>
    </url>" })

  let all_urls = list.append(post_urls, page_urls)

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
  <> "    <url>\n        <loc>"
  <> site.base_url
  <> "</loc>\n    </url>\n"
  <> string.join(all_urls, "\n")
  <> "\n</urlset>"
}

fn site_url(site: SiteMeta, path: String) -> String {
  trim_trailing_slashes(site.base_url) <> ensure_leading_slash(path)
}

fn ensure_leading_slash(path: String) -> String {
  case path {
    "" -> ""

    _ ->
      case string.starts_with(path, "/") {
        True -> path
        False -> "/" <> path
      }
  }
}

fn trim_trailing_slashes(value: String) -> String {
  case string.ends_with(value, "/") {
    True -> {
      let size = string.length(value)

      value
      |> string.slice(0, size - 1)
      |> trim_trailing_slashes
    }

    False -> value
  }
}

/// Render an XML stylesheet processing instruction.
///
/// The processing instruction must appear after the XML declaration and before
/// the root element. Browsers use it to transform the feed into a readable HTML
/// preview; feed readers normally ignore it.
fn xml_stylesheet_pi(href: String) -> String {
  case string.trim(href) {
    "" -> ""

    href ->
      "<?xml-stylesheet type=\"text/xsl\" href=\""
      <> xml_escape(href)
      <> "\"?>\n"
  }
}

/// Escape XML special characters.
fn xml_escape(s: String) -> String {
  s
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("\"", "&quot;")
  |> string.replace("'", "&apos;")
}
