# 🌾 AGENTS.md — Kisan Mandi Bhav & Crop AI Rules

> **MANDATORY INSTRUCTIONS FOR ALL AGENTS AND DEVELOPERS WORKING ON THIS CODEBASE**

---

## 🚨 Core Directives & Constraints

1. **NEVER DELETE OR REMOVE UI ELEMENTS:**
   - Any modifications to Flutter screens (`lib/screens/**`, `lib/widgets/**`) must preserve all existing cards, chips, buttons, modals, and texts. 
   - Never simplify or strip features. Solve overflows using `Expanded`, `Flexible`, `FittedBox`, or scroll views, not by removing content.

2. **CROP CHATBOT & VISION AI ARCHITECTURE (STRICT):**
   - The master blueprints are located at:
     * [CROP_AI_DETECTION_AND_CHATBOT_PLAN.md](file:///d:/mandi%20weather%20updates/docs/CROP_AI_DETECTION_AND_CHATBOT_PLAN.md) (Primary Zero-Cost Vercel/On-Device Execution Plan)
     * [INSFORGE_CROP_CHATBOT_SPEC.md](file:///d:/mandi%20weather%20updates/docs/INSFORGE_CROP_CHATBOT_SPEC.md) (InsForge Cloud Spec)
   - **Infrastructure**: Must strictly run on **InsForge (InstaCloud)** under project ID `5dc72ac3-ba67-4c4a-906e-c6f439abcd43`.
   - **Vision Model**: Strictly use **Llama 3.2 Vision** via the **InsForge Model Gateway**.
     - ⚠️ **DO NOT** replace with paid third-party APIs (OpenAI GPT-4o, Anthropic Claude, etc.) that would incur extra bills for the user.
   - **0% Permanent Storage Footprint**:
     - Farmer leaf/crop images must be compressed to `< 300KB` (JPEG 70-80% quality, max 1024x1024).
     - Images uploaded for inference must be purged/deleted immediately after processing. Never retain raw images in persistent cloud storage.
   - **Cure & Medicine Verification**:
     - All chemical dosages (e.g., Mancozeb, Propiconazole, Carbendazim, Neem Oil) must be fetched from the InsForge Postgres `crop_diseases` database table. The LLM must NOT hallucinate unverified dosages.
   - **Language Support**: All diagnostics and treatments must be presented in natural **Hindi / Hinglish** tailored for Indian farmers.

3. **PLAY STORE & RELEASE SAFETY:**
   - Active package name: `com.kisan.mandibhav`
   - NDK Version required for builds: `ndkVersion = "28.2.13676358"` in `android/app/build.gradle.kts`.
   - AdMob IDs:
     - App ID: `ca-app-pub-7650949194753110~4751917111`
     - Banner Ad: `ca-app-pub-7650949194753110/5674116546`
     - Native Ad: `ca-app-pub-7650949194753110/5373252690` (bich walo ads - Use `NativeAd` with `NativeTemplateStyle.small`, never load as BannerAd).

---

## 🛠️ Step-by-Step Execution Plan for Chatbot Integration

When the user asks to build or connect the chatbot:
1. **InsForge CLI Link**:
   ```bash
   npx @insforge/cli link --project-id 5dc72ac3-ba67-4c4a-906e-c6f439abcd43
   ```
2. **Execute Database Migration**:
   - Run the SQL DDL and seed data in [INSFORGE_CROP_CHATBOT_SPEC.md](file:///d:/mandi%20weather%20updates/docs/INSFORGE_CROP_CHATBOT_SPEC.md#3-database-schema-postgresql-on-insforge).
3. **Deploy API Endpoint**:
   - `/api/v1/detect-disease` on InsForge functions with Llama 3.2 Vision Gateway call.
4. **Flutter UI Wiring**:
   - Connect `lib/screens/crop_doctor/crop_doctor_screen.dart` to the API.
   - Support image picker (Camera / Gallery), Hindi voice readout (TTS), and WhatsApp share.
