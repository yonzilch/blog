//// Tests for the card grid's column-balanced reordering.

import gleam/list
import gleam/order.{type Order}
import gleam/string
import gleeunit
import gleeunit/should

import view/cards

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn reorder_4_items_2_columns_test() {
  // 4 items in 2 columns: items_per_column = ceil(4/2) = 2
  // Column-major order: col0={0,2}, col1={1,3} -> [0,2,1,3]
  let result = cards.reorder_for_columns(["a", "b", "c", "d"], 2)
  result |> should.equal(["a", "c", "b", "d"])
}

pub fn reorder_6_items_2_columns_test() {
  // 6 items in 2 columns: items_per_column = 3
  // Column-major: col0={0,2,4}, col1={1,3,5} -> [0,2,4,1,3,5]
  let result = cards.reorder_for_columns(["a", "b", "c", "d", "e", "f"], 2)
  result |> should.equal(["a", "c", "e", "b", "d", "f"])
}

pub fn reorder_3_items_2_columns_test() {
  // 3 items in 2 columns: items_per_column = ceil(3/2) = 2
  // Column-major: col0={0,2}, col1={1} -> [0,2,1]
  let result = cards.reorder_for_columns(["a", "b", "c"], 2)
  result |> should.equal(["a", "c", "b"])
}

pub fn reorder_1_column_test() {
  // 1 column: no reordering needed
  let result = cards.reorder_for_columns(["a", "b", "c"], 1)
  result |> should.equal(["a", "b", "c"])
}

pub fn reorder_empty_test() {
  let result = cards.reorder_for_columns([], 2)
  result |> should.equal([])
}

pub fn reorder_preserves_all_items_test() {
  // The reordered list should contain the same items as the input (just in a
  // different order). Sort both and compare.
  let input = ["a", "b", "c", "d", "e", "f", "g"]
  let result = cards.reorder_for_columns(input, 3)
  let result_sorted = list.sort(result, by: string_compare)
  let input_sorted = list.sort(input, by: string_compare)
  result_sorted |> should.equal(input_sorted)
}

fn string_compare(a: String, b: String) -> Order {
  string.compare(a, b)
}
