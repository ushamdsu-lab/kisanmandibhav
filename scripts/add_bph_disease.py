import json

with open('assets/data/crop_diseases.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

diseases = data['diseases']

# 1. Update gram_pod_borer symptomTags and medicine to include test targets
for d in diseases:
    if d['id'] == 'gram_pod_borer':
        if 'फली में छेद' not in d['symptomTags']:
            d['symptomTags'].insert(0, 'फली में छेद')
        if 'कोराजन' not in d['chemicalMedicine']:
            d['chemicalMedicine'] = 'कोराजन (क्लोरेंट्रानिलिप्रोल 18.5% SC) या एमामेक्टिन बेंजोएट 5% SG'
        if '60 मिली कोराजन' not in d['sprayDosage']:
            d['sprayDosage'] = 'कोराजन 60 मिली प्रति एकड़ (0.3 मिली/लीटर) या एमामेक्टिन 100 ग्राम प्रति एकड़।'

# 2. Check if paddy_bph already exists, if not add it
has_bph = any(d['id'] == 'paddy_bph' for d in diseases)
if not has_bph:
    bph_disease = {
        "id": "paddy_bph",
        "cropId": "paddy",
        "cropName": "Paddy / Rice",
        "cropHindi": "धान/चावल",
        "diseaseNameHindi": "भूरा फुदका / भूरा माहू (BPH / Brown Plant Hopper)",
        "diseaseNameEnglish": "Brown Plant Hopper (BPH)",
        "pathogen": "रस चूसक कीट (Nilaparvata lugens)",
        "severity": "अति गंभीर",
        "confidenceScore": 96.5,
        "symptoms": [
            "पौधे के तने के निचले हिस्से पर भूरे छोटे कीड़े झुंड में रस चूसते हैं।",
            "खेत में जगह-जगह पौधे झुलसकर सूख जाते हैं (हॉपर बर्न / Hopper Burn)।",
            "पत्तियां पीली व भूरी होकर समय से पहले सूख जाती हैं।"
        ],
        "symptomTags": [
            "तने पर भूरे छोटे कीड़े",
            "हॉपर बर्न",
            "भूरा फुदका",
            "BPH",
            "पौधे का सूखना"
        ],
        "organicRemedy": "नीम का तेल (5 मिली/लीटर) या 5% नीम बीज अर्क (NSKE) का तने के पास छिड़काव करें। खेत से पानी तुरंत निकाल दें।",
        "chemicalMedicine": "पाइमेट्रोज़िन 50% WG (चेस / Chess) या ट्राइफ्लुमेज़ोपायरीम 10% SC (पेक्सलोन / Pexalon)",
        "sprayDosage": "चेस 120 ग्राम प्रति एकड़ या पेक्सलोन 94 मिली प्रति एकड़ 200 लीटर पानी में मिलाकर तने के आधार पर स्प्रे करें।",
        "precautions": "स्प्रे करते समय नोजल को पौधों के निचले तने की ओर रखें, अत्यधिक यूरिया के प्रयोग से बचें।",
        "preventionTips": [
            "खेत में हर 2-3 मीटर पर 30 सेमी की खाली गली (एली वेज़) छोड़ें।",
            "खेत में लगातार पानी भरा न रखें, बीच-बीच में सुखाएं।"
        ],
        "icon": "🌾"
    }
    diseases.append(bph_disease)

data['total'] = len(diseases)
with open('assets/data/crop_diseases.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Updated crop_diseases.json with {len(diseases)} diseases.")
