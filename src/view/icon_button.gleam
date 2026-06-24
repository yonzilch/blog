//// Icon button component for external links.
////
//// Used by project cards for GitHub/GitLab/Codeberg/Forgejo/Demo links.
//// Icon assets are resolved through Config.base_path so non-root deployments
//// such as GitHub Pages project sites do not request `/icons/...` from the
//// domain root.

import config
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html

pub fn view(url: String, label: String, icon: String) -> Element(msg) {
  let site_config = config.default()

  html.a(
    [
      attribute.class("icon-button"),
      attribute.href(url),
      attribute.target("_blank"),
      attribute.rel("noopener"),
      attribute.attribute("aria-label", label),
      attribute.title(label),
    ],
    [
      html.img([
        attribute.alt(label),
        attribute.src(config.with_base_path(
          site_config.base_path,
          "/icons/social/" <> icon <> ".svg",
        )),
      ]),
    ],
  )
}
