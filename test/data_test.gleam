//// Tests for the tag index and search data modules.

import data/post.{type Post, Post, find_tag, tag_index}
import data/search
import gleam/list
import gleam/option.{None}
import gleeunit
import gleeunit/should

pub fn main() -> Nil {
  gleeunit.main()
}

// Tag index ------------------------------------------------------------------

fn sample_posts() -> List(Post) {
  [
    Post(
      slug: "a",
      title: "Post A",
      date: "2026-01-01",
      updated: None,
      description: "About gleam",
      body: "",
      toc: [],
      tags: ["gleam", "lustre"],
      draft: False,
      tldr: None,
      word_count: 0,
      reading_time: 0,
    ),
    Post(
      slug: "b",
      title: "Post B",
      date: "2026-01-02",
      updated: None,
      description: "About css",
      body: "",
      toc: [],
      tags: ["css", "design"],
      draft: False,
      tldr: None,
      word_count: 0,
      reading_time: 0,
    ),
    Post(
      slug: "c",
      title: "Post C",
      date: "2026-01-03",
      updated: None,
      description: "More gleam",
      body: "",
      toc: [],
      tags: ["gleam"],
      draft: False,
      tldr: None,
      word_count: 0,
      reading_time: 0,
    ),
  ]
}

pub fn tag_index_builds_test() {
  let entries = tag_index(sample_posts())
  // Should have 4 unique tags: css, design, gleam, lustre
  list.length(entries) |> should.equal(4)
}

pub fn tag_index_sorted_by_name_test() {
  let entries = tag_index(sample_posts())
  let names = list.map(entries, fn(e) { e.name })
  // Sorted alphabetically: css, design, gleam, lustre
  names |> should.equal(["css", "design", "gleam", "lustre"])
}

pub fn tag_index_gleam_has_2_posts_test() {
  let entries = tag_index(sample_posts())
  let assert Ok(gleam_entry) = find_tag(entries, "gleam")
  list.length(gleam_entry.posts) |> should.equal(2)
}

pub fn tag_index_css_has_1_post_test() {
  let entries = tag_index(sample_posts())
  let assert Ok(css_entry) = find_tag(entries, "css")
  list.length(css_entry.posts) |> should.equal(1)
}

pub fn tag_index_find_missing_returns_error_test() {
  let entries = tag_index(sample_posts())
  find_tag(entries, "nonexistent") |> should.be_error()
}

// Search ---------------------------------------------------------------------

pub fn search_empty_query_returns_empty_test() {
  let results = search.search(sample_posts(), "")
  list.length(results) |> should.equal(0)
}

pub fn search_matching_title_test() {
  let results = search.search(sample_posts(), "post a")
  list.length(results) |> should.equal(1)
}

pub fn search_matching_description_test() {
  let results = search.search(sample_posts(), "gleam")
  // "gleam" appears in description of Post A and Post C
  list.length(results) |> should.equal(2)
}

pub fn search_matching_tag_test() {
  let results = search.search(sample_posts(), "css")
  list.length(results) |> should.equal(1)
}

pub fn search_case_insensitive_test() {
  let results_lower = search.search(sample_posts(), "gleam")
  let results_upper = search.search(sample_posts(), "GLEAM")
  list.length(results_lower) |> should.equal(list.length(results_upper))
}

pub fn search_no_match_returns_empty_test() {
  let results = search.search(sample_posts(), "nonexistent")
  list.length(results) |> should.equal(0)
}
