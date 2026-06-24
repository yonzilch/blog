//// Mermaid shortcode: renders a `<pre class="mermaid">` block for
//// client-side rendering by the mermaid library, mirroring apollo's
//// `templates/shortcodes/mermaid.html`.
////
//// The actual diagram rendering (calling `mermaid.run()`) is handled by
//// Phase 14's `effect/script.gleam`. This shortcode just emits the container.
//// Returns an HTML string for embedding in the post body.

/// Render a mermaid diagram container.
pub fn view(body: String) -> String {
  "<pre class='mermaid'>" <> body <> "</pre>"
}
