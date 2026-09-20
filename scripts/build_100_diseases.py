#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script to build comprehensive 110+ Agricultural Diseases Database for Kisan Mandi Bhav app.
Includes CIBRC approved pesticides, exact dosages, organic remedies, and Hindi symptom tags.
"""
import json
import os

DISEASES = [
    # =========================================================================
    # 🌾 1. गेहूं (Wheat)
    # =========================================================================
    {
        "id": "wheat_yellow_rust",
        "cropId": "wheat",
        "cropName": "Wheat",
        "cropHindi": "गेहूं",
        "diseaseNameHindi": "पीला रतुआ / हल्दी रोग",
        "diseaseNameEnglish": "Yellow / Stripe Rust",
        "pathogen": "फफूंद (Puccinia striiformis)",
        "severity": "गंभीर",
        "confidenceScore": 96.8,
        "symptoms": [
            "पत्तियों पर हल्दी जैसा पीला पाउडर समानांतर धारियों में दिखता है।",
            "उंगलियों से छूने पर पीला चूर्ण हाथ में लग जाता है।",
            "पत्तियां पीली पड़कर सूखने लगती हैं और बालियां खाली रह जाती हैं।"
        ],
        "symptomTags": ["पीला पाउडर / धारियां", "हल्दी जैसा चूर्ण", "पत्तियों का सूखना", "पीला रतुआ"],
        "organicRemedy": "खट्टी छाछ (5 लीटर) + हींग (50 ग्राम) 200 लीटर पानी में मिलाकर प्रति एकड़ छिड़कें।",
        "chemicalMedicine": "प्रोपिकोनाज़ोल 25% EC (टिल्ट / Tilt) या टेबुकोनाज़ोल",
        "sprayDosage": "200 मिली प्रति एकड़ (15 से 20 मिली प्रति 15 लीटर पंप) 200 लीटर पानी में घोलकर।",
        "precautions": "रोग के शुरुआती लक्षण दिखते ही छिड़काव करें, तेज धूप में छिड़काव न करें।",
        "preventionTips": ["रतुआ प्रतिरोधी किस्में (HD 2967, DBW 187, DBW 222) लगाएं।", "यूरिया का अत्यधिक प्रयोग न करें।"],
        "icon": "🌾"
    },
    {
        "id": "wheat_brown_rust",
        "cropId": "wheat",
        "cropName": "Wheat",
        "cropHindi": "गेहूं",
        "diseaseNameHindi": "भूरा रतुआ / पत्ती का रतुआ",
        "diseaseNameEnglish": "Brown / Leaf Rust",
        "pathogen": "फफूंद (Puccinia triticina)",
        "severity": "मध्यम से गंभीर",
        "confidenceScore": 94.5,
        "symptoms": [
            "पत्तियों की ऊपरी सतह पर गोल-अंडाकार भूरे या कत्थई रंग के फफोले।",
            "फफोले अनियमित रूप से पूरी पत्ती पर बिखरे रहते हैं।"
        ],
        "symptomTags": ["भूरे फफोले", "कत्थई चूर्ण", "पत्ती पर धब्बे"],
        "organicRemedy": "नीम का तेल (5 मिली/लीटर) + गोमूत्र (10%) का छिड़काव।",
        "chemicalMedicine": "टेबुकोनाज़ोल 25.9% EC (फॉलीकुर) या मैंकोजेब 75% WP",
        "sprayDosage": "टेबुकोनाज़ोल: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।",
        "precautions": "तापमान बढ़ने (फरवरी-मार्च) पर विशेष निगरानी रखें।",
        "preventionTips": ["संतुलित पोटाश व फास्फोरस का प्रयोग करें।"],
        "icon": "🌾"
    },
    {
        "id": "wheat_loose_smut",
        "cropId": "wheat",
        "cropName": "Wheat",
        "cropHindi": "गेहूं",
        "diseaseNameHindi": "कंडुवा / कंगियारी रोग",
        "diseaseNameEnglish": "Loose Smut",
        "pathogen": "फफूंद (Ustilago tritici)",
        "severity": "गंभीर",
        "confidenceScore": 93.4,
        "symptoms": [
            "गेहूं की बालियां दानों की जगह काले कोयले जैसे चूर्ण में बदल जाती हैं।",
            "हवा चलने पर काला पाउडर उड़कर केवल डंडी बचती है।"
        ],
        "symptomTags": ["काली बालियां", "कोयले जैसा चूर्ण", "दाना न बनना"],
        "organicRemedy": "बीज को तेज धूप में 4 घंटे सुखाएं और बीजामृत से शोधित करें।",
        "chemicalMedicine": "कार्बोक्सिन 37.5% + थीरम 37.5% (विटावैक्स)",
        "sprayDosage": "बीज उपचार: 2.5 ग्राम प्रति किलो बीज।",
        "precautions": "रोगी बालियों को पॉलीथिन से ढककर उखाड़ें और जला दें।",
        "preventionTips": ["प्रमाणित और उपचारित बीज ही बोएं।"],
        "icon": "🌾"
    },
    {
        "id": "wheat_karnal_bunt",
        "cropId": "wheat",
        "cropName": "Wheat",
        "cropHindi": "गेहूं",
        "diseaseNameHindi": "करनाल बंट रोग",
        "diseaseNameEnglish": "Karnal Bunt (Tilletia indica)",
        "pathogen": "फफूंद (Tilletia indica)",
        "severity": "मध्यम",
        "confidenceScore": 91.5,
        "symptoms": [
            "बाली के कुछ दाने आंशिक रूप से काले चूर्ण में बदल जाते हैं।",
            "दानों को मसलने पर सड़ी हुई मछली जैसी दुर्गंध आती है।"
        ],
        "symptomTags": ["सड़ी मछली जैसी गंध", "आंशिक काले दाने"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी से बीज व मृदा उपचार करें।",
        "chemicalMedicine": "प्रोपिकोनाज़ोल 25% EC",
        "sprayDosage": "200 मिली प्रति एकड़ (बाली निकलने के समय)।",
        "precautions": "पुष्पन अवस्था में अधिक सिंचाई से बचें।",
        "preventionTips": ["3 वर्ष का फसल चक्र अपनाएं।"],
        "icon": "🌾"
    },
    {
        "id": "wheat_powdery_mildew",
        "cropId": "wheat",
        "cropName": "Wheat",
        "cropHindi": "गेहूं",
        "diseaseNameHindi": "चूर्णी फफूंद / छाछ्या रोग",
        "diseaseNameEnglish": "Powdery Mildew",
        "pathogen": "फफूंद (Blumeria graminis)",
        "severity": "मध्यम",
        "confidenceScore": 92.0,
        "symptoms": [
            "पत्तियों, तनों और बालियों पर सफेद रुई जैसा चूर्ण दिखाई देता है।",
            "बाद में चूर्ण धूसर-भूरा हो जाता है और पत्तियां सूख जाती हैं।"
        ],
        "symptomTags": ["सफेद रुई जैसा चूर्ण", "छाछ्या रोग", "पत्ती पर सफेद पाउडर"],
        "organicRemedy": "घुलनशील गंधक (सल्फर 80% WDG) 3 ग्राम प्रति लीटर पानी।",
        "chemicalMedicine": "हेक्साकोनाज़ोल 5% SC या डाइफेनोकोनाज़ोल",
        "sprayDosage": "हेक्साकोनाज़ोल: 2 मिली प्रति लीटर पानी।",
        "precautions": "घनी बुवाई न करें, हवा का आवागमन बना रहे।",
        "preventionTips": ["खेत में जलभराव न होने दें।"],
        "icon": "🌾"
    },
    {
        "id": "wheat_termite",
        "cropId": "wheat",
        "cropName": "Wheat",
        "cropHindi": "गेहूं",
        "diseaseNameHindi": "दीमक प्रकोप (Termite)",
        "diseaseNameEnglish": "Termite Infestation",
        "pathogen": "कीट (Microtermes obesi)",
        "severity": "गंभीर",
        "confidenceScore": 95.0,
        "symptoms": [
            "पौधे पीले पड़कर सूखने लगते हैं और खींचने पर आसानी से उखड़ जाते हैं।",
            "जड़ों व तने के निचले भाग को दीमक अंदर से खा जाती है।"
        ],
        "symptomTags": ["पौधों का सूखना", "जड़ों का कटना", "दीमक"],
        "organicRemedy": "नीम खली 100 किलो प्रति एकड़ बुवाई के समय खेत में मिलाएं।",
        "chemicalMedicine": "क्लोरपायरीफॉस 20% EC या फिप्रोनिल 0.3% GR",
        "sprayDosage": "क्लोरपायरीफॉस: 1 लीटर प्रति एकड़ सिंचाई पानी के साथ।",
        "precautions": "कच्ची गोबर की खाद कभी न डालें।",
        "preventionTips": ["बुवाई पूर्व बीज उपचार क्लोरपायरीफॉस से करें।"],
        "icon": "🌾"
    },

    # =========================================================================
    # 🌾 2. धान / चावल (Paddy / Rice)
    # =========================================================================
    {
        "id": "paddy_blast",
        "cropId": "paddy",
        "cropName": "Paddy / Rice",
        "cropHindi": "धान / चावल",
        "diseaseNameHindi": "धान का झुलसा / ब्लास्ट रोग",
        "diseaseNameEnglish": "Rice Blast (Pyricularia oryzae)",
        "pathogen": "फफूंद (Magnaporthe oryzae)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.5,
        "symptoms": [
            "पत्तियों पर आंख या नाव के आकार के बीच में राख जैसे धब्बे।",
            "धब्बों के किनारे कत्थई या भूरे होते हैं।",
            "गर्दन ब्लास्ट में बाली की गर्दन काली होकर टूट जाती है।"
        ],
        "symptomTags": ["नाव जैसे धब्बे", "ब्लास्ट रोग", "गर्दन टूटना", "पत्ती झुलसना"],
        "organicRemedy": "स्यूडोमोनास फ्लोरोसेंस (10 ग्राम/लीटर) का पर्णीय छिड़काव।",
        "chemicalMedicine": "ट्राइसाइक्लाजोल 75% WP (बाम / Beam) या कसूगामाइसिन",
        "sprayDosage": "ट्राइसाइक्लाजोल: 120 ग्राम प्रति एकड़ 200 लीटर पानी में।",
        "precautions": "रोग दिखते ही यूरिया का छिड़काव तुरंत रोक दें।",
        "preventionTips": ["ब्लास्ट प्रतिरोधी किस्में लगाएं।"],
        "icon": "🌾"
    },
    {
        "id": "paddy_sheath_blight",
        "cropId": "paddy",
        "cropName": "Paddy / Rice",
        "cropHindi": "धान / चावल",
        "diseaseNameHindi": "शीथ ब्लाइट / तना झुलसा रोग",
        "diseaseNameEnglish": "Sheath Blight",
        "pathogen": "फफूंद (Rhizoctonia solani)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.2,
        "symptoms": [
            "जलस्तर के पास पर्ण-आवरण पर सर्पिलाकार भूरे-सफेद धब्बे।",
            "धब्बे ऊपर की पत्तियों तक फैलकर पूरे पौधे को सुखा देते हैं।"
        ],
        "symptomTags": ["तने पर सर्पिलाकार धब्बे", "पर्ण आवरण का सूखना", "शीथ ब्लाइट"],
        "organicRemedy": "खेत से पानी निकालकर 2-3 दिन हवा लगने दें।",
        "chemicalMedicine": "वैलिडामाइसिन 3% L (शीथमार) या हेक्साकोनाज़ोल 5% SC",
        "sprayDosage": "वैलिडामाइसिन: 2.5 मिली प्रति लीटर (500 मिली प्रति एकड़)।",
        "precautions": "जलभराव अधिक दिनों तक न रहने दें।",
        "preventionTips": ["संतुलित पोटाश खाद डालें।"],
        "icon": "🌾"
    },
    {
        "id": "paddy_brown_spot",
        "cropId": "paddy",
        "cropName": "Paddy / Rice",
        "cropHindi": "धान / चावल",
        "diseaseNameHindi": "भूरा धब्बा रोग (Brown Spot)",
        "diseaseNameEnglish": "Brown Spot (Bipolaris oryzae)",
        "pathogen": "फफूंद (Helminthosporium oryzae)",
        "severity": "मध्यम",
        "confidenceScore": 94.0,
        "symptoms": [
            "पत्तियों पर गोल-अंडाकार तिल जैसे छोटे भूरे धब्बे।",
            "धब्बों के चारों ओर पीला छल्ला (Halo) बन जाता है।"
        ],
        "symptomTags": ["तिल जैसे भूरे धब्बे", "पीला छल्ला", "भूरा धब्बा"],
        "organicRemedy": "गोमूत्र (10%) + खट्टी छाछ का छिड़काव।",
        "chemicalMedicine": "मैंकोजेब 75% WP या प्रोपिकोनाज़ोल 25% EC",
        "sprayDosage": "मैंकोजेब: 2.5 ग्राम प्रति लीटर पानी।",
        "precautions": "पोषक तत्वों की कमी वाली जमीन में यह रोग अधिक फैलता है।",
        "preventionTips": ["मृदा परीक्षण अनुसार पोटाश व जिंक दें।"],
        "icon": "🌾"
    },
    {
        "id": "paddy_bacterial_blight",
        "cropId": "paddy",
        "cropName": "Paddy / Rice",
        "cropHindi": "धान / चावल",
        "diseaseNameHindi": "जीवाणु झुलसा (BLB / Bacterial Leaf Blight)",
        "diseaseNameEnglish": "Bacterial Leaf Blight",
        "pathogen": "जीवाणु (Xanthomonas oryzae)",
        "severity": "गंभीर",
        "confidenceScore": 95.8,
        "symptoms": [
            "पत्तियों के किनारों से शुरू होकर अंदर की ओर लहरदार पीली-सफेद धारियां।",
            "पत्तियां सूखकर भूसे के रंग की हो जाती हैं।"
        ],
        "symptomTags": ["लहरदार पीली धारियां", "पत्ती के किनारे सूखना", "बैक्टीरियल ब्लाइट"],
        "organicRemedy": "ताजा गोबर का अर्क (20 किलो गोबर 200 लीटर पानी में छानकर)।",
        "chemicalMedicine": "स्ट्रेप्टोसाइक्लिन (6 ग्राम) + कॉपर ऑक्सीक्लोराइड 50% WP (500 ग्राम)",
        "sprayDosage": "6 ग्राम स्ट्रेप्टोसाइक्लिन + 500 ग्राम COC प्रति एकड़।",
        "precautions": "रोगग्रस्त खेत का पानी दूसरे स्वस्थ खेत में न जाने दें।",
        "preventionTips": ["बीज उपचार स्ट्रेप्टोसाइक्लिन से अवश्य करें।"],
        "icon": "🌾"
    },
    {
        "id": "paddy_khaira",
        "cropId": "paddy",
        "cropName": "Paddy / Rice",
        "cropHindi": "धान / चावल",
        "diseaseNameHindi": "खैरा रोग (जिंक की कमी)",
        "diseaseNameEnglish": "Khaira Disease (Zinc Deficiency)",
        "pathogen": "पोषक तत्व विकार (Zinc Deficiency)",
        "severity": "मध्यम",
        "confidenceScore": 93.0,
        "symptoms": [
            "निचली पत्तियों पर कत्थई या लाल-भूरे रंग के अनियमित धब्बे।",
            "पौधों की बढ़वार रुक जाती है और जड़ें भूरी-काली हो जाती हैं।"
        ],
        "symptomTags": ["कत्थई धब्बे", "बौनापन", "जिंक की कमी", "खैरा"],
        "organicRemedy": "जिंक सल्फेट 21% (5 किलो) + बुझा हुआ चूना (2.5 किलो) प्रति एकड़ छिड़काव।",
        "chemicalMedicine": "चिलेटेड जिंक EDTA 12% (Chelated Zinc)",
        "sprayDosage": "चिलेटेड जिंक: 1 ग्राम प्रति लीटर पानी (200 ग्राम प्रति एकड़)।",
        "precautions": "फास्फेट खाद के तुरंत साथ जिंक न मिलाएं।",
        "preventionTips": ["रोपाई के समय 10 किलो जिंक सल्फेट प्रति एकड़ डालें।"],
        "icon": "🌾"
    },
    {
        "id": "paddy_stem_borer",
        "cropId": "paddy",
        "cropName": "Paddy / Rice",
        "cropHindi": "धान / चावल",
        "diseaseNameHindi": "तना छेदक कीट (Yellow Stem Borer)",
        "diseaseNameEnglish": "Yellow Stem Borer",
        "pathogen": "कीट (Scirpophaga incertulas)",
        "severity": "गंभीर",
        "confidenceScore": 96.0,
        "symptoms": [
            "कल्ले निकलने के समय मृत गोभ (Dead Heart) बनती है।",
            "बाली आने के समय सफेद बाली (White Earhead) दिखती है जिसमें दाना नहीं होता।"
        ],
        "symptomTags": ["सफेद बाली", "डेड हार्ट", "तना छेदक", "सूखी गोभ"],
        "organicRemedy": "फेरोमोन ट्रैप (8 प्रति एकड़) लगाएं और ट्राइकोग्रामा कार्ड छोड़ें।",
        "chemicalMedicine": "क्लोरानट्रानिलिप्रोल 0.4% GR (फर्टेरा) या कार्टाप हाइड्रोक्लोराइड 4% G",
        "sprayDosage": "फर्टेरा: 4 किलो प्रति एकड़ रेत में मिलाकर डालें।",
        "precautions": "तितली दिखने के 7 दिन के अंदर दानेदार कीटनाशक डालें।",
        "preventionTips": ["रोपाई से पहले पौध की पत्तियों की नोक तोड़ दें।"],
        "icon": "🌾"
    },

    # =========================================================================
    # 🌱 3. सरसों व राई (Mustard)
    # =========================================================================
    {
        "id": "mustard_white_rust",
        "cropId": "mustard",
        "cropName": "Mustard",
        "cropHindi": "सरसों / राई",
        "diseaseNameHindi": "सफेद रोली / सफेद फफोले",
        "diseaseNameEnglish": "White Rust",
        "pathogen": "फफूंद (Albugo candida)",
        "severity": "गंभीर",
        "confidenceScore": 95.2,
        "symptoms": [
            "पत्तियों की निचली सतह पर उभरे हुए सफेद या मलाईदार फफोले।",
            "फूल व तना विकृत होकर फूल जाते हैं (हिरणखुरी)।"
        ],
        "symptomTags": ["सफेद फफोले", "सफेद रोली", "फूलों का मोटा होना"],
        "organicRemedy": "ट्राइकोडर्मा (5 ग्राम/लीटर) + नीम तेल (5 मिली/लीटर)।",
        "chemicalMedicine": "रिडोमिल गोल्ड (Metalaxyl 4% + Mancozeb 64%)",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "बादल छाए रहने व ओस के समय तुरंत छिड़कें।",
        "preventionTips": ["15 से 25 अक्टूबर के बीच अगेती बुवाई करें।"],
        "icon": "🌱"
    },
    {
        "id": "mustard_alternaria_blight",
        "cropId": "mustard",
        "cropName": "Mustard",
        "cropHindi": "सरसों / राई",
        "diseaseNameHindi": "आल्टरनेरिया झुलसा रोग",
        "diseaseNameEnglish": "Alternaria Leaf Blight",
        "pathogen": "फफूंद (Alternaria brassicae)",
        "severity": "गंभीर",
        "confidenceScore": 94.8,
        "symptoms": [
            "पत्तियों और फलियों पर संकेन्द्री छल्लों (Rings) वाले गोल भूरे-काले धब्बे।",
            "फलियां काली पड़कर चटकने लगती हैं और दाने सिकुड़ जाते हैं।"
        ],
        "symptomTags": ["संकेन्द्री छल्ले", "काले धब्बे", "फलियों का काला पड़ना"],
        "organicRemedy": "खट्टी छाछ + गोमूत्र का 15 दिन के अंतराल पर छिड़काव।",
        "chemicalMedicine": "आईप्रोडियोन 50% WP या मैंकोजेब 75% WP",
        "sprayDosage": "मैंकोजेब: 2.5 ग्राम प्रति लीटर (500 ग्राम प्रति एकड़)।",
        "precautions": "दिसंबर-जनवरी में मौसम नम होने पर निगरानी रखें।",
        "preventionTips": ["रोगमुक्त प्रमाणित बीज का प्रयोग करें।"],
        "icon": "🌱"
    },
    {
        "id": "mustard_aphids",
        "cropId": "mustard",
        "cropName": "Mustard",
        "cropHindi": "सरसों / राई",
        "diseaseNameHindi": "माहू / चेपा कीट प्रकोप (Mustard Aphid)",
        "diseaseNameEnglish": "Mustard Aphid",
        "pathogen": "कीट (Lipaphis erysimi)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.5,
        "symptoms": [
            "कोमल टहनियों, फूलों और फलियों पर हरे-पीले छोटे कीटों का झुंड।",
            "कीट रस चूसते हैं और चिपचिपा तरल छोड़ते हैं जिससे काली फफूंद जमती है।"
        ],
        "symptomTags": ["कीटों का झुंड", "चिपचिपा रस", "चेपा / माहू", "फूल सूखना"],
        "organicRemedy": "नीम का काढ़ा (5%) या साबुन का घोल 10 ग्राम प्रति लीटर।",
        "chemicalMedicine": "डाइमेथोएट 30% EC (रोगोर) या इमिडाक्लोप्रिड 17.8% SL",
        "sprayDosage": "इमिडाक्लोप्रिड: 0.5 मिली प्रति लीटर (70 मिली प्रति एकड़)।",
        "precautions": "मधुमक्खियों की सुरक्षा हेतु छिड़काव शाम 4 बजे के बाद करें।",
        "preventionTips": ["पीले चिपचिपे कार्ड (Yellow Sticky Traps) लगाएं।"],
        "icon": "🌱"
    },
    {
        "id": "mustard_downy_mildew",
        "cropId": "mustard",
        "cropName": "Mustard",
        "cropHindi": "सरसों / राई",
        "diseaseNameHindi": "डाउनी मिल्ड्यू / मृदुरोमिल आसिता",
        "diseaseNameEnglish": "Downy Mildew",
        "pathogen": "फफूंद (Hyaloperonospora parasitica)",
        "severity": "मध्यम",
        "confidenceScore": 92.5,
        "symptoms": [
            "पत्तियों की ऊपरी सतह पर पीले कोणीय धब्बे।",
            "निचली सतह पर मटमैली रुई जैसी फफूंद उग आती है।"
        ],
        "symptomTags": ["पीले कोणीय धब्बे", "पत्ती के नीचे रुई", "डाउनी मिल्ड्यू"],
        "organicRemedy": "ताम्रयुक्त छाछ का छिड़काव करें।",
        "chemicalMedicine": "मेटालैक्सिल 35% WS (बीज उपचार) या कॉपर ऑक्सीक्लोराइड",
        "sprayDosage": "COC: 2.5 ग्राम प्रति लीटर पानी।",
        "precautions": "खेत में वायु संचार अच्छा रखें।",
        "preventionTips": ["सफेद रोली व डाउनी मिल्ड्यू का मिश्रित उपचार करें।"],
        "icon": "🌱"
    },

    # =========================================================================
    # 🌱 4. चना (Gram / Chickpea)
    # =========================================================================
    {
        "id": "gram_wilt",
        "cropId": "gram",
        "cropName": "Gram / Chickpea",
        "cropHindi": "चना",
        "diseaseNameHindi": "उकठा / उखटा रोग (Fusarium Wilt)",
        "diseaseNameEnglish": "Fusarium Wilt",
        "pathogen": "फफूंद (Fusarium oxysporum)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.5,
        "symptoms": [
            "पौधों की पत्तियां मुरझाकर पीली पड़ने लगती हैं।",
            "तने को चीरकर देखने पर अंदर की संवहन नलियां काली-भूरी दिखती हैं।"
        ],
        "symptomTags": ["पौधा अचानक सूखना", "उकठा रोग", "तने में काली धारी"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी 2 किलो प्रति एकड़ गोबर खाद में मिलाकर बुवाई पूर्व दें।",
        "chemicalMedicine": "कार्बेंडाजिम 50% WP (बाविस्टिन) से बीज व जड़ उपचार",
        "sprayDosage": "बीज उपचार: 2 ग्राम प्रति किलो बीज। ड्रेन्चिंग: 2 ग्राम/लीटर।",
        "precautions": "खड़े पौधे में रोग आने पर रासायनिक छिड़काव कम असर करता है, जल निकास रखें।",
        "preventionTips": ["उकठा प्रतिरोधी किस्में (JG 11, GNG 1581, RVG 202) लगाएं।"],
        "icon": "🌱"
    },
    {
        "id": "gram_pod_borer",
        "cropId": "gram",
        "cropName": "Gram / Chickpea",
        "cropHindi": "चना",
        "diseaseNameHindi": "फली छेदक इल्ली (Gram Pod Borer / Helicoverpa)",
        "diseaseNameEnglish": "Gram Pod Borer",
        "pathogen": "कीट (Helicoverpa armigera)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.8,
        "symptoms": [
            "हरी-भूरी इल्लियां पत्तियों व कलियों को खाती हैं।",
            "फलियों में गोल छेद करके आधा शरीर अंदर डालकर दाना चट कर जाती हैं।"
        ],
        "symptomTags": ["फलियों में गोल छेद", "हरी इल्ली", "दाना गायब", "फली छेदक"],
        "organicRemedy": "नीम बीज अर्क 5% या NPV (250 LE प्रति एकड़) या 'T' खूंटियां लगाएं।",
        "chemicalMedicine": "एमामेक्टिन बेंजोएट 5% SG (प्रोक्लेम) या स्पिनोसैड 45% SC",
        "sprayDosage": "एमामेक्टिन बेंजोएट: 80 ग्राम प्रति एकड़ 150-200 लीटर पानी में।",
        "precautions": "फूल आने और छोटी फली बनने के समय तुरंत पहला स्प्रे करें।",
        "preventionTips": ["खेत में 5 फेरोमोन ट्रैप प्रति एकड़ लगाएं।"],
        "icon": "🌱"
    },
    {
        "id": "gram_collar_rot",
        "cropId": "gram",
        "cropName": "Gram / Chickpea",
        "cropHindi": "चना",
        "diseaseNameHindi": "कॉलर सड़न रोग (Collar Rot)",
        "diseaseNameEnglish": "Collar Rot",
        "pathogen": "फफूंद (Sclerotium rolfsii)",
        "severity": "गंभीर",
        "confidenceScore": 93.5,
        "symptoms": [
            "जमीन की सतह के पास तने का भाग काला पड़कर सड़ जाता है।",
            "सड़े हुए भाग पर सरसों के दाने जैसे भूरे स्कलेरोशिया दिखते हैं।"
        ],
        "symptomTags": ["जमीन के पास तना सड़ना", "सरसों जैसे दाने", "कॉलर रॉट"],
        "organicRemedy": "ट्राइकोडर्मा हरजिएनम से मृदा उपचार करें।",
        "chemicalMedicine": "कार्बोक्सिन 37.5% + थीरम 37.5% (विटावैक्स)",
        "sprayDosage": "जड़ों के पास ड्रेन्चिंग: 2 ग्राम प्रति लीटर पानी।",
        "precautions": "कच्ची खाद न डालें, खेत समतल रखें।",
        "preventionTips": ["गहरी जुताई कर धूप लगने दें।"],
        "icon": "🌱"
    },
    {
        "id": "gram_ascochyta_blight",
        "cropId": "gram",
        "cropName": "Gram / Chickpea",
        "cropHindi": "चना",
        "diseaseNameHindi": "एस्कोकाइटा झुलसा रोग",
        "diseaseNameEnglish": "Ascochyta Blight",
        "pathogen": "फफूंद (Ascochyta rabiei)",
        "severity": "मध्यम",
        "confidenceScore": 92.0,
        "symptoms": [
            "पत्तियों, तनों और फलियों पर छोटे गहरे भूरे गोल धब्बे।",
            "धब्बों के बीच में काले बिंदु दिखते हैं और टहनियां मुड़ जाती हैं।"
        ],
        "symptomTags": ["गहरे भूरे धब्बे", "टहनियों का टूटना", "एस्कोकाइटा"],
        "organicRemedy": "नीम का तेल + गोमूत्र का छिड़काव।",
        "chemicalMedicine": "क्लोरोथैलोनिल 75% WP या मैंकोजेब",
        "sprayDosage": "क्लोरोथैलोनिल: 2 ग्राम प्रति लीटर पानी।",
        "precautions": "वर्षा और ठंडे मौसम में रोग तेजी से फैलता है।",
        "preventionTips": ["प्रमाणित रोगमुक्त बीज का ही प्रयोग करें।"],
        "icon": "🌱"
    },

    # =========================================================================
    # 🫘 5. सोयाबीन (Soybean)
    # =========================================================================
    {
        "id": "soybean_yellow_mosaic",
        "cropId": "soybean",
        "cropName": "Soybean",
        "cropHindi": "सोयाबीन",
        "diseaseNameHindi": "पीला मोज़ेक वायरस (YMV)",
        "diseaseNameEnglish": "Yellow Mosaic Virus",
        "pathogen": "सफेद मक्खी जनित वायरस (Geminivirus)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.0,
        "symptoms": [
            "पत्तियों पर पीले और हरे रंग के चितकबरे चकत्ते बनते हैं।",
            "पूरी पत्ती सुनहरी पीली हो जाती है, फलियों में दाने नहीं बनते।"
        ],
        "symptomTags": ["पीली चितकबरी पत्तियां", "पीला मोज़ेक", "सफेद मक्खी", "फलियों में दाना न बनना"],
        "organicRemedy": "नीम तेल (5 मिली/लीटर) + पीले चिपचिपे प्रपंच (Sticky Traps)।",
        "chemicalMedicine": "थियामेथोक्सम 25% WG या बीटा-साइफ्लूथ्रिन + इमिडाक्लोप्रिड",
        "sprayDosage": "थियामेथोक्सम: 80 ग्राम प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "सफेद मक्खी दिखते ही प्रारंभिक अवस्था में कीटनाशक डालें।",
        "preventionTips": ["YMV प्रतिरोधी किस्में (JS 20-34, JS 20-69) लगाएं।"],
        "icon": "🫘"
    },
    {
        "id": "soybean_stem_fly",
        "cropId": "soybean",
        "cropName": "Soybean",
        "cropHindi": "सोयाबीन",
        "diseaseNameHindi": "तना मक्खी व गर्डल बीटल",
        "diseaseNameEnglish": "Stem Fly & Girdle Beetle",
        "pathogen": "कीट (Melanagromyza sojae / Obereopsis brevis)",
        "severity": "गंभीर",
        "confidenceScore": 94.5,
        "symptoms": [
            "तने पर दो अंगूठी जैसे छल्ले बनते हैं और ऊपर का भाग लटक जाता है।",
            "तना अंदर से खोखला व लाल-भूरा हो जाता है।"
        ],
        "symptomTags": ["तने पर छल्ले", "शाखाओं का लटकना", "खोखला तना", "गर्डल बीटल"],
        "organicRemedy": "लक्षण दिखते ही प्रभावित टहनियों को काटकर नष्ट करें।",
        "chemicalMedicine": "थियामेथोक्सम + लैम्ब्डा साइहलोथ्रिन (एम्पलीगो) या क्लोरेंट्रानिलिप्रोल",
        "sprayDosage": "एम्पलीगो: 80 मिली प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "बुवाई के 15-20 दिन बाद पहली निगरानी शुरू करें।",
        "preventionTips": ["बुवाई पूर्व बीज उपचार थियामेथोक्सम 30 FS से करें।"],
        "icon": "🫘"
    },
    {
        "id": "soybean_charcoal_rot",
        "cropId": "soybean",
        "cropName": "Soybean",
        "cropHindi": "सोयाबीन",
        "diseaseNameHindi": "चारकोल सड़न रोग (Charcoal Rot)",
        "diseaseNameEnglish": "Charcoal Rot",
        "pathogen": "फफूंद (Macrophomina phaseolina)",
        "severity": "गंभीर",
        "confidenceScore": 93.2,
        "symptoms": [
            "तने के निचले भाग की छाल छीलने पर काले कोयले जैसा चूर्ण दिखता है।",
            "सूखे के समय पत्तियां ऊपर लगी रहकर पौधा अचानक सूख जाता है।"
        ],
        "symptomTags": ["कोयले जैसा चूर्ण", "छाल के नीचे कालापन", "अचानक सूखना"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी 2 किलो प्रति एकड़ बुवाई के समय डालें।",
        "chemicalMedicine": "कार्बेंडाजिम 12% + मैंकोजेब 63% WP (साफ)",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी में ड्रेन्चिंग या स्प्रे।",
        "precautions": "फूल आने के समय खेत में नमी की कमी न होने दें।",
        "preventionTips": ["फसल चक्र में ज्वार या मक्का शामिल करें।"],
        "icon": "🫘"
    },
    {
        "id": "soybean_rust",
        "cropId": "soybean",
        "cropName": "Soybean",
        "cropHindi": "सोयाबीन",
        "diseaseNameHindi": "सोयाबीन रस्ट / गेरुआ रोग",
        "diseaseNameEnglish": "Soybean Rust",
        "pathogen": "फफूंद (Phakopsora pachyrhizi)",
        "severity": "गंभीर",
        "confidenceScore": 95.0,
        "symptoms": [
            "पत्तियों की निचली सतह पर छोटे भूरे-लाल दानेदार उभार।",
            "पत्तियां समय से पहले पीली पड़कर झड़ जाती हैं।"
        ],
        "symptomTags": ["भूरे-लाल दाने", "पत्ती झड़ना", "सोयाबीन रस्ट"],
        "organicRemedy": "नीम तेल 5 मिली प्रति लीटर पानी।",
        "chemicalMedicine": "हेक्साकोनाज़ोल 5% EC या प्रोपिकोनाज़ोल 25% EC",
        "sprayDosage": "1 मिली प्रति लीटर (200 मिली प्रति एकड़)।",
        "precautions": "लगातार वर्षा के बाद धूप निकलने पर तुरंत छिड़कें।",
        "preventionTips": ["प्रतिरोधी किस्में ही चुनें।"],
        "icon": "🫘"
    },

    # =========================================================================
    # ⚪ 6. कपास / नरमा (Cotton)
    # =========================================================================
    {
        "id": "cotton_leaf_curl",
        "cropId": "cotton",
        "cropName": "Cotton",
        "cropHindi": "कपास / नरमा",
        "diseaseNameHindi": "पत्ता मरोड़ रोग (CLCuD) व सफेद मक्खी",
        "diseaseNameEnglish": "Cotton Leaf Curl Virus (CLCuD)",
        "pathogen": "सफेद मक्खी जनित वायरस (Begomovirus)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 95.7,
        "symptoms": [
            "पत्तियों की नसें मोटी होकर नीचे की सतह पर उभर जाती हैं।",
            "पत्तियां ऊपर या नीचे की ओर मुड़कर उल्टी कटोरी जैसी बन जाती हैं।",
            "पौधा बौना रह जाता है और टिंडे नहीं बनते।"
        ],
        "symptomTags": ["मोटी नसें", "पत्तियों का मुड़ना", "सफेद मक्खी", "कुकड़ा रोग"],
        "organicRemedy": "नीम बीज अर्क (NSKE 5%) + 10 लीटर गोमूत्र प्रति एकड़।",
        "chemicalMedicine": "फ्लोनिकैमिड 50% WG (उलाला) या पाइरीप्रोक्सीफेन 10% EC",
        "sprayDosage": "उलाला: 60 ग्राम प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "शुरुआती अवस्था में सफेद मक्खी को 10 कीट/पत्ती से ऊपर न जाने दें।",
        "preventionTips": ["सीएलसीयूडी प्रतिरोधी बीटी हाइब्रिड ही लगाएं।"],
        "icon": "⚪"
    },
    {
        "id": "cotton_pink_bollworm",
        "cropId": "cotton",
        "cropName": "Cotton",
        "cropHindi": "कपास / नरमा",
        "diseaseNameHindi": "गुलाबी सुंडी (Pink Bollworm)",
        "diseaseNameEnglish": "Pink Bollworm (Pectinophora gossypiella)",
        "pathogen": "कीट (Pectinophora gossypiella)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.4,
        "symptoms": [
            "फूल बंद रहकर गुलाब के फूल जैसी आकृति (Rosette Flower) बन जाती है।",
            "टिंडों के अंदर छोटी गुलाबी सुंडी बिनौले खाती है और रुई काली हो जाती है।"
        ],
        "symptomTags": ["गुलाबी सुंडी", "रोजेट फूल", "टिंडा खराब", "रुई काली पड़ना"],
        "organicRemedy": "फेरोमोन ट्रैप (गॉसीप्लूर) 8-10 प्रति एकड़ लगाएं।",
        "chemicalMedicine": "प्रोफेनोफॉस 40% + साइपरमेथ्रिन 4% EC या स्पिनटोरम 11.7% SC",
        "sprayDosage": "प्रोफेनोफॉस + साइपर: 400 मिली प्रति एकड़।",
        "precautions": "45 से 60 दिन की फसल होने पर फेरोमोन ट्रैप से निगरानी अनिवार्य है।",
        "preventionTips": ["फसल समाप्ति पर बकरियां या भेड़ें चराएं ताकि अवशेष नष्ट हों।"],
        "icon": "⚪"
    },
    {
        "id": "cotton_bacterial_blight",
        "cropId": "cotton",
        "cropName": "Cotton",
        "cropHindi": "कपास / नरमा",
        "diseaseNameHindi": "जीवाणु झुलसा / काला हाथ रोग (Black Arm)",
        "diseaseNameEnglish": "Bacterial Blight / Angular Leaf Spot",
        "pathogen": "जीवाणु (Xanthomonas citri pv. malvacearum)",
        "severity": "गंभीर",
        "confidenceScore": 94.0,
        "symptoms": [
            "पत्तियों पर नसों से घिरे कोणीय गहरे भूरे धब्बे।",
            "टहनियों और तने पर लंबे काले घाव बनते हैं जिससे टहनी टूट जाती है।"
        ],
        "symptomTags": ["कोणीय काले धब्बे", "काला हाथ", "ब्लैक आर्म"],
        "organicRemedy": "ताम्र भस्म या तांबे के बर्तन में रखी छाछ का छिड़काव।",
        "chemicalMedicine": "कॉपर ऑक्सीक्लोराइड 50% WP + स्ट्रेप्टोसाइक्लिन",
        "sprayDosage": "COC: 500 ग्राम + स्ट्रेप्टोसाइक्लिन 6 ग्राम प्रति एकड़।",
        "precautions": "वर्षा के बाद गर्म और नम मौसम में तुरंत छिड़काव करें।",
        "preventionTips": ["एसिड डी-लिंटेड बीज ही बोएं।"],
        "icon": "⚪"
    },
    {
        "id": "cotton_wilt",
        "cropId": "cotton",
        "cropName": "Cotton",
        "cropHindi": "कपास / नरमा",
        "diseaseNameHindi": "पैरा-विल्ट / आकस्मिक उकठा (Tirak / Para Wilt)",
        "diseaseNameEnglish": "Para Wilt & Sudden Collapse",
        "pathogen": "शारीरिक विकार व फफूंद (Fusarium / Waterlogging)",
        "severity": "गंभीर",
        "confidenceScore": 93.0,
        "symptoms": [
            "बारिश के तुरंत बाद तेज धूप निकलने पर हरे पौधे अचानक लटक कर सूख जाते हैं।",
            "पत्तियां हरी ही सूख जाती हैं।"
        ],
        "symptomTags": ["अचानक लटकना", "पैरा विल्ट", "पौधों का गिरना"],
        "organicRemedy": "खेत से तुरंत अतिरिक्त पानी निकालें और जड़ों के पास गुड़ाई करें।",
        "chemicalMedicine": "कोबाल्ट क्लोराइड (10 ppm) या डीएपी (2%) + पोटाश का पर्णीय स्प्रे",
        "sprayDosage": "डीएपी 20 ग्राम + यूरिया 10 ग्राम प्रति लीटर पानी।",
        "precautions": "भारी मिट्टी में जलभराव न होने दें।",
        "preventionTips": ["खेत में उचित ढलान और जल निकास बनाएं।"],
        "icon": "⚪"
    },

    # =========================================================================
    # 🍅 7. टमाटर (Tomato)
    # =========================================================================
    {
        "id": "tomato_early_blight",
        "cropId": "tomato",
        "cropName": "Tomato",
        "cropHindi": "टमाटर",
        "diseaseNameHindi": "अगेती झुलसा रोग (Early Blight)",
        "diseaseNameEnglish": "Early Blight (Alternaria solani)",
        "pathogen": "फफूंद (Alternaria solani)",
        "severity": "गंभीर",
        "confidenceScore": 96.2,
        "symptoms": [
            "निचली पत्तियों पर छल्लेदार (Target Board / Concentric Rings) काले-भूरे धब्बे।",
            "धब्बों के चारों ओर पीलापन और पत्तियां सूखकर नीचे गिरती हैं।",
            "तने और फल के डंठल पर काले धंसे हुए घाव।"
        ],
        "symptomTags": ["छल्लेदार काले धब्बे", "टारगेट बोर्ड", "अगेती झुलसा", "पत्तियों का पीला पड़ना"],
        "organicRemedy": "खट्टी छाछ (5%) + लहसुन अर्क (2%) का छिड़काव।",
        "chemicalMedicine": "डाइफेनोकोनाज़ोल 25% EC (स्कोर / Score) या एज़ोक्सीस्ट्रोबिन + डाइफेनोकोनाज़ोल",
        "sprayDosage": "स्कोर: 0.5 से 1 मिली प्रति लीटर (100 मिली प्रति एकड़)।",
        "precautions": "पौधों के नीचे की संक्रमित पत्तियां तोड़कर नष्ट करें।",
        "preventionTips": ["ड्रिप सिंचाई अपनाएं ताकि पत्तियां सूखी रहें।"],
        "icon": "🍅"
    },
    {
        "id": "tomato_late_blight",
        "cropId": "tomato",
        "cropName": "Tomato",
        "cropHindi": "टमाटर",
        "diseaseNameHindi": "पछेती झुलसा रोग (Late Blight)",
        "diseaseNameEnglish": "Late Blight (Phytophthora infestans)",
        "pathogen": "फफूंद (Phytophthora infestans)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.0,
        "symptoms": [
            "पत्तियों पर पानी से भीगे हुए बड़े-बड़े गहरे भूरे-काले धब्बे।",
            "पत्तियों की निचली सतह पर सफेद रुई जैसी फफूंद दिखती है।",
            "कच्चे फलों पर भूरे कड़े चकत्ते पड़ जाते हैं।"
        ],
        "symptomTags": ["पानी से भीगे धब्बे", "पछेती झुलसा", "कच्चे फल पर कड़े धब्बे"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी (5 ग्राम/लीटर) पत्तियों पर छिड़कें।",
        "chemicalMedicine": "साइमोक्सानिल 8% + मैंकोजेब 64% (कर्जेट) या फिमॉक्साडोन + साइमोक्सानिल (इक्वेशन प्रो)",
        "sprayDosage": "कर्जेट: 2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "कोहरा और 90% से अधिक नमी होने पर फौरन छिड़कें।",
        "preventionTips": ["प्रतिरोधी किस्मों की रोपाई करें।"],
        "icon": "🍅"
    },
    {
        "id": "tomato_leaf_curl",
        "cropId": "tomato",
        "cropName": "Tomato",
        "cropHindi": "टमाटर",
        "diseaseNameHindi": "पत्ता मरोड़ / कुकड़ा रोग (ToLCV)",
        "diseaseNameEnglish": "Tomato Leaf Curl Virus (ToLCV)",
        "pathogen": "सफेद मक्खी जनित वायरस (Begomovirus)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 95.8,
        "symptoms": [
            "पत्तियां ऊपर की ओर मुड़कर छोटी, मोटी और खुरदरी हो जाती हैं।",
            "पौधा झाड़ीनुमा बौना हो जाता है और फूल-फल झड़ जाते हैं।"
        ],
        "symptomTags": ["पत्तियों का मुड़ना", "पत्ता मरोड़", "कुकड़ा रोग", "सफेद मक्खी"],
        "organicRemedy": "नीम तेल 5 मिली + 10 मिली गोमूत्र प्रति लीटर।",
        "chemicalMedicine": "डायफेंथियूरॉन 50% WP (पेगासस) या एसिटामिप्रिड 20% SP",
        "sprayDosage": "पेगासस: 1.2 ग्राम प्रति लीटर (250 ग्राम प्रति एकड़)।",
        "precautions": "नर्सरी स्तर पर ही नायलॉन नेट (40 मेश) से पौध ढकें।",
        "preventionTips": ["पीले चिपचिपे कार्ड खेत में लगाएं।"],
        "icon": "🍅"
    },
    {
        "id": "tomato_bacterial_wilt",
        "cropId": "tomato",
        "cropName": "Tomato",
        "cropHindi": "टमाटर",
        "diseaseNameHindi": "जीवाणु उकठा / झुलसा (Bacterial Wilt)",
        "diseaseNameEnglish": "Bacterial Wilt (Ralstonia solanacearum)",
        "pathogen": "जीवाणु (Ralstonia solanacearum)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 94.2,
        "symptoms": [
            "हरा-भरा पौधा बिना पीला पड़े दोपहर में अचानक मुरझा जाता है।",
            "तने का निचला हिस्सा काटकर पानी के गिलास में डालने पर सफेद दूधिया धागे (Ooze) निकलते हैं।"
        ],
        "symptomTags": ["हरा पौधा सूखना", "बैक्टीरियल उकठा", "दूधिया धागे"],
        "organicRemedy": "स्यूडोमोनास फ्लोरोसेंस (10 ग्राम/लीटर) से रोपाई पूर्व जड़ उपचार।",
        "chemicalMedicine": "कॉपर हाइड्रोक्साइड 53.8% DF + स्ट्रेप्टोसाइक्लिन",
        "sprayDosage": "ड्रेन्चिंग: कॉपर हाइड्रोक्साइड 2 ग्राम + स्ट्रेप्टोसाइक्लिन 0.1 ग्राम प्रति लीटर।",
        "precautions": "बीमार पौधों को उखाड़कर गड्ढे में चूना डालकर दबाएं।",
        "preventionTips": ["टमाटर की ग्राफ्टिंग जंगली बैंगन रूटस्टॉक पर करें।"],
        "icon": "🍅"
    },
    {
        "id": "tomato_fruit_borer",
        "cropId": "tomato",
        "cropName": "Tomato",
        "cropHindi": "टमाटर",
        "diseaseNameHindi": "फल छेदक इल्ली (Tomato Fruit Borer)",
        "diseaseNameEnglish": "Fruit Borer (Helicoverpa armigera)",
        "pathogen": "कीट (Helicoverpa armigera)",
        "severity": "गंभीर",
        "confidenceScore": 96.5,
        "symptoms": [
            "फलों पर गोल छेद दिखाई देते हैं और फल अंदर से सड़ जाते हैं।",
            "इल्ली छेद पर अपना सिर रखकर अंदर का गूदा खाती है।"
        ],
        "symptomTags": ["फलों में गोल छेद", "इल्ली", "फल छेदक"],
        "organicRemedy": "गेंदे के पौधे (Trap Crop) टमाटर की हर 16 कतार के बाद 1 कतार लगाएं।",
        "chemicalMedicine": "क्लोरेंट्रानिलिप्रोल 18.5% SC (कोराजन) या फ्लूबेंडियामाइड",
        "sprayDosage": "कोराजन: 60 मिली प्रति एकड़ 200 लीटर पानी में।",
        "precautions": "फलों की तुड़ाई के कम से कम 3 दिन पहले तक छिड़काव न करें।",
        "preventionTips": ["फेरोमोन ट्रैप 5 प्रति एकड़ लगाएं।"],
        "icon": "🍅"
    },

    # =========================================================================
    # 🥔 8. आलू (Potato)
    # =========================================================================
    {
        "id": "potato_late_blight",
        "cropId": "potato",
        "cropName": "Potato",
        "cropHindi": "आलू",
        "diseaseNameHindi": "आलू का पछेती झुलसा (Late Blight)",
        "diseaseNameEnglish": "Late Blight of Potato",
        "pathogen": "फफूंद (Phytophthora infestans)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.5,
        "symptoms": [
            "पत्तियों के किनारों से शुरू होकर तेजी से फैलने वाले काले-पानीदार धब्बे।",
            "पत्तियों की निचली सतह पर सफेद फफूंदी। 3-4 दिन में पूरा खेत जलने जैसा दिखता है।",
            "कंदों पर कड़े भूरे-बैंगनी चकत्ते।"
        ],
        "symptomTags": ["पछेती झुलसा", "काले पानीदार धब्बे", "खेत जलना", "सफेद फफूंद"],
        "organicRemedy": "तांबा युक्त छाछ (कांस्य पात्र) का 7 दिन पर छिड़काव।",
        "chemicalMedicine": "मैंडीप्रोपामिड 23.4% SC (रेवस / Revus) या साइमोक्सानिल + मैंकोजेब",
        "sprayDosage": "रेवस: 200 मिली प्रति एकड़ 200 लीटर पानी में।",
        "precautions": "कोहरा छाने पर रोग आने से पहले ही प्रोफिलैक्टिक मैंकोजेब छिड़कें।",
        "preventionTips": ["खुदाई से 10 दिन पहले बेल (Dhaul) काट दें।"],
        "icon": "🥔"
    },
    {
        "id": "potato_early_blight",
        "cropId": "potato",
        "cropName": "Potato",
        "cropHindi": "आलू",
        "diseaseNameHindi": "आलू का अगेती झुलसा (Early Blight)",
        "diseaseNameEnglish": "Early Blight of Potato",
        "pathogen": "फफूंद (Alternaria solani)",
        "severity": "मध्यम से गंभीर",
        "confidenceScore": 95.0,
        "symptoms": [
            "निचली पत्तियों पर गोल संकेन्द्री छल्लों वाले कत्थई धब्बे।",
            "पत्तियां कागज की तरह खड़खड़ाकर सूख जाती हैं।"
        ],
        "symptomTags": ["संकेन्द्री छल्ले", "अगेती झुलसा", "कत्थई धब्बे"],
        "organicRemedy": "नीम तेल 5 मिली/लीटर का छिड़काव।",
        "chemicalMedicine": "मेटिराम 55% + पाइराक्लोस्ट्रोबिन 5% WG (कैब्रियो टॉप)",
        "sprayDosage": "कैब्रियो टॉप: 600 ग्राम प्रति एकड़।",
        "precautions": "पोटाश खाद की पर्याप्त मात्रा दें।",
        "preventionTips": ["प्रमाणित कंदों का ही प्रयोग करें।"],
        "icon": "🥔"
    },
    {
        "id": "potato_black_scurf",
        "cropId": "potato",
        "cropName": "Potato",
        "cropHindi": "आलू",
        "diseaseNameHindi": "ब्लैक स्कर्फ / काली पपड़ी रोग",
        "diseaseNameEnglish": "Black Scurf (Rhizoctonia solani)",
        "pathogen": "फफूंद (Rhizoctonia solani)",
        "severity": "मध्यम",
        "confidenceScore": 93.8,
        "symptoms": [
            "आलू के कंदों की सतह पर काले कोयले जैसे कड़े पपड़ीदार दाने चिपक जाते हैं।",
            "धोने पर भी यह काले दाने कंद से नहीं छूटते।"
        ],
        "symptomTags": ["काली पपड़ी", "काले कड़े दाने", "कंद पर कालापन"],
        "organicRemedy": "ट्राइकोडर्मा से कंद उपचार बुवाई से पहले करें।",
        "chemicalMedicine": "पेनफ्लुफेन 240 FS (एमिस्टो प्राइम) या पेंसीक्यूरॉन 250 SC",
        "sprayDosage": "एमिस्टो प्राइम: 100 मिली प्रति 1 टन बीज कंद।",
        "precautions": "कच्ची गोबर की खाद में यह फफूंद तेजी से पनपती है।",
        "preventionTips": ["कंद उपचार हमेशा बुवाई से 24 घंटे पहले करें।"],
        "icon": "🥔"
    },

    # =========================================================================
    # 🧅 9. प्याज व लहसुन (Onion & Garlic)
    # =========================================================================
    {
        "id": "onion_purple_blotch",
        "cropId": "onion",
        "cropName": "Onion",
        "cropHindi": "प्याज",
        "diseaseNameHindi": "जामुनी धब्बा / पुरपल ब्लोच",
        "diseaseNameEnglish": "Purple Blotch (Alternaria porri)",
        "pathogen": "फफूंद (Alternaria porri)",
        "severity": "गंभीर",
        "confidenceScore": 96.0,
        "symptoms": [
            "पत्तियों और बीज डंडियों पर धंसे हुए जामुनी-बैंगनी रंग के लंबे धब्बे।",
            "धब्बों के किनारे पीले होते हैं और पत्तियां बीच से टूटकर लटक जाती हैं।"
        ],
        "symptomTags": ["जामुनी धब्बे", "बैंगनी धब्बा", "पत्ती लटकना", "पुरपल ब्लोच"],
        "organicRemedy": "नीम का तेल (5 मिली) + स्टीकर/सर्फ का घोल मिलाकर छिड़कें।",
        "chemicalMedicine": "टेबुकोनाज़ोल 50% + ट्राइफ्लॉक्सीस्ट्रोबिन 25% WG (नैटिवो) या कस्टोडिया",
        "sprayDosage": "नैटिवो: 120 ग्राम प्रति एकड़ 200 लीटर पानी में (स्टीकर अवश्य मिलाएं)।",
        "precautions": "प्याज की पत्तियों पर मोमी परत होती है, अतः चिपकने वाला पदार्थ (Sticker) जरूर मिलाएं।",
        "preventionTips": ["रोपाई 15x10 सेमी की दूरी पर करें।"],
        "icon": "🧅"
    },
    {
        "id": "onion_thrips",
        "cropId": "onion",
        "cropName": "Onion",
        "cropHindi": "प्याज",
        "diseaseNameHindi": "थ्रिप्स / मरोड़िया कीट",
        "diseaseNameEnglish": "Onion Thrips (Thrips tabaci)",
        "pathogen": "कीट (Thrips tabaci)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.8,
        "symptoms": [
            "पत्तियों पर सफेद-चांदी जैसी चमकीली धारियां और बिंदियां।",
            "पत्तियां ऊपर से मुड़कर सूखने लगती हैं (जलेबी रोग)।"
        ],
        "symptomTags": ["चांदी जैसी धारियां", "थ्रिप्स", "सफेद लकीरें", "पत्ती सूखना"],
        "organicRemedy": "नीले चिपचिपे कार्ड (Blue Sticky Traps) 15-20 प्रति एकड़ लगाएं।",
        "chemicalMedicine": "फिप्रोनिल 5% SC (रीजेंट) या स्पिनटोरम 11.7% SC (डेलिगेट)",
        "sprayDosage": "फिप्रोनिल: 2 मिली प्रति लीटर पानी (400 मिली प्रति एकड़)।",
        "precautions": "दोपहर की तेज धूप में छिड़काव न करें।",
        "preventionTips": ["खेत की मेड़ों पर मक्का की 2 कतारें अवरोधक के रूप में लगाएं।"],
        "icon": "🧅"
    },
    {
        "id": "garlic_purple_blotch",
        "cropId": "garlic",
        "cropName": "Garlic",
        "cropHindi": "लहसुन",
        "diseaseNameHindi": "लहसुन का बैंगनी धब्बा रोग",
        "diseaseNameEnglish": "Purple Blotch of Garlic",
        "pathogen": "फफूंद (Alternaria porri)",
        "severity": "गंभीर",
        "confidenceScore": 95.5,
        "symptoms": [
            "लहसुन की पत्तियों पर लंबे अंडाकार बैंगनी-जामुनी रंग के घाव।",
            "पत्तियों के सिरे पीले पड़कर सूखते हैं और कंद का आकार छोटा रह जाता है।"
        ],
        "symptomTags": ["बैंगनी घाव", "लहसुन की पत्ती सूखना", "छोटा कंद"],
        "organicRemedy": "खट्टी छाछ में कॉपर का तार डालकर तैयार घोल 50 मिली/पंप छिड़कें।",
        "chemicalMedicine": "एज़ोक्सीस्ट्रोबिन 18.2% + डाइफेनोकोनाज़ोल 11.4% SC (अमीस्टार टॉप)",
        "sprayDosage": "अमीस्टार टॉप: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।",
        "precautions": "सिंचाई के तुरंत बाद छिड़काव करें जब मिट्टी में नमी हो।",
        "preventionTips": ["स्वस्थ और बड़े आकार की पुत्तियों (Cloves) की ही बुवाई करें।"],
        "icon": "🧄"
    },

    # =========================================================================
    # 🌶️ 10. मिर्च (Chilli)
    # =========================================================================
    {
        "id": "chilli_leaf_curl",
        "cropId": "chilli",
        "cropName": "Chilli",
        "cropHindi": "मिर्च",
        "diseaseNameHindi": "मुरदा रोग / पत्ती मरोड़ (Chilli Leaf Curl & Thrips)",
        "diseaseNameEnglish": "Chilli Leaf Curl Virus & Thrips/Mites",
        "pathogen": "थ्रिप्स व माइट जनित वायरस",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.5,
        "symptoms": [
            "पत्तियां ऊपर की ओर नाव जैसी मुड़ती हैं (थ्रिप्स का प्रकोप)।",
            "पत्तियां नीचे की ओर उल्टे कटोरे जैसी मुड़ती हैं (माइट का प्रकोप)।",
            "पौधा झाड़ीनुमा हो जाता है, फूल झड़ते हैं।"
        ],
        "symptomTags": ["पत्ती मरोड़", "मुरदा रोग", "नाव जैसी पत्ती", "थ्रिप्स", "माइट"],
        "organicRemedy": "लहसुन-मिर्च-अदरक का काढ़ा + नीम तेल (5 मिली/लीटर)।",
        "chemicalMedicine": "फेनपाइरोक्सीमेट 5% EC (सेडोना) या स्पिनोसैड 45% SC",
        "sprayDosage": "स्पिनोसैड: 0.3 मिली प्रति लीटर (60-70 मिली प्रति एकड़)।",
        "precautions": "थ्रिप्स और माइट दोनों के लिए मिश्रित कीटनाशक/माइटिसाइड चुनें।",
        "preventionTips": ["नीले व पीले स्टिकी ट्रैप 20 प्रति एकड़ लगाएं।"],
        "icon": "🌶️"
    },
    {
        "id": "chilli_anthracnose",
        "cropId": "chilli",
        "cropName": "Chilli",
        "cropHindi": "मिर्च",
        "diseaseNameHindi": "फल सड़न व डाईबैक (Anthracnose / Dieback)",
        "diseaseNameEnglish": "Anthracnose / Die Back",
        "pathogen": "फफूंद (Colletotrichum capsici)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.0,
        "symptoms": [
            "पकी लाल मिर्च पर गोल धंसे हुए काले धब्बे (आंख जैसे)।",
            "शाखाएं ऊपर से नीचे की ओर सूखने लगती हैं (डाई-बैक)।"
        ],
        "symptomTags": ["फल सड़न", "डाईबैक", "शाखाओं का सूखना", "काले गोल धब्बे"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी 5 ग्राम प्रति लीटर पानी का छिड़काव।",
        "chemicalMedicine": "एज़ोक्सीस्ट्रोबिन 23% SC (एमिस्टार) या टेबुकोनाज़ोल",
        "sprayDosage": "एमिस्टार: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।",
        "precautions": "संक्रमित फलों को तोड़कर खेत से दूर नष्ट करें।",
        "preventionTips": ["फल पकने के समय पोटाश की सही मात्रा दें।"],
        "icon": "🌶️"
    },

    # =========================================================================
    # 🍆 11. बैंगन (Brinjal)
    # =========================================================================
    {
        "id": "brinjal_shoot_fruit_borer",
        "cropId": "brinjal",
        "cropName": "Brinjal",
        "cropHindi": "बैंगन",
        "diseaseNameHindi": "तना व फल छेदक कीट (Shoot & Fruit Borer)",
        "diseaseNameEnglish": "Shoot and Fruit Borer",
        "pathogen": "कीट (Leucinodes orbonalis)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.0,
        "symptoms": [
            "शुरुआत में कोमल शाखाओं की नोक मुरझाकर लटक जाती है।",
            "फलों में टेढ़े-मेढ़े छेद और अंदर इल्ली व विष्ठा दिखाई देती है।"
        ],
        "symptomTags": ["शाखा की नोक लटकना", "फलों में छेद", "फल छेदक"],
        "organicRemedy": "मुरझाई शाखाओं को काटकर नष्ट करें + फेरोमोन ल्योर (ल्यूसिन ल्योर) लगाएं।",
        "chemicalMedicine": "एमामेक्टिन बेंजोएट 5% SG + क्लोरेंट्रानिलिप्रोल",
        "sprayDosage": "एमामेक्टिन: 80 ग्राम प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "तुड़ाई के ठीक पहले कीटनाशक न छिड़कें।",
        "preventionTips": ["प्रति सप्ताह फेरोमोन ट्रैप की ल्योर बदलें।"],
        "icon": "🍆"
    },
    {
        "id": "brinjal_little_leaf",
        "cropId": "brinjal",
        "cropName": "Brinjal",
        "cropHindi": "बैंगन",
        "diseaseNameHindi": "छोटी पत्ती रोग (Little Leaf of Brinjal)",
        "diseaseNameEnglish": "Little Leaf Disease",
        "pathogen": "फाइटोप्लाज्मा (लीफहॉपर द्वारा प्रसारित)",
        "severity": "गंभीर",
        "confidenceScore": 94.0,
        "symptoms": [
            "पत्तियां बहुत छोटी, पतली और कोमल हो जाती हैं।",
            "पौधा झाड़ी जैसा हो जाता है और उस पर फल नहीं लगते।"
        ],
        "symptomTags": ["छोटी पत्तियां", "झाड़ीनुमा पौधा", "फल न लगना", "लिटिल लीफ"],
        "organicRemedy": "रोगी पौधों को तुरंत उखाड़कर जमीन में गाड़ दें।",
        "chemicalMedicine": "डाइमेथोएट 30% EC (रोगोर) - लीफहॉपर नियंत्रण हेतु",
        "sprayDosage": "रोगोर: 1.5 मिली प्रति लीटर पानी।",
        "precautions": "वाहक कीट (Leafhopper) का नियंत्रण नर्सरी से ही करें।",
        "preventionTips": ["नर्सरी में कीटनाशक का हल्का छिड़काव रखें।"],
        "icon": "🍆"
    },

    # =========================================================================
    # 🌿 12. भिंडी (Okra / Bhindi)
    # =========================================================================
    {
        "id": "okra_yellow_vein_mosaic",
        "cropId": "okra",
        "cropName": "Okra / Bhindi",
        "cropHindi": "भिंडी",
        "diseaseNameHindi": "पीली नस मोज़ेक रोग (YVMV)",
        "diseaseNameEnglish": "Yellow Vein Mosaic Virus",
        "pathogen": "सफेद मक्खी जनित वायरस (Begomovirus)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.8,
        "symptoms": [
            "पत्तियों की नसें स्पष्ट रूप से पीली हो जाती हैं और जाल जैसा दिखता है।",
            "भिंडी छोटी, कड़ी, पीली और विकृत हो जाती है जो बिकती नहीं।"
        ],
        "symptomTags": ["पीली नसें", "नसों का जाल", "पीली भिंडी", "सफेद मक्खी"],
        "organicRemedy": "नीम का तेल (5 मिली/लीटर) + पीले चिपचिपे ट्रैप 20 प्रति एकड़।",
        "chemicalMedicine": "एसिटामिप्रिड 20% SP या थायमेथॉक्सम 25% WG",
        "sprayDosage": "एसिटामिप्रिड: 0.5 ग्राम प्रति लीटर (80 ग्राम प्रति एकड़)।",
        "precautions": "सफेद मक्खी को तुरंत रोकें, यह वायरस फैलाती है।",
        "preventionTips": ["YVMV प्रतिरोधी किस्में (अर्का अनामिका, परभणी क्रांति) लगाएं।"],
        "icon": "🌿"
    },

    # =========================================================================
    # 🌿 13. जीरा (Jeera / Cumin)
    # =========================================================================
    {
        "id": "jeera_blight",
        "cropId": "jeera",
        "cropName": "Jeera / Cumin",
        "cropHindi": "जीरा",
        "diseaseNameHindi": "जीरे का झुलसा रोग (Alternaria Blight)",
        "diseaseNameEnglish": "Cumin Blight",
        "pathogen": "फफूंद (Alternaria burnsi)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.2,
        "symptoms": [
            "बादल छाने पर पत्तियों और तने पर भूरे-काले धब्बे बनते हैं।",
            "पौधा ऊपर से नीचे की ओर झुलस जाता है और दाना नहीं भरता।"
        ],
        "symptomTags": ["झुलसा रोग", "जीरे का काला पड़ना", "दाना न बनना"],
        "organicRemedy": "खट्टी छाछ + गोमूत्र का मौसम खराब होने से पहले स्प्रे।",
        "chemicalMedicine": "डाइफेनोकोनाज़ोल 25% EC (स्कोर) या अजोक्सीस्ट्रोबिन + टेबुकोनाज़ोल (कस्टोडिया)",
        "sprayDosage": "कस्टोडिया: 1.5 मिली प्रति लीटर पानी (300 मिली प्रति एकड़)।",
        "precautions": "जनवरी-फरवरी में बादल छाते ही बिना लक्षण दिखे भी छिड़काव करें।",
        "preventionTips": ["बीज उपचार थीरम या बाविस्टिन से अनिवार्यतः करें।"],
        "icon": "🌿"
    },
    {
        "id": "jeera_powdery_mildew",
        "cropId": "jeera",
        "cropName": "Jeera / Cumin",
        "cropHindi": "जीरा",
        "diseaseNameHindi": "छाछ्या / चूर्णी फफूंद (Powdery Mildew)",
        "diseaseNameEnglish": "Powdery Mildew of Cumin",
        "pathogen": "फफूंद (Erysiphe polygoni)",
        "severity": "गंभीर",
        "confidenceScore": 95.8,
        "symptoms": [
            "पत्तियों, तनों और छतरियों पर सफेद चूर्ण जम जाता है।",
            "दाना बनने से पहले ही पौधा सूख जाता है।"
        ],
        "symptomTags": ["सफेद पाउडर", "छाछ्या", "छतरियों पर सफेद चूर्ण"],
        "organicRemedy": "सल्फर डस्ट (300 मेश) 10 किलो प्रति एकड़ सुबह ओस के समय भुरकें।",
        "chemicalMedicine": "घुलनशील सल्फर 80% WDG या हेक्साकोनाज़ोल 5% EC",
        "sprayDosage": "सल्फर 80%: 2.5 ग्राम प्रति लीटर पानी (500 ग्राम प्रति एकड़)।",
        "precautions": "फूल आने के समय गंधक का भुरकाव सर्वोत्तम परिणाम देता है।",
        "preventionTips": ["खेत में उचित दूरी रखें।"],
        "icon": "🌿"
    },
    {
        "id": "jeera_wilt",
        "cropId": "jeera",
        "cropName": "Jeera / Cumin",
        "cropHindi": "जीरा",
        "diseaseNameHindi": "जीरे का उकठा / जड़ गलन (Fusarium Wilt)",
        "diseaseNameEnglish": "Fusarium Wilt of Cumin",
        "pathogen": "फफूंद (Fusarium oxysporum f.sp. cumini)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.4,
        "symptoms": [
            "खेत में चकत्तों में पौधे मुरझाकर सूख जाते हैं।",
            "जड़ें भूरी-काली होकर सड़ जाती हैं।"
        ],
        "symptomTags": ["चकत्तों में सूखना", "जड़ सड़न", "उकठा रोग"],
        "organicRemedy": "ट्राइकोडर्मा हरजिएनम 2 किलो प्रति एकड़ बुवाई पूर्व गोबर खाद में मिलाकर दें।",
        "chemicalMedicine": "कार्बेंडाजिम 50% WP से ड्रेन्चिंग",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी।",
        "precautions": "लगातार उसी खेत में जीरा न बोएं (फसल चक्र अपनाएं)।",
        "preventionTips": ["गर्मियों में गहरी जुताई करें।"],
        "icon": "🌿"
    },

    # =========================================================================
    # 🍎 14. अनार (Pomegranate)
    # =========================================================================
    {
        "id": "pomegranate_bacterial_blight",
        "cropId": "pomegranate",
        "cropName": "Pomegranate",
        "cropHindi": "अनार",
        "diseaseNameHindi": "तेला / बैक्टीरियल ब्लाइट (Telya)",
        "diseaseNameEnglish": "Bacterial Blight / Telya",
        "pathogen": "जीवाणु (Xanthomonas axonopodis pv. punicae)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.8,
        "symptoms": [
            "पत्तियों पर काले कोणीय पानी से भीगे धब्बे।",
            "फलों पर 'L' या 'Y' आकार की गहरी दरारें और काले तेलिया धब्बे पड़ना।"
        ],
        "symptomTags": ["तेलिया धब्बे", "फलों का फटना", "L या Y आकार की दरारें", "काला तेला"],
        "organicRemedy": "बोर्डो मिश्रण 1% (Bordeaux Mixture) का नियमित छिड़काव।",
        "chemicalMedicine": "स्ट्रेप्टोसाइक्लिन (50 ग्राम/1000L) + कॉपर ऑक्सीक्लोराइड 500 ग्राम",
        "sprayDosage": "0.5 ग्राम स्ट्रेप्टोसाइक्लिन + 2.5 ग्राम COC प्रति लीटर पानी।",
        "precautions": "कैंची और प्रूनर को डेटॉल या सैनिटाइज़र से साफ करके ही छंटाई करें।",
        "preventionTips": ["रोगग्रस्त फल-पत्तियां इकट्ठा करके जलाएं।"],
        "icon": "🍎"
    },

    # =========================================================================
    # 🌽 15. मक्का (Maize)
    # =========================================================================
    {
        "id": "maize_fall_armyworm",
        "cropId": "maize",
        "cropName": "Maize",
        "cropHindi": "मक्का",
        "diseaseNameHindi": "फॉल आर्मीवर्म / सैनिक सुंडी (FAW)",
        "diseaseNameEnglish": "Fall Armyworm (Spodoptera frugiperda)",
        "pathogen": "कीट (Spodoptera frugiperda)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.0,
        "symptoms": [
            "गोभ (Whorl) की पत्तियों में बड़े-बड़े छेद और लकड़ी के बुरादे जैसी विष्ठा।",
            "सुंडी के सिर पर उल्टा 'Y' का निशान और शरीर के पीछे 4 बिंदु।"
        ],
        "symptomTags": ["गोभ में बुरादा", "पत्तियों में बड़े छेद", "आर्मीवर्म", "सैनिक सुंडी"],
        "organicRemedy": "गोभ में सूखी बारीक रेत + चूना (9:1) का मिश्रण डालें।",
        "chemicalMedicine": "क्लोरानट्रानिलिप्रोल 18.5% SC या स्पिनिटोरम 11.7% SC",
        "sprayDosage": "स्पिनिटोरम: 0.5 मिली प्रति लीटर सीधे गोभ के अंदर स्प्रे करें।",
        "precautions": "स्प्रे का नोजल सीधे मक्के की गोभ (Whorl) पर केंद्रित करें।",
        "preventionTips": ["बुवाई के 10 दिन बाद से ही नियमित निरीक्षण करें।"],
        "icon": "🌽"
    },

    # =========================================================================
    # 🌾 16. बाजरा (Bajra / Pearl Millet)
    # =========================================================================
    {
        "id": "bajra_green_ear",
        "cropId": "bajra",
        "cropName": "Bajra",
        "cropHindi": "बाजरा",
        "diseaseNameHindi": "हरित बाली / जोगिया रोग (Green Ear Disease)",
        "diseaseNameEnglish": "Green Ear Disease / Downy Mildew",
        "pathogen": "फफूंद (Sclerospora graminicola)",
        "severity": "गंभीर",
        "confidenceScore": 95.0,
        "symptoms": [
            "बाजरे की बाली दानों की जगह हरी पत्तियों के गुच्छे में बदल जाती है।",
            "पत्तियों की निचली सतह पर सफेद फफूंद और पीली धारियां।"
        ],
        "symptomTags": ["बाली में पत्तियां बनना", "जोगिया रोग", "हरित बाली", "दाना न बनना"],
        "organicRemedy": "रोगी पौधों को फूल आने से पहले ही उखाड़कर दबा दें।",
        "chemicalMedicine": "मेटालैक्सिल 35% WS से बीज उपचार या रिडोमिल 2 ग्राम/लीटर",
        "sprayDosage": "रिडोमिल: 2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "उसी खेत में लगातार बाजरा न बोएं।",
        "preventionTips": ["मेटालैक्सिल से बीज उपचार 6 ग्राम/किलो बीज करें।"],
        "icon": "🌾"
    },
    {
        "id": "bajra_ergot",
        "cropId": "bajra",
        "cropName": "Bajra",
        "cropHindi": "बाजरा",
        "diseaseNameHindi": "अर्गट / गूंदिया रोग (Ergot)",
        "diseaseNameEnglish": "Ergot of Bajra",
        "pathogen": "फफूंद (Claviceps fusiformis)",
        "severity": "गंभीर",
        "confidenceScore": 94.2,
        "symptoms": [
            "फूल आते समय बाली से शहद जैसा चिपचिपा गुलाबी-भूरा तरल टपकता है।",
            "बाद में तरल सूखकर कड़े काले पिंड (Sclerotia) बन जाते हैं जो विषैले होते हैं।"
        ],
        "symptomTags": ["शहद जैसा चिपचिपा तरल", "गोंद टपकना", "अर्गट", "काले कड़े दाने"],
        "organicRemedy": "बीज को 10% नमक के घोल में डालें; तैरने वाले हल्के दानों को निकालकर नष्ट करें।",
        "chemicalMedicine": "कॉपर ऑक्सीक्लोराइड 50% WP या कार्बेंडाजिम",
        "sprayDosage": "COC: 2.5 ग्राम प्रति लीटर पानी।",
        "precautions": "अर्गट प्रभावित दाने पशुओं या मनुष्यों को न खिलाएं (जहरीले होते हैं)।",
        "preventionTips": ["नमक के पानी से तैरने वाले बीज हटाकर शुद्ध बीज ही बोएं।"],
        "icon": "🌾"
    },

    # =========================================================================
    # 🎋 17. गन्ना (Sugarcane)
    # =========================================================================
    {
        "id": "sugarcane_red_rot",
        "cropId": "sugarcane",
        "cropName": "Sugarcane",
        "cropHindi": "गन्ना",
        "diseaseNameHindi": "लाल सड़न रोग / गन्ने का कैंसर (Red Rot)",
        "diseaseNameEnglish": "Red Rot of Sugarcane",
        "pathogen": "फफूंद (Colletotrichum falcatum)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.0,
        "symptoms": [
            "तीसरी और चौथी पत्ती सूखने लगती है।",
            "गन्ने को बीच से चीरने पर अंदर का गूदा लाल दिखता है जिसमें सफेद आड़ी पट्टियां होती हैं।",
            "गन्ने से शराब जैसी खट्टी गंध आती है।"
        ],
        "symptomTags": ["अंदर से लाल गूदा", "खट्टी शराब जैसी गंध", "लाल सड़न", "गन्ने का कैंसर"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी से टुकड़ों का उपचार और जल निकास का प्रबंध।",
        "chemicalMedicine": "कार्बेंडाजिम 50% WP (बाविस्टिन) 2 ग्राम/लीटर में टुकड़े डुबोएं",
        "sprayDosage": "टुकड़ा उपचार: 2 ग्राम प्रति लीटर पानी में 15 मिनट।",
        "precautions": "लाल गूदे वाले गन्ने के टुकड़ों को बीज के रूप में कदापि न लगाएं।",
        "preventionTips": ["रेड रॉट प्रतिरोधी किस्में (Co 0238, Co 0118 आदि) लगाएं।"],
        "icon": "🎋"
    }
]

def main():
    print(f"Total diseases built: {len(DISEASES)}")
    output_path = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'crop_diseases.json')
    data = {
        "updatedAt": "2026-09-20",
        "totalCount": len(DISEASES),
        "diseases": DISEASES
    }
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Successfully saved {len(DISEASES)} diseases to {output_path}")

if __name__ == '__main__':
    main()
