// Runtime config for landing analytics + lead capture.
// Local default: send to dev collector at http://127.0.0.1:8787
// Hosted default: send to same-origin API paths (/api/interest, /api/events)
(function () {
  const host = window.location.hostname;
  const isLocal = host === "localhost" || host === "127.0.0.1";

  window.NUTRISCAN_LANDING_CONFIG = {
    // Required for live form capture.
    formEndpoint: isLocal ? "http://127.0.0.1:8787/api/interest" : "/api/interest",
    // Required for live analytics ingestion.
    analyticsEndpoint: isLocal ? "http://127.0.0.1:8787/api/events" : "/api/events",
    // Optional: called on every tracked event.
    analyticsHook: null,
    // Optional: set true to print tracking logs in browser console.
    debug: false,
  };
})();
