const allowedEvents = new Set([
  "landing_page_view",
  "hero_cta_clicked",
  "screenshot_gallery_viewed",
  "faq_expanded",
  "waitlist_started",
  "waitlist_submit_attempted",
  "waitlist_submitted",
  "waitlist_submit_failed",
  "demo_requested",
  "confirmation_state_viewed",
]);

function json(statusCode, payload) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  };
}

function parseBody(raw) {
  try {
    return JSON.parse(raw || "{}");
  } catch (_err) {
    return null;
  }
}

function isValidEvent(body) {
  if (!body) return false;
  const name = String(body.event_name || "").trim();
  if (!allowedEvents.has(name)) return false;
  if (!String(body.event_time || "").trim()) return false;
  if (!String(body.page_path || "").trim()) return false;
  return true;
}

async function forwardIfConfigured(payload) {
  const endpoint = process.env.ANALYTICS_FORWARD_URL || "";
  if (!endpoint) return { forwarded: false };

  const res = await fetch(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    throw new Error(`Analytics forward failed: HTTP ${res.status}`);
  }

  return { forwarded: true };
}

exports.handler = async (event) => {
  if (event.httpMethod !== "POST") {
    return json(405, { accepted: false, error: "method_not_allowed" });
  }

  const body = parseBody(event.body);
  if (!isValidEvent(body)) {
    return json(400, { accepted: false, error: "invalid_payload" });
  }

  const analyticsEvent = {
    event_id: String(body.event_id || ""),
    event_name: String(body.event_name || "").trim(),
    event_time: String(body.event_time || "").trim(),
    session_id: String(body.session_id || "").trim(),
    page_path: String(body.page_path || "").trim(),
    page_url: String(body.page_url || "").trim(),
    referrer: String(body.referrer || "").trim(),
    user_agent: String(body.user_agent || "").trim(),
    props: typeof body.props === "object" && body.props !== null ? body.props : {},
  };

  try {
    const forwarding = await forwardIfConfigured(analyticsEvent);
    return json(202, {
      accepted: true,
      storage: forwarding.forwarded ? "forwarded" : "none",
      message:
        forwarding.forwarded
          ? "Event accepted and forwarded."
          : "Event accepted. Set ANALYTICS_FORWARD_URL to persist externally.",
    });
  } catch (err) {
    return json(502, { accepted: false, error: "forward_failed", detail: String(err.message || err) });
  }
};
