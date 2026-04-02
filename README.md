# 🌟 Nalla Pazhakam — நல்ல பழக்கம்

**Good Habits Tracker for Kids** — A Flutter PWA hosted on GitHub Pages.

Track daily habits, earn weekly stars, and level up every month!

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.27+ installed ([get it here](https://docs.flutter.dev/get-started/install))
- A GitHub account

### Run locally
```bash
# 1. Install dependencies
flutter pub get

# 2. Run on Chrome (PWA mode)
flutter run -d chrome

# 3. Or run the dev server
flutter run -d web-server --web-port 8080
```

### Build for production
```bash
# Replace 'nalla-pazhakam' with your actual GitHub repo name
flutter build web --release --web-renderer canvaskit --base-href "/nalla-pazhakam/"
```

---

## 🌐 GitHub Pages Deployment

### One-time setup (do this once)

1. **Create a GitHub repository** named `nalla-pazhakam`

2. **Push code to `main` branch:**
   ```bash
   git init
   git add .
   git commit -m "🌟 Initial commit — Nalla Pazhakam Phase 1"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/nalla-pazhakam.git
   git push -u origin main
   ```

3. **Enable GitHub Pages:**
   - Go to your repo → Settings → Pages
   - Under "Source" → select **GitHub Actions**
   - Save

4. **Update `base-href` in `.github/workflows/deploy.yml`:**
   - The workflow uses `/${{ github.event.repository.name }}/`
   - This auto-detects your repo name — no change needed!

5. **Your app will be live at:**
   ```
   https://YOUR_USERNAME.github.io/nalla-pazhakam/
   ```

### Auto-deploy
Every push to `main` triggers a build + deploy automatically. Check progress at:
`GitHub → Actions tab → 🚀 Build & Deploy to GitHub Pages`

---

## 📁 Project Structure

```
lib/
├── main.dart                   ← App entry point
├── app.dart                    ← Root widget + theme
├── core/
│   ├── theme/                  ← Colors, fonts, ThemeData
│   ├── router/                 ← go_router navigation
│   ├── constants/              ← Default habits, scoring rules
│   └── utils/                  ← Date helpers
├── features/
│   ├── home/                   ← Kids list screen
│   ├── kid_profile/            ← Setup & edit profiles
│   ├── daily_tracker/          ← Daily habit check
│   ├── weekly_report/          ← Stars & weekly summary
│   ├── monthly_report/         ← Level evaluation
│   └── settings/               ← Manage habits
└── shared/
    └── widgets/                ← Reusable components
```

---

## 🏗 Build Phases

| Phase | Status | Description |
|-------|--------|-------------|
| 1 | ✅ Done | Project setup, theme, routing, PWA, GitHub Actions |
| 2 | ⏳ Next | Database layer (Hive → IndexedDB) |
| 3 | 🔜 | Kid profiles & onboarding |
| 4 | 🔜 | Daily habit tracker |
| 5 | 🔜 | Weekly & monthly reports |
| 6 | 🔜 | Settings & polish |

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.27 |
| State Management | Riverpod 2.x |
| Navigation | go_router |
| Storage | Hive (IndexedDB on web) |
| Fonts | Nunito (Google Fonts) |
| Hosting | GitHub Pages |
| CI/CD | GitHub Actions |

---

## 📱 Install as PWA

1. Open the GitHub Pages URL in Chrome (Android) or Safari (iOS)
2. Android: tap the **⋮ menu → Add to Home Screen**
3. iOS: tap the **Share button → Add to Home Screen**

The app works fully **offline** after first load! 🎉

---

Made with ❤️ for little ones learning good habits.
