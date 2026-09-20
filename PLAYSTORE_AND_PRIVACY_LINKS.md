# 🌾 Kisan Mandi Bhav - Google Play Store & Legal Links

Official documentation and links for Google Play Console submission and user compliance.

---

## 🌐 1. Live Legal & Policy URLs (Hosted on GitHub Pages)

All legal pages are deployed and live on GitHub Pages with HTTPS:

| Document / Page | Google Play Console Field | Live URL |
|---|---|---|
| **Privacy Policy** | Store listing &gt; Privacy Policy | **https://ushamdsu-lab.github.io/kisan-mitra-privacy/privacy.html** |
| **Data Deletion Instructions** | App content &gt; Data safety &gt; Deletion URL | **https://ushamdsu-lab.github.io/kisan-mitra-privacy/data-deletion.html** |
| **Terms of Service** | Legal / Disclaimer | **https://ushamdsu-lab.github.io/kisan-mitra-privacy/terms.html** |
| **Support & Contact Us** | Store listing &gt; Contact details | **https://ushamdsu-lab.github.io/kisan-mitra-privacy/contact.html** |

---

## 📬 2. Developer & Contact Information

- **Official Support Email:** `edupluscreation@gmail.com`
- **Developer Name:** AgriTech India / Kisan Mitra Team
- **Application ID / Package:** `com.kisanmitra.kisan_mitra`
- **GitHub Policy Repository:** [https://github.com/ushamdsu-lab/kisan-mitra-privacy](https://github.com/ushamdsu-lab/kisan-mitra-privacy)
- **Main App Repository:** [https://github.com/ushamdsu-lab/kisanmandibhav](https://github.com/ushamdsu-lab/kisanmandibhav)

---

## 📋 3. Google Play Console: Data Safety (डेटा सुरक्षा) Answers

Use these exact answers when filling out the **Data Safety** questionnaire in Play Console:

| Section / Question | Response | Reason / Details |
|---|---|---|
| **Does your app collect or share user data?** | **Yes** | Required for AdMob ads and Weather location |
| **Is all data encrypted in transit?** | **Yes** | All network requests use HTTPS / TLS |
| **Do you provide a way for users to request data deletion?** | **Yes** | URL: `https://ushamdsu-lab.github.io/kisan-mitra-privacy/data-deletion.html` |
| **Location (Approximate & Precise)** | **Collected: Yes, Shared: No** | Used for local 7-day weather forecast, radar, and nearby Mandis. Ephemeral (not stored on server). |
| **Photos and Videos (Camera)** | **Collected: Yes (User-initiated)** | Used solely when user scans crop leaves in AI Crop Doctor. |
| **Device or other IDs** | **Collected: Yes, Shared: Yes** | Collected by Google Mobile Ads SDK (AdMob) for banner ads and fraud prevention. |
| **Financial Info (Farm Khata)** | **Not Collected** | Farm income/expense entries are stored strictly on-device (local SQLite/Preferences), never sent to server. |

---

## 🎨 4. Local Play Store Assets (Ready to Upload)

All assets were generated from the real Flutter application UI and verified against Google Play specifications:

- **All-in-One Download ZIP:**  
  `D:\mandi weather updates\out\Kisan_Mandi_Bhav_PlayStore_Assets.zip`
- **Feature Graphic (1024 × 500 PX, No Alpha):**  
  `D:\mandi weather updates\out\play_store_feature_graphic_1024x500.png`
- **High-Res App Icon (512 × 512 PX):**  
  `D:\mandi weather updates\out\play_store_icon_512.png`
- **Framed Phone Screenshots (1080 × 1920 PX):**
  1. `D:\mandi weather updates\out\screenshots\pixel-10-pro\en-US\01-mandi-bhav.png` (Live Mandi Rates)
  2. `D:\mandi weather updates\out\screenshots\pixel-10-pro\en-US\02-weather-radar.png` (Weather & Doppler Radar)
  3. `D:\mandi weather updates\out\screenshots\pixel-10-pro\en-US\03-ai-crop-doctor.png` (AI Crop Doctor)
  4. `D:\mandi weather updates\out\screenshots\pixel-10-pro\en-US\04-govt-schemes.png` (PM Kisan & Govt Schemes)
  5. `D:\mandi weather updates\out\screenshots\pixel-10-pro\en-US\05-farm-khata.png` (Farm Khata & Dairy Tracker)

---

## 📱 5. Play Store Listing Copy (Metadata)

### App Title (30 characters max):
```text
Kisan Mandi Bhav & Weather
```
*(या हिंदी: किसान मंडी भाव व मौसम)*

### Short Description (80 characters max):
```text
ताजा मंडी भाव, 7-दिवसीय सटीक मौसम पूर्वानुमान, AI फसल डॉक्टर व सरकारी योजनाएं।
```
*(English option: Live daily Mandi rates, 7-day weather radar, AI crop doctor & farm ledger.)*

### Category:
- **Category:** Weather / Agriculture / Productivity
- **Content Rating:** Everyone (3+)
