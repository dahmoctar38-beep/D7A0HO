# NutriScan AI — Project Rules

## Stack
- **Mobile**: Flutter 3.x / Dart, flutter_riverpod, go_router, mobile_scanner, dio
- **Backend**: Python 3.12, FastAPI, httpx, Pydantic v2
- **Infra**: Docker Compose (3 services: gateway:8000, product-catalog:8001, ai-nutrition:8002)

## File Map

```
mobile/lib/
  main.dart                             → entry point, ProviderScope
  app/
    app.dart                            → MaterialApp.router
    router.dart                         → StatefulShellRoute, all routes
    di/providers.dart                   → ALL Riverpod providers (mock vs HTTP via USE_REAL_API)
    shell/main_shell.dart               → bottom NavigationBar (4 tabs)
    theme/app_theme.dart                → colors, typography
  core/
    config/app_config.dart              → apiBaseUrl (platform-aware)
    network/api_client.dart             → Dio factory
    constants/app_constants.dart        → AppRoutes, AppStrings
    widgets/                            → ns_loading, ns_error, ns_empty, legal_disclaimer
  features/
    scanner/                            → real MobileScanner, flash toggle
    product_details/                    → Product model, mock+HTTP repos
    ai_analysis/                        → AnalysisResult model, mock+HTTP services, scoring
    auth/                               → AppUser, MockAuthService, LoginPage
    profile/                            → UserPreferences, PreferencesService, ProfilePage
    history/                            → ScanRecord, HistoryService (max 50), HistoryPage
    favorites/                          → FavoritesService (toggle), FavoritesPage
    home/                               → HomePage (tab)

services/
  gateway/            → FastAPI proxy on :8000, routes /v1/products/{b} and /v1/analysis/{b}
  product-catalog/    → FastAPI on :8001, OFF API + seed fallback
  ai-nutrition/       → FastAPI on :8002, rule-based scoring, optional Claude LLM

shared/schemas/       → Reference Pydantic models (not imported by services)
infra/env/.env.example
```

## Run Commands

```bash
# Flutter (mock data, no backend needed)
cd mobile && flutter run

# Flutter with real backend
cd mobile && flutter run --dart-define=USE_REAL_API=true

# Backend
docker-compose up --build

# Backend tests
cd services/product-catalog && .venv/bin/python -m pytest tests/ -v
cd services/ai-nutrition    && .venv/bin/python -m pytest tests/ -v

# Python venv setup (requires Python 3.12, NOT 3.14)
/opt/homebrew/bin/python3.12 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt
```

## Key Rules
- Mock is default (USE_REAL_API=false). App runs without backend.
- Python venv must use python3.12 — pydantic-core doesn't support Python 3.14 yet.
- respx must be >=0.22.0 — 0.21.x is incompatible with httpx 0.28.x.
- Scoring: saturated_fat >5 → -15 pts, >10 → -20 pts. Empty calorie penalty: sugar>5 + protein==0 + fiber==0 → -20.
- Backend healthchecks use Python urllib (no curl in slim image).
