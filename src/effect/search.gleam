//// Search effect: a global keyboard listener for the search modal, mirroring
//// apollo's `searchElasticlunr.js` keyboard handling.
////
//// Registers a `keydown` listener on `window` that dispatches
//// `SearchKeyPressed` messages with the key name and modifier state. The
//// `update` function interprets these:
////   - Cmd/Ctrl+K → open the modal
////   - Escape → close the modal
////   - ArrowUp/ArrowDown → navigate results (only when the modal is open)
////   - Enter → follow the selected result (only when the modal is open)
////
//// The FFI lives in `src/ffi/search.ffi.mjs`. The `@external` declaration has
//// a no-op Gleam fallback so the project builds on Erlang.

import lustre/effect.{type Effect}

/// The key event data dispatched by the FFI.
pub type SearchKeyEvent {
  SearchKeyEvent(key: String, cmd_or_ctrl: Bool)
}

/// Messages produced by the search keyboard effect.
pub type SearchMsg {
  SearchKeyPressed(event: SearchKeyEvent)
}

/// Register a global `keydown` listener for search shortcuts. Returns an
/// effect that dispatches `SearchKeyEvent` values. The caller maps these into
/// the app's `Msg` type via `effect.map`.
pub fn subscribe_to_search_keys() -> Effect(SearchKeyEvent) {
  use dispatch <- effect.from
  let _ = subscribe(dispatch)
  Nil
}

@external(javascript, "../ffi/search.ffi.mjs", "subscribe_to_search_keys")
fn subscribe(dispatch: fn(SearchKeyEvent) -> Nil) -> fn() -> Nil
