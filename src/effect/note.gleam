//// Note toggle effect: post-processes `.note-toggle` buttons in the rendered
//// post body to attach click handlers for expand/collapse, mirroring apollo's
//// `static/js/note.js`.
////
//// Because the post body is rendered via `element.unsafe_raw_html`, the note
//// HTML is in the DOM but without event handlers. This effect runs after each
//// post view renders and calls the FFI to wire up the toggle behaviour.
////
//// The FFI lives in `src/ffi/note.ffi.mjs`. The `@external` declaration has a
//// no-op Gleam fallback body so the project builds on Erlang.

import lustre/effect.{type Effect}

/// Enhance all `.note-toggle` buttons in the current document. Should be
/// called after each post view renders.
pub fn enhance() -> Effect(Nil) {
  use _ <- effect.from
  enhance_notes()
  Nil
}

@external(javascript, "../ffi/note.ffi.mjs", "enhance_notes")
fn enhance_notes() -> Nil
