# 🌾 Kisan Mandi Bhav - Play Store Master Record & Release Guide

> **Document Created**: 20 September 2026  
> **App Title**: किसान मंडी भाव (Kisan Mandi Bhav)  
> **Package Name (Application ID)**: `com.kisanmitra.kisan_mitra`  
> **Current Track**: Production (In Review ⏳)  
> **Current Version**: `1.0.6` (Version Code: `7`)

---

## 📌 1. Summary of Work Done Today (20 Sept 2026)

1. **Production Keystore Generation**:
   - Generated release keystore (`kisan_release_key.jks`) using Java 21 OpenJDK `keytool`.
   - Configured `android/key.properties` and updated `android/app/build.gradle.kts` with `signingConfigs.create("release")`.
2. **Google Play Policy & Permission Compliance**:
   - Removed deprecated broad media permissions (`READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`) from `AndroidManifest.xml`.
   - Allowed the app to seamlessly use Android Photo Picker via `image_picker` without triggering Google Play's photo/video declaration roadblocks.
3. **Release Build & Upload**:
   - Rebuilt signed Android App Bundle (`AAB`) with `versionCode 7` (`1.0.6`).
   - Successfully uploaded to Google Play Console Production Track (`kisan_mandi_bhav_v1.0.6_build7.aab`).
   - Status: **In Review** by Google Play Review Team.
4. **Legal & Compliance Infrastructure**:
   - Created dedicated GitHub repo: [`ushamdsu-lab/kisan-mitra-privacy`](https://github.com/ushamdsu-lab/kisan-mitra-privacy).
   - Hosted live privacy policy, data deletion, terms, and contact pages on GitHub Pages.
   - Cleaned all confusing mentions of "passwords" or "accounts". The app is officially declared as **100% Free & Open Access (No login, no sign-up, no accounts)**.
5. **Play Store Listing Assets**:
   - Generated high-resolution 512x512 App Icon.
   - Designed 1024x500 Feature Graphic (Agriculture field background + UI showcase).
   - Created 5 Framed Screenshots (1080x1920) capturing real app UI.

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
