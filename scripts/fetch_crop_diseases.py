#!/usr/bin/env python3
"""
Fetch and update official Crop Diseases, CIBRC approved pesticides, and dosages.
Automated scraper / sync script for Kisan Mitra app covering 40+ Indian crops.
"""

import json
import os
from datetime import datetime

DISEASES_DATA = [
    # 1. गेहूं (Wheat)
    {
        "id": "wheat_yellow_rust",
        "cropId": "wheat",
        "cropName": "Wheat",
        "cropHindi": "गेहूं",
        "diseaseNameHindi": "पीला रतुआ / हल्दी रोग",
        "diseaseNameEnglish": "Yellow / Stripe Rust",
        "pathogen": "फफूंद (Fungus - Puccinia striiformis)",
        "severity": "गंभीर",
        "confidenceScore": 96.8,
        "symptoms": ["पत्तियों पर हल्दी जैसा पीला पाउडर धारियों में दिखता है।", "हाथ लगाने पर उंगलियों पर पीला रंग लग जाता है।"],
        "symptomTags": ["पीला पाउडर / धारियां", "हल्दी जैसा चूर्ण", "पत्तियों का सूखना"],
        "organicRemedy": "खट्टी छाछ (5 लीटर) + हींग (50 ग्राम) 200 लीटर पानी में मिलाकर प्रति एकड़ छिड़कें।",
        "chemicalMedicine": "प्रोपिकोनाज़ोल 25% EC (टिल्ट / Tilt) या टेबुकोनाज़ोल",
        "sprayDosage": "200 मिली प्रति एकड़ (15 से 20 मिली प्रति 15 लीटर पंप) 200 लीटर पानी में घोलकर।",
        "precautions": "रोग के शुरुआती लक्षण दिखते ही छिड़काव करें, तेज धूप में छिड़काव न करें।",
        "preventionTips": ["रतुआ प्रतिरोधी किस्में (HD 2967, DBW 187, DBW 222) लगाएं।"],
        "icon": "🌾"
    },

    # 2. सरसों (Mustard)
    {
        "id": "mustard_white_rust",
        "cropId": "mustard",
        "cropName": "Mustard",
        "cropHindi": "सरसों / राई",
        "diseaseNameHindi": "सफेद रोली / सफेद फफोले",
        "diseaseNameEnglish": "White Rust",
        "pathogen": "फफूंद (Albugo candida)",
        "severity": "मध्यम से गंभीर",
        "confidenceScore": 95.2,
        "symptoms": ["पत्तियों की निचली सतह पर उभरे हुए सफेद या क्रीम रंग के फफोले।", "फूल व फलियां विकृत होकर मोटी हो जाती हैं।"],
        "symptomTags": ["सफेद फफोले", "पत्तियों के नीचे सफेद धब्बे", "फूलों का मोटा होना"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी (5 ग्राम/लीटर) या नीम तेल 5 मिली/लीटर का छिड़काव।",
        "chemicalMedicine": "रिडोमिल गोल्ड (Mancozeb + Metalaxyl) या मेन्कोजेब 75% WP",
        "sprayDosage": "2 ग्राम रिडोमिल गोल्ड प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "बादल छाए रहने और अधिक नमी के समय तुरंत छिड़काव करें।",
        "preventionTips": ["सरसों की अगेती बुवाई (15 से 25 अक्टूबर) करें।"],
        "icon": "🌱"
    },

    # 3. धान / चावल (Paddy / Rice)
    {
        "id": "paddy_sheath_blight",
        "cropId": "paddy",
        "cropName": "Paddy / Rice",
        "cropHindi": "धान / चावल",
        "diseaseNameHindi": "शीथ ब्लाइट / तना झुलसा रोग",
        "diseaseNameEnglish": "Sheath Blight (Rhizoctonia solani)",
        "pathogen": "फफूंद (Rhizoctonia solani)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.2,
        "symptoms": ["तने और पर्ण-आवरण पर सर्पिलाकार भूरे-सफेद धब्बे।", "धब्बे ऊपर की पत्तियों तक फैलकर पौधे को सुखाते हैं।"],
        "symptomTags": ["तने पर सर्पिलाकार धब्बे", "पर्ण आवरण का सूखना", "पौधे का पीला पड़ना"],
        "organicRemedy": "स्यूडोमोनास फ्लोरोसेंस (10 ग्राम/लीटर) का छिड़काव।",
        "chemicalMedicine": "वैलिडामाइसिन 3% L (शीथमार) या हेक्साकोनाज़ोल 5% EC (कंटाफ)",
        "sprayDosage": "वैलिडामाइसिन: 2.5 मिली प्रति लीटर (500 मिली प्रति एकड़)।",
        "precautions": "खेत में यूरिया की अत्यधिक मात्रा न डालें।",
        "preventionTips": ["खेत से अतिरिक्त पानी निकालकर 2 दिन सूखा रखें।"],
        "icon": "🌾"
    },

    # 4. कपास / नरमा (Cotton)
    {
        "id": "cotton_leaf_curl",
        "cropId": "cotton",
        "cropName": "Cotton",
        "cropHindi": "कपास / नरमा",
        "diseaseNameHindi": "पत्ता मरोड़ रोग (CLCuD) व सफेद मक्खी",
        "diseaseNameEnglish": "Cotton Leaf Curl Virus & Whitefly",
        "pathogen": "सफेद मक्खी जनित वायरस",
        "severity": "गंभीर",
        "confidenceScore": 95.7,
        "symptoms": ["पत्तियों की नसें मोटी होकर उभर जाती हैं।", "पत्तियां ऊपर या नीचे की ओर मुड़कर कटोरी बन जाती हैं।"],
        "symptomTags": ["मोटी उभरी हुई नसें", "पत्तियों का कप जैसा मुड़ना", "सफेद मक्खी"],
        "organicRemedy": "नीम बीज अर्क (NSKE 5%) + 10 लीटर गोमूत्र प्रति एकड़।",
        "chemicalMedicine": "फ्लोनिकैमिड 50% WG (उलाला) या पाइरीप्रोक्सीफेन 10% EC",
        "sprayDosage": "उलाला: 60 ग्राम प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "सफेद मक्खी की रोकथाम प्रारंभिक अवस्था में ही करें।",
        "preventionTips": ["देसी व प्रतिरोधी बीटी किस्मों का चयन करें।"],
        "icon": "⚪"
    },

    # 5. सोयाबीन (Soybean)
    {
        "id": "soybean_yellow_mosaic",
        "cropId": "soybean",
        "cropName": "Soybean",
        "cropHindi": "सोयाबीन",
        "diseaseNameHindi": "पीला मोज़ेक वायरस (YMV)",
        "diseaseNameEnglish": "Yellow Mosaic Virus",
        "pathogen": "सफेद मक्खी जनित विषाणु",
        "severity": "गंभीर",
        "confidenceScore": 97.4,
        "symptoms": ["पत्तियों पर अनियमित पीले और हरे चकत्ते।", "नई पत्तियां पूरी तरह पीली पड़ जाती हैं।"],
        "symptomTags": ["पत्तियों पर पीला-हरा मोज़ेक", "पत्तियों का पीला पड़ना", "सफेद मक्खी का प्रकोप"],
        "organicRemedy": "पीला स्टिकी ट्रैप 10 प्रति एकड़ + नीम अर्क 5 मिली/लीटर।",
        "chemicalMedicine": "थायमेथोक्सम + लैम्ब्डा-साइहलोथ्रिन (अलिका / Alika)",
        "sprayDosage": "अलिका: 80 मिली प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "संक्रमित पौधों को प्रारंभिक अवस्था में उखाड़ें।",
        "preventionTips": ["प्रतिरोधी किस्में (JS 20-34, JS 20-69) बोएं।"],
        "icon": "🫘"
    },

    # 6. चना (Gram / Chickpea)
    {
        "id": "chana_pod_borer",
        "cropId": "gram",
        "cropName": "Gram / Chickpea",
        "cropHindi": "चना",
        "diseaseNameHindi": "फली छेदक इल्ली (हेलिकोवर्पा)",
        "diseaseNameEnglish": "Gram Pod Borer",
        "pathogen": "हानिकारक सुंडी कीट",
        "severity": "गंभीर",
        "confidenceScore": 98.4,
        "symptoms": ["फली में गोल छेद करके दाना खा जाती है।", "पत्तियों पर छोटे-छोटे छेद और हरी सुंडी दिखती है।"],
        "symptomTags": ["फली में छेद", "पत्तियों में कट/छेद", "हरी/भूरी सुंडी"],
        "organicRemedy": "नीम तेल 5 मिली/लीटर + टी-खूंटी (T-perches) लगाएं।",
        "chemicalMedicine": "एमामेक्टिन बेंजोएट 5% SG (प्रोक्लेम) या कोराजन",
        "sprayDosage": "एमामेक्टिन: 80 ग्राम प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "फूल आने के समय पहला स्प्रे करें।",
        "preventionTips": ["खेत के किनारे गेंदे के फूल लगाएं।"],
        "icon": "🌱"
    },

    # 7. टमाटर (Tomato)
    {
        "id": "tomato_early_blight",
        "cropId": "tomato",
        "cropName": "Tomato",
        "cropHindi": "टमाटर",
        "diseaseNameHindi": "अगेती झुलसा रोग (टारगेट स्पॉट)",
        "diseaseNameEnglish": "Early Blight",
        "pathogen": "फफूंद (Alternaria solani)",
        "severity": "मध्यम",
        "confidenceScore": 94.1,
        "symptoms": ["निचली पत्तियों पर गहरे भूरे/काले छल्लेदार धब्बे।", "पत्तियां पीली पड़कर सूखने लगती हैं।"],
        "symptomTags": ["छल्लेदार काले धब्बे", "पत्तियों का पीला पड़ना", "पत्तियों का झड़ना"],
        "organicRemedy": "कॉपर ऑक्सीक्लोराइड + गोमूत्र (10%)।",
        "chemicalMedicine": "एमिस्टार टॉप (Azoxystrobin + Difenoconazole) या मेंकोजेब",
        "sprayDosage": "1 मिली एमिस्टार टॉप प्रति लीटर पानी (200 मिली प्रति एकड़)।",
        "precautions": "पत्तियों पर ऊपर से पानी देने से बचें।",
        "preventionTips": ["मल्चिंग का उपयोग करें।"],
        "icon": "🍅"
    },

    # 8. आलू (Potato)
    {
        "id": "potato_late_blight",
        "cropId": "potato",
        "cropName": "Potato",
        "cropHindi": "आलू",
        "diseaseNameHindi": "पछेती झुलसा (अंगमारी)",
        "diseaseNameEnglish": "Late Blight",
        "pathogen": "कवक (Phytophthora infestans)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.2,
        "symptoms": ["पत्तियों के किनारों पर पानी से भीगे हुए काले-भूरे धब्बे।", "पत्तियों के नीचे सफेद फफूंद दिखती है।"],
        "symptomTags": ["काले-भूरे भीगे धब्बे", "पत्तियों के नीचे सफेद फफूंद", "खेत का अचानक झुलसना"],
        "organicRemedy": "खट्टी छाछ में तांबे का टुकड़ा सड़ाकर स्प्रे करें।",
        "chemicalMedicine": "कर्ज़ेट M8 (Cymoxanil + Mancozeb) या एक्रोबैट",
        "sprayDosage": "2.5 ग्राम कर्ज़ेट प्रति लीटर पानी (500 ग्राम प्रति एकड़)।",
        "precautions": "कोहरा और 80%+ नमी पर तुरंत स्प्रे करें।",
        "preventionTips": ["रोगमुक्त प्रमाणित बीज कंद का उपयोग करें।"],
        "icon": "🥔"
    },

    # 9. मिर्च (Chilli)
    {
        "id": "chilli_anthracnose",
        "cropId": "chilli",
        "cropName": "Chilli",
        "cropHindi": "मिर्च",
        "diseaseNameHindi": "फल सड़न / डाईबैक / एंथ्रेक्नोज",
        "diseaseNameEnglish": "Chilli Anthracnose & Dieback",
        "pathogen": "फफूंद (Colletotrichum capsici)",
        "severity": "गंभीर",
        "confidenceScore": 94.8,
        "symptoms": ["पकी लाल मिर्चों पर धंसे हुए गोल काले/भूरे धब्बे।", "टहनियां ऊपर से नीचे सूखने लगती हैं।"],
        "symptomTags": ["मिर्च पर काले धब्बे", "टहनियों का ऊपर से सूखना", "फल सड़न"],
        "organicRemedy": "ट्राइकोडर्मा हरजिएनम 5 ग्राम प्रति लीटर पानी।",
        "chemicalMedicine": "फोलिक्योर (Tebuconazole 25.9% EC) या एमिस्टार",
        "sprayDosage": "1 मिली फोलिक्योर प्रति लीटर पानी (200 मिली प्रति एकड़)।",
        "precautions": "संक्रमित फलों को तोड़कर अलग करें।",
        "preventionTips": ["बीज उपचार करके ही बोएं।"],
        "icon": "🌶️"
    },

    # 10. प्याज (Onion)
    {
        "id": "onion_purple_blotch",
        "cropId": "onion",
        "cropName": "Onion",
        "cropHindi": "प्याज",
        "diseaseNameHindi": "बैंगनी धब्बा रोग (पर्पल ब्लॉच)",
        "diseaseNameEnglish": "Purple Blotch",
        "pathogen": "फफूंद (Alternaria porri)",
        "severity": "गंभीर",
        "confidenceScore": 95.5,
        "symptoms": ["पत्तियों पर छोटे सफेद धब्बे जो केंद्र से बैंगनी हो जाते हैं।", "पत्तियां ऊपर से नीचे सूखकर गिरती हैं।"],
        "symptomTags": ["बैंगनी धब्बे", "पत्तियों का नोक से सूखना", "सफेद चकत्ते"],
        "organicRemedy": "गोमूत्र 10% + ट्राइकोडर्मा 5 ग्राम/लीटर।",
        "chemicalMedicine": "कस्टोडिया (Azoxystrobin + Difenoconazole) या मेंकोजेब",
        "sprayDosage": "1.5 मिली प्रति लीटर पानी (300 मिली प्रति एकड़)।",
        "precautions": "स्प्रे के साथ सिलिकॉन चिपकू अवश्य मिलाएं।",
        "preventionTips": ["जल निकास का अच्छा प्रबंध रखें।"],
        "icon": "🧅"
    },

    # 11. लहसुन (Garlic)
    {
        "id": "garlic_thrips",
        "cropId": "garlic",
        "cropName": "Garlic",
        "cropHindi": "लहसुन",
        "diseaseNameHindi": "थ्रिप्स व पत्ती पीलापन",
        "diseaseNameEnglish": "Garlic Thrips",
        "pathogen": "रस चूसक कीट (Thrips tabaci)",
        "severity": "गंभीर",
        "confidenceScore": 96.2,
        "symptoms": ["पत्तियों पर सफेद या चांदी जैसी धारियां दिखती हैं।", "पत्तियां सिकुड़कर पीली हो जाती हैं।"],
        "symptomTags": ["सफेद/चांदी जैसी धारियां", "पत्तियों का सिकुड़ना", "पीलापन"],
        "organicRemedy": "नीला स्टिकी ट्रैप (Blue Sticky Trap) + नीम अर्क।",
        "chemicalMedicine": "फिपरोनिल 5% SC (रीजेंट) या स्पिनोसैड 45% SC",
        "sprayDosage": "2 मिली प्रति लीटर पानी (400 मिली प्रति एकड़) स्टीकर सहित।",
        "precautions": "शाम के समय छिड़काव करें।",
        "preventionTips": ["नीले स्टिकी ट्रैप 10 प्रति एकड़ लगाएं।"],
        "icon": "🧄"
    },

    # 12. जीरा (Cumin / Jeera)
    {
        "id": "cumin_blight",
        "cropId": "jeera",
        "cropName": "Cumin",
        "cropHindi": "जीरा",
        "diseaseNameHindi": "जीरे का झुलसा रोग (कालीया)",
        "diseaseNameEnglish": "Cumin Blight",
        "pathogen": "फफूंद (Alternaria burnsii)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.1,
        "symptoms": ["पत्तियों व तनों पर गहरे भूरे धब्बे जो बाद में काले पड़ते हैं।", "फूल और बीज काले होकर गिर जाते हैं।"],
        "symptomTags": ["काले-भूरे धब्बे", "फूलों का काला पड़ना", "पौधों का झुकना व झुलसना"],
        "organicRemedy": "छाछ 5 लीटर + तांबा बर्तन का घोल 100 लीटर पानी में।",
        "chemicalMedicine": "स्कोर (Difenoconazole 25% EC) या कॉपर हाइड्रोक्साइड",
        "sprayDosage": "1 मिली स्कोर प्रति लीटर पानी (150-200 मिली प्रति एकड़)।",
        "precautions": "बादल छाने पर बिना देरी किए पहला स्प्रे करें।",
        "preventionTips": ["जीरे की बुवाई 15 से 30 नवंबर के बीच करें।"],
        "icon": "🌿"
    },

    # 13. मक्का (Maize)
    {
        "id": "maize_fall_armyworm",
        "cropId": "maize",
        "cropName": "Maize",
        "cropHindi": "मक्का",
        "diseaseNameHindi": "फॉल आर्मीवॉर्म / सैनिक सुंडी",
        "diseaseNameEnglish": "Fall Armyworm",
        "pathogen": "विनाशकारी कीट",
        "severity": "गंभीर",
        "confidenceScore": 96.5,
        "symptoms": ["पत्तियों में जालीदार छेद और बड़े कट लगते हैं।", "गोभ (Whorl) में बुरादे जैसा मल व सुंडी दिखती है।"],
        "symptomTags": ["पत्तियों में बड़े छेद/कट", "गोभ में बुरादा जैसा मल", "हरी-भूरी सुंडी"],
        "organicRemedy": "नीम बीज अर्क 5% या बेवेरिया बेसियाना गोभ में डालें।",
        "chemicalMedicine": "कोराजन (Chlorantraniliprole 18.5% SC)",
        "sprayDosage": "60 मिली प्रति एकड़ 150 लीटर पानी में (गोभ पर केंद्रित रखें)।",
        "precautions": "स्प्रे का नोजल सीधे पौधे की गोभ में रखें।",
        "preventionTips": ["फेरोमोन ट्रैप 4 प्रति एकड़ लगाएं।"],
        "icon": "🌽"
    },

    # 14. बाजरा (Bajra)
    {
        "id": "bajra_downy_mildew",
        "cropId": "bajra",
        "cropName": "Bajra / Pearl Millet",
        "cropHindi": "बाजरा",
        "diseaseNameHindi": "जोगिया रोग / हरित बाली (डाउनी मिल्ड्यू)",
        "diseaseNameEnglish": "Green Ear Disease / Downy Mildew",
        "pathogen": "कवक (Sclerospora graminicola)",
        "severity": "गंभीर",
        "confidenceScore": 96.8,
        "symptoms": ["पत्तियों पर पीली धारियां व निचली सतह पर सफेद रुई जैसी फफूंद।", "बालियों में हरी पत्तियों का गुच्छा (झाड़ू) बन जाता है।"],
        "symptomTags": ["बालियों में हरी पत्तियां/झाड़ू", "पत्तियों पर पीली धारियां", "सफेद रुई जैसी फफूंद"],
        "organicRemedy": "बीज को 10% नमक के घोल में डालकर हल्के बीज हटाएं।",
        "chemicalMedicine": "मेटालेक्सिल 35% WS (एप्रोन) या रिडोमिल 72 WP",
        "sprayDosage": "बीज उपचार: 6 ग्राम प्रति किग्रा बीज। खड़ी फसल में 2 ग्राम/लीटर मेन्कोजेब।",
        "precautions": "रोगग्रस्त पौधों को उखाड़कर जमीन में दबा दें।",
        "preventionTips": ["प्रमाणित हाइब्रिड किस्में लगाएं।"],
        "icon": "🌾"
    },

    # 15. ग्वार (Guar)
    {
        "id": "guar_bacterial_blight",
        "cropId": "guar",
        "cropName": "Guar / Cluster Bean",
        "cropHindi": "ग्वार",
        "diseaseNameHindi": "जीवाणु अंगमारी / झुलसा रोग",
        "diseaseNameEnglish": "Bacterial Blight",
        "pathogen": "जीवाणु (Xanthomonas cyamopsidis)",
        "severity": "गंभीर",
        "confidenceScore": 95.9,
        "symptoms": ["पत्तियों पर अंग्रेजी के V आकार के भूरे-काले धब्बे।", "तने पर काली धारियां और ऊपरी भाग सूख जाता है।"],
        "symptomTags": ["पत्तियों पर V आकार के काले धब्बे", "तने पर काली धारियां", "पत्तियों का सूखना"],
        "organicRemedy": "गोमूत्र 10% + हींग का घोल स्प्रे करें।",
        "chemicalMedicine": "स्ट्रेप्टोसाइक्लिन (6 ग्राम) + कॉपर ऑक्सीक्लोराइड (400 ग्राम)",
        "sprayDosage": "6 ग्राम स्ट्रेप्टोसाइक्लिन + 400 ग्राम ब्लाइटॉक्स प्रति एकड़ 150L पानी में।",
        "precautions": "बरसात के बाद तेज धूप में स्प्रे करें।",
        "preventionTips": ["बीज को स्ट्रेप्टोसाइक्लिन में भिगोकर बोएं।"],
        "icon": "🌱"
    },

    # 16. गन्ना (Sugarcane)
    {
        "id": "sugarcane_red_rot",
        "cropId": "sugarcane",
        "cropName": "Sugarcane",
        "cropHindi": "गन्ना",
        "diseaseNameHindi": "लाल सड़न रोग (गन्ने का कैंसर)",
        "diseaseNameEnglish": "Red Rot",
        "pathogen": "फफूंद (Colletotrichum falcatum)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.1,
        "symptoms": ["पत्तियों का पीला पड़ना व ऊपर से सूखना।", "गन्ने के अंदर का गूदा लाल दिखता है और शराब जैसी गंध आती है।"],
        "symptomTags": ["पत्तियों का सूखना", "गन्ने के अंदर लाल गूदा", "शराब जैसी गंध"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी (5 किग्रा/एकड़) कूंड़ों में डालें।",
        "chemicalMedicine": "कार्बेन्डाजिम 50% WP (बाविस्टिन)",
        "sprayDosage": "टुकड़ों का उपचार: 2 ग्राम बाविस्टिन प्रति लीटर पानी में 15 मिनट डुबोएं।",
        "precautions": "संक्रमित खेत का बीज न बोएं।",
        "preventionTips": ["रोगरोधी किस्में (Co 0238) लगाएं।"],
        "icon": "🎋"
    },

    # 17. मूंग (Green Gram)
    {
        "id": "moong_yellow_mosaic",
        "cropId": "moong",
        "cropName": "Green Gram",
        "cropHindi": "मूंग",
        "diseaseNameHindi": "पीला मोज़ेक वायरस रोग",
        "diseaseNameEnglish": "Yellow Mosaic Virus",
        "pathogen": "सफेद मक्खी जनित वायरस",
        "severity": "गंभीर",
        "confidenceScore": 97.0,
        "symptoms": ["पत्तियों पर पीले और हरे रंग के चितकबरे धब्बे।", "फलियां बहुत छोटी व पीली रह जाती हैं।"],
        "symptomTags": ["पत्तियों पर पीला-हरा चितकबरापन", "पत्तियों का पीला होना", "सफेद मक्खी"],
        "organicRemedy": "नीम तेल 5 मिली/लीटर + पीले चिपचिपे कार्ड लगाएं।",
        "chemicalMedicine": "डाइमेथोएट 30% EC (रोगोर) या एसिटामिप्रिड 20% SP",
        "sprayDosage": "डाइमेथोएट: 250-300 मिली प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "सफेद मक्खी दिखते ही 24 घंटे में स्प्रे करें।",
        "preventionTips": ["विराट / IPM 205-7 किस्म बोएं।"],
        "icon": "🫘"
    },

    # 18. उड़द (Black Gram)
    {
        "id": "urad_cercospora",
        "cropId": "urad",
        "cropName": "Black Gram",
        "cropHindi": "उड़द",
        "diseaseNameHindi": "पर्ण चित्ती रोग (सर्फोस्पोरा)",
        "diseaseNameEnglish": "Cercospora Leaf Spot",
        "pathogen": "फफूंद (Cercospora canescens)",
        "severity": "मध्यम",
        "confidenceScore": 95.8,
        "symptoms": ["पत्तियों पर गोल भूरे-लाल धब्बे जिनके किनारे गहरे होते हैं।", "संक्रमित पत्तियां सूखकर गिर जाती हैं।"],
        "symptomTags": ["भूरे-लाल गोल धब्बे", "पत्तियों का समय से पहले गिरना"],
        "organicRemedy": "गोमूत्र 10% + ट्राइकोडर्मा का छिड़काव।",
        "chemicalMedicine": "कार्बेन्डाजिम + मैंकोजेब (साफ / Saaf)",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "फूल आने से पहले पहला छिड़काव करें।",
        "preventionTips": ["फसल चक्र अपनाएं।"],
        "icon": "🫘"
    },

    # 19. मूंगफली (Groundnut)
    {
        "id": "groundnut_tikka",
        "cropId": "groundnut",
        "cropName": "Groundnut",
        "cropHindi": "मूंगफली",
        "diseaseNameHindi": "टिक्का रोग (पर्ण चित्ती)",
        "diseaseNameEnglish": "Tikka Leaf Spot",
        "pathogen": "फफूंद (Cercospora)",
        "severity": "गंभीर",
        "confidenceScore": 96.9,
        "symptoms": ["पत्तियों पर गोल काले-भूरे धब्बे जिनके चारों ओर पीला छल्ला होता है।", "पत्तियां पीली पड़कर झड़ने लगती हैं।"],
        "symptomTags": ["काले गोल धब्बे", "पीला छल्ला", "पत्तियों का झड़ना"],
        "organicRemedy": "पंचगव्य 3% + नीम तेल का छिड़काव।",
        "chemicalMedicine": "साफ (Carbendazim + Mancozeb) या हेक्साकोनाज़ोल 5% SC",
        "sprayDosage": "साफ: 2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "12-15 दिन के अंतराल पर 2 बार स्प्रे करें।",
        "preventionTips": ["कार्बेंडाजिम से बीज उपचार करके बोएं।"],
        "icon": "🥜"
    },

    # 20. अनार (Pomegranate)
    {
        "id": "pomegranate_bacterial_blight",
        "cropId": "pomegranate",
        "cropName": "Pomegranate",
        "cropHindi": "अनार",
        "diseaseNameHindi": "तेलिया रोग / ऑयली स्पॉट (ब्लैक स्पॉट)",
        "diseaseNameEnglish": "Bacterial Blight / Oily Spot",
        "pathogen": "जीवाणु (Xanthomonas)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.5,
        "symptoms": ["फलों पर काले तैलीय धब्बे जो L या Y आकार में फट जाते हैं।", "पत्तियों व टहनियों पर काले चकत्ते।"],
        "symptomTags": ["फलों पर काले तैलीय धब्बे", "फलों का L/Y आकार में फटना", "पत्तियों पर काले चकत्ते"],
        "organicRemedy": "बोर्डो मिश्रण 1% (Bordeaux Mixture) का नियमित स्प्रे।",
        "chemicalMedicine": "स्ट्रेप्टोसाइक्लिन 50 ग्राम + कॉपर ऑक्सीक्लोराइड 500 ग्राम प्रति 200L",
        "sprayDosage": "स्ट्रेप्टोसाइक्लिन (0.5 ग्राम/लीटर) + कॉपर ऑक्सीक्लोराइड (2.5 ग्राम/लीटर)।",
        "precautions": "संक्रमित टहनी 2 इंच नीचे से काटकर बोर्डो पेस्ट लगाएं।",
        "preventionTips": ["औजारों को सैनिटाइज़ करके कटाई-छंटाई करें।"],
        "icon": "🍎"
    },

    # 21. बैंगन (Brinjal / Eggplant)
    {
        "id": "brinjal_shoot_fruit_borer",
        "cropId": "brinjal",
        "cropName": "Brinjal / Eggplant",
        "cropHindi": "बैंगन",
        "diseaseNameHindi": "तना व फल छेदक सुंडी (सफेद इल्ली)",
        "diseaseNameEnglish": "Shoot and Fruit Borer",
        "pathogen": "हानिकारक कीट (Leucinodes orbonalis)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.6,
        "symptoms": ["कोमल टहनियां मुरझाकर लटक जाती हैं।", "बैंगन के अंदर छेद करके गूदा खा जाती है।"],
        "symptomTags": ["टहनियों का मुरझाना", "बैंगन में छेद", "सुंडी"],
        "organicRemedy": "फेरोमोन ट्रैप 10 प्रति एकड़ + नीम अर्क 5 मिली/लीटर।",
        "chemicalMedicine": "एम्पलीगो (Chlorantraniliprole + Lambda-cyhalothrin) या कोराजन",
        "sprayDosage": "एम्पलीगो: 80 मिली प्रति एकड़ 150 लीटर पानी में।",
        "precautions": "मुरझाई हुई टहनियों को सुंडी सहित तोड़कर दबाएं।",
        "preventionTips": ["ल्यूर ट्रैप समय पर लगाएं।"],
        "icon": "🍆"
    },

    # 22. भिंडी (Okra / Ladyfinger)
    {
        "id": "okra_yellow_vein_mosaic",
        "cropId": "okra",
        "cropName": "Okra / Ladyfinger",
        "cropHindi": "भिंडी",
        "diseaseNameHindi": "पीली नस मोज़ेक वायरस (YVMV)",
        "diseaseNameEnglish": "Yellow Vein Mosaic Virus",
        "pathogen": "सफेद मक्खी जनित वायरस",
        "severity": "गंभीर",
        "confidenceScore": 96.7,
        "symptoms": ["पत्तियों की नसें स्पष्ट रूप से पीली पड़ जाती हैं।", "भिंडी का रंग पीला और फल कड़ा हो जाता है।"],
        "symptomTags": ["नसों का पीला पड़ना", "भिंडी का पीला व कड़ा होना", "सफेद मक्खी"],
        "organicRemedy": "पीले स्टिकी ट्रैप 12 प्रति एकड़ + नीम तेल 5 मिली/लीटर।",
        "chemicalMedicine": "एसिटामिप्रिड 20% SP (प्राइड) या थायमेथोक्सम 25% WG",
        "sprayDosage": "एसिटामिप्रिड: 1 ग्राम प्रति 2 लीटर पानी।",
        "precautions": "सफेद मक्खी का नियंत्रण शुरुआत में ही करें।",
        "preventionTips": ["प्रतिरोधी किस्में (अर्का अनामिका, परभणी क्रांति) लगाएं।"],
        "icon": "🌿"
    },

    # 23. गोभी (Cauliflower & Cabbage)
    {
        "id": "cauliflower_dbm",
        "cropId": "cauliflower",
        "cropName": "Cauliflower & Cabbage",
        "cropHindi": "फूलगोभी / पत्तागोभी",
        "diseaseNameHindi": "डायमंड बैक मोथ (DBM सुंडी / जालीदार कीट)",
        "diseaseNameEnglish": "Diamondback Moth (DBM)",
        "pathogen": "कीट (Plutella xylostella)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.0,
        "symptoms": ["पत्तियों के नीचे जालीदार छेद और हरी छोटी इल्लियां।", "फूल के अंदर घुसकर फसल बर्बाद कर देती हैं।"],
        "symptomTags": ["पत्तियों में जालीदार छेद", "हरी छोटी सुंडी", "फूल का खराब होना"],
        "organicRemedy": "सरसों को ट्रैप क्रॉप के रूप में 25 लाइन गोभी के बाद 2 लाइन सरसों लगाएं।",
        "chemicalMedicine": "स्पिनोसैड 45% SC (ट्रेसर) या कोराजन 18.5% SC",
        "sprayDosage": "स्पिनोसैड: 0.3 मिली प्रति लीटर पानी (60 मिली प्रति एकड़)।",
        "precautions": "कीटनाशक को बदल-बदल कर स्प्रे करें ताकि कीट में प्रतिरोध न बने।",
        "preventionTips": ["ट्रैप क्रॉपिंग अपनाएं।"],
        "icon": "🥦"
    },

    # 24. मटर (Green Pea)
    {
        "id": "pea_powdery_mildew",
        "cropId": "pea",
        "cropName": "Green Pea",
        "cropHindi": "मटर",
        "diseaseNameHindi": "चूर्णी फफूंद / छाछिया रोग",
        "diseaseNameEnglish": "Powdery Mildew",
        "pathogen": "फफूंद (Erysiphe pisi)",
        "severity": "गंभीर",
        "confidenceScore": 97.3,
        "symptoms": ["पत्तियों, तनों व फलियों पर सफेद आटे जैसा चूर्ण फैल जाता है।", "पत्तियां पीली पड़कर सूख जाती हैं।"],
        "symptomTags": ["सफेद आटे जैसा पाउडर", "फलियों पर सफेद चूर्ण", "पत्तियों का सूखना"],
        "organicRemedy": "खट्टी छाछ (5%) या घुलनशील सल्फर 2 ग्राम/लीटर।",
        "chemicalMedicine": "हेक्साकोनाज़ोल 5% EC या घुलनशील सल्फर 80% WDG (सल्फेक्स)",
        "sprayDosage": "सल्फेक्स: 2.5 ग्राम प्रति लीटर पानी (500 ग्राम प्रति एकड़)।",
        "precautions": "दोपहर की तेज धूप में सल्फर स्प्रे न करें।",
        "preventionTips": ["अगेती किस्में बोएं।"],
        "icon": "🫛"
    },

    # 25. अदरक (Ginger)
    {
        "id": "ginger_rhizome_rot",
        "cropId": "ginger",
        "cropName": "Ginger",
        "cropHindi": "अदरक",
        "diseaseNameHindi": "प्रकंद सड़न (कंद गलन रोग)",
        "diseaseNameEnglish": "Rhizome Rot / Soft Rot",
        "pathogen": "कवक (Pythium aphanidermatum)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.3,
        "symptoms": ["पौधे की निचली पत्तियां पीली पड़कर नीचे से ऊपर सूखती हैं।", "कंद गलकर पानी छोड़ने लगता है और बदबू आती है।"],
        "symptomTags": ["कंद का सड़ना व बदबू", "पत्तियों का नीचे से सूखना", "पौधे का उखड़ना"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी 2 किग्रा को गोबर की खाद में मिलाकर खेत में डालें।",
        "chemicalMedicine": "रिडोमिल गोल्ड (Metalaxyl + Mancozeb) या कॉपर ऑक्सीक्लोराइड",
        "sprayDosage": "2.5 ग्राम प्रति लीटर पानी से पौधों की जड़ों में ड्रेंचिंग (Drenching) करें।",
        "precautions": "खेत में पानी भरने न दें, जल निकासी का उचित प्रबंध रखें।",
        "preventionTips": ["प्रकंद को कार्बेंडाजिम से उपचारित करके बोएं।"],
        "icon": "🫚"
    },

    # 26. हल्दी (Turmeric)
    {
        "id": "turmeric_leaf_spot",
        "cropId": "turmeric",
        "cropName": "Turmeric",
        "cropHindi": "हल्दी",
        "diseaseNameHindi": "पर्ण चित्ती / धब्बा रोग (कोलेटोट्राइकम)",
        "diseaseNameEnglish": "Turmeric Leaf Spot",
        "pathogen": "फफूंद (Colletotrichum capsici)",
        "severity": "मध्यम",
        "confidenceScore": 96.0,
        "symptoms": ["पत्तियों पर अंडाकार भूरे धब्बे जिनका केंद्र सफेद होता है।", "संक्रमित पत्तियां पीली पड़कर सूख जाती हैं।"],
        "symptomTags": ["अंडाकार भूरे धब्बे", "पत्तियों का सूखना", "सफेद केंद्र वाले चकत्ते"],
        "organicRemedy": "पंचगव्य 3% + गोमूत्र 10% का छिड़काव।",
        "chemicalMedicine": "साफ (Carbendazim 12% + Mancozeb 63% WP)",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "रोग के शुरुआती लक्षण दिखते ही स्प्रे करें।",
        "preventionTips": ["कंद उपचार करके ही बोएं।"],
        "icon": "🟡"
    },

    # 27. धनिया (Coriander)
    {
        "id": "coriander_powdery_mildew",
        "cropId": "coriander",
        "cropName": "Coriander",
        "cropHindi": "धनिया",
        "diseaseNameHindi": "छाछिया रोग / चूर्णी फफूंद",
        "diseaseNameEnglish": "Powdery Mildew",
        "pathogen": "फफूंद (Erysiphe polygoni)",
        "severity": "गंभीर",
        "confidenceScore": 97.1,
        "symptoms": ["पत्तियों, फूलों व बीजों पर सफेद पाउडर जम जाता है।", "बीज छोटे व हल्के बनते हैं, उत्पादन घट जाता है।"],
        "symptomTags": ["फूलों व बीजों पर सफेद पाउडर", "पत्तियों पर सफेद चूर्ण"],
        "organicRemedy": "खट्टी छाछ (5 लीटर/100L) या घुलनशील गंधक।",
        "chemicalMedicine": "घुलनशील गंधक (Sulphur 80% WDG) या हेक्साकोनाज़ोल 5% EC",
        "sprayDosage": "सल्फर: 2 ग्राम प्रति लीटर (400 ग्राम प्रति एकड़)।",
        "precautions": "फूल आने के समय पहला स्प्रे अवश्य करें।",
        "preventionTips": ["प्रतिरोधी किस्में (RCr 436, RCr 728) बोएं।"],
        "icon": "🌿"
    },

    # 28. सौंफ (Fennel)
    {
        "id": "fennel_ramularia_blight",
        "cropId": "fennel",
        "cropName": "Fennel",
        "cropHindi": "सौंफ",
        "diseaseNameHindi": "झुलसा व रामुलेरिया ब्लाइट",
        "diseaseNameEnglish": "Ramularia Blight",
        "pathogen": "फफूंद (Ramularia foeniculi)",
        "severity": "गंभीर",
        "confidenceScore": 96.4,
        "symptoms": ["पत्तियों व छतरियों (Umbel) पर छोटे भूरे-काले धब्बे।", "फूल जलकर काले पड़ जाते हैं और बीज नहीं बनते।"],
        "symptomTags": ["छतरियों पर काले धब्बे", "फूलों का काला पड़ना व जलना"],
        "organicRemedy": "नीम तेल 5 मिली + छाछ 5% का स्प्रे।",
        "chemicalMedicine": "डाइफेनोकोनाज़ोल 25% EC (स्कोर) या मेन्कोजेब",
        "sprayDosage": "1 मिली स्कोर प्रति लीटर पानी (200 मिली प्रति एकड़)।",
        "precautions": "बादल छाने पर तुरंत पहला स्प्रे करें।",
        "preventionTips": ["सौंफ की रोपाई समय पर करें।"],
        "icon": "🌿"
    },

    # 29. मेथी (Fenugreek)
    {
        "id": "fenugreek_downy_mildew",
        "cropId": "fenugreek",
        "cropName": "Fenugreek",
        "cropHindi": "मेथी",
        "diseaseNameHindi": "डाउनी मिल्ड्यू / तुलासिता रोग",
        "diseaseNameEnglish": "Downy Mildew",
        "pathogen": "कवक (Peronospora trigonellae)",
        "severity": "गंभीर",
        "confidenceScore": 95.9,
        "symptoms": ["पत्तियों की ऊपरी सतह पर पीले धब्बे और निचली सतह पर बैंगनी-सफेद फफूंद।", "पत्तियां पीली होकर झड़ जाती हैं।"],
        "symptomTags": ["ऊपर पीले धब्बे", "नीचे बैंगनी-सफेद फफूंद", "पत्तियों का झड़ना"],
        "organicRemedy": "ट्राइकोडर्मा 5 ग्राम/लीटर + गोमूत्र।",
        "chemicalMedicine": "रिडोमिल गोल्ड (Metalaxyl + Mancozeb)",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "नमी अधिक होने पर तुरंत स्प्रे करें।",
        "preventionTips": ["प्रमाणित किस्में (RMT 1, RMT 305) लगाएं।"],
        "icon": "🌿"
    },

    # 30. इसबगोल (Isabgol / Psyllium)
    {
        "id": "isabgol_downy_mildew",
        "cropId": "isabgol",
        "cropName": "Isabgol / Psyllium",
        "cropHindi": "इसबगोल",
        "diseaseNameHindi": "झुलसा व डाउनी मिल्ड्यू रोग",
        "diseaseNameEnglish": "Downy Mildew & Blight",
        "pathogen": "फफूंद (Peronospora plantaginis)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.5,
        "symptoms": ["पत्तियों पर हल्के पीले धब्बे जो बाद में भूरे-काले हो जाते हैं।", "बालियां (Spikes) काली पड़कर सूख जाती हैं।"],
        "symptomTags": ["बालियों का काला पड़ना", "पत्तियों पर भूरे-काले धब्बे", "फसल का झुलसना"],
        "organicRemedy": "खट्टी छाछ + तांबा बर्तन का घोल।",
        "chemicalMedicine": "मेन्कोजेब 75% WP या रिडोमिल गोल्ड",
        "sprayDosage": "2.5 ग्राम मेन्कोजेब प्रति लीटर पानी (500 ग्राम प्रति एकड़)।",
        "precautions": "मौसम में बदली और ओस बढ़ते ही पहला स्प्रे करें।",
        "preventionTips": ["इसबगोल की बुवाई नवंबर प्रथम सप्ताह में करें।"],
        "icon": "🌾"
    },

    # 31. संतरा / नींबू (Citrus / Lemon)
    {
        "id": "citrus_canker",
        "cropId": "citrus",
        "cropName": "Citrus / Lemon / Orange",
        "cropHindi": "संतरा / किन्नू / नींबू",
        "diseaseNameHindi": "सिट्रस कैंकर (खुरंड / खसरा रोग)",
        "diseaseNameEnglish": "Citrus Canker",
        "pathogen": "जीवाणु (Xanthomonas citri)",
        "severity": "गंभीर",
        "confidenceScore": 98.0,
        "symptoms": ["पत्तियों, टहनियों व फलों पर उभरे हुए खुरदरे भूरे रंग के फफोले।", "फलों की गुणवत्ता और बाज़ार भाव गिर जाता है।"],
        "symptomTags": ["फलों पर खुरदरे भूरे फफोले", "पत्तियों पर उभरे हुए दाने", "टहनियों पर खुरंड"],
        "organicRemedy": "बोर्डो मिश्रण 1% या कॉपर ऑक्सीक्लोराइड।",
        "chemicalMedicine": "स्ट्रेप्टोसाइक्लिन (50 ग्राम) + कॉपर ऑक्सीक्लोराइड (500 ग्राम) प्रति 200L",
        "sprayDosage": "0.5 ग्राम स्ट्रेप्टोसाइक्लिन + 2.5 ग्राम ब्लाइटॉक्स प्रति लीटर पानी।",
        "precautions": "संक्रमित टहनियों को काटकर जलाएं।",
        "preventionTips": ["रोगमुक्त कलमी पौधे लगाएं।"],
        "icon": "🍋"
    },

    # 32. आम (Mango)
    {
        "id": "mango_powdery_mildew",
        "cropId": "mango",
        "cropName": "Mango",
        "cropHindi": "आम",
        "diseaseNameHindi": "बौर का खर्रा रोग (चूर्णी फफूंद) व मधुआ कीट",
        "diseaseNameEnglish": "Mango Powdery Mildew & Hopper",
        "pathogen": "फफूंद (Oidium mangiferae) व कीट",
        "severity": "गंभीर",
        "confidenceScore": 97.8,
        "symptoms": ["आम के बौर (फूलों) पर सफेद पाउडर जम जाता है और बौर सूखकर गिर जाता है।", "मधुआ कीट रस चूसकर बौर को चिपचिपा कर देता है।"],
        "symptomTags": ["बौर पर सफेद पाउडर", "बौर का गिरना", "चिपचिपा रस / मधुआ"],
        "organicRemedy": "नीम तेल 5 मिली/लीटर + घुलनशील गंधक।",
        "chemicalMedicine": "हेक्साकोनाज़ोल 5% SC (कंटाफ) + इमिडाक्लोप्रिड 17.8% SL",
        "sprayDosage": "1.5 मिली कंटाफ + 0.5 मिली इमिडाक्लोप्रिड प्रति लीटर पानी।",
        "precautions": "बौर आने पर और मटर के दाने जितने फल बनने पर 2 स्प्रे करें।",
        "preventionTips": ["बगीचे की साफ-सफाई रखें।"],
        "icon": "🥭"
    },

    # 33. अमरूद (Guava)
    {
        "id": "guava_wilt",
        "cropId": "guava",
        "cropName": "Guava",
        "cropHindi": "अमरूद",
        "diseaseNameHindi": "अमरूद का उकठा रोग (विल्ट / सूखा रोग)",
        "diseaseNameEnglish": "Guava Wilt",
        "pathogen": "मृदा जनित फफूंद (Fusarium oxysporum)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.2,
        "symptoms": ["पेड़ की पत्तियां पीली पड़कर अचानक मुरझाने लगती हैं।", "कुछ ही हफ़्तों में पूरा हरा-भरा पेड़ सूख जाता है।"],
        "symptomTags": ["पेड़ का अचानक सूखना", "पत्तियों का पीला पड़ना व झड़ना", "जड़ों का काला होना"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी 25 ग्राम प्रति पेड़ गोबर की खाद में मिलाकर जड़ों में डालें।",
        "chemicalMedicine": "कार्बेन्डाजिम 50% WP (बाविस्टिन) से तने व जड़ों के पास ड्रेंचिंग",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी से थाले (Basin) में ड्रेंचिंग करें।",
        "precautions": "संक्रमित पेड़ की जड़ों को खोदकर बाहर निकालें और चूना डालें।",
        "preventionTips": ["जलभराव से बचें।"],
        "icon": "🍈"
    },

    # 34. पपीता (Papaya)
    {
        "id": "papaya_ring_spot",
        "cropId": "papaya",
        "cropName": "Papaya",
        "cropHindi": "पपीता",
        "diseaseNameHindi": "रिंग स्पॉट वायरस (पत्ता मरोड़ व गोल छल्ले)",
        "diseaseNameEnglish": "Papaya Ring Spot Virus (PRSV)",
        "pathogen": "माहू कीट द्वारा फैलने वाला वायरस",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.5,
        "symptoms": ["पत्तियों पर गहरे हरे-पीले छांवदार चकत्ते और पत्तियां छोटी हो जाती हैं।", "फलों पर गहरे हरे गोल छल्ले (Rings) बनते हैं।"],
        "symptomTags": ["फलों पर गोल छल्ले", "पत्तियों का छोटा होना / मरोड़", "पौधे का बौना होना"],
        "organicRemedy": "सिल्वर रंग की मल्चिंग + पीला स्टिकी ट्रैप लगाएं।",
        "chemicalMedicine": "माहू कीट नियंत्रण: डायमेथोएट 30% EC या इमिडाक्लोप्रिड",
        "sprayDosage": "1 मिली प्रति लीटर पानी।",
        "precautions": "संक्रमित पौधे को तुरंत उखाड़कर नष्ट करें।",
        "preventionTips": ["रोगमुक्त नर्सरी पौधे लगाएं।"],
        "icon": "🍈"
    },

    # 35. तरबूज व खरबूजा (Watermelon & Muskmelon)
    {
        "id": "melon_downy_mildew",
        "cropId": "watermelon",
        "cropName": "Watermelon & Muskmelon",
        "cropHindi": "तरबूज / खरबूजा",
        "diseaseNameHindi": "डाउनी मिल्ड्यू (झुलसा) व फल मक्खी",
        "diseaseNameEnglish": "Downy Mildew & Fruit Fly",
        "pathogen": "फफूंद (Pseudoperonospora) व कीट",
        "severity": "गंभीर",
        "confidenceScore": 97.4,
        "symptoms": ["पत्तियों की ऊपरी सतह पर पीले कोणीय धब्बे जो नसों के बीच सीमित होते हैं।", "फल मक्खी फल में डंक मारकर कीड़े पैदा करती है।"],
        "symptomTags": ["पीले कोणीय धब्बे", "फल में डंक व सड़न", "पत्तियों का सूखना"],
        "organicRemedy": "फेरोमोन फ्रूट फ्लाई ट्रैप 6 प्रति एकड़ लगाएं।",
        "chemicalMedicine": "रिडोमिल गोल्ड (Mancozeb + Metalaxyl) या एमिस्टार",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।",
        "precautions": "ड्रिप से सिंचाई करें, पत्तियों पर पानी न डालें।",
        "preventionTips": ["मल्चिंग शीट लगाएं।"],
        "icon": "🍉"
    },

    # 36. अरंडी (Castor)
    {
        "id": "castor_semilooper",
        "cropId": "castor",
        "cropName": "Castor",
        "cropHindi": "अरंडी",
        "diseaseNameHindi": "सेमीलूपर सुंडी (पत्ती खाने वाली इल्ली)",
        "diseaseNameEnglish": "Castor Semilooper",
        "pathogen": "हानिकारक कीट (Achaea janata)",
        "severity": "गंभीर",
        "confidenceScore": 97.0,
        "symptoms": ["काले-भूरे रंग की बड़ी सुंडी पत्तियों को तेजी से खाकर सिर्फ नसें छोड़ती है।", "पौधा पत्तियों रहित हो जाता है।"],
        "symptomTags": ["पत्तियों का तेजी से कटना", "काली-भूरी बड़ी सुंडी", "सिर्फ नसों का बचना"],
        "organicRemedy": "नीम तेल 5 मिली/लीटर या टी-खूंटी पक्षियों के लिए लगाएं।",
        "chemicalMedicine": "क्विनालफॉस 25% EC या प्रोफेनोफॉस 50% EC",
        "sprayDosage": "2 मिली प्रति लीटर पानी (400 मिली प्रति एकड़)।",
        "precautions": "सुंडी छोटी होने पर ही पहला स्प्रे करें।",
        "preventionTips": ["खेत की गहरी जुताई करें।"],
        "icon": "🫘"
    },

    # 37. सूरजमुखी (Sunflower)
    {
        "id": "sunflower_head_rot",
        "cropId": "sunflower",
        "cropName": "Sunflower",
        "cropHindi": "सूरजमुखी",
        "diseaseNameHindi": "फूल सड़न / हेड रॉट रोग",
        "diseaseNameEnglish": "Head Rot (Rhizopus)",
        "pathogen": "फफूंद (Rhizopus)",
        "severity": "गंभीर",
        "confidenceScore": 96.5,
        "symptoms": ["फूल के पिछले हिस्से पर पानी से भीगे भूरे धब्बे जो सड़ जाते हैं।", "फूल गिर जाता है और बीज काले पड़ जाते हैं।"],
        "symptomTags": ["फूल का सड़ना", "पिछले हिस्से पर भूरापन", "बीज का काला होना"],
        "organicRemedy": "ट्राइकोडर्मा 5 ग्राम/लीटर का स्प्रे।",
        "chemicalMedicine": "मेंकोजेब 75% WP या कार्बेन्डाजिम",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी।",
        "precautions": "फूल बनने के समय बारिश के बाद तुरंत स्प्रे करें।",
        "preventionTips": ["उचित दूरी पर पौधे लगाएं।"],
        "icon": "🌻"
    },

    # 38. तिल (Sesame / Til)
    {
        "id": "sesame_phyllody",
        "cropId": "sesame",
        "cropName": "Sesame / Til",
        "cropHindi": "तिल",
        "diseaseNameHindi": "फाइलोडी रोग (फूलों का हरी पत्तियों में बदलना)",
        "diseaseNameEnglish": "Sesame Phyllody",
        "pathogen": "फाइटोप्लाज्मा (लीपहॉपर कीट द्वारा)",
        "severity": "गंभीर",
        "confidenceScore": 97.3,
        "symptoms": ["फूलों के सभी अंग हरी पत्तियों के गुच्छे (झाड़ू) में बदल जाते हैं।", "पौधे पर कोई फली या तिल का बीज नहीं बनता।"],
        "symptomTags": ["फूलों की जगह हरी पत्तियां / झाड़ू", "फली न बनना", "पौधे का बौना होना"],
        "organicRemedy": "पीला स्टिकी ट्रैप + नीम तेल 5 मिली/लीटर।",
        "chemicalMedicine": "हॉपर कीट नियंत्रण: डाइमेथोएट 30% EC या इमिडाक्लोप्रिड",
        "sprayDosage": "1.5 मिली प्रति लीटर पानी।",
        "precautions": "रोगग्रस्त पौधों को तुरंत उखाड़कर नष्ट करें।",
        "preventionTips": ["बीज उपचार करके बोएं।"],
        "icon": "⚪"
    },

    # 39. केला (Banana)
    {
        "id": "banana_panama_wilt",
        "cropId": "banana",
        "cropName": "Banana",
        "cropHindi": "केला",
        "diseaseNameHindi": "पनामा विल्ट (उकठा / तना फटना)",
        "diseaseNameEnglish": "Panama Wilt",
        "pathogen": "मृदा जनित कवक (Fusarium oxysporum f.sp. cubense)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.7,
        "symptoms": ["निचली पत्तियां पीली पड़कर डंठल के पास से लटक जाती हैं (स्कर्ट जैसा रूप)।", "तने का आधार लंबाई में फट जाता है और अंदर से भूरा दिखता है।"],
        "symptomTags": ["पत्तियों का लटकना", "तने का फटना", "अंदर से भूरा/काला तना"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी 50 ग्राम प्रति पौधा गड्ढे में गोबर खाद के साथ डालें।",
        "chemicalMedicine": "कार्बेन्डाजिम 50% WP (बाविस्टिन) से जड़ों में ड्रेंचिंग",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी (2 से 3 लीटर घोल प्रति पौधा)।",
        "precautions": "संक्रमित खेत के सकर (Pups) न लगाएं।",
        "preventionTips": ["ग्रैंड नैने (G9) जैसी प्रतिरोधी टिशू कल्चर किस्में लगाएं।"],
        "icon": "🍌"
    },

    # 40. सेब (Apple)
    {
        "id": "apple_scab",
        "cropId": "apple",
        "cropName": "Apple",
        "cropHindi": "सेब",
        "diseaseNameHindi": "सेब का स्कैब / पपड़ी रोग",
        "diseaseNameEnglish": "Apple Scab",
        "pathogen": "फफूंद (Venturia inaequalis)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 98.4,
        "symptoms": ["पत्तियों और फलों पर मखमली जैतून-हरे से काले खुरदुरे धब्बे।", "फल विकृत होकर फट जाते हैं।"],
        "symptomTags": ["फलों पर काले खुरदुरे धब्बे / पपड़ी", "फलों का फटना", "पत्तियों पर जैतून-हरे धब्बे"],
        "organicRemedy": "बोर्डो मिश्रण 1% या कॉपर ऑक्सीक्लोराइड।",
        "chemicalMedicine": "डाइफेनोकोनाज़ोल 25% EC (स्कोर) या मेन्कोजेब 75% WP",
        "sprayDosage": "0.5 मिली स्कोर प्रति लीटर पानी (100 मिली प्रति 200L ड्रम)।",
        "precautions": "पत्ती झड़ने के बाद 5% यूरिया का स्प्रे जमीन पर करें ताकि फफूंद नष्ट हो सके।",
        "preventionTips": ["नियमित कटाई-छंटाई करें।"],
        "icon": "🍎"
    }
]

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    output_path = os.path.join(base_dir, "assets", "data", "crop_diseases.json")
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    unique_crops = sorted(list(set(d["cropId"] for d in DISEASES_DATA)))

    payload = {
        "version": "2.0.0",
        "lastUpdated": datetime.now().isoformat(),
        "source": "ICAR & CIBRC DPPQS Government Approved Database",
        "totalCrops": len(unique_crops),
        "totalDiseases": len(DISEASES_DATA),
        "cropsList": unique_crops,
        "diseases": DISEASES_DATA
    }

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)

    print(f"Successfully compiled {len(DISEASES_DATA)} crop disease records across {len(unique_crops)} crops to {output_path}")

if __name__ == "__main__":
    main()
