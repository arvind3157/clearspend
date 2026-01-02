# ClearSpend 💸

ClearSpend is a **privacy-first, offline expense tracking app** for iOS that helps you understand exactly where your money goes — month by month, category by category.

No accounts. No backend. No tracking.  
Your data stays **on your device**.

---

## ✨ Features

### 📊 Expense Tracking
- Add expenses manually
- Categorize spends using **categories & subcategories**
- Track expenses **month-wise** using ledgers

### 📈 Analytics & Insights
- Monthly spending overview
- Category-wise breakdown
- Interactive pie charts for quick insights
- Drill down into categories for granular analysis

### ➕ Fast Add Experience
- Floating **FAB (+)** button for quick actions
- Add Expense
- Scan Bill (OCR-based foundation, offline-friendly)

### 🔐 Privacy & Security
- Fully **offline-first**
- No login / signup
- Optional **App Lock**
  - Face ID / Touch ID
  - Device passcode fallback

### 💾 Backup & Portability
- Export expenses as **CSV**
- Import CSV backups (idempotent, no duplicates)
- Designed for future iCloud sync

---

## 🧠 Design Philosophy

- **Offline-first**: Works without internet
- **Privacy-first**: No backend, no analytics, no tracking
- **Fast UX**: Minimal taps, no unnecessary screens
- **Explicit ownership**: Every expense belongs to a monthly ledger

---

## 🏗️ Architecture

- **SwiftUI** for UI
- **SwiftData** for persistence
- **MVVM** for state management
- Modular services for:
  - CSV Import / Export
  - Authentication (App Lock)
  - OCR (Bill Scanning – extensible)

---

## 📁 Project Structure (High-Level)

ClearSpend/
├── App/
│   └── ClearSpendApp.swift
├── Models/
│   ├── Expense.swift
│   ├── Category.swift
│   ├── SubCategory.swift
│   └── MonthLedger.swift
├── Views/
│   ├── Dashboard/
│   ├── Analytics/
│   ├── AddExpense/
│   └── Settings/
├── ViewModels/
├── Services/
│   ├── CSVImportService.swift
│   ├── CSVExportService.swift
│   ├── AuthenticationService.swift
│   └── OCRService.swift
├── DesignSystem/
└── Utilities/

---

## 🧾 CSV Import / Export

### Export
- Expenses → `clearspend_expenses.csv`
- Uses native iOS share sheet (Files, AirDrop, Mail, etc.)

### Import
- Idempotent import (no duplicate records)
- Automatically assigns expenses to correct **MonthLedger**
- Safe to re-import the same file multiple times

---

## 🔒 App Lock

ClearSpend supports optional app locking:
- Enable / disable from **Settings**
- Uses Face ID / Touch ID when available
- Falls back to device passcode

No user profile or cloud account required.

---

## 🚀 Roadmap (Planned)

- iCloud backup & sync
- Export All (ZIP)
- Import preview & replace/merge options
- Smart insights (trends, anomalies)
- Budgeting & alerts
- Improved OCR accuracy for bills

---

## 🛠️ Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+ (Swift 6–ready)

---

## 🧑‍💻 Development Notes

- SwiftData `ModelContext` is always accessed on `MainActor`
- Import/export is designed to be **future CloudKit-compatible**
- UI avoids nested navigation for faster flows
- Category & Subcategory selection uses a single-sheet, auto-dismiss UX

---

## 🤝 Contributing

This is an early-stage project.  
Ideas, UX suggestions, and architectural feedback are welcome.

---

## 📄 License

Personal project – license to be defined.

---

**ClearSpend**  
*See your spending clearly.*