//// Tests for Zola-style weight ordering on friend links.
////
//// Invariants:
////   - smaller weight appears earlier
////   - equal weight falls back to lowercase title ordering
////   - loaded links always have a non-negative weight

import content/loader
import data/link.{type Link}
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/string
import gleeunit/should

pub fn load_links_orders_by_weight_test() {
  let links = loader.load_links()

  let has_links = links != []
  has_links |> should.equal(True)

  assert_sorted_by_weight_then_title(links)
}

pub fn load_links_have_non_negative_weights_test() {
  let links = loader.load_links()

  links
  |> list.all(fn(link) { link.weight >= 0 })
  |> should.equal(True)
}

pub fn load_links_has_deterministic_order_test() {
  let links = loader.load_links()

  links
  |> is_sorted_by_weight_then_title
  |> should.equal(True)
}

fn assert_sorted_by_weight_then_title(links: List(Link)) -> Nil {
  case links {
    [] -> Nil
    [_] -> Nil
    [first, second, ..rest] -> {
      compare_link_order(first, second)
      |> should.equal(True)

      assert_sorted_by_weight_then_title([second, ..rest])
    }
  }
}

fn is_sorted_by_weight_then_title(links: List(Link)) -> Bool {
  case links {
    [] -> True
    [_] -> True
    [first, second, ..rest] ->
      compare_link_order(first, second)
      && is_sorted_by_weight_then_title([second, ..rest])
  }
}

fn compare_link_order(a: Link, b: Link) -> Bool {
  case int.compare(a.weight, b.weight) {
    Lt -> True
    Eq ->
      string.compare(string.lowercase(a.title), string.lowercase(b.title)) != Gt
    Gt -> False
  }
}
