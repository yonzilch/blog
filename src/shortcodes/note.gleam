//// Note shortcode: renders a static or dynamic note box, mirroring apollo's
//// `templates/shortcodes/note.html`.
////
//// Static notes show a `.note-header` (with an icon or centered text) and a
//// `.note-content` always visible. Dynamic notes use a `<button
//// class="note-toggle">` that toggles the `.note-content` display — the
//// toggle behaviour is wired by `effect/note.gleam` (FFI post-processor that
//// attaches click handlers to `.note-toggle` buttons, mirroring apollo's
//// `note.js`).
////
//// Returns an HTML string (not a Lustre Element) because notes are embedded
//// inside the post body's pre-rendered HTML. The future markdown pipeline
//// (Phase 17) will call this function to expand `{{ note(...) }}` syntax.

/// Render a note box.
///
/// - `header`: the header text (rendered as markdown by the pipeline; here it
///   is treated as plain text).
/// - `body`: the body HTML.
/// - `clickable`: when True, the header becomes a toggle button (dynamic note).
/// - `hidden`: when True (and clickable), the body starts hidden.
/// - `center`: when True, the header is centered instead of using an icon.
pub fn view(
  header: String,
  body: String,
  clickable: Bool,
  hidden: Bool,
  center: Bool,
) -> String {
  let header_class = case center {
    True -> "note-center"
    False -> "note-icon"
  }
  let display = case clickable && hidden {
    True -> "none"
    False -> "block"
  }
  case clickable {
    True ->
      "<div class='note-container'>"
      <> "<button class='note-toggle'>"
      <> "<div class='"
      <> header_class
      <> "'>"
      <> header
      <> "</div>"
      <> "</button>"
      <> "<div class='note-content' style='display: "
      <> display
      <> ";'>"
      <> body
      <> "</div>"
      <> "</div>"
    False ->
      "<div class='note-container'>"
      <> "<div class='note-header'>"
      <> "<div class='"
      <> header_class
      <> "'>"
      <> header
      <> "</div>"
      <> "</div>"
      <> "<div class='note-content'>"
      <> body
      <> "</div>"
      <> "</div>"
  }
}
