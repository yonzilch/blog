//// Cards page view: renders the `/projects` page as a column-balanced card
//// grid, mirroring apollo's `templates/cards.html`.
////
//// apollo reorders the items so they fill column-major (e.g. for 6 items in 2
//// columns the order is 1,3,5,2,4,6) — this keeps the grid visually balanced.
//// arata replicates this with a pure `reorder_for_columns` function.

import data/project.{type Project}
import gleam/int
import gleam/list
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import view/card

/// Number of columns in the projects grid. apollo reads this from
/// `section.extra.cards_columns` (default 2); arata uses 2 for now.
const default_columns = 2

/// Render the projects page: a `.page-header`, the section content (empty for
/// now), and the column-balanced `.cards` grid.
pub fn view(projects: List(Project)) -> Element(msg) {
  html.div([], [
    html.div([attribute.class("page-header")], [html.text("Projects")]),
    html.main([], [
      html.div(
        [
          attribute.class("cards"),
          attribute.style("--columns", int.to_string(default_columns)),
        ],
        projects
          |> reorder_for_columns(default_columns)
          |> list.map(card.view),
      ),
    ]),
  ])
}

/// Reorder `items` so that when rendered into a CSS `column-count: N` container
/// they fill column-major (item 1 in column 1, item 2 in column 2, …, item N+1
/// back in column 1). This matches apollo's `reordered_indices` Tera logic.
///
/// For 6 items in 2 columns this produces the order 1,3,5,2,4,6 (0-indexed:
/// 0,2,4,1,3,5).
pub fn reorder_for_columns(items: List(a), columns: Int) -> List(a) {
  let total = list.length(items)
  // Ceiling division: items_per_column = ceil(total / columns).
  let assert Ok(items_per_column) =
    int.floor_divide(total + columns - 1, columns)
  // Build the column-major index sequence, then map each index back to the
  // original item via `at/2`.
  let indices = column_major_indices(columns, items_per_column, total, 0, [])
  list.filter_map(indices, fn(idx) { at(items, idx) })
}

/// Get the element at `index` in `list`, or `Error(Nil)` if out of bounds.
/// stdlib v1.0.x has no `list.at`, so we walk the list with `list.rest`.
fn at(list: List(a), index: Int) -> Result(a, Nil) {
  case index <= 0 {
    True -> list.first(list)
    False ->
      case list.rest(list) {
        Ok(rest) -> at(rest, index - 1)
        Error(Nil) -> Error(Nil)
      }
  }
}

/// Generate the column-major index sequence recursively: for each column
/// (0..columns-1), for each row (0..items_per_column-1), emit
/// `row * columns + col` when it is < total.
fn column_major_indices(
  columns: Int,
  items_per_column: Int,
  total: Int,
  col: Int,
  acc: List(Int),
) -> List(Int) {
  case col >= columns {
    True -> acc
    False ->
      column_major_indices(
        columns,
        items_per_column,
        total,
        col + 1,
        list.append(
          acc,
          row_indices(col, columns, items_per_column, total, 0, []),
        ),
      )
  }
}

fn row_indices(
  col: Int,
  columns: Int,
  items_per_column: Int,
  total: Int,
  row: Int,
  acc: List(Int),
) -> List(Int) {
  case row >= items_per_column {
    True -> list.reverse(acc)
    False -> {
      let idx = row * columns + col
      let next_acc = case idx < total {
        True -> [idx, ..acc]
        False -> acc
      }
      row_indices(col, columns, items_per_column, total, row + 1, next_acc)
    }
  }
}
