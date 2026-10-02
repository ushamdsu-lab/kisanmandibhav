# 🌾 Kisan AI Crop Doctor & Disease Detection Engine
## Master Architecture & Implementation Plan (100% Zero-Cost & Production-Ready)

> **Document Status**: Production Blueprint & Implementation Plan  
> **Last Updated**: October 2026  
> **Target App**: Kisan Mandi Bhav (`com.kisan.mandibhav`)  
> **Architecture Goal**: 100% Free, Scalable to 1,00,000+ daily scans, 0% Cloud Bills, 0% Permanent Storage Footprint.

---

## 📌 1. Executive Summary & Vision

The goal of this system is to provide Indian farmers with an instant, authentic, and scientific **Crop Disease Doctor & AI Mitra**. 
A farmer can either:
1. **Take a photo of a diseased leaf** from their camera or gallery, and receive an instant diagnosis with exact medicine names, dosages, and organic remedies in simple Hindi.
2. **Chat or speak via microphone** in Hindi/Hinglish to ask agricultural, mandi rate, or weather questions.

### Core Non-Negotiable Directives:
* **₹0 Lifetime Cost**: No expensive third-party subscriptions (no Pro plans or credit-card dependencies).
* **Zero Cloud Storage Cost**: Uploaded leaf photos are processed in-memory and immediately purged. Never store farmer images persistently in cloud storage.
* **Scientific & CIBRC Approved**: All chemical remedies (e.g., Mancozeb 75% WP, Propiconazole 25% EC, Imidacloprid) and spray dosages must be fetched from the verified database to prevent AI hallucinations.
* **Farmer Accessibility**:
  - Natural Hindi / Hinglish language.
  - One-tap Audio Narration (TTS) so illiterate farmers can listen to the treatment.
  - One-tap WhatsApp Prescription Share button.

---

## 🏗️ 2. High-Level System Architecture

```
                  ┌──────────────────────────────────────────────┐
                  │          Kisan Mobile App (Flutter)          │
                  │  - Camera / Gallery Leaf Photo Picker        │
                  │  - Smart Image Compression (< 200 KB)        │
                  │  - Hindi Voice (TTS) & WhatsApp Share Button │
                  └──────────────────────┬───────────────────────┘
                                         │
                         HTTPS POST /api/detect-disease
                         (Base64 / Multipart Image)
                                         │
                                         ▼
                  ┌──────────────────────────────────────────────┐
                  │      Vercel Serverless Edge API Engine       │
                  │  (https://kisanmandibhav.vercel.app/api)     │
                  │  - 1,00,000 Free Daily Requests              │
                  │  - In-Memory Processing & Instant Purge      │
                  │  - Smart 2-Hour Edge Cache                   │
                  └──────────────────────┬───────────────────────┘
                                         │
                      ┌──────────────────┴──────────────────┐
                      ▼                                     ▼
        ┌───────────────────────────┐         ┌───────────────────────────┐
        │  Deep Learning Vision AI  │         │ Verified Indian Database  │
        │  (PlantVillage / Llama)   │         │ (crop_diseases.json)      │
        │  - Identifies Crop & Leaf │         │ - 56 Indian Crops         │
        │  - Detects Disease Type   │         │ - CIBRC Chemical Dosages  │
        │  - Calculates Confidence  │         │ - Organic / Desi Remedies │
        └─────────────┬─────────────┘         └─────────────┬─────────────┘
                      │                                     │
                      └──────────────────┬──────────────────┘
                                         ▼
                  ┌──────────────────────────────────────────────┐
                  │          Unified Hindi JSON Output           │
                  │  { disease_name, crop, severity, chemical,   │
                  │    dosage, organic, precautions, audio_text }│
                  └──────────────────────────────────────────────┘
```

---

## 🌿 3. Crop & Disease Detection Logic (How It Differentiates)

The vision engine is trained on **Crop + Disease Pairs** across 38 core agricultural classes. It does not just detect diseases; it evaluates the **leaf morphology (edges, veins, shape)** to identify the crop first, then classifies the pathology.

### Sample Supported Matrix:
| Crop (फसल) | Recognizable Diseases (रोग) | Scientific Cure & Spray Dosage (दवा व मात्रा) | Organic Alternative (देसी नुस्खा) |
| :--- | :--- | :--- | :--- |
| **टमाटर (Tomato)** | Early Blight (अगेती झुलसा) | मैंकोजेब 75% WP (Mancozeb) @ 2 ग्राम / लीटर पानी | 5% नीम का तेल (Neem Oil) स्प्रे |
| **टमाटर (Tomato)** | Late Blight (पिछेती झुलसा) | मेटलैक्टिस + मैंकोजेब (Ridomil MZ) @ 2.5 ग्राम / लीटर | खट्टी छाछ और तांबे के बर्तन का पानी |
| **टमाटर (Tomato)** | Leaf Curl / Mosaic (मरोड़िया) | इमिडाक्लोप्रिड 17.8% SL (Imidacloprid) @ 1 ml / 3 लीटर | पीला स्टिकी ट्रैप + नीम अर्क |
| **आलू (Potato)** | Early & Late Blight | कॉपर ऑक्सीक्लोराइड 50% WP (Blitox) @ 3 ग्राम / लीटर | ट्राइकोडर्मा विरिडी (Trichoderma) |
| **मिर्च (Chilli)** | Anthracnose / Dieback | कार्बेन्डाजिम 50% WP (Bavistin) @ 1.5 ग्राम / लीटर | राख व नीम की खली की जड़ में धुलाई |
| **मिर्च (Chilli)** | Thrips / Churda-Murda | फिप्रोनिल 5% SC (Fipronil) @ 2 ml / लीटर | आकड़े के पत्तों का रस व गोमूत्र |
| **गेहूं (Wheat)** | Yellow/Brown Rust (रतुआ) | प्रोपिकोनाजोल 25% EC (Tilt) @ 1 मिली / लीटर पानी | राख का भुरकाव + जीवामृत |
| **सरसों (Mustard)** | White Rust & Powdery Mildew | घुलनशील सल्फर 80% WDG (Sulfur) @ 2.5 ग्राम / लीटर | खट्टी छाछ (Buttermilk) स्प्रे |
| **सरसों (Mustard)** | Aphids / Chepa (माहू) | डाइमेथोएट 30% EC (Rogor) @ 1.7 मिली / लीटर पानी | साबुन का हल्का घोल या नीम तेल |

---

## 🛠️ 4. Phased Implementation Roadmap

### 📍 Phase 1: Vercel Serverless Detection API
* **Endpoint Path**: `api/detect-disease.js`
* **Workflow**:
  1. Accepts `POST` with `image` (Base64 or multipart) and optional `crop_hint` (e.g., `'tomato'`, `'potato'`, or `'auto'`).
  2. Runs lightweight vision feature extraction & classification.
  3. Matches output with authentic Indian remedy records.
  4. Returns complete localized response in `< 1.2 seconds`.
  5. 0% storage footprint (image stream immediately discarded from RAM).

### 📍 Phase 2: Verified Remedies Database
* **File**: `assets/data/crop_diseases_master.json` & serverless counterpart.
* **Fields per disease**:
  ```json
  {
    "id": "tomato_early_blight",
    "crop_id": "tomato",
    "crop_hindi": "टमाटर",
    "disease_name_hindi": "अगेती झुलसा (Early Blight)",
    "pathogen": "Fungal (फफूंद)",
    "severity": "मध्यम",
    "symptoms": "पत्तियों पर गहरे भूरे रंग के गोल छल्ले (Target spots) बनते हैं।",
    "chemical_cure": "मैंकोजेब 75% WP (Mancozeb)",
    "dosage": "2 ग्राम प्रति लीटर पानी में मिलाकर 10-12 दिन के अंतराल पर स्प्रे करें।",
    "organic_remedy": "5% नीम का तेल या खट्टी छाछ का छिड़काव करें।",
    "precautions": "दोपहर की तेज धूप में छिड़काव न करें। शाम को 4 बजे के बाद स्प्रे करें।"
  }
  ```

### 📍 Phase 3: Flutter Mobile App Integration
* **File**: `lib/screens/crop_doctor/crop_doctor_screen.dart`
* **Features**:
  1. **Image Picker**: Camera (live snapshot) & Gallery with 1024x1024 JPEG compression.
  2. **Shimmer Scanning Animation**: Visual scan line over leaf photo while waiting for response.
  3. **Prescription Card**:
     - Visual badge indicating disease severity (शुरुआती / मध्यम / गंभीर).
     - Chemical cure card with spray dosage.
     - Organic / Desi remedy card.
  4. **Hindi Voice Audio (TTS)**: `flutter_tts` integration to speak out the prescription in clear Hindi.
  5. **WhatsApp Share**: Generates clean formatted text:
     ```text
     🌾 किसान मित्र - फसल डॉक्टर रिपोर्ट
     फसल: टमाटर | रोग: अगेती झुलसा (Early Blight)
     दवा: मैंकोजेब 75% WP (2 ग्राम/लीटर पानी)
     देसी नुस्खा: 5% नीम तेल स्प्रे
     📲 किसान मंडी भाव ऐप से जांची गई रिपोर्ट
     ```

### 📍 Phase 4: Hybrid Offline Resilience
* If farmer's mobile internet is unstable in the field:
  - App automatically engages local on-device rule engine (`CropDoctorService`) so the farmer **never gets a blank screen or connection failure**.

---

## 🔒 5. Scalability, Concurrency & Security

1. **Handling 1,000+ Concurrent Farmers**:
   - Vercel Serverless dynamically spins up isolated execution instances for each farmer request.
   - Response latency: ~300ms - 1200ms.
2. **Abuse Protection & Rate Limiting**:
   - Client-side rate limiting: 5 free scans per farmer per day (resets daily) to prevent bot scraping.
3. **Privacy**:
   - No farmer identity, GPS coordinates, or personal metadata are attached to uploaded plant photos.

---

## ✅ Ready for Execution
This plan is 100% compatible with our existing Flutter app structure, our active Vercel API, and strict Play Store release guidelines.
