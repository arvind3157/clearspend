# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClearSpend is a privacy-first, offline iOS expense tracking app. No backend, no accounts — all data stays on-device. Built with SwiftUI + SwiftData, targeting iOS 17+, Xcode 15+, Swift 5.9+.

## Build & Run

This is a native Xcode project (no CocoaPods, SPM, or other package managers).

```bash
# Build from command line
xcodebuild -project ClearSpend.xcodeproj -scheme ClearSpend -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -project ClearSpend.xcodeproj -scheme ClearSpend -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test
xcodebuild -project ClearSpend.xcodeproj -scheme ClearSpend -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ClearSpendTests/TestClassName/testMethodName test
```

No linter or formatter is configured.

## Architecture

**Pattern:** MVVM with SwiftData persistence.

**App entry:** `ClearSpend/App/ClearSpendApp.swift` — creates the `ModelContainer` with all models and seeds default categories on first launch.

**Navigation:** Tab-based (`RootView.swift`) with 3 tabs: Dashboard, Analytics, Settings. A floating action button (FAB) on the root view triggers sheet modals for "Add Expense" and "Scan Bill". The app avoids nested navigation — secondary flows use sheets with auto-dismiss.

### Key Layers

- **Models/** — SwiftData `@Model` classes: `Expense`, `MonthLedger`, `Category`, `SubCategory`, `UserProfile`, `AppSettings`. Relationships use `@Relationship` with cascade delete rules.
- **ViewModels/** — `DashboardViewModel` (monthly aggregations), `AnalyticsViewModel` (chart calculations).
- **Services/** — Business logic singletons/utilities:
  - `AuthenticationService` — Biometric/passcode app lock (singleton, emits `isUnlocked` state)
  - `MonthLedgerManager` — CRUD for monthly expense containers
  - `CSVExportService` / `CSVImportService` — Idempotent CSV backup/restore
  - `OCRService` — Vision framework bill scanning with keyword-based category suggestion
  - `CategorySeeder` — Populates default categories on first launch
- **Views/** — SwiftUI views organized by feature: `Add/`, `Dashboard/`, `Analytics/`, `Settings/`, `Authentication/`
- **Utilities/** — `DesignSystem.swift` (centralized colors, typography, spacing, shadows, view modifiers like `cardStyle()`, `primaryButtonStyle()`)

### Data Model

Every expense belongs to a `MonthLedger` (month/year container). Expenses reference a `SubCategory`, which belongs to a `Category`. This hierarchy is: MonthLedger → Expense → SubCategory → Category.

### Threading

SwiftData `ModelContext` is always accessed on `@MainActor`. Views use `@Query` for reactive data binding.

### Design System

All UI theming goes through `DesignSystem.swift`. Primary color is Indigo (#4F46E5). Use the defined constants (`DesignSystem.Colors`, `DesignSystem.Typography`, `DesignSystem.Spacing`, `DesignSystem.CornerRadius`) and view modifiers rather than inline values.
