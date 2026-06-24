//// Project card view: renders a single project as a `.card`, mirroring
//// apollo's `templates/cards.html` per-card structure.
////
//// Each card optionally shows media (image), a title (linked externally via
//// `link_to` or internally to `/{slug}`), decorative `#tag` chips, a tagline
//// description, and a footer with GitHub/GitLab/Codeberg/Forgejo/Demo
//// icon-buttons.
////
//// Layout invariant:
////   card-title -> card-tags -> card-tagline -> card-footer
////
//// Tags are intentionally rendered as their own row between title and
//// tagline. Keeping tags out of `.card-footer` prevents them from competing
//// with icon-buttons for horizontal space on narrow screens.

import data/project.{type Project}
import gleam/list
import gleam/option.{type Option}
import lustre/attribute
import lustre/element.{type Element, none}
import lustre/element/html
import route
import view/icon_button

/// Render a single project card.
pub fn view(project: Project) -> Element(msg) {
  html.div([attribute.class("card")], [
    view_media(project.image, project.title),
    html.div([attribute.class("card-content")], [
      html.h1([attribute.class("card-title")], [view_title(project)]),
      view_tags(project.tags),
      view_tagline(project.description),
      view_footer(project),
    ]),
  ])
}

/// The card media: an image when `image` is set, otherwise nothing.
fn view_media(image: Option(String), alt: String) -> Element(msg) {
  case image {
    option.Some(src) ->
      html.div([attribute.class("card-media")], [
        html.img([
          attribute.class("card-image"),
          attribute.alt(alt),
          attribute.src(src),
        ]),
      ])

    option.None -> none()
  }
}

/// The card title as a link. External `link_to` opens in a new tab; otherwise
/// the title links to the internal project page through the typed router so
/// non-root deployments keep the configured base path.
fn view_title(project: Project) -> Element(msg) {
  case project.link_to {
    option.Some(url) ->
      html.a(
        [
          attribute.href(url),
          attribute.target("_blank"),
          attribute.rel("noopener"),
        ],
        [html.text(project.title)],
      )

    option.None ->
      html.a([route.href(route.Page(project.slug))], [
        html.text(project.title),
      ])
  }
}

/// The `#tag` chips, capped at 4.
///
/// Tags are decorative, not links, matching apollo's card tag behavior.
/// They are rendered as a standalone row between title and tagline so they
/// wrap cleanly on narrow screens.
fn view_tags(tags: List(String)) -> Element(msg) {
  case tags {
    [] -> none()

    _ ->
      html.div(
        [attribute.class("card-tags")],
        list.map(list.take(tags, 4), fn(tag) {
          html.span([attribute.class("card-tag")], [html.text("#" <> tag)])
        }),
      )
  }
}

/// The card tagline (description). apollo wraps it in `<p class="card-tagline">`.
fn view_tagline(description: String) -> Element(msg) {
  case description {
    "" -> none()

    _ -> html.p([attribute.class("card-tagline")], [html.text(description)])
  }
}

/// The card footer: GitHub/GitLab/Codeberg/Forgejo/Demo icon-buttons only.
/// Shown only when the project has at least one configured link.
fn view_footer(project: Project) -> Element(msg) {
  let links =
    view_links(
      project.github,
      project.gitlab,
      project.codeberg,
      project.forgejo,
      project.demo,
    )

  case list.is_empty(links) {
    True -> none()

    False ->
      html.div([attribute.class("card-footer")], [
        html.div([attribute.class("card-links")], links),
      ])
  }
}

/// The GitHub, GitLab, Codeberg, Forgejo, and Demo icon-buttons, if their URLs
/// are set.
fn view_links(
  github: Option(String),
  gitlab: Option(String),
  codeberg: Option(String),
  forgejo: Option(String),
  demo: Option(String),
) -> List(Element(msg)) {
  let gh = case github {
    option.Some(url) -> [icon_button.view(url, "GitHub", "github")]
    option.None -> []
  }

  let gl = case gitlab {
    option.Some(url) -> [icon_button.view(url, "GitLab", "gitlab")]
    option.None -> []
  }

  let cb = case codeberg {
    option.Some(url) -> [icon_button.view(url, "Codeberg", "codeberg")]
    option.None -> []
  }

  let fj = case forgejo {
    option.Some(url) -> [icon_button.view(url, "Forgejo", "forgejo")]
    option.None -> []
  }

  let dm = case demo {
    option.Some(url) -> [icon_button.view(url, "Demo", "globe")]
    option.None -> []
  }

  list.flatten([gh, gl, cb, fj, dm])
}
