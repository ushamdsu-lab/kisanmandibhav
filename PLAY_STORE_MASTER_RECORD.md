# 🌾 Kisan Mandi Bhav - Play Store Master Record & Release Guide

> **Last Updated**: 02 October 2026  
> **App Title**: किसान मंडी भाव (Kisan Mandi Bhav)  
> **Package Name (Application ID)**: `com.kisanmitra.kisan_mitra`  
> **Current Track**: Production (Rollout in Review ⏳)  
> **Current Version**: `1.0.8` (Version Code: `9`)

---

## 📌 1. Release History & Milestones

### 🚀 Release 1.0.8 (Version Code: 9) — 02 October 2026 (Live Release Bundle Ready 📦)
1. **🤖 Kisan Mitra AI Chatbot Integration ("किसान मित्र AI")**:
   - Built a high-performance offline & master-data NLP conversational AI engine (`KisanChatService`).
   - Dual-intent routing:
     - **Mandi Bhav Intent**: Queries for market rates across 39,000+ national records (e.g., "नीमच में लहसुन भाव", "इंदौर सोयाबीन") return live APMC modal price, min/max range, arrival status, and date.
     - **Crop Doctor Intent**: Queries for disease symptoms or treatments (e.g., "चने में इल्ली", "गेहूं में पीला रतुआ", "सरसों में माहू") return certified CIBRC chemical remedies, precise spray dosages per 15L pump, and organic neem oil solutions.
   - Elimination of raw markdown asterisks with structured prescription cards, Hindi TTS audio readouts, and WhatsApp sharing.
   - Ultra-modern, highlighted, high-contrast AI spotlight card with interactive prompt chips on the Dashboard and Crop Doctor screens.
2. **🌱 Expanded National Crop Catalog (26+ Crops)**:
   - Expanded the Kheti crop catalog from 6 crops to 26+ major Indian crops across Kharif, Rabi, and Zaid seasons.
   - Added complete 6-stage agronomy guides (soil, seed treatment, sowing, irrigation, fertilizer management, and harvesting).
   - Linked all crops to DAP, Urea, MOP, SSP, Zinc Sulphate, and Vermicompost recommendations.
   - Replaced cartoon carrot mascot with a clean, professional natural leaf watermark.
3. **🎯 Active AdMob Production Native Ad ID**:
   - Production App ID: `ca-app-pub-7650949194753110~4751917111`
   - Production Banner ID: `ca-app-pub-7650949194753110/5674116546`
   - Production Native Ad ID ("बीच वाला ऐड"): `ca-app-pub-7650949194753110/5522618474`
   - Active in Mandi, Weather, and Yojana lists via `InlineAdCard` with `NativeTemplateStyle.small` and automatic banner fallback.
   - `AdService.isTestMode = false` configured for live production revenue.
4. **⚡ R8 Minification & Size Reduction**:
   - Configured `ndk { debugSymbolLevel = "none" }` in `buildTypes.release` to eliminate heavy native debug tables.
   - R8 tree-shaking purged unused bytecode across Firebase, AdMob, and image libraries.
   - Bundle size reduced from **57.0 MB down to 49.6 MB** despite adding 20+ crops and AI chatbot!
   - Root Bundle: `kisan_mandi_v1.0.8_release.aab` (49.6 MB, SHA signed).

#### Play Console Ready Release Notes:
```xml
<en-US>
• 🤖 Kisan AI Mitra: Instant answers for live mandi bhav & crop diseases!
• 🌾 26+ National Crops: Complete guides for Kharif, Rabi & Zaid seasons.
• 🩺 Smart Crop Doctor: Instant pest identification & certified dosages.
• ⚡ Faster Mandi Lookup: Auto-detect nearby APMC mandis with hybrid GPS.
• 📈 Real-time Market Trends: Daily arrival status & MSP updates.
• 🚀 Faster performance & smoother UI experience.
</en-US>

<hi-IN>
• 🤖 किसान मित्र AI: मंडी भाव और फसल बीमारी का तुरंत समाधान!
• 🌾 26+ प्रमुख फसलें: खरीफ, रबी और जायद फसलों की संपूर्ण खेती गाइड।
• 🩺 फसल डॉक्टर: कीट-रोग की सटीक पहचान और दवा की सही मात्रा।
• ⚡ तेज मंडी सर्च: आपके जिले और नजदीकी मंडी के ताज़ा भाव तुरंत पाएं।
• 📈 लाइव बाजार भाव: दैनिक आवक, न्यूनतम-अधिकतम भाव व MSP की जानकारी।
• 🚀 ऐप की गति और स्थिरता में बड़े सुधार।
</hi-IN>
```

---

### 📦 Release 1.0.7 (Version Code: 8) — 02 October 2026 (Rollout Record)
1. **AdMob Integration & Native Ad Support**:
   - AdMob App ID: `ca-app-pub-7650949194753110~4751917111`
   - Banner Ad Unit: `ca-app-pub-7650949194753110/5674116546`
   - Native Ad Unit (`bich walo ads`): `ca-app-pub-7650949194753110/5522618474`
   - Integrated `NativeTemplateStyle(templateType: TemplateType.small)` in `InlineAdCard` with seamless `BannerAd` fallback.
   - `AdService.isTestMode = false` configured for live production revenue.
2. **Cell-Tower + GPS Hybrid Location Detection**:
   - Solved indoor / weak satellite GPS hangs by implementing instant 3-step hybrid detection:
     - Step 1: `Geolocator.getLastKnownPosition()` (Cell tower cache, 10-50ms instant)
     - Step 2: `AndroidSettings(accuracy: LocationAccuracy.medium, forceLocationManager: false)` (Fused Location Provider via cell towers + Wi-Fi, 3s limit)
     - Step 3: High-accuracy satellite GPS refinement (4s limit)
   - Enhanced district matching by cross-referencing BigDataCloud reverse-geocoding against `MandiDirectory`'s 260+ popular agricultural cities.
3. **Comprehensive UI Overflow & Responsiveness Audit**:
   - **Fertilizer Calculator**: Fixed 38px overflow in area unit dropdown by adjusting flex ratio to 6:5, `isExpanded: true`, and `FittedBox`.
   - **Mandi Rates Card**: Constrained arrival status with `Expanded` + `ellipsis` to prevent Govt MSP badge overflow.
   - **Govt Data Modals**: Wrapped MSP, Fertilizer, Soil Testing, and Helpline headers in `Expanded` and converted filter chips to horizontal scroll.
   - **Dashboard**: Adjusted grid aspect ratios and tile padding to prevent 2-line Hindi text overflow.
   - **Dairy Tracker & Farm Khata**: Wrapped 6-7 digit currency totals and profit/loss metrics in `FittedBox(fit: BoxFit.scaleDown)`.
   - **Weather Screen**: Wrapped audio bulletin button in `Flexible FittedBox` and clamped temperature bar range bounds.
4. **Firebase Integration Verified**:
   - `google-services.json` (Project: `kisan-mandi-bhav-10973`, App ID: `1:787097310112:android:832cbc9b437af468640ac5`) verified.
   - Gradle plugins (`com.google.gms.google-services` v4.4.4 & `com.google.firebase.crashlytics` v3.0.7) verified.
   - `FirebaseCrashlytics.instance.recordFlutterFatalError` & `FirebaseAnalytics` active in `main.dart`.
5. **NDK & Build Fix**:
   - Set explicit `ndkVersion = "28.2.13676358"` in `android/app/build.gradle.kts`.
   - Generated signed release bundle: `kisan_mandi_v1.0.7_release.aab` (57.0 MB).

---

### 📦 Release 1.0.6 (Version Code: 7) — 20 September 2026
1. **Production Keystore Generation**:
   - Generated release keystore (`kisan_release_key.jks`) using Java 21 OpenJDK `keytool`.
   - Configured `android/key.properties` and updated `android/app/build.gradle.kts` with `signingConfigs.create("release")`.
2. **Google Play Policy & Permission Compliance**:
   - Removed deprecated broad media permissions (`READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`) from `AndroidManifest.xml`.
   - Allowed the app to seamlessly use Android Photo Picker via `image_picker` without triggering Google Play's photo/video declaration roadblocks.
3. **Release Build & Upload**:
   - Rebuilt signed Android App Bundle (`AAB`) with `versionCode 7` (`1.0.6`).
   - Successfully uploaded to Google Play Console Production Track (`kisan_mandi_bhav_v1.0.6_build7.aab`).
4. **Legal & Compliance Infrastructure**:
   - Created dedicated GitHub repo: [`ushamdsu-lab/kisan-mitra-privacy`](https://github.com/ushamdsu-lab/kisan-mitra-privacy).
   - Hosted live privacy policy, data deletion, terms, and contact pages on GitHub Pages.
5. **Play Store Listing Assets**:
   - Generated high-resolution 512x512 App Icon, 1024x500 Feature Graphic, and 5 Framed Screenshots (1080x1920).

---

## 🔑 2. Keystore & Signing Configuration

> [!CAUTION]
> **Never delete or lose `kisan_release_key.jks` or `key.properties`!**  
> Google Play will permanently reject future updates if signed with a different key.

| Property | Value |
| :--- | :--- |
| **Keystore File** | `android/app/kisan_release_key.jks` |
| **Key Properties** | `android/key.properties` |
| **Key Alias** | `kisan_mandi_key` |
| **Keystore Password** | `KisanMandi@2026` |
| **Key Password** | `KisanMandi@2026` |
| **Key Algorithm** | RSA 2048-bit |
| **Signature Algorithm** | SHA384withRSA |
| **Validity** | 10,000 days (Expires: 05 Feb 2054) |
| **Developer / Org** | `CN=Kisan Mandi Bhav, OU=Mobile, O=Eduplus, L=Jaipur, ST=Rajasthan, C=IN` |

---

## 🌐 3. Live Legal & Policy URLs

Hosted on GitHub Pages (`ushamdsu-lab/kisan-mitra-privacy`):

| Page | Live URL |
| :--- | :--- |
| **Privacy Policy** | [https://ushamdsu-lab.github.io/kisan-mitra-privacy/privacy.html](https://ushamdsu-lab.github.io/kisan-mitra-privacy/privacy.html) |
| **Data Deletion Policy** | [https://ushamdsu-lab.github.io/kisan-mitra-privacy/data-deletion.html](https://ushamdsu-lab.github.io/kisan-mitra-privacy/data-deletion.html) |
| **Terms & Conditions** | [https://ushamdsu-lab.github.io/kisan-mitra-privacy/terms.html](https://ushamdsu-lab.github.io/kisan-mitra-privacy/terms.html) |
| **Contact Support** | [https://ushamdsu-lab.github.io/kisan-mitra-privacy/contact.html](https://ushamdsu-lab.github.io/kisan-mitra-privacy/contact.html) |
| **Developer Email** | `edupluscreation@gmail.com` |

---

## 📋 4. Google Play Console Questionnaire Record

| Section | Answer / Selected Option |
| :--- | :--- |
| **Category** | Weather / Productivity |
| **Support Email** | `edupluscreation@gmail.com` |
| **Content Rating (IARC)** | Everyone (3+) |
| **Target Age Group** | 18 and over (General audience) |
| **Government Apps** | No |
| **Financial Features** | "My app doesn't provide any financial features" |
| **Advertising ID** | Yes (Google AdMob SDK used) |
| **Data Collection** | No personal data collected (No user accounts, no login) |

---

## 📁 5. Releases & Assets Directory Structure

A dedicated `releases/` directory has been created to archive every release bundle, mapping file, and store asset:

```text
d:\mandi weather updates\
├── releases\
│   ├── store_graphics\
│   │   ├── play_store_icon_512.png                 # 512x512 Store Icon
│   │   ├── play_store_feature_graphic_1024x500.png  # 1024x500 Feature Graphic
│   │   └── screenshots\
│   │       ├── 01-mandi-bhav.png                   # 1080x1920 Mandi Rates
│   │       ├── 02-weather-radar.png                # 1080x1920 Weather Forecast
│   │       ├── 03-ai-crop-doctor.png               # 1080x1920 Crop Doctor
│   │       ├── 04-govt-schemes.png                 # 1080x1920 Govt Schemes
│   │       └── 05-farm-khata.png                   # 1080x1920 Khata Book
│   │
│   └── v1.0.6_build7\                              # Uploaded 20-Sep-2026 (In Review)
│       ├── kisan_mandi_bhav_v1.0.6_build7.aab      # Signed AAB Bundle
│       ├── mapping.txt                             # R8 Crash Deobfuscation File
│       └── RELEASE_NOTES.md                        # Release log & change details
│
├── android\
│   ├── app\
│   │   └── kisan_release_key.jks                   # PRODUCTION KEYSTORE (DO NOT DELETE)
│   └── key.properties                              # Keystore credentials
```

---

## 🚀 6. How to Build Next Future Versions (v1.0.7 / Build 8, etc.)

Jab bhi aap naya update nikalna chahein, bas yeh simple steps follow karein:

### Step 1: Version Number Badhayein
1. **`pubspec.yaml`** kholein aur version badhayein:
   ```yaml
   version: 1.0.7+8
   ```
   *(Pehle `1.0.6+7` tha, agle ke liye `1.0.7+8` karein).*
2. **`android/local.properties`** kholein aur sync karein:
   ```properties
   flutter.versionName=1.0.7
   flutter.versionCode=8
   ```

### Step 2: Release AAB Build Karein
Terminal (PowerShell) mein yeh command chalayein:
```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
cd "D:\mandi weather updates\android"
.\gradlew.bat :app:bundleRelease
```

### Step 3: Naye Release Folder Mein Archive Karein
1. Naya folder banayein: `releases\v1.0.7_build8\`
2. Build file copy karein:
   ```powershell
   Copy-Item "D:\mandi weather updates\build\app\outputs\bundle\release\app-release.aab" -Destination "D:\mandi weather updates\releases\v1.0.7_build8\kisan_mandi_bhav_v1.0.7_build8.aab"
   Copy-Item "D:\mandi weather updates\build\app\outputs\mapping\release\mapping.txt" -Destination "D:\mandi weather updates\releases\v1.0.7_build8\mapping.txt"
   ```
3. `kisan_mandi_bhav_v1.0.7_build8.aab` ko Google Play Console par upload karein!
