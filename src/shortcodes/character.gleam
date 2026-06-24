//// Character shortcode: renders an avatar with a speech bubble, mirroring
//// apollo's `templates/shortcodes/character.html`.
////
//// The avatar is 80×80px; the default image is `images/characters/hooded.png`.
//// The `position` field ("left" or "right") flips the row direction and
//// mirrors the avatar. Returns an HTML string for embedding in the post body.

/// Render a character speech bubble.
///
/// - `name`: the character name (used for CSS classes and the default image).
/// - `body`: the speech text (rendered as markdown by the pipeline).
/// - `position`: "left" or "right".
/// - `image`: optional image filename (without path); defaults to
///   `hooded.png` when `name` is "hooded".
pub fn view(
  name: String,
  body: String,
  position: String,
  image: String,
) -> String {
  let img_src = case image {
    "" ->
      case name {
        "hooded" -> "/images/characters/hooded.png"
        _ -> ""
      }
    _ -> "/images/characters/" <> image
  }
  let avatar = case img_src {
    "" -> name
    _ ->
      "<img src='"
      <> img_src
      <> "' alt='"
      <> name
      <> "' width='80' height='80' />"
  }
  "<div class='character-note character-"
  <> name
  <> " character-comment character-"
  <> position
  <> "'>"
  <> "<div class='character-avatar'>"
  <> avatar
  <> "</div>"
  <> "<div class='character-content'>"
  <> "<div class='character-bubble'>"
  <> body
  <> "</div>"
  <> "</div>"
  <> "</div>"
}
