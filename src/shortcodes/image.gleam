//// Image shortcode: renders an `<img>` with lazy loading and an aspect-ratio
//// attribute, mirroring apollo's `templates/shortcodes/image.html`.
////
//// apollo uses `resize_image` at build time to produce avif/webp derivatives.
//// arata defers image processing to Phase 17's build pipeline; for now the
//// shortcode just emits the `<img>` tag with the given path. Returns an HTML
//// string for embedding in the post body.

import gleam/int

/// Render an image.
///
/// - `path`: the image src URL.
/// - `alt`: the alt text.
/// - `width`, `height`: used for the `aspect-ratio` attribute.
/// - `loading`: "lazy" (default) or "eager".
/// - `decoding`: "async" (default) or "sync".
pub fn view(
  path: String,
  alt: String,
  width: Int,
  height: Int,
  loading: String,
  decoding: String,
) -> String {
  "<img aspect-ratio='"
  <> int.to_string(width)
  <> " / "
  <> int.to_string(height)
  <> "' src='"
  <> path
  <> "' alt='"
  <> alt
  <> "' loading='"
  <> loading
  <> "' decoding='"
  <> decoding
  <> "' />"
}
