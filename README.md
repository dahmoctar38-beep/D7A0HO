# NutriScan AI

Barcode food scanner with AI nutrition analysis.

**Flow:** Home → Scan barcode → Product details → AI score + diabetic risk + recommendations

## Architecture

```
Mobile (Flutter)
    └── Mock mode (no backend, default)
    └── Real mode (--dart-define=USE_REAL_API=true)
            └── Gateway :8000
                    ├── Product Catalog :8001  (Open Food Facts + seed fallback)
                    └── AI Nutrition    :8002  (rule-based + optional Claude LLM)
```

---

## Quick Start — Mobile (no backend needed)

```bash
cd mobile
flutter pub get
flutter run
```

App starts with mock data. Scan any barcode — it cycles through 5 seeded products.

---

## Quick Start — Full Stack

### 1. Prerequisites
- Flutter 3.x
- Python 3.12 (not 3.14 — pydantic-core limitation)
- Docker + Docker Compose

### 2. Backend

```bash
# Copy env example
cp infra/env/.env.example .env

# Start all 3 services (gateway, product-catalog, ai-nutrition)
docker-compose up --build

# Verify
curl http://localhost:8000/v1/products/5449000000996
curl http://localhost:8000/v1/analysis/5449000000996
```

Optional: set `ANTHROPIC_API_KEY=sk-...` in `.env` to enable Claude-powered summaries.

### 3. Mobile with real backend

```bash
cd mobile
# Android emulator (default — uses 10.0.2.2)
flutter run --dart-define=USE_REAL_API=true

# Real device or custom host
flutter run --dart-define=USE_REAL_API=true --dart-define=API_BASE_URL=http://192.168.x.x:8000
```

### 4. Build APK

```bash
cd mobile
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Backend Tests

```bash
# Set up Python venvs (one-time)
cd services/product-catalog && /opt/homebrew/bin/python3.12 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt
cd services/ai-nutrition    && /opt/homebrew/bin/python3.12 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt

# Run tests
cd services/product-catalog && .venv/bin/python -m pytest tests/ -v  # 5 tests
cd services/ai-nutrition    && .venv/bin/python -m pytest tests/ -v  # 15 tests
```

---

## Mock Barcodes

| Barcode | Product | Nutriscore |
|---------|---------|------------|
| 6281006530015 | Almarai Full Fat Milk | B |
| 6281034000011 | Chips Oman Classic | D |
| 5449000000996 | Coca-Cola Original | E |
| 6221012850014 | Quaker Oats | A |
| 8712100325977 | Snickers Bar | E |

---

## Stack

| Layer | Technology |
|-------|------------|
| Mobile | Flutter 3.x, Dart, flutter_riverpod, go_router, mobile_scanner, dio |
| Backend | Python 3.12, FastAPI, Pydantic v2, httpx |
| AI | Rule-based scoring + optional Claude API (lazy import) |
| Infra | Docker Compose, python:3.12-slim images |
| Tests | pytest, pytest-asyncio, respx 0.22+ |
| CI | GitHub Actions (mobile-ci.yml, backend-ci.yml) |

---

## Legal

This app is not a substitute for a doctor or nutritionist.
Nutrition data sourced from Open Food Facts (openfoodfacts.org).
Always consult a healthcare professional before making dietary decisions.
