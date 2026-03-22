# NutriScan AI — Cycle 1: Mobile MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a runnable Flutter app covering Home → Scan → Product Details → AI Analysis with mocked data.

**Architecture:** Feature-first clean structure (data/domain/presentation per feature), Riverpod for state, go_router for navigation. No real backend — mock repositories return hardcoded data.

**Tech Stack:** Flutter 3.41, Dart 3.11, flutter_riverpod ^2.6.1, go_router ^14.6.2, mobile_scanner ^6.0.2

---

## File Map

| File | Purpose |
|------|---------|
| `mobile/pubspec.yaml` | Add go_router, flutter_riverpod, mobile_scanner |
| `mobile/lib/main.dart` | Entry point, ProviderScope |
| `mobile/lib/app/app.dart` | MaterialApp.router |
| `mobile/lib/app/router.dart` | go_router config, all routes |
| `mobile/lib/app/theme/app_theme.dart` | Colors, text styles, input decoration |
| `mobile/lib/core/constants/app_constants.dart` | Strings, routes, keys |
| `mobile/lib/core/widgets/ns_loading.dart` | Shared loading indicator |
| `mobile/lib/core/widgets/ns_error.dart` | Shared error display |
| `mobile/lib/core/widgets/ns_empty.dart` | Shared empty state |
| `mobile/lib/core/widgets/legal_disclaimer.dart` | Reusable disclaimer banner |
| `mobile/lib/features/home/presentation/home_page.dart` | Home screen |
| `mobile/lib/features/scanner/domain/scanner_service.dart` | Abstract interface |
| `mobile/lib/features/scanner/data/mock_scanner_service.dart` | Mock impl |
| `mobile/lib/features/scanner/presentation/scanner_page.dart` | Scan screen |
| `mobile/lib/features/product_details/domain/product.dart` | Product model |
| `mobile/lib/features/product_details/domain/product_repository.dart` | Abstract interface |
| `mobile/lib/features/product_details/data/mock_product_repository.dart` | Mock data |
| `mobile/lib/features/product_details/presentation/product_details_page.dart` | Product screen |
| `mobile/lib/features/ai_analysis/domain/analysis_result.dart` | AnalysisResult model |
| `mobile/lib/features/ai_analysis/domain/analysis_service.dart` | Abstract interface |
| `mobile/lib/features/ai_analysis/data/mock_analysis_service.dart` | Mock impl |
| `mobile/lib/features/ai_analysis/presentation/ai_analysis_page.dart` | Analysis screen |
| `mobile/lib/app/di/providers.dart` | All Riverpod providers |
| `README.md` | Root README with run instructions |

---

### Task 1: Update pubspec.yaml + install deps
- [ ] Replace pubspec.yaml content with correct deps
- [ ] Run `flutter pub get`

### Task 2: Core — theme, constants, shared widgets
- [ ] Write app_theme.dart
- [ ] Write app_constants.dart
- [ ] Write ns_loading.dart, ns_error.dart, ns_empty.dart, legal_disclaimer.dart

### Task 3: Product model + mock repository
- [ ] Write product.dart
- [ ] Write product_repository.dart (abstract)
- [ ] Write mock_product_repository.dart (5 hardcoded products)

### Task 4: AI Analysis model + mock service
- [ ] Write analysis_result.dart
- [ ] Write analysis_service.dart (abstract)
- [ ] Write mock_analysis_service.dart

### Task 5: Scanner domain + mock
- [ ] Write scanner_service.dart (abstract)
- [ ] Write mock_scanner_service.dart

### Task 6: Riverpod providers
- [ ] Write providers.dart wiring all services

### Task 7: Router
- [ ] Write router.dart with 4 routes

### Task 8: App shell + main
- [ ] Write app.dart
- [ ] Write main.dart

### Task 9: Feature pages
- [ ] Write home_page.dart
- [ ] Write scanner_page.dart
- [ ] Write product_details_page.dart
- [ ] Write ai_analysis_page.dart

### Task 10: README + verify build
- [ ] Write root README.md
- [ ] Run `flutter analyze` in mobile/
- [ ] Run `flutter build apk --debug` to confirm no compile errors
