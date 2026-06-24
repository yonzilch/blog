// arata — analytics FFI: dynamically injects the analytics provider's script
// into the document head, mirroring apollo's `partials/header.html` analytics
// section.
//
// Because arata doesn't yet have a custom index.html (Phase 17), the scripts
// are injected dynamically on first load. The provider is selected by the
// `Analytics` config type:
//   - GoatCounter: loads the vendored count.js with data-goatcounter.
//   - Umami: loads the vendored imamu.js with data-website-id.

export function inject_analytics(provider) {
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (document.getElementById("arata-analytics")) return;

  switch (provider.kind) {
    case "goatcounter": {
      const script = document.createElement("script");
      script.id = "arata-analytics";
      script.src = "/js/count.js";
      script.async = true;
      script.setAttribute(
        "data-goatcounter",
        "https://" + provider.user + "." + (provider.host || "goatcounter.com") + "/count",
      );
      document.head.appendChild(script);
      break;
    }
    case "umami": {
      const script = document.createElement("script");
      script.id = "arata-analytics";
      script.src = "/js/imamu.js";
      script.async = true;
      script.setAttribute("data-website-id", provider.website_id);
      script.setAttribute("data-host-url", provider.host_url);
      document.head.appendChild(script);
      break;
    }
    default:
      break;
  }
}
