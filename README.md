# 🌾 किसान मंडी भाव व मौसम (Kisan Mandi Bhav & Weather App)

> **सम्पूर्ण भारत के किसानों के लिए आधुनिक व सम्पूर्ण कृषि साथी मोबाइल व वेब ऐप**  
> Live APMC Mandi Rates, Real-Time Agromet Weather Forecast, Fertilizer Calculator, Crop Disease Doctor & Sarkari Yojna Platform.

---

## ✨ प्रमुख विशेषताएं (Key Features)

### 1. 🏪 लाइव मंडी भाव (Live APMC Mandi Rates)
- **ऑल इंडिया 20+ राज्य कवरेज**: राजस्थान, मध्य प्रदेश, गुजरात, पंजाब, हरियाणा, उत्तर प्रदेश, महाराष्ट्र, कर्नाटक, बिहार, पश्चिम बंगाल, आदि।
- **3-स्टेप स्मार्ट फ़िल्टर**: 📍 राज्य -> 🏛️ जिला -> 🏪 मंडी।
- **लाइव भाव कार्ड्स**: न्यूनतम, अधिकतम, और मॉडल भाव (प्रति क्विंटल) + आवक स्थिति।
- **मंडी तुलना (Multi-Mandi Comparison)**: एक ही फसल के अलग-अलग मंडियों में भावों की तुलना।
- **WhatsApp भाव रसीद शेयरिंग**: एक क्लिक में आज के भाव की सुंदर रसीद इमेज बनाकर शेयर करें।

### 2. 🌤️ कृषि मौसम व स्प्रे सलाह (Agromet Weather Advisory)
- **लाइव तापमान, आर्द्रता व बारिश का सटीक अनुमान** (Open-Meteo API)।
- **7-दिवसीय मौसम पूर्वानुमान**।
- **दवा छिड़काव अनुकूलता मीटर (Spraying Suitability)**: हवा व बारिश के अनुसार कीटनाशक छिड़काव का सही समय।

### 3. 🔔 लोकेशन आधारित भाव नोटिफिकेशन (Location-Based Price Alerts)
- किसान की चुनी हुई मंडी/लोकेशन के अनुसार नए भाव जारी होते ही तुरंत नोटिफिकेशन।
- इन-ऐप नोटिफिकेशन सेंटर (In-App Notification Tray) व अनरीड बैज काउंटर।

### 4. 🧮 खाद कैलकुलेटर (Fertilizer Dosage Calculator)
- यूरिया, डीएपी (DAP), एमओपी (MOP), और एसएसपी (SSP) की खेत के क्षेत्रफल (बीघा/एकड़) अनुसार सही मात्रा व लागत का तुरंत सटीक हिसाब।

### 5. 🌱 खेती सलाह व फसल गाइड (Crop Advisory & Calendar)
- 24+ प्रमुख फसलों (रबी, खरीफ, जायद) की बुवाई, सिंचाई, खाद प्रबंधन व कीट रोकथाम की संपूर्ण मार्गदर्शिका।
- मृदा परीक्षण प्रयोगशालाओं (Soil Testing Labs) की संपर्क डायरेक्टरी।

### 6. 📋 सरकारी योजनाएं व पात्रता जांच (Sarkari Yojna & Eligibility)
- 50+ केंद्र व राज्य सरकार की योजनाएं (PM-Kisan, KCC, फसल बीमा, सोलर पंप आदि)।
- 1-क्लिक पात्रता जांच (Eligibility Checker Quiz) व आवश्यक दस्तावेज़ों की सूची।

### 7. 📞 किसान हेल्पलाइन (Toll-Free Farmer Support)
- किसान कॉल सेंटर (1800-180-1551) व राज्य कृषि सहायता केंद्रों पर सीधे 1-टैप कॉल।

---

## 🛠️ तकनीकी विवरण (Tech Stack)

- **Framework**: Flutter 3.x (Dart 3.x)
- **Architecture**: Provider (State Management), GoRouter (Declarative Routing)
- **Data & APIs**: 
  - `data.gov.in` (Agmarknet APMC Rates)
  - `Open-Meteo` (Agromet Weather API)
  - `Nominatim / OSM` (Reverse Geolocation)
- **Platforms**: Android (Play Store ready `.aab` / `.apk`) & Web (PWA / GitHub Pages)

---

## 🚀 इंस्टॉलेशन व रनिंग गाइड (Getting Started)

### 1. कोड क्लोन करें:
```bash
git clone https://github.com/ushamdsu-lab/kisanmandibhav.git
cd kisanmandibhav
```

### 2. डिपेंडेंसीज इंस्टॉल करें:
```bash
flutter pub get
```

### 3. ऐप चलाएं:
```bash
# वेब पर चलाएं
flutter run -d chrome

# या एंड्रॉइड फोन/एम्युलेटर पर चलाएं
flutter run
```

### 4. प्रोडक्शन बिल्ड बनाएं:
```bash
# Android App Bundle (Google Play Store के लिए)
flutter build appbundle --release

# Android APK
flutter build apk --release

# Web Build (GitHub Pages / PWA)
flutter build web --release
```

---

## 📄 लाइसेंस (License)
यह प्रोजेक्ट ओपन-सोर्स है और किसानों के कल्याण हेतु समर्पित है।
