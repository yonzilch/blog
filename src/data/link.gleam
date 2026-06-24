//// Content model for a friend link, rendered on the /links page.
////
//// `weight` follows Zola's convention: smaller values are rendered earlier.
//// Links without a configured weight should use the loader default `999`.

import gleam/option.{type Option}

pub type Link {
  Link(
    title: String,
    url: String,
    description: String,
    image: Option(String),
    weight: Int,
  )
}
