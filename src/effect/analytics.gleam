//// Analytics effect: dynamically injects the analytics provider's script
//// into the document head, mirroring apollo's `partials/header.html`
//// analytics section.
////
//// Because arata doesn't yet have a custom `index.html` (Phase 17), the
//// script is injected dynamically on first load via the FFI. The provider is
//// selected by the `data/site.Analytics` config type:
////   - GoatCounter: loads `/js/count.js` with `data-goatcounter`.
////   - Umami: loads `/js/imamu.js` with `data-website-id`.
////
//// The FFI lives in `src/ffi/analytics.ffi.mjs`. The `@external` declaration
//// has a no-op Gleam fallback so the project builds on Erlang.

import data/site.{type Analytics}
import lustre/effect.{type Effect}

/// Inject the analytics script for the configured provider. No-op when
/// `analytics` is `Disabled`.
pub fn inject(analytics: Analytics) -> Effect(Nil) {
  use _ <- effect.from
  inject_analytics(analytics)
  Nil
}

@external(javascript, "../ffi/analytics.ffi.mjs", "inject_analytics")
fn inject_analytics(analytics: Analytics) -> Nil
