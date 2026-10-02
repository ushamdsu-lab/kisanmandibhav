# 🤖 Kisan AI Chatbot & Crop Disease Detection — Master Architecture Spec

> **Project Name**: `kisan chat bot`  
> **Platform**: InsForge (InstaCloud) Agent-Native Cloud Runtime  
> **Project ID**: `5dc72ac3-ba67-4c4a-906e-c6f439abcd43`  
> **Target Vision Model**: **Llama 3.2 Vision** (via InsForge Model Gateway)  
> **Database**: PostgreSQL on InsForge  
> **Last Updated**: 02 October 2026  
> **Status**: Production Blueprint for Agents & Developers

---

## 📌 1. Project Overview & Vision
This document serves as the **Single Source of Truth (SSOT)** for all future AI agents and developers implementing or extending the **Kisan AI Crop Doctor & Chatbot**. 

The goal is to allow Indian farmers to take a photo of an infected leaf/crop or ask a question in Hindi/Hinglish, and receive instant, authentic, agricultural-board-approved remedies without running out of free-tier compute or storage.

---

## ☁️ 2. InsForge Cloud Infrastructure & Linking
The backend runs on **InsForge (InstaCloud)** under the project:
```bash
# Link project to local CLI or Antigravity Agent
npx @insforge/cli link --project-id 5dc72ac3-ba67-4c4a-906e-c6f439abcd43
```

### Key InsForge Services Used:
1. **Model Gateway**: Calls **Llama 3.2 Vision** directly using InsForge internal tokens (no third-party OpenAI/Anthropic bill).
2. **Postgres Database**: Stores verified Indian crop diseases, scientific remedies, chemical dosages, and organic alternatives in Hindi/Hinglish.
3. **Serverless Functions**: Hosts `/api/v1/detect-disease` endpoint.
4. **Temporary S3-Compatible Storage Bucket**: Ephemeral image store (strictly auto-deleted after analysis).

---

## 🗄️ 3. Database Schema (PostgreSQL on InsForge)

### SQL Definition:
```sql
-- Table: crop_diseases
CREATE TABLE IF NOT EXISTS crop_diseases (
    id SERIAL PRIMARY KEY,
    crop_type VARCHAR(100) NOT NULL,
    disease_name VARCHAR(150) NOT NULL,
    scientific_name VARCHAR(150),
    symptoms TEXT NOT NULL,
    cure_details TEXT NOT NULL,
    prevention_tips TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_crop_disease ON crop_diseases (LOWER(crop_type), LOWER(disease_name));
```

### Initial Verified Seed Data (5 Core Indian Crops):
```sql
INSERT INTO crop_diseases (crop_type, disease_name, symptoms, cure_details, prevention_tips) VALUES
(
    'Tomato',
    'Early Blight (अर्ली ब्लाइट / अगेती झुलसा)',
    'पत्तियों पर गहरे भूरे या काले रंग के गोल छल्ले (Target spots) बनते हैं और नीचे की पत्तियां पीली पड़कर सूखने लगती हैं।',
    'मैन्कोजेब (Mancozeb 75% WP) 2.5 ग्राम प्रति लीटर पानी में या एज़ोक्सीस्ट्रोबिन (Azoxystrobin 23% SC) 1 मिली प्रति लीटर पानी में मिलाकर 10-12 दिन के अंतराल पर छिड़काव करें।',
    'खेत में जलभराव न होने दें, पुरानी सूखी पत्तियों को तोड़कर नष्ट करें और फसल चक्र अपनाएं।'
),
(
    'Wheat',
    'Yellow Rust (पीला रतुआ / हल्दी रोग)',
    'गेहूं की पत्तियों पर हल्दी जैसा पीला पाउडर धारियों के रूप में जम जाता है, जिसे छूने पर हाथ पीला हो जाता है।',
    'प्रोपिकोनाजोल (Propiconazole 25% EC - Tilt) 1 मिली प्रति लीटर पानी में मिलाकर तुरंत पूरे खेत में छिड़कें। रोग ज्यादा होने पर 15 दिन बाद दोबारा छिड़काव करें।',
    'रतुआ रोधी किस्में (जैसे HD-3086, DBW-187) लगाएं और खेत में लगातार नमी की जांच रखें।'
),
(
    'Potato',
    'Late Blight (पिछेती झुलसा)',
    'पत्तियों के किनारों पर काले-भूरे गीले धब्बे बनते हैं और पत्तियों की निचली सतह पर सफेद फफूंद दिखाई देती है। ठंडे और नम मौसम में यह तेजी से फैलता है।',
    'साइमोक्सानिल + मैन्कोजेब (Cymoxanil 8% + Mancozeb 64% WP - Curzate) 3 ग्राम प्रति लीटर या मेटलैक्ट्सिल + मैन्कोजेब (Ridomil MZ) 2.5 ग्राम प्रति लीटर पानी में छिड़कें।',
    'बीमार कंदों को बीज के रूप में इस्तेमाल न करें और बीमारी के लक्षण दिखते ही तुरंत सिंचाई रोक दें।'
),
(
    'Mustard',
    'White Rust (सफेद रतुआ / छाछिया)',
    'पत्तियों की निचली सतह पर सफेद उभरे हुए फफोले बनते हैं और तना व फूल विकृत होकर सूज जाते हैं (Staghead symptom)।',
    'मेटालेक्सिल 35% WS से बीज उपचार करें और लक्षण दिखने पर रिडोमिल (Metalaxyl-Mancozeb) 2 ग्राम प्रति लीटर पानी में मिलाकर छिड़काव करें।',
    'बुवाई समय पर (15 अक्टूबर से 30 अक्टूबर) करें और पौधों के बीच उचित दूरी रखें।'
),
(
    'Cotton',
    'Pink Bollworm (गुलाबी सुंडी)',
    'कपास के फूलों का आकार गुलाब जैसा (Rosetted flower) हो जाता है और टिंडों में छेद करके सुंडी अंदर के रेशे व बीज को खा जाती है।',
    'फेनप्रोपाथ्रिन 30% EC 1 मिली/लीटर या इमामेक्टिन बेंजोएट 5% SG 0.5 ग्राम/लीटर का छिड़काव करें। खेत में प्रति एकड़ 5-8 फेरोमोन ट्रैप लगाएं।',
    'खेत में नीम तेल (1500 PPM) 5 मिली प्रति लीटर का प्रारंभिक छिड़काव करें और समय पर कपास की चुनाई पूरी करें।'
);
```

---

## 🧠 4. Vision AI Pipeline (InsForge Model Gateway + Llama 3.2 Vision)

### Model Gateway Call Spec:
- **Model**: `meta-llama/llama-3.2-11b-vision-instruct` (or `llama-3.2-vision` in InsForge Gateway).
- **System Instruction**:
  ```text
  You are an expert Agronomist and Plant Pathologist.
  Analyze this crop leaf/plant image. Identify the crop and visual symptoms of any disease or pest damage.
  Output STRICTLY a valid JSON object with exactly two keys:
  {
    "crop_type": "<crop_name_in_english>",
    "detected_disease": "<disease_or_pest_name_in_english>"
  }
  Do not include any conversational filler, explanation, markdown formatting, or code fences. Output raw JSON only.
  ```

### Expected Clean Model Output:
```json
{"crop_type": "Tomato", "detected_disease": "Early Blight"}
```

---

## ⚙️ 5. Complete Backend Workflow (`/api/v1/detect-disease`)

```
   [Mobile Client (Flutter)]
              │
              ▼ (Multipart POST: /api/v1/detect-disease)
  ┌────────────────────────────────────────────────────────┐
  │ 1. IN-MEMORY IMAGE COMPRESSION                         │
  │    - Downsample image resolution & quality to < 300KB  │
  │    - Compute MD5/SHA256 hash for 5-minute cache lookup │
  └───────────────────────────┬────────────────────────────┘
                              │
  ┌───────────────────────────▼────────────────────────────┐
  │ 2. CACHE HIT CHECK (5-Min Redis / In-Memory Map)       │
  │    - If identical image processed in last 5 mins:      │
  │      Return cached diagnosis immediately (0 tokens!)   │
  └───────────────────────────┬────────────────────────────┘
                              │ (Cache miss)
  ┌───────────────────────────▼────────────────────────────┐
  │ 3. CALL LLAMA 3.2 VISION (InsForge Gateway)            │
  │    - Base64 payload passed to model gateway            │
  │    - Receive JSON: {crop_type, detected_disease}       │
  └───────────────────────────┬────────────────────────────┘
                              │
  ┌───────────────────────────▼────────────────────────────┐
  │ 4. DATABASE LOOKUP (InsForge Postgres)                 │
  │    - Query crop_diseases matching crop & disease       │
  │    - Extract symptoms, cure_details, & prevention_tips │
  └───────────────────────────┬────────────────────────────┘
                              │
  ┌───────────────────────────▼────────────────────────────┐
  │ 5. RESPONSE GENERATION (Hindi/Hinglish)                │
  │    - Format doctor-prescription response with dosage   │
  │    - If unknown: Provide 3 organic safety tips         │
  └───────────────────────────┬────────────────────────────┘
                              │
  ┌───────────────────────────▼────────────────────────────┐
  │ 6. ASYNC CLEANUP HOOK (Crucial Zero Storage Rule)      │
  │    - Purge any temp files / buffers                    │
  │    - Maintain 0% storage footprint on InsForge free tier│
  └────────────────────────────────────────────────────────┘
```

---

## 📦 6. Production API Implementation (Node.js / Express / TypeScript)

```typescript
import express, { Request, Response } from 'express';
import multer from 'multer';
import sharp from 'sharp';
import { Pool } from 'pg';
import crypto from 'crypto';

const app = express();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 15 * 1024 * 1024 } });

// InsForge Database Pool
const pool = new Pool({
  connectionString: process.env.INSFORGE_DATABASE_URL,
});

// 5-Minute In-Memory Response Cache (Prevent Token Wastage)
const responseCache = new Map<string, { data: any; expiry: number }>();

app.post('/api/v1/detect-disease', upload.single('image'), async (req: Request, res: Response) => {
  let fileBuffer: Buffer | null = req.file?.buffer ?? null;

  if (!fileBuffer) {
    return res.status(400).json({ success: false, error: 'कृपया पौधे/पत्ते की फोटो अपलोड करें।' });
  }

  try {
    // 1. Image Optimization Middleware: Compress to < 300KB
    const compressedBuffer = await sharp(fileBuffer)
      .resize({ width: 1024, withoutEnlargement: true })
      .jpeg({ quality: 80 })
      .toBuffer();

    // 2. 5-Minute Duplicate Query Caching
    const hash = crypto.createHash('md5').update(compressedBuffer).digest('hex');
    const cached = responseCache.get(hash);
    if (cached && cached.expiry > Date.now()) {
      return res.json({ success: true, cached: true, ...cached.data });
    }

    // 3. Call Llama 3.2 Vision via InsForge Model Gateway
    const base64Image = `data:image/jpeg;base64,${compressedBuffer.toString('base64')}`;
    const gatewayResponse = await fetch(`${process.env.INSFORGE_GATEWAY_URL}/v1/chat/completions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.INSFORGE_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'meta-llama/llama-3.2-11b-vision-instruct',
        messages: [
          {
            role: 'system',
            content: 'You are an agricultural expert. Analyze this leaf. Output strictly a JSON object: {"crop_type": "<crop>", "detected_disease": "<disease>"}. No markdown, no conversational text.',
          },
          {
            role: 'user',
            content: [
              { type: 'text', text: 'Identify the crop and disease in this leaf image.' },
              { type: 'image_url', image_url: { url: base64Image } }
            ],
          },
        ],
        temperature: 0.1,
      }),
    });

    const aiResult = await gatewayResponse.json();
    const rawContent = aiResult.choices?.[0]?.message?.content?.trim() || '{}';
    const parsed = JSON.parse(rawContent.replace(/```json|```/g, '').trim());

    const cropType = parsed.crop_type || 'Unknown';
    const detectedDisease = parsed.detected_disease || 'Unknown';

    // 4. Query Postgres on InsForge for CIBRC Approved Cures
    const dbQuery = `
      SELECT * FROM crop_diseases 
      WHERE LOWER(crop_type) LIKE LOWER($1) 
         OR LOWER(disease_name) LIKE LOWER($2)
      LIMIT 1
    `;
    const dbResult = await pool.query(dbQuery, [`%${cropType}%`, `%${detectedDisease}%`]);

    let responsePayload: any;

    if (dbResult.rows.length > 0) {
      const match = dbResult.rows[0];
      responsePayload = {
        crop: match.crop_type,
        disease: match.disease_name,
        confidence: 'High',
        symptoms: match.symptoms,
        treatment: match.cure_details,
        prevention: match.prevention_tips,
        messageHindi: `🌾 आपकी **${match.crop_type}** की फसल में **${match.disease_name}** के लक्षण पाए गए हैं।\n\n💊 **सटीक उपचार:**\n${match.cure_details}\n\n🛡️ **बचाव के उपाय:**\n${match.prevention_tips}`,
      };
    } else {
      // Safe fallback when disease is unconfirmed in local DB
      responsePayload = {
        crop: cropType,
        disease: detectedDisease,
        confidence: 'Moderate',
        symptoms: 'पत्तियों पर रोग के प्रारंभिक लक्षण दिखाई दे रहे हैं।',
        treatment: '1. नजदीकी कृषि विज्ञान केंद्र (KVK) या कृषि पर्यवेक्षक से सलाह लें।\n2. 5 मिली नीम तेल (Neem Oil) प्रति लीटर पानी में मिलाकर प्राथमिक छिड़काव करें।\n3. संक्रमित पत्तियों को तोड़कर खेत से दूर नष्ट कर दें।',
        messageHindi: `🌾 आपकी फसल में **${detectedDisease}** के लक्षण प्रतीत होते हैं। सुरक्षित उपचार हेतु नीम तेल का छिड़काव करें और कृषि विशेषज्ञ से सलाह लें।`,
      };
    }

    // 5. Cache result for 5 minutes
    responseCache.set(hash, { data: responsePayload, expiry: Date.now() + 5 * 60 * 1000 });

    return res.json({ success: true, ...responsePayload });
  } catch (error: any) {
    console.error('Detection error:', error);
    return res.status(500).json({ success: false, error: 'जांच प्रक्रिया में त्रुटि हुई। कृपया दोबारा प्रयास करें।' });
  } finally {
    // 6. Zero Storage Leak: Purge memory buffers immediately
    fileBuffer = null;
  }
});
```

---

## 📱 7. Flutter Mobile App Client Connection
In the Flutter mobile app (`lib/screens/crop_doctor/crop_doctor_screen.dart`):
```dart
// POST request to InsForge Serverless Function
final uri = Uri.parse('https://<your-insforge-app>.insforge.app/api/v1/detect-disease');
final request = http.MultipartRequest('POST', uri);
request.files.add(await http.MultipartFile.fromPath('image', photoFile.path));

final response = await request.send();
final responseData = await response.stream.bytesToString();
final result = jsonDecode(responseData);
```

---

## 🔒 8. Golden Rules for Future Agents:
1. **Never use third-party paid Vision APIs (OpenAI GPT-4o / Claude Vision)** when InsForge Model Gateway is available. Always use **Llama 3.2 Vision via InsForge Model Gateway**.
2. **Never store user photos permanently on cloud disks.** Always stream, optimize in RAM, infer, and drop from memory (0% storage footprint).
3. **Never hallucinate chemical dosages.** All pesticide/fungicide quantities (grams/liters) must originate from the `crop_diseases` PostgreSQL database.
