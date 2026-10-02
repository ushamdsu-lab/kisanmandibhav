# Project Notes - Kisan Mandi Bhav

## GitHub Account & Repos
- **GitHub User:** `ushamdsu-lab` (jeet2444 / dynamitegehlot@gmail.com)
- **GitHub Token:** Saved locally at `C:\Users\msi\.gemini\antigravity-ide\github_token.txt` (NEVER commit to repo)
- **Firebase Login Email:** `ushamdsu@gmail.com`
- **Main App Repo:** `ushamdsu-lab/kisanmandibhav` → GitHub Pages from `docs/` folder
- **Privacy Pages Repo:** `ushamdsu-lab/kisan-mitra-privacy` → serves at `ushamdsu-lab.github.io/kisan-mitra-privacy/`
- **Root GitHub Pages Repo:** `ushamdsu-lab/ushamdsu-lab.github.io` → serves at `ushamdsu-lab.github.io/`

## App Details
- **App Name:** Kisan Mandi Bhav & Weather
- **Package Name:** `com.kisanmitra.kisan_mitra`
- **Support Email:** edupluscreation@gmail.com

## AdMob / Ads
- **AdMob Publisher ID:** `pub-7650949194753110`
- **app-ads.txt** hosted at `ushamdsu-lab.github.io/app-ads.txt` (in the `ushamdsu-lab.github.io` repo)
- **app-ads.txt content:** `google.com, pub-7650949194753110, DIRECT, f08c47fec0942fa0`
- **AdMob verification:** ✅ Verified (2 Oct 2026)
- **Current Ad Units:**
  - `mandibanner` — Banner ad (active, showing on Mandi screen)
- **Future Ad Ideas (not yet implemented):**
  - Interstitial ads — fullscreen ads on screen transitions (HIGH revenue)
  - Native ads — blend into feed naturally (MEDIUM revenue)
  - Rewarded ads — user watches video for reward (HIGHEST revenue)

## Firebase
- **Firebase Project:** Kisan Mandi Bhav
- **Firebase Project ID:** `kisan-mandi-bhav-10973`
- **Firebase Console:** https://console.firebase.google.com/project/kisan-mandi-bhav-10973
- **Android App ID:** `1:787097310112:android:832cbc9b437af468640ac5`
- **Firebase Plan:** Spark (FREE forever for our usage)
- **Services Enabled:**
  - ✅ Firebase Core — initialized in `lib/main.dart`
  - ✅ Firebase Analytics — user tracking & behavior analytics
  - ✅ Firebase Crashlytics — automatic crash reporting
  - ❌ AdMob Linking — NOT yet linked (do from Firebase Console → Monetize)
  - ❌ Push Notifications (FCM) — NOT yet added
  - ❌ Remote Config — NOT yet added
- **Config Files:**
  - `android/app/google-services.json` — Firebase Android config
  - `lib/firebase_options.dart` — FlutterFire generated config
  - `firebase.json` — Firebase project config

## Key URLs
- **Privacy Policy:** https://ushamdsu-lab.github.io/kisan-mitra-privacy/privacy.html
- **Data Deletion:** https://ushamdsu-lab.github.io/kisan-mitra-privacy/data-deletion.html
- **Terms of Service:** https://ushamdsu-lab.github.io/kisan-mitra-privacy/terms.html
- **Contact/Support:** https://ushamdsu-lab.github.io/kisan-mitra-privacy/contact.html

## CLI Tools Installed
- **Firebase CLI:** v15.32.1 (via npm)
- **FlutterFire CLI:** v1.4.1 (via dart pub global, path: `C:\Users\msi\AppData\Local\Pub\Cache\bin`)

## Change Log
### 2 Oct 2026
1. **app-ads.txt fix** — AdMob was checking `ushamdsu-lab.github.io/app-ads.txt` (root) but file was in `kisan-mitra-privacy` repo (sub-path). Created new repo `ushamdsu-lab.github.io` with app-ads.txt at root. AdMob verified ✅
2. **Firebase setup** — Created Firebase project `kisan-mandi-bhav-10973`, registered Android app, added `firebase_core`, `firebase_analytics`, `firebase_crashlytics` packages, initialized in `main.dart`
3. **Project notes** — Created this file for future reference

## Pending / TODO
- [ ] Link AdMob with Firebase (from Firebase Console → Monetize your app)
- [ ] Add Interstitial ads for higher revenue
- [ ] Add Push Notifications (FCM) for user engagement
- [ ] Add Remote Config for dynamic app settings
- [ ] Build new APK/AAB and push to Play Store with Firebase integrated
- [ ] Wait 24hrs for Analytics data to appear in Firebase Console
