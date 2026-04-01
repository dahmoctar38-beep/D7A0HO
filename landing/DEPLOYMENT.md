# Landing Deployment

## Current state

- Landing is deployable.
- HTTPS is not live from this repository by itself.
- Deployment target is prepared for Netlify static + serverless functions.

## Option A (recommended): Netlify

Prerequisites:

- Netlify account
- `NETLIFY_AUTH_TOKEN`
- `NETLIFY_SITE_ID` (optional for existing site)

Prepared files:

- root `netlify.toml`:
  - `publish = "landing"`
  - `functions = "landing/functions"`
  - redirects for `/api/interest` and `/api/events`

### Deploy commands

```bash
cd /Users/dahamar/nutriscan-ai
npx --yes netlify-cli login --request "NutriScan landing production publish"
npx --yes netlify-cli deploy --prod --dir=landing --functions=landing/functions
```

If linking to an existing site:

```bash
npx --yes netlify-cli link --id "<SITE_ID>"
npx --yes netlify-cli deploy --prod --dir=landing --functions=landing/functions
```

### Current environment reality

- Anonymous deploy was attempted and failed because this project includes Netlify Functions.
- Netlify requires authentication for function-enabled deploys.
- Final manual step is login + deploy commands above.
- Do not use Netlify Drop (static drag-and-drop) for this project because Drop does not deploy functions.

### Environment variables (recommended)

Set in Netlify project settings:

- `INTEREST_FORWARD_URL`
- `ANALYTICS_FORWARD_URL`

Without these, endpoints accept payloads but do not persist externally.

## Option B: Any static host + custom API

1. Host `landing/` on any static provider over HTTPS.
2. Keep `config.js` hosted defaults or set explicit endpoint URLs.
3. Provide two POST endpoints:
   - `/api/interest`
   - `/api/events`
4. Use contracts in `docs/acquire/*-endpoint-contract.md`.

## Post-deploy smoke checks

1. Open landing page over HTTPS.
2. Click a hero CTA and submit form.
3. Verify:
   - `/api/events` receives event payloads
   - `/api/interest` receives lead payloads
4. Confirm status text: `Thanks. Your request was submitted.`
5. Verify captured records in your external sink.

## Important

- Do not claim live HTTPS deployment until URL is confirmed accessible.
- Do not claim real demand evidence until external submissions/events are confirmed from non-test traffic.
