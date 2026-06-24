// arata — search keyboard shortcut FFI: a global keydown listener that
// dispatches search-related messages for the Cmd/Ctrl+K modal.
//
// Mirrors apollo's `searchElasticlunr.js` keyboard handling:
//   - Cmd/Ctrl+K opens the search modal.
//   - Escape closes it.
//   - ArrowUp/ArrowDown navigate the results.
//   - Enter follows the selected result.
//
// The listener is registered once at startup and dispatches the key name
// ("k", "Escape", "ArrowUp", "ArrowDown", "Enter") along with the modifier
// state (cmd_or_ctrl: Bool). The Gleam `update` function decides what to do
// based on the current search state.

export function subscribe_to_search_keys(dispatch) {
  if (typeof window === "undefined") return () => {};
  const handler = (e) => {
    const cmd_or_ctrl = e.metaKey || e.ctrlKey;
    // Prevent Cmd/Ctrl+K from focusing the browser address bar
    if (cmd_or_ctrl && e.key === "k") {
      e.preventDefault();
    }
    dispatch({
      key: e.key,
      cmd_or_ctrl: cmd_or_ctrl,
    });
  };
  window.addEventListener("keydown", handler);
  return () => window.removeEventListener("keydown", handler);
}
