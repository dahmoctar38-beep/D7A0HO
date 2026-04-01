# NutriScan AI Landing

Minimal landing page + demand funnel + event instrumentation.

## What exists now

- Static page (`index.html`) with CTA and interest form
- Screenshot assets shipped under `landing/assets/screenshots/`
- Event tracking in `app.js`
- Config-driven form and analytics endpoints (`config.js`)
- Draft legal pages (`privacy.html`, `terms.html`)
- Local collector for end-to-end testing (`dev_collector.py`)
- Netlify deployment mapping via root `netlify.toml`

## Local run (single command)

```bash
cd landing
python3 dev_collector.py --host 127.0.0.1 --port 8787
```

Open: `http://127.0.0.1:8787/index.html`

This serves both:

- static landing
- `/api/interest` and `/api/events` endpoints

Runtime data is saved to:

- `landing/runtime/interest-submissions.jsonl`
- `landing/runtime/events.jsonl`

## Production wiring

Default hosted endpoints in `config.js`:

- `formEndpoint = /api/interest`
- `analyticsEndpoint = /api/events`

To persist externally in serverless mode, set environment variables:

- `INTEREST_FORWARD_URL`
- `ANALYTICS_FORWARD_URL`

Template:

- `landing/.env.example`

See:

- `landing/DEPLOYMENT.md`
- `docs/acquire/form-endpoint-contract.md`
- `docs/acquire/analytics-endpoint-contract.md`

## Event names

- `landing_page_view`
- `hero_cta_clicked`
- `screenshot_gallery_viewed`
- `faq_expanded`
- `waitlist_started`
- `waitlist_submit_attempted`
- `waitlist_submitted`
- `waitlist_submit_failed`
- `demo_requested`
- `confirmation_state_viewed`
