//// Comments view: renders a comments section (Giscus or Utterances) at the
//// bottom of a post, mirroring apollo's `base.html` giscus section and
//// `_giscus_script.html`.
////
//// apollo emits `<div class="giscus"></div>` + a giscus/utterances `<script>`
//// when `page.extra.comment` is true. arata does the same: the comments
//// container + script are emitted via `unsafe_raw_html` (the external script
//// won't re-execute on Lustre vdom diff, so a future Phase 17 SSR `index.html`
//// or a post-render effect would be needed for full giscus functionality).
//// For now, the container is rendered so the structure is in place.

import data/site.{type CommentsConfig, CommentsDisabled, Giscus, Utterances}
import lustre/element.{type Element, none, unsafe_raw_html}

/// Render the comments section. Returns `element.none()` when comments are
/// disabled. The caller passes the post slug for the giscus `mapping`.
pub fn view(config: CommentsConfig, slug: String) -> Element(msg) {
  case config {
    Giscus(repo:, repo_id:, category:, category_id:) ->
      unsafe_raw_html(
        "",
        "div",
        [],
        "<div class='giscus'></div>"
          <> "<script src='https://giscus.app/client.js'"
          <> " data-repo='"
          <> repo
          <> "'"
          <> " data-repo-id='"
          <> repo_id
          <> "'"
          <> " data-category='"
          <> category
          <> "'"
          <> " data-category-id='"
          <> category_id
          <> "'"
          <> " data-mapping='specific'"
          <> " data-term='"
          <> slug
          <> "'"
          <> " data-strict='0'"
          <> " data-reactions-enabled='1'"
          <> " data-emit-metadata='0'"
          <> " data-input-position='top'"
          <> " data-theme='preferred_color_scheme'"
          <> " data-lang='en'"
          <> " data-loading='lazy'"
          <> " crossorigin='anonymous'"
          <> " async>"
          <> "</script>",
      )
    Utterances(repo:) ->
      unsafe_raw_html(
        "",
        "div",
        [],
        "<div class='giscus'></div>"
          <> "<script src='https://utteranc.es/client.js'"
          <> " repo='"
          <> repo
          <> "'"
          <> " issue-term='pathname'"
          <> " theme='preferred_color_scheme'"
          <> " crossorigin='anonymous'"
          <> " async>"
          <> "</script>",
      )
    CommentsDisabled -> none()
  }
}
