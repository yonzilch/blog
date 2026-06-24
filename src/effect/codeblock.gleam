//// Code-block enhancement effect: post-processes `<pre><code>` blocks in the
//// rendered post body to inject a copy button and a language label, mirroring
//// apollo's `static/js/codeblock.js`.
////
//// Because the post body is rendered via `element.unsafe_raw_html`, the
//// `<pre><code>` elements are in the DOM but without apollo's fancy buttons.
//// This effect runs after each post view renders (via `effect.from`) and
//// calls the FFI to enhance every code block: it reads the `data-lang`
//// attribute (defaulting to "default"), appends a `.clipboard-button` (with
//// clipboard/check/× SVG icons and a 2s icon swap on copy) and a
//// `.code-label.label-<lang>` (colored per the ported `$language-colors` map),
//// and wires the scroll-pinning behaviour.
////
//// The FFI lives in `src/ffi/codeblock.ffi.mjs`. The `@external` declaration
//// has a no-op Gleam fallback body so the project still builds on Erlang.

import lustre/effect.{type Effect}

/// Enhance all `<pre><code>` blocks in the current document. Should be called
/// after each post view renders (the previous post's blocks are gone from the
/// DOM, so there's no need to clean up first).
pub fn enhance() -> Effect(Nil) {
  use _ <- effect.from
  enhance_code_blocks()
  Nil
}

@external(javascript, "../ffi/codeblock.ffi.mjs", "enhance_code_blocks")
fn enhance_code_blocks() -> Nil
