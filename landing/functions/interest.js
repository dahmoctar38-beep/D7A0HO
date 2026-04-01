const allowedInterestTypes = new Set([
  "request_demo",
  "join_waitlist",
  "early_access",
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

function isValidLead(body) {
  if (!body) return false;
  if (!String(body.full_name || "").trim()) return false;
  if (!String(body.email || "").trim()) return false;
  if (!allowedInterestTypes.has(String(body.interest_type || "").trim())) return false;
  return true;
}

async function forwardIfConfigured(payload) {
  const endpoint = process.env.INTEREST_FORWARD_URL || "";
  if (!endpoint) return { forwarded: false };

  const res = await fetch(endpoint, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  if (!res.ok) {
    throw new Error(`Interest forward failed: HTTP ${res.status}`);
  }

  return { forwarded: true };
}

exports.handler = async (event) => {
  if (event.httpMethod !== "POST") {
    return json(405, { accepted: false, error: "method_not_allowed" });
  }

  const body = parseBody(event.body);
  if (!isValidLead(body)) {
    return json(400, { accepted: false, error: "invalid_payload" });
  }

  const lead = {
    lead_id: String(body.lead_id || ""),
    submitted_at: String(body.submitted_at || ""),
    session_id: String(body.session_id || ""),
    source: "landing_page",
    full_name: String(body.full_name || "").trim(),
    email: String(body.email || "").trim().toLowerCase(),
    interest_type: String(body.interest_type || "").trim(),
    notes: String(body.notes || "").trim(),
  };

  try {
    const forwarding = await forwardIfConfigured(lead);
    return json(202, {
      accepted: true,
      storage: forwarding.forwarded ? "forwarded" : "none",
      message:
        forwarding.forwarded
          ? "Lead accepted and forwarded."
          : "Lead accepted. Set INTEREST_FORWARD_URL to persist externally.",
    });
  } catch (err) {
    return json(502, { accepted: false, error: "forward_failed", detail: String(err.message || err) });
  }
};
