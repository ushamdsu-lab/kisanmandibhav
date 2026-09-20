# 🔍 Kisan Mandi Bhav - Deep Technical & Policy Analysis

## 1. App Identity & Fundamentals
- **Official App Name (Android Manifest):** `किसान मंडी भाव` (English: *Kisan Mandi Bhav*)
- **Application ID / Package Name:** `com.kisanmitra.kisan_mitra`
- **Framework & SDK:** Flutter 3.x / Dart (Native Android Engine)
- **Target Audience:** Indian Farmers, Traders, Agriculture Professionals (Age: Everyone / 3+)
- **Monetization & Access Model:** **100% Free & Open Access**
  - No User Account creation
  - No Sign-up / Login required
  - No Passwords or Credentials collected
  - No In-App Purchases, Subscriptions, or Paywalls
  - Supported strictly by standard Google AdMob non-intrusive Banner Ads

---

## 2. Permissions Breakdown (AndroidManifest.xml)

| Android Permission | Actual Function in Code | Google Play Disclosure Requirement |
|---|---|---|
| `INTERNET` | Fetching daily mandi rates, weather forecast, satellite radar, govt schemes | Standard internet access |
| `ACCESS_FINE_LOCATION` & `ACCESS_COARSE_LOCATION` | Detects user's district to automatically highlight nearest APMC mandi and localized weather. | Ephemeral (real-time only, never logged or tracked historically). |
| `CAMERA` | Taking photo of infected crop leaf in AI Crop Doctor. | User-initiated only; no background camera access. |
| `READ_EXTERNAL_STORAGE` & `READ_MEDIA_IMAGES` | Selecting crop leaf image from device photo gallery. | User-initiated only; photos are analyzed locally and not shared. |
| `QUERY_ALL_PACKAGES` / `TTS_SERVICE` | Used for Hindi Audio Voice Bulletin (सुनें भाव) and WhatsApp report sharing. | Declared under `<queries>` intent filter. |

---

## 3. Services & External Data Endpoints Audit

1. **Mandi Commodity Rates:**
   - Source: Open Government Data Platform (`api.data.gov.in`), Agmarknet, and CDN fallback (`cdn.jsdelivr.net`).
   - Purpose: Daily modal prices, min/max rates, arrivals.
2. **Weather & Meteorological Data:**
   - Source: Open-Meteo Weather & Air Quality API.
   - Purpose: 7-day temperature, rainfall probability, wind speed, satellite radar.
3. **Advertising (AdMob):**
   - App ID: `ca-app-pub-7650949194753110~4751917111`
   - Banner Ad Unit: `ca-app-pub-7650949194753110/5674116546`
   - Interstitial Ads: Explicitly disabled.
4. **AI Crop Doctor & Treatments:**
   - 110 Indian crop diseases database compiled locally in-app.
   - Treatments follow CIBRC (Central Insecticide Board & Registration Committee) and ICAR guidelines.
5. **Farm Khata & Dairy Tracker:**
   - 100% On-Device storage using `shared_preferences`.
   - Never transmitted to external cloud servers.

---

## 4. Google Play Console: Data Safety (डेटा सुरक्षा) Declaration

| Data Safety Field | Value to Select | Exact Explanation |
|---|---|---|
| **Data Collection & Sharing** | **Yes** | Required due to AdMob SDK and Location |
| **Data Encrypted in Transit** | **Yes** | All network requests use HTTPS / TLS 1.3 |
| **Data Deletion URL** | **Yes** | `https://ushamdsu-lab.github.io/kisan-mitra-privacy/data-deletion.html` |
| **Location (Approximate & Precise)** | **Collected: Yes, Shared: No** | Used for local mandi rates & weather forecast (App Functionality) |
| **Photos & Videos** | **Collected: Yes (User-initiated)** | For plant leaf disease scan in AI Crop Doctor (App Functionality) |
| **Device or other IDs** | **Collected: Yes, Shared: Yes** | Handled by Google Mobile Ads SDK for Ad delivery & fraud prevention |
| **Financial / Khata Data** | **Not Collected** | Stored locally on device, never sent to external servers |

---

## 5. Live Production Links (GitHub Pages)

- **Official Privacy Policy:**  
  `https://ushamdsu-lab.github.io/kisan-mitra-privacy/privacy.html`
- **Data Deletion Instructions:**  
  `https://ushamdsu-lab.github.io/kisan-mitra-privacy/data-deletion.html`
- **Terms & Agricultural Disclaimer:**  
  `https://ushamdsu-lab.github.io/kisan-mitra-privacy/terms.html`
- **Support & Developer Contact:**  
  `https://ushamdsu-lab.github.io/kisan-mitra-privacy/contact.html`
- **Official Support Email:** `edupluscreation@gmail.com`
