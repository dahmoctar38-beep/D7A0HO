# NutriScan AI — Release Notes

## Milestone: Cycles 1–3 Complete

**Date:** 2026-03-21  
**Status:** MVP complete — ready for device testing and staged production rollout

---

## What Was Built

### Mobile App (Flutter)
| Feature | Status |
|---------|--------|
| Barcode scanner (real camera + flash toggle) | ✅ Production-ready |
| Product details page (nutrition card, allergens, ingredients) | ✅ Production-ready |
| AI analysis page (score ring, highlights, concerns, diabetic flag) | ✅ Production-ready |
| Bottom navigation (Home / History / Favorites / Profile) | ✅ Production-ready |
| Scan history (last 50 scans, dedup by barcode, SharedPreferences) | ✅ Production-ready |
| Favorites (toggle per product, persistent) | ✅ Production-ready |
| Dietary preferences (diabetic mode, vegan, allergen list) | ✅ Production-ready |
| Login page + mock auth | ✅ Mock only (see limitations) |
| Mock/real backend switch via `--dart-define=USE_REAL_API=true` | ✅ Production-ready |

### Backend Services (Python / FastAPI)
| Service | Port | Status |
|---------|------|--------|
| Gateway | 8000 | ✅ Production-ready |
| Product Catalog | 8001 | ✅ Production-ready |
| AI Nutrition | 8002 | ✅ Production-ready |

### Backend Tests
| Suite | Tests | Result |
|-------|-------|--------|
| product-catalog | 5 | ✅ All pass |
| ai-nutrition | 15 | ✅ All pass |

### CI
| Workflow | Trigger | Jobs |
|----------|---------|------|
| `mobile-ci.yml` | push/PR to `mobile/**` | analyze → test → build APK |
| `backend-ci.yml` | push/PR to `services/**` | product-catalog tests → ai-nutrition tests → docker build |

---

## What Is Mock vs Production-Ready

### Mock (not yet production)
- **Auth**: `MockAuthService` stores email+flag in `SharedPreferences`. No real backend, no JWT, no OAuth.
- **Analysis summary when `ANTHROPIC_API_KEY` is unset**: rule-based string, not LLM-generated.

### Production-ready
- **Product data**: live Open Food Facts API with 5-product seed fallback.
- **Scoring algorithm**: deterministic, tested, consistent between Python agent and Dart mock.
- **All 3 microservices**: containerized, health-checked, CORS-enabled.
- **Camera scanner**: real `mobile_scanner` with barcode detection guard.
- **Persistent storage**: history, favorites, preferences all use `SharedPreferences`.

---

## What Was NOT Done

| Item | Reason |
|------|--------|
| Real authentication (Firebase/JWT/OAuth) | Deferred — needs backend decision (Firebase vs custom) |
| iOS App Store build / signing | Requires paid Apple Developer account |
| Push notifications | Not in scope for Cycles 1–3 |
| User account sync / cloud backup | Deferred — requires auth backend first |
| Barcode image capture (photo scan, not live) | `mobile_scanner` live only in this build |
| Admin panel / product management UI | Deferred |
| Production infrastructure (cloud VMs, CDN, domain) | Deferred |
| Rate limiting / API keys on gateway | Deferred |
| Analytics / crash reporting | Deferred |

---

## Known Limitations

| Limitation | Impact | Workaround |
|------------|--------|------------|
| Open Food Facts coverage varies by region | Some barcodes return 404 → seed fallback | Expand seed dataset |
| `ANTHROPIC_API_KEY` not set → rule-based summaries | Summaries are generic, not AI-personalized | Set env var to enable Claude summaries |
| Snickers score = 45 (poor) but nutritional data is 100g reference, not per serving | Score may seem harsh for small servings | Display per-serving toggle (future) |
| No offline mode beyond seed data | 404 on unknown product without internet | Expand seed or local DB (future) |
| History dedup by barcode only (not by scan date) | Re-scanning same product only updates timestamp | Expected behavior; configurable per requirements |
| Android emulator uses `10.0.2.2`, real device needs LAN IP | App may not reach backend on real device without `--dart-define=API_BASE_URL=...` | Pass correct IP at build time |

---

## Next Recommended Milestones

### Milestone 4 — Real Auth
- Replace `MockAuthService` with Firebase Auth (Google Sign-In + email/password)
- Backend: validate Firebase ID tokens on protected routes
- Mobile: token refresh handling, auth guard in router

### Milestone 5 — Production Infrastructure
- Deploy 3 services to a VPS or cloud (e.g. Railway, Fly.io, or Docker on VPS)
- Add HTTPS via Caddy or nginx reverse proxy
- Add `API_BASE_URL` to `.env` in mobile build pipeline

### Milestone 6 — Personalization
- Use `UserPreferences.isDiabetic` / allergens to filter and flag analysis results in real-time
- Cloud-sync scan history and favorites (requires auth)
- LLM-powered personalized advice (already wired — just needs `ANTHROPIC_API_KEY`)

### Milestone 7 — App Store Submission
- Enroll in Apple Developer Program
- Set up iOS provisioning + code signing
- Write App Store metadata, screenshots, privacy policy
