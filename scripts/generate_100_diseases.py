#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generate complete 105+ Agricultural Diseases Database for Kisan Mandi Bhav app.
"""
import json
import os

def create_database():
    # Load existing from fetch_crop_diseases.py if any
    from scripts.build_100_diseases import DISEASES as base_diseases
    diseases = list(base_diseases)

    more_diseases = [
        # =========================================================================
        # 🥜 18. मूंगफली (Groundnut)
        # =========================================================================
        {
            "id": "groundnut_tikka",
            "cropId": "groundnut",
            "cropName": "Groundnut",
            "cropHindi": "मूंगफली",
            "diseaseNameHindi": "टिक्का रोग / पर्ण चित्ती (Tikka Disease)",
            "diseaseNameEnglish": "Tikka Leaf Spot",
            "pathogen": "फफूंद (Cercospora personata / arachidicola)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.8,
            "symptoms": [
                "पत्तियों पर गोल गहरे भूरे से काले धब्बे जिनके चारों ओर पीला छल्ला (Halo) होता है।",
                "पत्तियां समय से पहले पीली पड़कर तेजी से झड़ जाती हैं और दाना छोटा रह जाता है।"
            ],
            "symptomTags": ["काले गोल धब्बे", "पीला छल्ला", "टिक्का रोग", "पत्ती झड़ना"],
            "organicRemedy": "खट्टी छाछ (5 लीटर) + नीम तेल (5 मिली/लीटर) का 15 दिन के अंतराल पर छिड़काव।",
            "chemicalMedicine": "कार्बेंडाजिम 12% + मैंकोजेब 63% WP (साफ / Saaf) या हेक्साकोनाज़ोल 5% SC",
            "sprayDosage": "साफ: 2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़ 200 लीटर पानी में)।",
            "precautions": "बुवाई के 35-40 दिन बाद पहला लक्षण दिखते ही स्प्रे करें।",
            "preventionTips": ["बीज को थीरम या बाविस्टिन 2 ग्राम/किलो से उपचारित करें।"],
            "icon": "🥜"
        },
        {
            "id": "groundnut_collar_rot",
            "cropId": "groundnut",
            "cropName": "Groundnut",
            "cropHindi": "मूंगफली",
            "diseaseNameHindi": "कॉलर सड़न / तना गलन (Collar Rot)",
            "diseaseNameEnglish": "Collar Rot of Groundnut",
            "pathogen": "फफूंद (Aspergillus niger)",
            "severity": "गंभीर",
            "confidenceScore": 94.5,
            "symptoms": [
                "अंकुरण के समय जमीन की सतह पर तने का भाग काला पड़कर सड़ जाता है।",
                "सड़े हुए भाग पर काला चूर्ण उग आता है और पौधा गिरकर सूख जाता है।"
            ],
            "symptomTags": ["तने का सड़ना", "काला चूर्ण", "कॉलर सड़न", "पौधा गिरना"],
            "organicRemedy": "ट्राइकोडर्मा विरिडी 2 किलो प्रति एकड़ गोबर खाद में मिलाकर बुवाई से पहले डालें।",
            "chemicalMedicine": "कार्बोक्सिन 37.5% + थीरम 37.5% (विटावैक्स)",
            "sprayDosage": "बीज उपचार: 2.5 ग्राम प्रति किलो बीज।",
            "precautions": "खेत में कच्ची गोबर खाद न डालें।",
            "preventionTips": ["बीज की गहराई 5 सेमी से अधिक न रखें।"],
            "icon": "🥜"
        },
        {
            "id": "groundnut_white_grub",
            "cropId": "groundnut",
            "cropName": "Groundnut",
            "cropHindi": "मूंगफली",
            "diseaseNameHindi": "सफेद लट (White Grub)",
            "diseaseNameEnglish": "White Grub (Holotrichia consanguinea)",
            "pathogen": "कीट (Holotrichia consanguinea)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.2,
            "symptoms": [
                "पौधे अचानक कतारों में सूखने लगते हैं और आसानी से उखड़ जाते हैं।",
                "जड़ों को अंग्रेजी के 'C' आकार की सफेद सुंडी पूरी तरह काट देती है।"
            ],
            "symptomTags": ["कतार में पौधे सूखना", "जड़ कटना", "सफेद लट", "C आकार की सुंडी"],
            "organicRemedy": "बवेरिया बैसियाना 2 किलो प्रति एकड़ गोबर खाद में मिलाकर दें।",
            "chemicalMedicine": "क्लोथियानिडिन 50% WDG (डेंटोट्सु) या फिप्रोनिल 40% + इमिडाक्लोप्रिड 40% WG",
            "sprayDosage": "क्लोथियानिडिन: 100 ग्राम प्रति एकड़ बुवाई पूर्व या सिंचाई के साथ।",
            "precautions": "पहली बारिश के बाद प्रकाश प्रपंच (Light Trap) लगाकर भृंगों को नष्ट करें।",
            "preventionTips": ["खेत की मेड़ों पर लगे खेजड़ी/बबूल के पेड़ों पर मोनोक्रोटोफॉस का छिड़काव करें।"],
            "icon": "🥜"
        },

        # =========================================================================
        # 🫘 19. मूंग व उड़द (Moong & Urad)
        # =========================================================================
        {
            "id": "moong_yellow_mosaic",
            "cropId": "moong",
            "cropName": "Moong",
            "cropHindi": "मूंग",
            "diseaseNameHindi": "पीला मोज़ेक वायरस (YMV of Moong)",
            "diseaseNameEnglish": "Yellow Mosaic Virus of Moong",
            "pathogen": "सफेद मक्खी जनित वायरस (Mungbean Yellow Mosaic Virus)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.5,
            "symptoms": [
                "पत्तियों पर पीले-हरे रंग के चकत्ते बनते हैं जो बाद में पूरी पत्ती को सुनहरा पीला कर देते हैं।",
                "पौधों में फलियां बहुत कम लगती हैं और दाना बारीक रह जाता है।"
            ],
            "symptomTags": ["पीली पत्ती", "पीला मोज़ेक", "सफेद मक्खी", "मूंग का पीलापन"],
            "organicRemedy": "नीम तेल 5 मिली/लीटर + 15 पीले चिपचिपे कार्ड प्रति एकड़ लगाएं।",
            "chemicalMedicine": "थियामेथोक्सम 25% WG या डायफेंथियूरॉन 50% WP",
            "sprayDosage": "थियामेथोक्सम: 80 ग्राम प्रति एकड़ 150 लीटर पानी में।",
            "precautions": "सफेद मक्खी की पहली पीढ़ी को तुरंत रोकें।",
            "preventionTips": ["YMV प्रतिरोधी किस्में (IPM 02-3, GM 4, SML 668) लगाएं।"],
            "icon": "🫘"
        },
        {
            "id": "moong_powdery_mildew",
            "cropId": "moong",
            "cropName": "Moong",
            "cropHindi": "मूंग",
            "diseaseNameHindi": "चूर्णी फफूंद / छाछ्या रोग (Powdery Mildew)",
            "diseaseNameEnglish": "Powdery Mildew of Green Gram",
            "pathogen": "फफूंद (Erysiphe polygoni)",
            "severity": "मध्यम से गंभीर",
            "confidenceScore": 94.0,
            "symptoms": [
                "पत्तियों की ऊपरी व निचली सतह पर सफेद आटे जैसा चूर्ण जम जाता है।",
                "पत्तियां पीली पड़कर सूखती हैं और फलियों का विकास रुक जाता है।"
            ],
            "symptomTags": ["सफेद चूर्ण", "आटे जैसा पाउडर", "छाछ्या रोग"],
            "organicRemedy": "घुलनशील गंधक (सल्फर 80% WDG) 3 ग्राम प्रति लीटर।",
            "chemicalMedicine": "हेक्साकोनाज़ोल 5% EC या माइक्लोब्यूटानिल 10% WP",
            "sprayDosage": "हेक्साकोनाज़ोल: 2 मिली प्रति लीटर (400 मिली प्रति एकड़)।",
            "precautions": "सुबह के समय ओस सूखने के बाद छिड़काव करें।",
            "preventionTips": ["फसल की कटाई के बाद अवशेष जलाएं।"],
            "icon": "🫘"
        },
        {
            "id": "urad_cercospora_leaf_spot",
            "cropId": "urad",
            "cropName": "Urad",
            "cropHindi": "उड़द",
            "diseaseNameHindi": "सर्कोस्पोरा पत्ती धब्बा रोग (Leaf Spot)",
            "diseaseNameEnglish": "Cercospora Leaf Spot of Black Gram",
            "pathogen": "फफूंद (Cercospora canescens)",
            "severity": "मध्यम",
            "confidenceScore": 93.0,
            "symptoms": [
                "पत्तियों पर कोणीय या गोल लाल-भूरे धब्बे जिनके केंद्र राख के रंग के होते हैं।",
                "अधिक प्रकोप होने पर पत्तियां समय से पहले गिर जाती हैं।"
            ],
            "symptomTags": ["लाल-भूरे धब्बे", "राख जैसा केंद्र", "पत्ती धब्बा"],
            "organicRemedy": "गोमूत्र 10% + नीम पत्ती अर्क का छिड़काव।",
            "chemicalMedicine": "कार्बेंडाजिम 50% WP (बाविस्टिन) या मैंकोजेब",
            "sprayDosage": "कार्बेंडाजिम: 1 ग्राम प्रति लीटर (200 ग्राम प्रति एकड़)।",
            "precautions": "वर्षा ऋतु में रोग दिखते ही पहला छिड़काव करें।",
            "preventionTips": ["संतुलित फास्फोरस का उपयोग करें।"],
            "icon": "🫘"
        },

        # =========================================================================
        # 🫛 20. मटर (Pea)
        # =========================================================================
        {
            "id": "pea_powdery_mildew",
            "cropId": "pea",
            "cropName": "Pea",
            "cropHindi": "मटर",
            "diseaseNameHindi": "मटर का चूर्णी फफूंद / सफेद फफूंदी",
            "diseaseNameEnglish": "Powdery Mildew of Pea",
            "pathogen": "फफूंद (Erysiphe pisi)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.0,
            "symptoms": [
                "पत्तियों, तनों और फलियों पर सफेद चूने जैसा पाउडर छा जाता है।",
                "फलियां काली पड़ जाती हैं और दानों का स्वाद खराब हो जाता है।"
            ],
            "symptomTags": ["सफेद पाउडर", "चूने जैसा चूर्ण", "काली फलियां", "छाछ्या"],
            "organicRemedy": "सल्फर डस्ट (गंधक चूर्ण) 10 किलो प्रति एकड़ भुरकें।",
            "chemicalMedicine": "डिनोकैप 48% EC (कराथेन) या अजोक्सीस्ट्रोबिन 23% SC",
            "sprayDosage": "कराथेन: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।",
            "precautions": "फरवरी में तापमान 20°C से ऊपर जाते ही विशेष सावधानी रखें।",
            "preventionTips": ["चूर्णी फफूंद प्रतिरोधी किस्में (अर्का अजीत, रचना, मालवीय 15) लगाएं।"],
            "icon": "🫛"
        },
        {
            "id": "pea_rust",
            "cropId": "pea",
            "cropName": "Pea",
            "cropHindi": "मटर",
            "diseaseNameHindi": "मटर का गेरुआ / रतुआ रोग",
            "diseaseNameEnglish": "Pea Rust (Uromyces fabae)",
            "pathogen": "फफूंद (Uromyces fabae)",
            "severity": "गंभीर",
            "confidenceScore": 94.0,
            "symptoms": [
                "पत्तियों की दोनों सतहों पर पीले-भूरे उभरे हुए दाने (Pustules)।",
                "बाद में दाने गहरे काले हो जाते हैं और पत्तियां सूखकर गिर जाती हैं।"
            ],
            "symptomTags": ["पीले-भूरे दाने", "रतुआ रोग", "मटर का रस्ट"],
            "organicRemedy": "नीम का काढ़ा + खट्टी छाछ का छिड़काव।",
            "chemicalMedicine": "मैंकोजेब 75% WP (इंडोफिल एम-45) या प्रोपिकोनाज़ोल",
            "sprayDosage": "मैंकोजेब: 2.5 ग्राम प्रति लीटर पानी।",
            "precautions": "लक्षण दिखते ही 10 दिन के अंतराल पर 2 स्प्रे करें।",
            "preventionTips": ["अगेती बुवाई करें।"],
            "icon": "🫛"
        },

        # =========================================================================
        # 🥦 21. फूलगोभी व पत्तागोभी (Cauliflower & Cabbage)
        # =========================================================================
        {
            "id": "cabbage_black_rot",
            "cropId": "cauliflower",
            "cropName": "Cauliflower / Cabbage",
            "cropHindi": "फूलगोभी / पत्तागोभी",
            "diseaseNameHindi": "काला सड़न रोग (Black Rot)",
            "diseaseNameEnglish": "Black Rot of Crucifers",
            "pathogen": "जीवाणु (Xanthomonas campestris pv. campestris)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.5,
            "symptoms": [
                "पत्तियों के किनारे से 'V' आकार के पीले-भूरे धब्बे अंदर की ओर बढ़ते हैं।",
                "पत्तियों की नसें काली पड़ जाती हैं और तने को काटने पर काला छल्ला दिखता है।"
            ],
            "symptomTags": ["V आकार के धब्बे", "काली नसें", "काला सड़न", "फूल सड़ना"],
            "organicRemedy": "गर्म पानी उपचार (50°C पर 30 मिनट बीज डुबोएं)।",
            "chemicalMedicine": "स्ट्रेप्टोसाइक्लिन (6 ग्राम) + कॉपर ऑक्सीक्लोराइड (500 ग्राम)",
            "sprayDosage": "स्ट्रेप्टोसाइक्लिन 1 ग्राम प्रति 10 लीटर + COC 2.5 ग्राम/लीटर।",
            "precautions": "वर्षा के समय खेत में पानी जमा न होने दें।",
            "preventionTips": ["गर्म जल से उपचारित बीज ही लगाएं।"],
            "icon": "🥦"
        },
        {
            "id": "cabbage_diamond_back_moth",
            "cropId": "cauliflower",
            "cropName": "Cauliflower / Cabbage",
            "cropHindi": "फूलगोभी / पत्तागोभी",
            "diseaseNameHindi": "डायमंड बैक मोथ / डीबीएम इल्ली (DBM)",
            "diseaseNameEnglish": "Diamond Back Moth (Plutella xylostella)",
            "pathogen": "कीट (Plutella xylostella)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.4,
            "symptoms": [
                "पत्तियों की निचली सतह को खुरचकर इल्ली जाली (Windowing) बना देती है।",
                "फूल के अंदर इल्ली घुसकर उसे गंदा और खाने योग्य नहीं छोड़ती।"
            ],
            "symptomTags": ["पत्ती पर जाली", "हरी छोटी इल्ली", "डीबीएम", "फूल में छेद"],
            "organicRemedy": "सरसों को जाल फसल (Trap Crop) के रूप में गोभी के चारों ओर लगाएं।",
            "chemicalMedicine": "स्पिनटोरम 11.7% SC (डेलिगेट) या क्लोरेंट्रानिलिप्रोल (कोराजन)",
            "sprayDosage": "डेलिगेट: 0.9 मिली प्रति लीटर (180 मिली प्रति एकड़)।",
            "precautions": "कीटनाशक बदलते रहें ताकि इल्लियों में प्रतिरोधक क्षमता न बने।",
            "preventionTips": ["फेरोमोन ट्रैप 10 प्रति एकड़ लगाएं।"],
            "icon": "🥦"
        },

        # =========================================================================
        # 🌿 22. धनिया (Coriander)
        # =========================================================================
        {
            "id": "coriander_stem_gall",
            "cropId": "coriander",
            "cropName": "Coriander",
            "cropHindi": "धनिया",
            "diseaseNameHindi": "गलका / लौंगिया रोग (Stem Gall of Coriander)",
            "diseaseNameEnglish": "Stem Gall / Tumour Disease",
            "pathogen": "फफूंद (Protomyces macrosporus)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.0,
            "symptoms": [
                "तनों, पत्तियों और फलों पर लौंग या मस्से जैसे उभरे हुए फोड़े बन जाते हैं।",
                "दाना विकृत होकर फूल जाता है जिससे तेल की मात्रा खत्म हो जाती है।"
            ],
            "symptomTags": ["लौंग जैसे फोड़े", "गलका रोग", "लौंगिया", "फूले हुए दाने"],
            "organicRemedy": "ट्राइकोडर्मा 2 किलो प्रति एकड़ बुवाई पूर्व गोबर में मिलाकर दें।",
            "chemicalMedicine": "क्लोरोथैलोनिल 75% WP या कार्बेन्डाजिम + मैंकोजेब",
            "sprayDosage": "क्लोरोथैलोनिल: 2 ग्राम प्रति लीटर (400 ग्राम प्रति एकड़)।",
            "precautions": "फूल आने के समय नमी अधिक होने पर तुरंत पहला स्प्रे करें।",
            "preventionTips": ["गलका प्रतिरोधी किस्में (आरसीआर 41, आरसीआर 436) लगाएं।"],
            "icon": "🌿"
        },
        {
            "id": "coriander_powdery_mildew",
            "cropId": "coriander",
            "cropName": "Coriander",
            "cropHindi": "धनिया",
            "diseaseNameHindi": "धनिया का छाछ्या रोग (Powdery Mildew)",
            "diseaseNameEnglish": "Powdery Mildew of Coriander",
            "pathogen": "फफूंद (Erysiphe polygoni)",
            "severity": "गंभीर",
            "confidenceScore": 95.0,
            "symptoms": [
                "पत्तियों और फूल की छतरियों पर सफेद चूर्ण जम जाता है।",
                "दाना बनने से पहले ही फूल सूखकर गिर जाते हैं।"
            ],
            "symptomTags": ["सफेद चूर्ण", "छाछ्या", "छतरियों पर पाउडर"],
            "organicRemedy": "सल्फर 80% WDG 2.5 ग्राम प्रति लीटर पानी।",
            "chemicalMedicine": "डाइफेनोकोनाज़ोल 25% EC (स्कोर) या हेक्साकोनाज़ोल",
            "sprayDosage": "स्कोर: 0.5 मिली प्रति लीटर पानी।",
            "precautions": "तेज धूप में सल्फर का स्प्रे न करें।",
            "preventionTips": ["संतुलित खाद और सही बुवाई दूरी रखें।"],
            "icon": "🌿"
        },

        # =========================================================================
        # 🌿 23. सौंफ व मेथी (Fennel & Fenugreek)
        # =========================================================================
        {
            "id": "fennel_ramularia_blight",
            "cropId": "fennel",
            "cropName": "Fennel",
            "cropHindi": "सौंफ",
            "diseaseNameHindi": "सौंफ का झुलसा रोग (Ramularia Blight)",
            "diseaseNameEnglish": "Ramularia Blight of Fennel",
            "pathogen": "फफूंद (Ramularia foeniculi)",
            "severity": "गंभीर",
            "confidenceScore": 95.2,
            "symptoms": [
                "पत्तियों और फूल की छतरियों पर छोटे-छोटे भूरे-काले धब्बे।",
                "छतरियां काली पड़कर सूख जाती हैं और दाना नहीं बनता।"
            ],
            "symptomTags": ["काली छतरियां", "झुलसा रोग", "सौंफ काली पड़ना"],
            "organicRemedy": "खट्टी छाछ + गोमूत्र का 10 दिन के अंतराल पर छिड़काव।",
            "chemicalMedicine": "अजोक्सीस्ट्रोबिन 18.2% + डाइफेनोकोनाज़ोल 11.4% SC",
            "sprayDosage": "1 मिली प्रति लीटर पानी (200 मिली प्रति एकड़)।",
            "precautions": "बादल छाने और कोहरा होने पर बिना देरी किए छिड़कें।",
            "preventionTips": ["प्रमाणित किस्म (आरएफ 101, आरएफ 125) बोएं।"],
            "icon": "🌿"
        },
        {
            "id": "fenugreek_downy_mildew",
            "cropId": "fenugreek",
            "cropName": "Fenugreek",
            "cropHindi": "मेथी",
            "diseaseNameHindi": "मेथी का तुलासिता / डाउनी मिल्ड्यू",
            "diseaseNameEnglish": "Downy Mildew of Fenugreek",
            "pathogen": "फफूंद (Peronospora trigonellae)",
            "severity": "मध्यम से गंभीर",
            "confidenceScore": 93.8,
            "symptoms": [
                "पत्तियों की ऊपरी सतह पर पीले चकत्ते और निचली सतह पर बैगनी-धूसर फफूंदी।",
                "पत्तियां पीली पड़कर नीचे गिर जाती हैं।"
            ],
            "symptomTags": ["पीले चकत्ते", "बैगनी फफूंदी", "डाउनी मिल्ड्यू"],
            "organicRemedy": "तांबे के बर्तन में रखी छाछ का स्प्रे।",
            "chemicalMedicine": "रिडोमिल गोल्ड (Metalaxyl + Mancozeb)",
            "sprayDosage": "2 ग्राम प्रति लीटर पानी।",
            "precautions": "घनी बुवाई से बचें ताकि पौधों में धूप लगे।",
            "preventionTips": ["जल निकास की अच्छी व्यवस्था रखें।"],
            "icon": "🌿"
        },

        # =========================================================================
        # 🟡 24. हल्दी व अदरक (Turmeric & Ginger)
        # =========================================================================
        {
            "id": "ginger_rhizome_rot",
            "cropId": "ginger",
            "cropName": "Ginger",
            "cropHindi": "अदरक",
            "diseaseNameHindi": "प्रकंद सड़न / सॉफ्ट रॉट (Rhizome Rot)",
            "diseaseNameEnglish": "Rhizome Rot / Soft Rot of Ginger",
            "pathogen": "फफूंद (Pythium aphanidermatum)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.2,
            "symptoms": [
                "पत्तियां किनारों से पीली पड़कर सूखती हैं और पौधा गिर जाता है।",
                "जमीन के नीचे अदरक का प्रकंद (गांठ) पिलपिला होकर सड़ जाता है और बदबू आती है।"
            ],
            "symptomTags": ["गांठ सड़ना", "पिलपिला प्रकंद", "बदबूदार सड़न", "प्रकंद सड़न"],
            "organicRemedy": "ट्राइकोडर्मा विरिडी 5 किलो प्रति एकड़ खेत में गोबर के साथ दें।",
            "chemicalMedicine": "मेटालैक्सिल 8% + मैंकोजेब 64% WP से ड्रेन्चिंग",
            "sprayDosage": "2.5 ग्राम प्रति लीटर पानी से पौधों की जड़ों में ड्रेन्चिंग करें।",
            "precautions": "खेत में तनिक भी जलभराव न होने दें।",
            "preventionTips": ["गांठों को रोपाई से पहले 30 मिनट कवकनाशी में डुबोएं।"],
            "icon": "🫚"
        },
        {
            "id": "turmeric_leaf_spot",
            "cropId": "turmeric",
            "cropName": "Turmeric",
            "cropHindi": "हल्दी",
            "diseaseNameHindi": "हल्दी का पर्ण चित्ती रोग (Colletotrichum Leaf Spot)",
            "diseaseNameEnglish": "Leaf Spot of Turmeric",
            "pathogen": "फफूंद (Colletotrichum capsici)",
            "severity": "गंभीर",
            "confidenceScore": 95.0,
            "symptoms": [
                "पत्तियों पर भूरे-काले अंडाकार धब्बे जिनके बीच का भाग धूसर होता है।",
                "धब्बे आपस में मिलकर पूरी पत्ती को सुखा देते हैं।"
            ],
            "symptomTags": ["अंडाकार धब्बे", "धूसर केंद्र", "पत्ती सूखना"],
            "organicRemedy": "नीम तेल 5 मिली + खट्टी छाछ का छिड़काव।",
            "chemicalMedicine": "टेबुकोनाज़ोल 25.9% EC या मैंकोजेब 75% WP",
            "sprayDosage": "टेबुकोनाज़ोल: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।",
            "precautions": "मानसून के समय हर 20 दिन में सुरक्षात्मक स्प्रे करें।",
            "preventionTips": ["रोगमुक्त गांठों का चयन करें।"],
            "icon": "🟡"
        },

        # =========================================================================
        # 🍋 25. संतरा व नींबू (Citrus / Lemon)
        # =========================================================================
        {
            "id": "citrus_canker",
            "cropId": "citrus",
            "cropName": "Citrus / Lemon",
            "cropHindi": "संतरा / नींबू",
            "diseaseNameHindi": "नींबू का कैंकर रोग (Citrus Canker)",
            "diseaseNameEnglish": "Citrus Canker (Xanthomonas citri)",
            "pathogen": "जीवाणु (Xanthomonas axonopodis pv. citri)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.6,
            "symptoms": [
                "पत्तियों, टहनियों और फलों पर उभरे हुए खुरदरे भूरे-काले मस्से (खुरंड)।",
                "धब्बों के चारों ओर पीला छल्ला दिखता है और फल बदसूरत हो जाते हैं।"
            ],
            "symptomTags": ["खुरदरे मस्से", "खुरंड", "सिट्रस कैंकर", "पीला छल्ला"],
            "organicRemedy": "बोर्डो मिश्रण 1% (1 किलो चूना + 1 किलो नीला थोथा 100 लीटर पानी में)।",
            "chemicalMedicine": "स्ट्रेप्टोसाइक्लिन (10 ग्राम) + कॉपर ऑक्सीक्लोराइड (500 ग्राम/200L)",
            "sprayDosage": "स्ट्रेप्टोसाइक्लिन 1 ग्राम प्रति 20 लीटर + COC 2.5 ग्राम/लीटर।",
            "precautions": "लीफ माइनर कीट का नियंत्रण करें क्योंकि वह घाव बनाता है जहां से कैंकर फैलता है।",
            "preventionTips": ["संक्रमित टहनियों को काटकर बोर्डो पेस्ट लगाएं।"],
            "icon": "🍋"
        },
        {
            "id": "citrus_dieback",
            "cropId": "citrus",
            "cropName": "Citrus / Lemon",
            "cropHindi": "संतरा / नींबू",
            "diseaseNameHindi": "डाईबैक / टहनी सुखा रोग",
            "diseaseNameEnglish": "Citrus Dieback",
            "pathogen": "फफूंद (Colletotrichum gloeosporioides)",
            "severity": "गंभीर",
            "confidenceScore": 94.5,
            "symptoms": [
                "टहनियां ऊपरी सिरे से नीचे की ओर सूखने लगती हैं।",
                "सूखी टहनी पर पत्तियां गिर जाती हैं और पौधा धीरे-धीरे कमजोर होता है।"
            ],
            "symptomTags": ["ऊपर से नीचे सूखना", "डाईबैक", "सूखी टहनी"],
            "organicRemedy": "सूखी टहनी को 2 इंच हरे भाग सहित काटकर बोर्डो पेस्ट लगाएं।",
            "chemicalMedicine": "कॉपर ऑक्सीक्लोराइड 50% WP या कार्बेंडाजिम",
            "sprayDosage": "COC: 3 ग्राम प्रति लीटर पानी।",
            "precautions": "बरसात शुरू होने से पहले प्रूनिंग अवश्य करें।",
            "preventionTips": ["जिंक व कॉपर सूक्ष्म पोषक तत्वों की कमी न होने दें।"],
            "icon": "🍋"
        },

        # =========================================================================
        # 🥭 26. आम (Mango)
        # =========================================================================
        {
            "id": "mango_powdery_mildew",
            "cropId": "mango",
            "cropName": "Mango",
            "cropHindi": "आम",
            "diseaseNameHindi": "आम का बौर छाछ्या (Powdery Mildew of Mango)",
            "diseaseNameEnglish": "Powdery Mildew of Mango",
            "pathogen": "फफूंद (Oidium mangiferae)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.0,
            "symptoms": [
                "मंजर (फूलों के गुच्छे) पर सफेद-धूसर चूर्ण जम जाता है।",
                "फूल और छोटे मटर दाने जैसे फल सूखकर काले होकर झड़ जाते हैं।"
            ],
            "symptomTags": ["बौर पर सफेद पाउडर", "फूल झड़ना", "आम का छाछ्या"],
            "organicRemedy": "घुलनशील सल्फर 80% WDG (2 ग्राम/लीटर) मंजर खिलने से पूर्व छिड़कें।",
            "chemicalMedicine": "हेक्साकोनाज़ोल 5% SC (कंटाफ) या डिनोकैप 48% EC",
            "sprayDosage": "हेक्साकोनाज़ोल: 1.5 मिली प्रति लीटर पानी।",
            "precautions": "फूल खिलने (पूर्ण पुष्पन) के समय अत्यधिक दबाव से स्प्रे न करें।",
            "preventionTips": ["पहला स्प्रे बौर आने पर और दूसरा फल बनने पर करें।"],
            "icon": "🥭"
        },
        {
            "id": "mango_anthracnose",
            "cropId": "mango",
            "cropName": "Mango",
            "cropHindi": "आम",
            "diseaseNameHindi": "एन्थ्रेक्नोज़ / फल चित्ती रोग",
            "diseaseNameEnglish": "Mango Anthracnose",
            "pathogen": "फफूंद (Colletotrichum gloeosporioides)",
            "severity": "गंभीर",
            "confidenceScore": 95.4,
            "symptoms": [
                "पत्तियों पर काले-भूरे धब्बे और टहनियों का सूखना।",
                "पके फलों पर बड़े-बड़े काले धंसे हुए दाग पड़ते हैं जिससे फल सड़ जाते हैं।"
            ],
            "symptomTags": ["फलों पर काले दाग", "एन्थ्रेक्नोज़", "फल सड़ना"],
            "organicRemedy": "गर्म जल उपचार (फलों को 52°C पर 5 मिनट डुबोएं)।",
            "chemicalMedicine": "अजोक्सीस्ट्रोबिन 23% SC या कॉपर ऑक्सीक्लोराइड",
            "sprayDosage": "अजोक्सीस्ट्रोबिन: 1 मिली प्रति लीटर पानी।",
            "precautions": "बरसात के मौसम में फल तुड़ाई के 15 दिन पहले स्प्रे करें।",
            "preventionTips": ["पेड़ के अंदर धूप व हवा आने हेतु कटाई-छंटाई रखें।"],
            "icon": "🥭"
        },
        {
            "id": "mango_hopper",
            "cropId": "mango",
            "cropName": "Mango",
            "cropHindi": "आम",
            "diseaseNameHindi": "आम का भुनगा / फुदका कीट (Mango Hopper)",
            "diseaseNameEnglish": "Mango Hopper",
            "pathogen": "कीट (Amritodus atkinsoni)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.8,
            "symptoms": [
                "बौर पर छोटे भूरे फुदके रस चूसते हैं जिससे मंजर सूख जाता है।",
                "कीटों के मल से चिपचिपा रस निकलता है जिस पर काली फफूंद (Sooty Mold) जम जाती है।"
            ],
            "symptomTags": ["काली फफूंद", "बौर सूखना", "चिपचिपा रस", "आम का फुदका"],
            "organicRemedy": "नीम बीज अर्क 5% या वर्टिसिलियम लेकानी 5 ग्राम/लीटर।",
            "chemicalMedicine": "इमिडाक्लोप्रिड 17.8% SL या थायमेथॉक्सम 25% WG",
            "sprayDosage": "इमिडाक्लोप्रिड: 0.5 मिली प्रति लीटर पानी।",
            "precautions": "बौर आने की प्रारंभिक अवस्था में ही छिड़काव कर दें।",
            "preventionTips": ["पेड़ के तने के आसपास छंटाई रखें।"],
            "icon": "🥭"
        },

        # =========================================================================
        # 🍈 27. अमरूद व पपीता (Guava & Papaya)
        # =========================================================================
        {
            "id": "guava_wilt",
            "cropId": "guava",
            "cropName": "Guava",
            "cropHindi": "अमरूद",
            "diseaseNameHindi": "अमरूद का उकठा रोग (Guava Wilt)",
            "diseaseNameEnglish": "Guava Wilt",
            "pathogen": "फफूंद (Fusarium oxysporum f.sp. psidii)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.2,
            "symptoms": [
                "पेड़ की एक शाखा या पूरा पेड़ अचानक पत्तियां पीली पड़कर सूखने लगता है।",
                "पत्तियां झड़ जाती हैं और फल कड़े होकर पेड़ पर ही सूख जाते हैं।"
            ],
            "symptomTags": ["पेड़ का अचानक सूखना", "उकठा रोग", "कड़े सूखे फल"],
            "organicRemedy": "ट्राइकोडर्मा विरिडी 25 ग्राम प्रति पेड़ की थाली में गोबर के साथ डालें।",
            "chemicalMedicine": "कार्बेंडाजिम 50% WP से तने के चारों ओर ड्रेन्चिंग",
            "sprayDosage": "2 ग्राम प्रति लीटर पानी से थाली की मिट्टी तर करें।",
            "precautions": "संक्रमित पेड़ की जड़ों को काटकर खेत में न फैलाएं।",
            "preventionTips": ["उकठा प्रतिरोधी रूटस्टॉक (Psidium friedrichsthalianum) का प्रयोग करें।"],
            "icon": "🍈"
        },
        {
            "id": "papaya_ringspot_virus",
            "cropId": "papaya",
            "cropName": "Papaya",
            "cropHindi": "पपीता",
            "diseaseNameHindi": "पपीता का रिंगस्पॉट वायरस (PRSV)",
            "diseaseNameEnglish": "Papaya Ringspot Virus",
            "pathogen": "एफिड द्वारा प्रसारित वायरस (Potyvirus)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.8,
            "symptoms": [
                "पत्तियों की डंडियों पर गहरे हरे रंग की तैलीय धारियां।",
                "फलों की सतह पर गोल छल्ले (Rings) बन जाते हैं और पत्तियों का आकार छोटा हो जाता है।"
            ],
            "symptomTags": ["फलों पर छल्ले", "तैलीय धारियां", "रिंगस्पॉट वायरस", "पत्ती सिकुड़ना"],
            "organicRemedy": "रोगी पौधों को तुरंत उखाड़कर नष्ट करें।",
            "chemicalMedicine": "डाइमेथोएट 30% EC या इमिडाक्लोप्रिड (वाहक माहू कीट नियंत्रण)",
            "sprayDosage": "इमिडाक्लोप्रिड: 0.5 मिली प्रति लीटर पानी।",
            "precautions": "पपीते के पास कद्दू वर्गीय फसलें न लगाएं (एफिड का घर)।",
            "preventionTips": ["किनारों पर मक्का या बाजरा की 3 कतारें बॉर्डर क्रॉप के रूप में लगाएं।"],
            "icon": "🍈"
        },

        # =========================================================================
        # 🍉 28. तरबूज, खरबूजा व कद्दू वर्ग (Cucurbits)
        # =========================================================================
        {
            "id": "watermelon_downy_mildew",
            "cropId": "watermelon",
            "cropName": "Watermelon / Muskmelon",
            "cropHindi": "तरबूज / खरबूजा",
            "diseaseNameHindi": "डाउनी मिल्ड्यू / पीला झुलसा",
            "diseaseNameEnglish": "Downy Mildew of Cucurbits",
            "pathogen": "फफूंद (Pseudoperonospora cubensis)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.5,
            "symptoms": [
                "पत्तियों की ऊपरी सतह पर नसों से बंधे कोणीय पीले धब्बे।",
                "निचली सतह पर जामुनी-धूसर फफूंदी उग आती है और बेल 2 दिन में सूख जाती है।"
            ],
            "symptomTags": ["कोणीय पीले धब्बे", "डाउनी मिल्ड्यू", "बेल सूखना", "जामुनी फफूंद"],
            "organicRemedy": "नीम तेल 5 मिली + खट्टी छाछ का साप्ताहिक छिड़काव।",
            "chemicalMedicine": "साइमोक्सानिल 8% + मैंकोजेब 64% (कर्जेट) या एमिस्टार टॉप",
            "sprayDosage": "कर्जेट: 2 ग्राम प्रति लीटर (400 ग्राम प्रति एकड़)।",
            "precautions": "बेलों के ऊपर फव्वारा सिंचाई न करें, ड्रिप से पानी दें।",
            "preventionTips": ["प्रतिरोधी हाइब्रिड किस्मों का चयन करें।"],
            "icon": "🍉"
        },
        {
            "id": "cucurbit_fruit_fly",
            "cropId": "watermelon",
            "cropName": "Cucurbits",
            "cropHindi": "तरबूज / लौकी / खीरा",
            "diseaseNameHindi": "फल मक्खी प्रकोप (Fruit Fly)",
            "diseaseNameEnglish": "Melon Fruit Fly (Bactrocera cucurbitae)",
            "pathogen": "कीट (Bactrocera cucurbitae)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.0,
            "symptoms": [
                "छोटे फलों पर मक्खी डंक मारती है जहां से भूरा गोंद निकलता है।",
                "फल अंदर से टेढ़ा होकर सड़ जाता है और उसमें सफेद कीड़े (मैगट) निकलते हैं।"
            ],
            "symptomTags": ["फलों पर डंक", "गोंद निकलना", "फल सड़ना", "फल मक्खी"],
            "organicRemedy": "मिथाइल यूजीनॉल फेरोमोन ट्रैप (क्यू-ल्योर) 10 प्रति एकड़ लगाएं।",
            "chemicalMedicine": "मैलाथियान 50% EC + गुड़ का विष प्रलोभन (Poison Bait)",
            "sprayDosage": "20 ग्राम गुड़ + 2 मिली मैलाथियान प्रति लीटर पानी का छिड़काव।",
            "precautions": "डंक लगे गिरे हुए फलों को जमीन में गहरा दबाएं।",
            "preventionTips": ["फलों को अखबार या पेपर बैग से ढकें।"],
            "icon": "🍉"
        },

        # =========================================================================
        # 🍌 29. केला (Banana)
        # =========================================================================
        {
            "id": "banana_panama_wilt",
            "cropId": "banana",
            "cropName": "Banana",
            "cropHindi": "केला",
            "diseaseNameHindi": "पनामा विल्ट / उकठा रोग",
            "diseaseNameEnglish": "Panama Wilt (Fusarium oxysporum f.sp. cubense)",
            "pathogen": "फफूंद (Fusarium oxysporum f.sp. cubense)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.8,
            "symptoms": [
                "निचली पत्तियां किनारों से पीली पड़कर डंठल के पास से लटक जाती हैं (स्कर्ट जैसी)।",
                "तने को चीरने पर संवहन बंडल लाल-भूरे रंग के सड़े दिखते हैं।"
            ],
            "symptomTags": ["पत्तियों का लटकना", "पनामा विल्ट", "तने में लाल धारी"],
            "organicRemedy": "ट्राइकोडर्मा विरिडी 50 ग्राम प्रति पौधा रोपाई के समय गड्ढे में दें।",
            "chemicalMedicine": "कार्बेंडाजिम 50% WP (2 ग्राम/लीटर) से गड्ढों की ड्रेन्चिंग",
            "sprayDosage": "जड़ों के पास 3 से 5 लीटर घोल प्रति पौधा डालें।",
            "precautions": "संक्रमित बाग से पुत्ती (Suckers) कभी न लें।",
            "preventionTips": ["टिशू कल्चर (G-9 किस्म) के रोगमुक्त पौधे लगाएं।"],
            "icon": "🍌"
        },
        {
            "id": "banana_sigatoka",
            "cropId": "banana",
            "cropName": "Banana",
            "cropHindi": "केला",
            "diseaseNameHindi": "सिगाटोका पत्ती धब्बा रोग",
            "diseaseNameEnglish": "Sigatoka Leaf Spot",
            "pathogen": "फफूंद (Mycosphaerella musicola)",
            "severity": "गंभीर",
            "confidenceScore": 95.0,
            "symptoms": [
                "पत्तियों पर नाव के आकार के पीले-भूरे धब्बे जिनके केंद्र राख जैसे होते हैं।",
                "धब्बे आपस में मिलकर पूरी पत्ती को सुखा देते हैं जिससे घौद (Bunch) छोटा रहता है।"
            ],
            "symptomTags": ["नाव जैसे धब्बे", "सिगाटोका", "पत्ती सूखना"],
            "organicRemedy": "मिनरल ऑयल (कृषि तेल) 10 मिली प्रति लीटर का छिड़काव।",
            "chemicalMedicine": "प्रोपिकोनाज़ोल 25% EC (टिल्ट) या टेबुकोनाज़ोल",
            "sprayDosage": "1 मिली प्रति लीटर + मिनरल ऑयल 10 मिली प्रति लीटर पानी।",
            "precautions": "खेत में वायु संचार हेतु अतिरिक्त पुत्तियों को काटते रहें।",
            "preventionTips": ["सूखी संक्रमित पत्तियों को काटकर नष्ट करें।"],
            "icon": "🍌"
        },

        # =========================================================================
        # 🍎 30. सेब (Apple)
        # =========================================================================
        {
            "id": "apple_scab",
            "cropId": "apple",
            "cropName": "Apple",
            "cropHindi": "सेब",
            "diseaseNameHindi": "सेब का स्कैब / पपड़ी रोग (Apple Scab)",
            "diseaseNameEnglish": "Apple Scab (Venturia inaequalis)",
            "pathogen": "फफूंद (Venturia inaequalis)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.5,
            "symptoms": [
                "पत्तियों और फलों पर मखमली जैतूनी-हरे से काले गोल धब्बे।",
                "फलों की त्वचा खुरदरी, पपड़ीदार होकर फट जाती है।"
            ],
            "symptomTags": ["जैतूनी-काले धब्बे", "पपड़ीदार फल", "फलों का फटना", "सेब स्कैब"],
            "organicRemedy": "पतझड़ के समय गिरी पत्तियों पर 5% यूरिया का छिड़काव ताकि फफूंद सड़ जाए।",
            "chemicalMedicine": "डाइफेनोकोनाज़ोल 25% EC (स्कोर) या मैंकोजेब 75% WP",
            "sprayDosage": "स्कोर: 0.3 मिली प्रति लीटर (60 मिली प्रति 200 लीटर पानी)।",
            "precautions": "कली खिलने (Pink Bud) अवस्था में पहला सुरक्षात्मक छिड़काव करें।",
            "preventionTips": ["स्कैब पूर्वानुमान प्रणाली (Mills Table) के अनुसार छिड़कें।"],
            "icon": "🍎"
        },

        # =========================================================================
        # 🌾 31. ग्वार (Guar / Cluster Bean)
        # =========================================================================
        {
            "id": "guar_bacterial_blight",
            "cropId": "guar",
            "cropName": "Guar",
            "cropHindi": "ग्वार",
            "diseaseNameHindi": "जीवाणु झुलसा / अंगमारी (Bacterial Blight of Guar)",
            "diseaseNameEnglish": "Bacterial Blight of Cluster Bean",
            "pathogen": "जीवाणु (Xanthomonas axonopodis pv. cyamopsidis)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.0,
            "symptoms": [
                "पत्तियों पर नसों से घिरे काले-भूरे कोणीय धब्बे।",
                "तना काला पड़कर लंबवत फट जाता है और पौधा झुककर सूख जाता है।"
            ],
            "symptomTags": ["कोणीय काले धब्बे", "तना फटना", "जीवाणु झुलसा"],
            "organicRemedy": "तांबे के तार वाली खट्टी छाछ का छिड़काव।",
            "chemicalMedicine": "स्ट्रेप्टोसाइक्लिन (6 ग्राम) + कॉपर ऑक्सीक्लोराइड (400 ग्राम)",
            "sprayDosage": "6 ग्राम स्ट्रेप्टोसाइक्लिन + 400 ग्राम COC प्रति एकड़।",
            "precautions": "बारिश के बाद धूप खिलते ही तुरंत छिड़काव करें।",
            "preventionTips": ["बीज उपचार स्ट्रेप्टोसाइक्लिन 1 ग्राम/10 किलो बीज करें।"],
            "icon": "🌱"
        },
        {
            "id": "guar_alternaria_leaf_spot",
            "cropId": "guar",
            "cropName": "Guar",
            "cropHindi": "ग्वार",
            "diseaseNameHindi": "आल्टरनेरिया पत्ती धब्बा रोग",
            "diseaseNameEnglish": "Alternaria Leaf Spot of Guar",
            "pathogen": "फफूंद (Alternaria cyamopsidis)",
            "severity": "मध्यम",
            "confidenceScore": 93.5,
            "symptoms": [
                "पत्तियों पर संकेन्द्री छल्लेदार गहरे भूरे गोल धब्बे।",
                "पत्तियां समय से पहले पीली होकर गिर जाती हैं।"
            ],
            "symptomTags": ["संकेन्द्री छल्ले", "भूरे धब्बे", "पत्ती गिरना"],
            "organicRemedy": "नीम तेल 5 मिली प्रति लीटर पानी।",
            "chemicalMedicine": "मैंकोजेब 75% WP (इंडोफिल) 2.5 ग्राम प्रति लीटर",
            "sprayDosage": "500 ग्राम प्रति एकड़ 200 लीटर पानी में।",
            "precautions": "फूल आने के समय रोग की निगरानी रखें।",
            "preventionTips": ["ग्वार की प्रमाणित किस्में (HG 365, RGC 936, RGC 1003) लगाएं।"],
            "icon": "🌱"
        },

        # =========================================================================
        # 🌾 32. इसबगोल (Isabgol)
        # =========================================================================
        {
            "id": "isabgol_downy_mildew",
            "cropId": "isabgol",
            "cropName": "Isabgol",
            "cropHindi": "इसबगोल",
            "diseaseNameHindi": "इसबगोल का डाउनी मिल्ड्यू / छाछ्या",
            "diseaseNameEnglish": "Downy Mildew of Isabgol",
            "pathogen": "फफूंद (Peronospora plantaginis)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.5,
            "symptoms": [
                "पत्तियों पर पीले-सफेद धब्बे और निचली सतह पर धूसर फफूंदी।",
                "बालियां निकलने से पहले ही पौधा सूखकर काला पड़ जाता है।"
            ],
            "symptomTags": ["पीले धब्बे", "धूसर फफूंदी", "इसबगोल सूखना"],
            "organicRemedy": "खट्टी छाछ 5 लीटर प्रति एकड़ छिड़कें।",
            "chemicalMedicine": "रिडोमिल गोल्ड (Metalaxyl + Mancozeb)",
            "sprayDosage": "2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
            "precautions": "ओस और बादल छाने पर बिना देरी किए पहला स्प्रे करें।",
            "preventionTips": ["प्रतिरोधी किस्में (जीआई 2) लगाएं।"],
            "icon": "🌾"
        },

        # =========================================================================
        # 🫘 33. अरंडी (Castor)
        # =========================================================================
        {
            "id": "castor_semilooper",
            "cropId": "castor",
            "cropName": "Castor",
            "cropHindi": "अरंडी",
            "diseaseNameHindi": "अरंडी की सेमीलूपर इल्ली (Castor Semilooper)",
            "diseaseNameEnglish": "Castor Semilooper (Achaea janata)",
            "pathogen": "कीट (Achaea janata)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 97.0,
            "symptoms": [
                "काली-भूरी लंबी इल्लियां लूप (कुबड़) बनाकर चलती हैं।",
                "पत्तियों की केवल नसें छोड़ती हैं और पूरे पौधे को कंकाल बना देती हैं।"
            ],
            "symptomTags": ["कुबड़ वाली इल्ली", "पत्तियों का कंकाल", "सेमीलूपर"],
            "organicRemedy": "नीम बीज अर्क 5% या 'T' आकार की चिड़िया खूंटियां 10 प्रति एकड़ लगाएं।",
            "chemicalMedicine": "क्लोरपायरीफॉस 20% EC या प्रोफेनोफॉस 50% EC",
            "sprayDosage": "प्रोफेनोफॉस: 2 मिली प्रति लीटर (400 मिली प्रति एकड़)।",
            "precautions": "इल्लियां छोटी अवस्था में ही आसानी से मरती हैं।",
            "preventionTips": ["अंडों के गुच्छों को पत्तियों से तोड़कर नष्ट करें।"],
            "icon": "🫘"
        },

        # =========================================================================
        # 🌻 34. सूरजमुखी (Sunflower)
        # =========================================================================
        {
            "id": "sunflower_head_rot",
            "cropId": "sunflower",
            "cropName": "Sunflower",
            "cropHindi": "सूरजमुखी",
            "diseaseNameHindi": "फूल सड़न / हेड रॉट (Head Rot)",
            "diseaseNameEnglish": "Rhizopus Head Rot",
            "pathogen": "फफूंद (Rhizopus oryzae)",
            "severity": "गंभीर",
            "confidenceScore": 94.0,
            "symptoms": [
                "फूल के पीछे की थाली भूरी पड़कर पिलपिली हो जाती है।",
                "फूल पर सफेद-काली रोएंदार फफूंद जमती है और दाने सड़ जाते हैं।"
            ],
            "symptomTags": ["फूल सड़न", "हेड रॉट", "पिलपिली थाली"],
            "organicRemedy": "ट्राइकोडर्मा विरिडी का फूल पर छिड़काव।",
            "chemicalMedicine": "मैंकोजेब 75% WP या कॉपर ऑक्सीक्लोराइड",
            "sprayDosage": "2.5 ग्राम प्रति लीटर पानी।",
            "precautions": "चिड़ियों या कीड़ों द्वारा फूल पर घाव होने से बचाएं।",
            "preventionTips": ["फूल खिलने के बाद पानी का भराव न होने दें।"],
            "icon": "🌻"
        },

        # =========================================================================
        # ⚪ 35. तिल (Sesame / Til)
        # =========================================================================
        {
            "id": "sesame_phyllody",
            "cropId": "sesame",
            "cropName": "Sesame",
            "cropHindi": "तिल",
            "diseaseNameHindi": "तिल का फाइलोडी / बांझपन रोग",
            "diseaseNameEnglish": "Sesame Phyllody",
            "pathogen": "फाइटोप्लाज्मा (लीफहॉपर द्वारा प्रसारित)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.5,
            "symptoms": [
                "फूलों के अंग हरी पत्तियों के गुच्छे में बदल जाते हैं (Witches' Broom)।",
                "पौधे में कोई फलियां या बीज नहीं बनते और पौधा बांझ रह जाता है।"
            ],
            "symptomTags": ["फूलों की जगह पत्तियां", "बांझ पौधा", "फाइलोडी"],
            "organicRemedy": "रोगी पौधों को देखते ही तुरंत उखाड़कर जला दें।",
            "chemicalMedicine": "इमिडाक्लोप्रिड 17.8% SL (लीफहॉपर नियंत्रण हेतु)",
            "sprayDosage": "0.5 मिली प्रति लीटर (100 मिली प्रति एकड़)।",
            "precautions": "वाहक कीड़े को बुवाई के 30 दिन के अंदर नियंत्रित करें।",
            "preventionTips": ["अंतरवर्तीय फसल के रूप में अरहर या मूंग लगाएं।"],
            "icon": "⚪"
        },

        # =========================================================================
        # 🌾 36. जौ (Barley)
        # =========================================================================
        {
            "id": "barley_covered_smut",
            "cropId": "barley",
            "cropName": "Barley",
            "cropHindi": "जौ",
            "diseaseNameHindi": "जौ का आवृत कंडुवा रोग (Covered Smut)",
            "diseaseNameEnglish": "Covered Smut of Barley",
            "pathogen": "फफूंद (Ustilago hordei)",
            "severity": "गंभीर",
            "confidenceScore": 94.0,
            "symptoms": [
                "बाली के दाने पतली पारदर्शी झिल्ली में बंद काले चूर्ण में बदल जाते हैं।",
                "कटाई-मड़ाई के समय झिल्ली फटकर काला चूर्ण स्वस्थ दानों पर चिपक जाता है।"
            ],
            "symptomTags": ["झिल्लीदार काले दाने", "कंडुवा रोग", "जौ का स्मट"],
            "organicRemedy": "बीज को बीजामृत या गोमूत्र से शोधित करके बोएं।",
            "chemicalMedicine": "थीरम 75% WS या विटावैक्स",
            "sprayDosage": "बीज उपचार: 2.5 ग्राम प्रति किलो बीज।",
            "precautions": "उपचारित बीज ही खेत में डालें।",
            "preventionTips": ["फसल चक्र अपनाएं।"],
            "icon": "🌾"
        },

        # =========================================================================
        # 🌾 37. ज्वार (Jowar / Sorghum)
        # =========================================================================
        {
            "id": "jowar_grain_smut",
            "cropId": "jowar",
            "cropName": "Jowar / Sorghum",
            "cropHindi": "ज्वार",
            "diseaseNameHindi": "दाना कंडुवा / स्मट (Grain Smut)",
            "diseaseNameEnglish": "Grain Smut of Sorghum",
            "pathogen": "फफूंद (Sphacelotheca sorghi)",
            "severity": "गंभीर",
            "confidenceScore": 94.8,
            "symptoms": [
                "बाली के कुछ या सभी दाने लम्बे-अंडाकार धूसर रंग के थैलों में बदल जाते हैं।",
                "थैली फोड़ने पर अंदर से काला कोयले जैसा चूर्ण निकलता है।"
            ],
            "symptomTags": ["धूसर थैले", "काला चूर्ण", "दाना कंडुवा"],
            "organicRemedy": "गंधक चूर्ण 4 ग्राम प्रति किलो बीज से बीज उपचार।",
            "chemicalMedicine": "कार्बेंडाजिम 50% WP (बाविस्टिन)",
            "sprayDosage": "बीज उपचार: 2 ग्राम प्रति किलो बीज।",
            "precautions": "खेत में रोग दिखने पर बालियां तोड़कर जलाएं।",
            "preventionTips": ["प्रमाणित किस्मों का चयन करें।"],
            "icon": "🌾"
        },

        # =========================================================================
        # 🫘 38. अरहर / तुअर (Pigeon Pea / Arhar)
        # =========================================================================
        {
            "id": "arhar_wilt",
            "cropId": "arhar",
            "cropName": "Pigeon Pea / Arhar",
            "cropHindi": "अरहर / तुअर",
            "diseaseNameHindi": "अरहर का उकठा रोग (Fusarium Wilt)",
            "diseaseNameEnglish": "Fusarium Wilt of Pigeon Pea",
            "pathogen": "फफूंद (Fusarium udum)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 96.5,
            "symptoms": [
                "फूल व फली आने के समय पूरा पौधा या एक तरफ की शाखाएं सूख जाती हैं।",
                "तने की छाल छीलने पर अंदर गहरी काली-बैंगनी संवहन धारियां दिखती हैं।"
            ],
            "symptomTags": ["अचानक पौधा सूखना", "तने में काली धारी", "उकठा रोग"],
            "organicRemedy": "ट्राइकोडर्मा विरिडी 2 किलो प्रति एकड़ गोबर खाद में मिलाकर दें।",
            "chemicalMedicine": "कार्बेंडाजिम 2 ग्राम/लीटर से जड़ ड्रेन्चिंग",
            "sprayDosage": "ड्रेन्चिंग: 2 ग्राम प्रति लीटर पानी।",
            "precautions": "लगातार 3 साल तक उसी खेत में अरहर न लगाएं।",
            "preventionTips": ["उकठा प्रतिरोधी किस्में (आशा / ICPL 87119, मारुति, बहार) लगाएं।"],
            "icon": "🫘"
        },
        {
            "id": "arhar_sterility_mosaic",
            "cropId": "arhar",
            "cropName": "Pigeon Pea / Arhar",
            "cropHindi": "अरहर / तुअर",
            "diseaseNameHindi": "बांझपन मोज़ेक रोग (Sterility Mosaic Disease)",
            "diseaseNameEnglish": "Sterility Mosaic Disease (SMD)",
            "pathogen": "माइट जनित वायरस (Eriophyid mite transmitted)",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 95.8,
            "symptoms": [
                "पत्तियां छोटी, हल्की हरी-पीली चितकबरी हो जाती हैं।",
                "पौधों पर फूल और फलियां बिल्कुल नहीं लगतीं, पौधा बांझ रह जाता है।"
            ],
            "symptomTags": ["बांझ पौधा", "फूल-फली न लगना", "छोटी चितकबरी पत्तियां", "एसएमडी"],
            "organicRemedy": "नीम तेल 5 मिली प्रति लीटर पानी।",
            "chemicalMedicine": "फेनाज़ाक्विन 10% EC (मैजिस्टार) या प्रोपरगाइट 57% EC",
            "sprayDosage": "फेनाज़ाक्विन: 2 मिली प्रति लीटर पानी।",
            "precautions": "शुरुआती 45 दिनों में माइट का नियंत्रण आवश्यक है।",
            "preventionTips": ["एसएमडी प्रतिरोधी किस्में लगाएं।"],
            "icon": "🫘"
        },

        # =========================================================================
        # 🫘 39. मसूर (Lentil)
        # =========================================================================
        {
            "id": "lentil_rust",
            "cropId": "lentil",
            "cropName": "Lentil",
            "cropHindi": "मसूर",
            "diseaseNameHindi": "मसूर का गेरुआ / रतुआ (Lentil Rust)",
            "diseaseNameEnglish": "Rust of Lentil (Uromyces viciae-fabae)",
            "pathogen": "फफूंद (Uromyces viciae-fabae)",
            "severity": "गंभीर",
            "confidenceScore": 94.5,
            "symptoms": [
                "पत्तियों और तनों पर छोटे भूरे-नारंगी दाने (पस्ट्यूल्स)।",
                "पत्तियां पीली पड़कर सूखती हैं और पौधा समय से पहले मर जाता है।"
            ],
            "symptomTags": ["भूरे-नारंगी दाने", "मसूर का रतुआ", "पत्ती सूखना"],
            "organicRemedy": "खट्टी छाछ 5 लीटर प्रति एकड़।",
            "chemicalMedicine": "हेक्साकोनाज़ोल 5% EC या मैंकोजेब 75% WP",
            "sprayDosage": "मैंकोजेब: 2 ग्राम प्रति लीटर पानी।",
            "precautions": "दिसंबर-जनवरी में ओस के समय निगरानी रखें।",
            "preventionTips": ["रतुआ प्रतिरोधी किस्में (पंत एल 406, पूसा वैभव) लगाएं।"],
            "icon": "🫘"
        },

        # =========================================================================
        # 🥒 40. खीरा, ककड़ी व लौकी (Cucumber & Bottle Gourd)
        # =========================================================================
        {
            "id": "cucumber_powdery_mildew",
            "cropId": "chaulai",
            "cropName": "Cucurbits / Gourds",
            "cropHindi": "खीरा / लौकी / कद्दू",
            "diseaseNameHindi": "चूर्णी फफूंद / छाछ्या रोग (Powdery Mildew)",
            "diseaseNameEnglish": "Powdery Mildew of Cucurbits",
            "pathogen": "फफूंद (Podosphaera xanthii)",
            "severity": "गंभीर",
            "confidenceScore": 96.0,
            "symptoms": [
                "पत्तियों की दोनों सतहों पर सफेद आटे जैसा चूर्ण छा जाता है।",
                "पत्तियां पीली पड़कर सूखती हैं और फल कड़वे या छोटे रह जाते हैं।"
            ],
            "symptomTags": ["सफेद पाउडर", "आटे जैसा चूर्ण", "छाछ्या रोग", "पत्ती पीली पड़ना"],
            "organicRemedy": "बेकिंग सोडा (मीठा सोडा) 5 ग्राम + 5 मिली नीम तेल प्रति लीटर पानी।",
            "chemicalMedicine": "डाइफेनोकोनाज़ोल 25% EC या अजोक्सीस्ट्रोबिन 23% SC",
            "sprayDosage": "डाइफेनोकोनाज़ोल: 0.5 मिली प्रति लीटर पानी।",
            "precautions": "बेलों को मचान (Trellis) पर चढ़ाएं ताकि जमीन से हवा लगे।",
            "preventionTips": ["रोगमुक्त संकर बीज बोएं।"],
            "icon": "🥒"
        },
        {
            "id": "gourd_mosaic_virus",
            "cropId": "chaulai",
            "cropName": "Cucurbits / Gourds",
            "cropHindi": "खीरा / लौकी / करेला",
            "diseaseNameHindi": "ककड़ी मोज़ेक वायरस (CMV)",
            "diseaseNameEnglish": "Cucumber Mosaic Virus (CMV)",
            "pathogen": "माहू / एफिड जनित वायरस",
            "severity": "अत्यंत गंभीर",
            "confidenceScore": 95.5,
            "symptoms": [
                "पत्तियों पर गहरे और हल्के हरे रंग के चितकबरे चकत्ते और पत्तियों का सिकुड़ना।",
                "फल टेढ़े-मेढ़े, खुरदुरे और गांठदार हो जाते हैं।"
            ],
            "symptomTags": ["चितकबरी पत्तियां", "गांठदार फल", "मोज़ेक वायरस", "सिकुड़ी पत्ती"],
            "organicRemedy": "नीम बीज अर्क (NSKE 5%) + 15 पीले स्टिकी ट्रैप प्रति एकड़।",
            "chemicalMedicine": "इमिडाक्लोप्रिड 17.8% SL या एसिटामिप्रिड 20% SP",
            "sprayDosage": "इमिडाक्लोप्रिड: 0.5 मिली प्रति लीटर पानी।",
            "precautions": "संक्रमित बेलों को तुरंत उखाड़कर नष्ट करें।",
            "preventionTips": ["नर्सरी में कीट जाल (Insect Net) का प्रयोग करें।"],
            "icon": "🥒"
        }
    ]

    diseases.extend(more_diseases)
    print(f"Total compiled diseases: {len(diseases)}")

    # Write to assets/data/crop_diseases.json
    output_json = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'crop_diseases.json')
    data = {
        "updatedAt": "2026-09-20",
        "totalCount": len(diseases),
        "diseases": diseases
    }
    with open(output_json, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Saved {len(diseases)} diseases to {output_json}")

    return diseases

if __name__ == '__main__':
    create_database()
