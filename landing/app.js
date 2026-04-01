(function () {
  "use strict";

  const config = window.NUTRISCAN_LANDING_CONFIG || {};
  const eventQueueKey = "nutriscan_landing_event_queue";
  const leadQueueKey = "nutriscan_landing_lead_queue";
  const sessionKey = "nutriscan_landing_session_id";

  const runtime = {
    sessionId:
      sessionStorage.getItem(sessionKey) ||
      (typeof crypto !== "undefined" && crypto.randomUUID
        ? crypto.randomUUID()
        : "session_" + Date.now()),
  };
  sessionStorage.setItem(sessionKey, runtime.sessionId);

  function nowIso() {
    return new Date().toISOString();
  }

  function readQueue(key) {
    return JSON.parse(localStorage.getItem(key) || "[]");
  }

  function writeQueue(key, value) {
    localStorage.setItem(key, JSON.stringify(value));
  }

  function appendQueue(key, value) {
    const list = readQueue(key);
    list.push(value);
    writeQueue(key, list);
  }

  function removeFromQueue(key, idKey, idValue) {
    const list = readQueue(key).filter(function (item) {
      return item[idKey] !== idValue;
    });
    writeQueue(key, list);
  }

  async function postJson(url, payload) {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      throw new Error("HTTP " + response.status);
    }
  }

  function buildEvent(eventName, props) {
    return {
      event_id:
        typeof crypto !== "undefined" && crypto.randomUUID
          ? crypto.randomUUID()
          : "evt_" + Date.now(),
      event_name: eventName,
      event_time: nowIso(),
      session_id: runtime.sessionId,
      page_path: window.location.pathname,
      page_url: window.location.href,
      referrer: document.referrer || "",
      user_agent: navigator.userAgent,
      props: props || {},
    };
  }

  async function sendEvent(eventPayload) {
    if (!config.analyticsEndpoint) return false;

    try {
      await postJson(config.analyticsEndpoint, eventPayload);
      removeFromQueue(eventQueueKey, "event_id", eventPayload.event_id);
      return true;
    } catch (_err) {
      return false;
    }
  }

  async function flushEventQueue() {
    const queue = readQueue(eventQueueKey);
    for (const eventPayload of queue) {
      // Stop on first failure to avoid hammering unavailable endpoints.
      const ok = await sendEvent(eventPayload);
      if (!ok) break;
    }
  }

  async function track(eventName, props) {
    const payload = buildEvent(eventName, props);
    appendQueue(eventQueueKey, payload);

    if (config.debug) {
      // eslint-disable-next-line no-console
      console.log("[nutriscan-landing]", payload);
    }

    if (typeof config.analyticsHook === "function") {
      config.analyticsHook(payload);
    }

    await sendEvent(payload);
  }

  function buildLeadPayload(formData) {
    return {
      lead_id:
        typeof crypto !== "undefined" && crypto.randomUUID
          ? crypto.randomUUID()
          : "lead_" + Date.now(),
      submitted_at: nowIso(),
      session_id: runtime.sessionId,
      source: "landing_page",
      full_name: String(formData.get("full_name") || "").trim(),
      email: String(formData.get("email") || "").trim().toLowerCase(),
      interest_type: String(formData.get("interest_type") || "").trim(),
      notes: String(formData.get("notes") || "").trim(),
    };
  }

  function cacheLeadLocally(payload) {
    appendQueue(leadQueueKey, payload);
  }

  function bindCtaTracking() {
    const buttons = document.querySelectorAll("[data-event='hero_cta_clicked']");
    buttons.forEach(function (node) {
      node.addEventListener("click", function () {
        const cta = node.getAttribute("data-cta") || "unknown";
        track("hero_cta_clicked", { cta: cta, section: "hero_or_nav" });
        if (cta.indexOf("demo") >= 0) {
          track("demo_requested", { source: "cta_click", intent: "request_demo" });
        }
      });
    });
  }

  function bindScreenshotTracking() {
    const gallery = document.querySelector("[data-track-gallery]");
    if (!gallery || !("IntersectionObserver" in window)) return;

    let tracked = false;
    const observer = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (entry) {
          if (!tracked && entry.isIntersecting) {
            tracked = true;
            track("screenshot_gallery_viewed", { section: "screenshots" });
            observer.disconnect();
          }
        });
      },
      { threshold: 0.35 }
    );

    observer.observe(gallery);
  }

  function bindFaqTracking() {
    const nodes = document.querySelectorAll("#faq details");
    nodes.forEach(function (node, index) {
      node.addEventListener("toggle", function () {
        if (node.open) {
          track("faq_expanded", { item_index: index + 1, section: "faq" });
        }
      });
    });
  }

  function bindFormTracking() {
    const form = document.getElementById("lead-form");
    const status = document.getElementById("form-status");
    if (!form || !status) return;

    let started = false;
    form.addEventListener("focusin", function () {
      if (!started) {
        started = true;
        track("waitlist_started", { source: "form_focus" });
      }
    });

    form.addEventListener("submit", async function (evt) {
      evt.preventDefault();

      const payload = buildLeadPayload(new FormData(form));
      track("waitlist_submit_attempted", { interest_type: payload.interest_type });

      const setStatus = function (text, success) {
        status.classList.toggle("success", !!success);
        status.textContent = text;
      };

      if (!config.formEndpoint) {
        cacheLeadLocally(payload);
        track("waitlist_submit_failed", {
          reason: "form_endpoint_missing",
          interest_type: payload.interest_type,
        });
        setStatus("Saved locally. Configure form endpoint for production capture.", true);
        track("confirmation_state_viewed", {
          source: "local_fallback",
          interest_type: payload.interest_type,
        });
        return;
      }

      try {
        await postJson(config.formEndpoint, payload);
        form.reset();
        setStatus("Thanks. Your request was submitted.", true);
        track("waitlist_submitted", {
          source: "form_submit",
          interest_type: payload.interest_type,
        });
        if (payload.interest_type === "request_demo") {
          track("demo_requested", { source: "form_submit", intent: "request_demo" });
        }
        track("confirmation_state_viewed", {
          source: "form_submit",
          interest_type: payload.interest_type,
        });
      } catch (_err) {
        cacheLeadLocally(payload);
        track("waitlist_submit_failed", {
          reason: "form_endpoint_error",
          interest_type: payload.interest_type,
        });
        setStatus("Saved locally. Endpoint failed; verify deployment wiring.", true);
        track("confirmation_state_viewed", {
          source: "local_fallback",
          interest_type: payload.interest_type,
        });
      }
    });
  }

  track("landing_page_view", { section: "hero" });
  flushEventQueue();
  bindCtaTracking();
  bindScreenshotTracking();
  bindFaqTracking();
  bindFormTracking();
})();
