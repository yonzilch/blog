// src/build/robots.gleam

import data/site.{type SiteMeta}
import gleam/string

pub fn render(site: SiteMeta) -> String {
  let base_url = normalize_base_url(site.base_url)

  case base_url {
    "" -> "User-agent: *\n" <> "Allow: /\n"

    base_url ->
      "User-agent: *\n"
      <> "Allow: /\n"
      <> "\n"
      <> "Sitemap: "
      <> base_url
      <> "/sitemap.xml\n"
  }
}

fn normalize_base_url(base_url: String) -> String {
  base_url
  |> string.trim
  |> trim_trailing_slashes
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
