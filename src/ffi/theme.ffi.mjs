// arata — theme FFI: localStorage persistence and prefers-color-scheme
// subscription.
//
// Mirrors apollo's `static/js/themetoggle.js` behaviour:
//   - `get_theme()` reads `localStorage["theme-storage"]`, falling back to the
//     system preference. Returns the string "light" | "dark" | "auto".
//   - `set_theme(mode)` writes the string to localStorage and applies the
//     `dark`/`light` class on <html> (resolving `auto` against the system
//     preference).
//   - `subscribe_to_system_changes(dispatch)` registers a matchMedia change
//     listener that calls `dispatch(true|false)` when the OS theme changes.
//
// The class on <html> is the single source of truth for the CSS: `:root` is
// light by default, `:root.dark` overrides to dark (see arata.css). This
// matches apollo's `htmlElement.classList.add/remove("dark"/"light")`.

export function get_theme() {
  let stored = null;
  try {
    stored = window.localStorage.getItem("theme-storage");
  } catch {
    // localStorage may be unavailable (e.g. privacy mode); fall back to system.
  }
  if (stored === "light" || stored === "dark" || stored === "auto") {
    return stored;
  }
  // No saved preference — use the system preference.
  return get_system_prefers_dark() ? "dark" : "light";
}

export function set_theme(mode) {
  try {
    window.localStorage.setItem("theme-storage", mode);
  } catch {
    // Ignore write failures (privacy mode, quota, etc.).
  }
  apply_theme(mode);
}

/// Apply the theme to the DOM: toggle the `dark`/`light` classes on <html>.
/// `auto` resolves against the system preference.
///
/// Important:
/// Theme-toggle icon rendering is owned by Lustre (`view/header.gleam`).
/// Do not mutate sun/moon/auto icon display or filter here, otherwise the FFI
/// can race against Lustre's virtual DOM and show the wrong icon after refresh.
export function apply_theme(mode) {
  const useDark =
    mode === "dark" || (mode === "auto" && get_system_prefers_dark());

  const html = document.documentElement;

  if (useDark) {
    html.classList.remove("light");
    html.classList.add("dark");
  } else {
    html.classList.remove("dark");
    html.classList.add("light");
  }
}

export function get_system_prefers_dark() {
  return (
    typeof window !== "undefined" &&
    window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: dark)").matches
  );
}

/// Register a listener for system theme changes. The callback receives `true`
/// when the system switches to dark, `false` for light. Returns an unsubscribe
/// function.
export function subscribe_to_system_changes(dispatch) {
  if (typeof window === "undefined" || !window.matchMedia) return () => {};
  const mql = window.matchMedia("(prefers-color-scheme: dark)");
  const handler = (e) => dispatch(e.matches);
  mql.addEventListener("change", handler);
  return () => mql.removeEventListener("change", handler);
}
