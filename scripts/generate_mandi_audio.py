#!/usr/bin/env python3
"""
Automated Daily Mandi Audio Bulletin Generator
Uses Microsoft Swara Neural (100% Natural Studio Hindi Female Voice)
Generates lightweight MP3 audio bulletins for all mandis and saves them in assets/audio/bulletins/
"""

import os
import sys
import json
import asyncio
import hashlib
import edge_tts

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

VOICE = "hi-IN-SwaraNeural"
RATE = "-4%"   # Slightly relaxed, natural radio news pace
PITCH = "+2Hz" # Clear, pleasant female announcer pitch

HINDI_COMMODITY_MAP = {
    "Wheat": "गेहूं",
    "Paddy(Dhan)(Common)": "धान",
    "Paddy(Dhan)(Basmati)": "बासमती धान",
    "Bajra(Pearl Millet/Cumbu)": "बाजरा",
    "Mustard": "सरसों",
    "Mustard Oil": "सरसों",
    "Guar": "ग्वार",
    "Guar Seed(Cluster Beans Seed)": "ग्वार",
    "Guar Gum": "ग्वार गम",
    "Gram": "चना",
    "Gram Raw(Chholia)": "चना",
    "Cumin Seed(Jeera)": "जीरा",
    "Jeera": "जीरा",
    "Moath Dal": "मोठ",
    "Moath": "मोठ",
    "Moong(Green Gram)": "मूंग",
    "Cotton": "कपास",
    "Castor Seed": "अरंडी",
    "Soyabean": "सोयाबीन",
    "Isabgul (Psyllium)": "इसबगोल",
    "Isabgol": "इसबगोल",
    "Groundnut": "मूंगफली",
    "Maize": "मक्का",
    "Barley (Jau)": "जौ",
    "Barley": "जौ",
    "Fenugreek(Methi)": "मेथी",
    "Methi(Leaves)": "मेथी",
    "Coriander(Leaves)": "धनिया",
    "Turmeric": "हल्दी",
    "Garlic": "लहसुन",
    "Onion": "प्याज़",
    "Potato": "आलू",
    "Tomato": "टमाटर",
    "Chilli Red": "लाल मिर्च",
    "Green Chilli": "हरी मिर्च",
    "Taramira": "तारामीरा",
    "Sesamum(Sesame,Gingelly,Til)": "तिल",
    "Linseed": "अलसी",
    "Lemon": "नींबू",
    "Bhindi(Ladies Finger)": "भिंडी",
    "Tori": "तोरई",
}

def get_hindi_commodity(name):
    clean = name.strip()
    return HINDI_COMMODITY_MAP.get(clean, clean)

async def generate_mandi_mp3(mandi_name, rates, output_dir, manifest):
    if not rates:
        return
    
    # Safe slug for filename e.g. "mandi_jodhpur.mp3"
    slug_hash = hashlib.md5(mandi_name.encode('utf-8')).hexdigest()[:8]
    clean_ascii = "".join(c for c in mandi_name if c.isalnum() or c in (' ', '_')).strip().replace(" ", "_")
    if not clean_ascii:
        clean_ascii = f"mandi_{slug_hash}"
    filename = f"{clean_ascii}_{slug_hash}.mp3".lower()
    output_file = os.path.join(output_dir, filename)
    
    # Build beautiful, natural Hindi speech text
    lines = [f"नमस्कार किसान भाइयों! आज {mandi_name} के प्रमुख मंडी भाव इस प्रकार हैं:"]
    for r in rates[:12]:
        crop_hindi = get_hindi_commodity(r.get("commodity", ""))
        price = int(float(r.get("modal_price", 0)))
        if price > 0:
            lines.append(f"{crop_hindi} {price} रुपये,")
    
    lines.append("प्रति क्विंटल दर्ज हुआ है। धन्यवाद और आपका दिन शुभ हो!")
    full_text = " ".join(lines)

    try:
        communicate = edge_tts.Communicate(full_text, VOICE, rate=RATE, pitch=PITCH)
        await communicate.save(output_file)
        manifest[mandi_name] = f"assets/audio/bulletins/{filename}"
        print(f"  [OK] Generated {filename} ({len(rates)} crops)")
    except Exception as e:
        print(f"  [ERROR] Failed {mandi_name}: {e}")

async def main():
    output_dir = os.path.join("assets", "audio", "bulletins")
    os.makedirs(output_dir, exist_ok=True)
    manifest = {}

    # Read latest live cached mandi rates
    data_file = os.path.join("assets", "data", "mandi_rates.json")
    if not os.path.exists(data_file):
        print("No mandi_rates.json found. Creating default bulletins...")
        rates_by_mandi = {
            "जोधपुर मंडी": [
                {"commodity": "Wheat", "modal_price": 2650},
                {"commodity": "Jeera", "modal_price": 26800},
                {"commodity": "Mustard", "modal_price": 5750},
                {"commodity": "Moong(Green Gram)", "modal_price": 8100},
                {"commodity": "Guar", "modal_price": 5350},
                {"commodity": "Gram", "modal_price": 5850},
            ],
            "मेड़ता सिटी": [
                {"commodity": "Jeera", "modal_price": 27200},
                {"commodity": "Moong(Green Gram)", "modal_price": 8350},
                {"commodity": "Isabgol", "modal_price": 14500},
                {"commodity": "Guar", "modal_price": 5400},
            ],
            "बीकानेर मंडी": [
                {"commodity": "Wheat", "modal_price": 2580},
                {"commodity": "Mustard", "modal_price": 5800},
                {"commodity": "Groundnut", "modal_price": 6200},
                {"commodity": "Gram", "modal_price": 5900},
            ],
            "जयपुर मंडी": [
                {"commodity": "Wheat", "modal_price": 2620},
                {"commodity": "Bajra(Pearl Millet/Cumbu)", "modal_price": 2250},
                {"commodity": "Mustard", "modal_price": 5780},
                {"commodity": "Gram", "modal_price": 5820},
            ],
        }
    else:
        with open(data_file, "r", encoding="utf-8") as f:
            all_rates = json.load(f)
        rates_by_mandi = {}
        for r in all_rates:
            market = r.get("market", "Mandi").strip()
            if market not in rates_by_mandi:
                rates_by_mandi[market] = []
            rates_by_mandi[market].append(r)

    print(f"Generating studio Hindi voice bulletins for {len(rates_by_mandi)} mandis...")
    tasks = []
    for mandi, rates in rates_by_mandi.items():
        tasks.append(generate_mandi_mp3(mandi, rates, output_dir, manifest))
    
    await asyncio.gather(*tasks)
    
    # Save manifest
    manifest_file = os.path.join(output_dir, "audio_manifest.json")
    with open(manifest_file, "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=2)
    print(f"Saved manifest with {len(manifest)} bulletins at {manifest_file}")
    print("All studio voice bulletins generated successfully!")

if __name__ == "__main__":
    asyncio.run(main())
