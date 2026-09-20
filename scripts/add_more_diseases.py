#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
import os

ADDITIONAL_DISEASES = [
    {
        "id": "grapes_downy_mildew",
        "cropId": "fruits",
        "cropName": "Grapes",
        "cropHindi": "अंगूर",
        "diseaseNameHindi": "अंगूर का डाउनी मिल्ड्यू (Downy Mildew of Grapes)",
        "diseaseNameEnglish": "Downy Mildew of Grapes (Plasmopara viticola)",
        "pathogen": "फफूंद (Plasmopara viticola)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.5,
        "symptoms": [
            "पत्तियों की ऊपरी सतह पर पीले तैलीय धब्बे (Oil Spots)।",
            "निचली सतह पर सफेद घनी रोएंदार फफूंद और अंगूर के गुच्छों का सूखकर भूरा-कड़ा होना।"
        ],
        "symptomTags": ["तैलीय धब्बे", "सफेद फफूंद", "अंगूर सूखना", "डाउनी मिल्ड्यू"],
        "organicRemedy": "बोर्डो मिश्रण 1% (1 किलो चूना + 1 किलो नीला थोथा 100 लीटर पानी) का नियमित छिड़काव।",
        "chemicalMedicine": "डाइमेथोमॉर्फ 50% WP (एक्यूबेट) या साइमोक्सानिल + मैंकोजेब (कर्जेट)",
        "sprayDosage": "डाइमेथोमॉर्फ: 1 ग्राम प्रति लीटर (200 ग्राम प्रति एकड़)।",
        "precautions": "वर्षा ऋतु में पत्तियां भीगने के 24 घंटे के अंदर सुरक्षात्मक स्प्रे करें।",
        "preventionTips": ["अंगूर के मंडप (Bower) में धूप और हवा का संचार बनाए रखें।"],
        "icon": "🍇"
    },
    {
        "id": "grapes_powdery_mildew",
        "cropId": "fruits",
        "cropName": "Grapes",
        "cropHindi": "अंगूर",
        "diseaseNameHindi": "अंगूर का चूर्णी फफूंद / छाछ्या (Powdery Mildew)",
        "diseaseNameEnglish": "Powdery Mildew of Grapes (Uncinula necator)",
        "pathogen": "फफूंद (Uncinula necator)",
        "severity": "गंभीर",
        "confidenceScore": 96.0,
        "symptoms": [
            "पत्तियों, शाखाओं और मणियों (फलों) पर सफेद राख जैसा पाउडर छा जाता है।",
            "दाने फट जाते हैं और उनमें दरारें पड़ जाती हैं।"
        ],
        "symptomTags": ["सफेद पाउडर", "दाने फटना", "छाछ्या", "मणियों पर चूर्ण"],
        "organicRemedy": "घुलनशील गंधक (सल्फर 80% WDG) 2 ग्राम प्रति लीटर पानी।",
        "chemicalMedicine": "टेबुकोनाज़ोल 25.9% EC (फॉलीकुर) या पेनकोनाज़ोल 10% EC (टोपाज)",
        "sprayDosage": "टोपाज: 0.5 मिली प्रति लीटर पानी।",
        "precautions": "तापमान 30°C से ऊपर जाने पर सल्फर का उपयोग न करें।",
        "preventionTips": ["छंटाई के बाद तनों पर बोर्डो पेस्ट लगाएं।"],
        "icon": "🍇"
    },
    {
        "id": "ber_powdery_mildew",
        "cropId": "fruits",
        "cropName": "Ber / Jujube",
        "cropHindi": "बेर",
        "diseaseNameHindi": "बेर का छाछ्या रोग (Powdery Mildew of Ber)",
        "diseaseNameEnglish": "Powdery Mildew of Ber (Oidium erysiphoides)",
        "pathogen": "फफूंद (Oidium erysiphoides f.sp. zizyphi)",
        "severity": "गंभीर",
        "confidenceScore": 95.2,
        "symptoms": [
            "छोटे फलों और पत्तियों पर सफेद चूर्ण जम जाता है।",
            "फलों की त्वचा कत्थई-भूरी, खुरदरी और कॉर्क जैसी हो जाती है और फल फट जाते हैं।"
        ],
        "symptomTags": ["सफेद चूर्ण", "खुरदरे फल", "फल फटना", "छाछ्या"],
        "organicRemedy": "गंधक चूर्ण (सल्फर डस्ट) 25 किलो प्रति हेक्टेयर भुरकें।",
        "chemicalMedicine": "डिनोकैप 48% EC (कराथेन) या घुलनशील सल्फर 80% WDG",
        "sprayDosage": "कराथेन: 1 मिली प्रति लीटर पानी।",
        "precautions": "पहला छिड़काव अक्टूबर के अंत में फल बनने पर करें।",
        "preventionTips": ["छंटाई समय पर (मई-जून) करें।"],
        "icon": "🍈"
    },
    {
        "id": "pomegranate_fruit_borer",
        "cropId": "pomegranate",
        "cropName": "Pomegranate",
        "cropHindi": "अनार",
        "diseaseNameHindi": "अनार की तितली / फल छेदक (Anar Butterfly)",
        "diseaseNameEnglish": "Pomegranate Butterfly / Fruit Borer (Deudorix isocrates)",
        "pathogen": "कीट (Deudorix isocrates)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 97.0,
        "symptoms": [
            "फलों पर गोल छेद होता है जिससे बदबूदार चिपचिपा विष्ठा (मल) बाहर निकलता है।",
            "फल अंदर से पूरी तरह सड़कर भूरा हो जाता है और गिर जाता है।"
        ],
        "symptomTags": ["फलों पर गोल छेद", "बदबूदार मल निकलना", "अनार तितली", "फल सड़ना"],
        "organicRemedy": "बटर पेपर बैग से छोटे फलों को बांधें (Bagging)।",
        "chemicalMedicine": "स्पिनोसैड 45% SC या क्लोरेंट्रानिलिप्रोल 18.5% SC",
        "sprayDosage": "स्पिनोसैड: 0.4 मिली प्रति लीटर पानी।",
        "precautions": "फूल आने के समय तितलियां दिखने पर तुरंत पहला स्प्रे करें।",
        "preventionTips": ["प्रभावित फलों को तोड़कर गड्ढे में गहरा दबाएं।"],
        "icon": "🍎"
    },
    {
        "id": "tea_red_rust",
        "cropId": "commercial",
        "cropName": "Tea",
        "cropHindi": "चाय",
        "diseaseNameHindi": "चाय का लाल रतुआ (Red Rust of Tea)",
        "diseaseNameEnglish": "Red Rust of Tea (Cephaleuros parasiticus)",
        "pathogen": "शैवाल (Alga - Cephaleuros virescens)",
        "severity": "गंभीर",
        "confidenceScore": 94.0,
        "symptoms": [
            "पत्तियों की ऊपरी सतह पर गोल उभरे हुए नारंगी-लाल मखमली धब्बे।",
            "टहनियां सूखने लगती हैं और चाय की पत्तियों की गुणवत्ता घट जाती है।"
        ],
        "symptomTags": ["नारंगी-लाल मखमली धब्बे", "रेड रस्ट", "पत्तियां सूखना"],
        "organicRemedy": "ताम्रयुक्त घोल का सुरक्षात्मक छिड़काव।",
        "chemicalMedicine": "कॉपर ऑक्सीक्लोराइड 50% WP (2.5 ग्राम/लीटर)",
        "sprayDosage": "500 ग्राम प्रति एकड़ 200 लीटर पानी में।",
        "precautions": "छायादार पेड़ों की अत्यधिक छंटाई न करें।",
        "preventionTips": ["उचित जल निकास और पोटाश खाद का संतुलित प्रयोग करें।"],
        "icon": "☕"
    },
    {
        "id": "coffee_leaf_rust",
        "cropId": "commercial",
        "cropName": "Coffee",
        "cropHindi": "कॉफ़ी",
        "diseaseNameHindi": "कॉफ़ी का पर्ण रतुआ (Coffee Leaf Rust)",
        "diseaseNameEnglish": "Coffee Leaf Rust (Hemileia vastatrix)",
        "pathogen": "फफूंद (Hemileia vastatrix)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.5,
        "symptoms": [
            "पत्तियों की निचली सतह पर नारंगी-पीले दानेदार फफोले (Pustules)।",
            "पत्तियां तेजी से झड़ जाती हैं और केवल नंगी शाखाएं बचती हैं।"
        ],
        "symptomTags": ["नारंगी-पीले फफोले", "पत्ती झड़ना", "कॉफ़ी रस्ट"],
        "organicRemedy": "बोर्डो मिश्रण 0.5% का मानसून पूर्व और पश्चात छिड़काव।",
        "chemicalMedicine": "प्रोपिकोनाज़ोल 25% EC या हेक्साकोनाज़ोल 5% SC",
        "sprayDosage": "1 मिली प्रति लीटर पानी।",
        "precautions": "मानसून से पहले पहला स्प्रे अनिवार्य है।",
        "preventionTips": ["रतुआ प्रतिरोधी किस्में (कावेरी, चयन 9) लगाएं।"],
        "icon": "☕"
    },
    {
        "id": "cauliflower_clubroot",
        "cropId": "cauliflower",
        "cropName": "Cauliflower / Cabbage",
        "cropHindi": "फूलगोभी / पत्तागोभी",
        "diseaseNameHindi": "क्लब रॉट / गांठ रोग (Clubroot)",
        "diseaseNameEnglish": "Clubroot (Plasmodiophora brassicae)",
        "pathogen": "फफूंद (Plasmodiophora brassicae)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 95.8,
        "symptoms": [
            "जड़ें अनियमित रूप से फूलकर गांठदार और गदा (Club) जैसी मोटी हो जाती हैं।",
            "दोपहर में धूप में पौधा मुरझा जाता है और शाम को पुनः सामान्य दिखता है।"
        ],
        "symptomTags": ["गांठदार जड़ें", "दोपहर में मुरझाना", "क्लब रॉट", "फूल न बनना"],
        "organicRemedy": "अम्लीय मिट्टी में बुझा हुआ चूना (2 टन/हेक्टेयर) मिलाकर pH 7.2 से ऊपर रखें।",
        "chemicalMedicine": "फ्लुअज़िनम 40% SC या ट्राइकोडर्मा से पौध जड़ उपचार",
        "sprayDosage": "फ्लुअज़िनम: 1.5 मिली प्रति लीटर पानी से ड्रेन्चिंग।",
        "precautions": "संक्रमित खेत के औजार दूसरे खेत में न ले जाएं।",
        "preventionTips": ["कम से कम 5 वर्ष का फसल चक्र अपनाएं।"],
        "icon": "🥦"
    },
    {
        "id": "carrot_alternaria_blight",
        "cropId": "vegetables",
        "cropName": "Carrot",
        "cropHindi": "गाजर",
        "diseaseNameHindi": "गाजर का आल्टरनेरिया झुलसा (Leaf Blight of Carrot)",
        "diseaseNameEnglish": "Alternaria Leaf Blight (Alternaria dauci)",
        "pathogen": "फफूंद (Alternaria dauci)",
        "severity": "गंभीर",
        "confidenceScore": 94.5,
        "symptoms": [
            "पत्तियों के किनारों पर काले-भूरे धब्बे जिनके चारों ओर पीलापन होता है।",
            "पत्तियां झुलसकर जलने जैसी दिखती हैं और कंद (गाजर) की बढ़वार रुक जाती है।"
        ],
        "symptomTags": ["पत्तियों पर काले-भूरे धब्बे", "झुलसा", "गाजर पतली रहना"],
        "organicRemedy": "नीम का तेल (5 मिली) + गोमूत्र (10%) का छिड़काव।",
        "chemicalMedicine": "डाइफेनोकोनाज़ोल 25% EC या क्लोरोथैलोनिल 75% WP",
        "sprayDosage": "क्लोरोथैलोनिल: 2 ग्राम प्रति लीटर पानी।",
        "precautions": "शाम के समय पत्तियां ज्यादा देर गीली न रहने दें।",
        "preventionTips": ["रोगमुक्त प्रमाणित बीज ही बोएं।"],
        "icon": "🥕"
    },
    {
        "id": "radish_white_rust",
        "cropId": "vegetables",
        "cropName": "Radish",
        "cropHindi": "मूली",
        "diseaseNameHindi": "मूली का सफेद रोली रोग (White Rust of Radish)",
        "diseaseNameEnglish": "White Rust of Radish (Albugo candida)",
        "pathogen": "फफूंद (Albugo candida)",
        "severity": "मध्यम",
        "confidenceScore": 93.8,
        "symptoms": [
            "पत्तियों की निचली सतह पर सफेद उभरे हुए चमकीले फफोले।",
            "पत्तियां विकृत होकर मुड़ जाती हैं और मूली में स्वाद कड़वा हो जाता है।"
        ],
        "symptomTags": ["सफेद फफोले", "सफेद रोली", "पत्ती मुड़ना"],
        "organicRemedy": "ताम्रयुक्त खट्टी छाछ का छिड़काव।",
        "chemicalMedicine": "मैंकोजेब 75% WP या रिडोमिल गोल्ड",
        "sprayDosage": "मैंकोजेब: 2.5 ग्राम प्रति लीटर पानी।",
        "precautions": "सुबह ओस सूखने के बाद ही स्प्रे करें।",
        "preventionTips": ["घनी बुवाई न करें, पौध से पौध दूरी 8 सेमी रखें।"],
        "icon": "🌱"
    },
    {
        "id": "bottle_gourd_anthracnose",
        "cropId": "vegetables",
        "cropName": "Bottle Gourd",
        "cropHindi": "लौकी / कद्दू",
        "diseaseNameHindi": "लौकी का एन्थ्रेक्नोज़ / फल सड़न रोग",
        "diseaseNameEnglish": "Anthracnose of Bottle Gourd (Colletotrichum orbiculare)",
        "pathogen": "फफूंद (Colletotrichum orbiculare)",
        "severity": "गंभीर",
        "confidenceScore": 95.0,
        "symptoms": [
            "फलों पर गोल धंसे हुए पानीदार काले चकत्ते।",
            "नमी में धब्बों पर गुलाबी रंग का चिपचिपा द्रव निकलता है और फल सड़ जाता है।"
        ],
        "symptomTags": ["गोल धंसे काले चकत्ते", "गुलाबी चिपचिपा द्रव", "लौकी सड़ना"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी 5 ग्राम प्रति लीटर पानी का छिड़काव।",
        "chemicalMedicine": "अजोक्सीस्ट्रोबिन 18.2% + डाइफेनोकोनाज़ोल 11.4% SC (अमीस्टार टॉप)",
        "sprayDosage": "1 मिली प्रति लीटर पानी (200 मिली प्रति एकड़)।",
        "precautions": "फलों को जमीन पर सीधा न टिकने दें, मचान या सूखी घास बिछाएं।",
        "preventionTips": ["बीज को कार्बेन्डाजिम से उपचारित करके लगाएं।"],
        "icon": "🥒"
    },
    {
        "id": "bitter_gourd_mosaic",
        "cropId": "vegetables",
        "cropName": "Bitter Gourd",
        "cropHindi": "करेला",
        "diseaseNameHindi": "करेला का मोज़ेक वायरस (Mosaic Virus of Bitter Gourd)",
        "diseaseNameEnglish": "Bitter Gourd Mosaic Virus",
        "pathogen": "माहू / एफिड जनित वायरस",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.2,
        "symptoms": [
            "पत्तियों पर गहरे व हल्के हरे रंग के चितकबरे चकत्ते और पत्तियों का सिकुड़ना।",
            "करेले का आकार छोटा, टेढ़ा और गांठदार हो जाता है।"
        ],
        "symptomTags": ["चितकबरी पत्तियां", "गांठदार करेला", "मोज़ेक वायरस"],
        "organicRemedy": "नीम का तेल (5 मिली) + पीले चिपचिपे कार्ड 15 प्रति एकड़।",
        "chemicalMedicine": "डायफेंथियूरॉन 50% WP (पेगासस) या एसिटामिप्रिड 20% SP",
        "sprayDosage": "पेगासस: 1.2 ग्राम प्रति लीटर पानी।",
        "precautions": "संक्रमित बेलों को खेत से तुरंत उखाड़कर नष्ट करें।",
        "preventionTips": ["मचान विधि से खेती करें।"],
        "icon": "🥒"
    },
    {
        "id": "spinach_downy_mildew",
        "cropId": "vegetables",
        "cropName": "Spinach",
        "cropHindi": "पालक",
        "diseaseNameHindi": "पालक का डाउनी मिल्ड्यू / पीली चित्ती",
        "diseaseNameEnglish": "Downy Mildew of Spinach (Peronospora effusa)",
        "pathogen": "फफूंद (Peronospora effusa)",
        "severity": "गंभीर",
        "confidenceScore": 94.5,
        "symptoms": [
            "पत्तियों की ऊपरी सतह पर हल्के पीले धब्बे।",
            "निचली सतह पर बैगनी-धूसर मखमली फफूंदी उग आती है और पत्ती सड़ जाती है।"
        ],
        "symptomTags": ["पीले धब्बे", "बैगनी मखमली फफूंदी", "पालक सड़ना"],
        "organicRemedy": "नीम पत्ती का काढ़ा 10% का छिड़काव।",
        "chemicalMedicine": "कॉपर ऑक्सीक्लोराइड 50% WP या मैंकोजेब",
        "sprayDosage": "2 ग्राम प्रति लीटर पानी।",
        "precautions": "कटाई के 7 दिन पहले रासायनिक छिड़काव बंद कर दें।",
        "preventionTips": ["जलभराव वाली भूमि में पालक न बोएं।"],
        "icon": "🥬"
    },
    {
        "id": "capsicum_powdery_mildew",
        "cropId": "vegetables",
        "cropName": "Capsicum",
        "cropHindi": "शिमला मिर्च",
        "diseaseNameHindi": "शिमला मिर्च का चूर्णी फफूंद (Powdery Mildew)",
        "diseaseNameEnglish": "Powdery Mildew of Capsicum (Leveillula taurica)",
        "pathogen": "फफूंद (Leveillula taurica)",
        "severity": "गंभीर",
        "confidenceScore": 95.5,
        "symptoms": [
            "पत्तियों की निचली सतह पर सफेद चूर्ण और ऊपरी सतह पर पीले चकत्ते।",
            "पत्तियां समय से पहले पीली पड़कर तेजी से गिर जाती हैं।"
        ],
        "symptomTags": ["सफेद पाउडर", "पीले चकत्ते", "पत्ती झड़ना"],
        "organicRemedy": "घुलनशील गंधक 2.5 ग्राम प्रति लीटर पानी।",
        "chemicalMedicine": "पेनकोनाज़ोल 10% EC (टोपाज) या माइक्लोब्यूटानिल 10% WP",
        "sprayDosage": "टोपाज: 0.5 मिली प्रति लीटर (100 मिली प्रति एकड़)।",
        "precautions": "पॉलीहाउस में वेंटिलेशन खुला रखें।",
        "preventionTips": ["संतुलित नाइट्रोजन व पोटाश का प्रयोग करें।"],
        "icon": "🫑"
    },
    {
        "id": "date_palm_leaf_spot",
        "cropId": "fruits",
        "cropName": "Date Palm",
        "cropHindi": "खजूर",
        "diseaseNameHindi": "खजूर का ग्राफिओला पर्ण चित्ती (Graphiola Leaf Spot)",
        "diseaseNameEnglish": "Graphiola Leaf Spot (False Smut)",
        "pathogen": "फफूंद (Graphiola phoenicis)",
        "severity": "मध्यम",
        "confidenceScore": 93.0,
        "symptoms": [
            "पत्तियों (पिंडों) की दोनों सतहों पर छोटे कड़े काले मस्सेदार उभार।",
            "उभार फटने पर पीले बीजाणु निकलते हैं और पत्तियां पीली पड़कर सूखती हैं।"
        ],
        "symptomTags": ["काले मस्से", "पीले बीजाणु", "खजूर की पत्ती सूखना"],
        "organicRemedy": "संक्रमित निचली सूखी पत्तियों की नियमित छंटाई कर जलाएं।",
        "chemicalMedicine": "कॉपर ऑक्सीक्लोराइड 50% WP (3 ग्राम/लीटर)",
        "sprayDosage": "3 ग्राम प्रति लीटर पानी।",
        "precautions": "छंटाई के बाद कटे भाग पर बोर्डो पेस्ट लगाएं।",
        "preventionTips": ["हवा व धूप का आवागमन बनाए रखें।"],
        "icon": "🌴"
    },
    {
        "id": "apple_powdery_mildew",
        "cropId": "apple",
        "cropName": "Apple",
        "cropHindi": "सेब",
        "diseaseNameHindi": "सेब का चूर्णी फफूंद (Powdery Mildew of Apple)",
        "diseaseNameEnglish": "Powdery Mildew of Apple (Podosphaera leucotricha)",
        "pathogen": "फफूंद (Podosphaera leucotricha)",
        "severity": "गंभीर",
        "confidenceScore": 95.0,
        "symptoms": [
            "कोमल टहनियों और पत्तियों पर सफेद-धूसर मखमली पाउडर छा जाता है।",
            "पत्तियां संकरी, मुड़ी हुई और चांदी जैसी दिखती हैं; फल पर जालीदार दाग पड़ते हैं।"
        ],
        "symptomTags": ["सफेद पाउडर", "मुड़ी हुई पत्तियां", "जालीदार फल"],
        "organicRemedy": "घुलनशील सल्फर 80% WDG 2.5 ग्राम प्रति लीटर।",
        "chemicalMedicine": "पेनकोनाज़ोल 10% EC या ट्राइफ्लॉक्सीस्ट्रोबिन + टेबुकोनाज़ोल (नैटिवो)",
        "sprayDosage": "नैटिवो: 0.4 ग्राम प्रति लीटर पानी।",
        "precautions": "सर्दियों में छंटाई के समय सफेद कवक लगी टहनियों को काटकर जलाएं।",
        "preventionTips": ["कली फटने की अवस्था में पहला स्प्रे करें।"],
        "icon": "🍎"
    },
    {
        "id": "watermelon_fusarium_wilt",
        "cropId": "watermelon",
        "cropName": "Watermelon",
        "cropHindi": "तरबूज",
        "diseaseNameHindi": "तरबूज का उकठा / फ्यूजेरियम विल्ट (Fusarium Wilt)",
        "diseaseNameEnglish": "Fusarium Wilt of Watermelon",
        "pathogen": "फफूंद (Fusarium oxysporum f.sp. niveum)",
        "severity": "अत्यंत गंभीर",
        "confidenceScore": 96.4,
        "symptoms": [
            "बेल की एक या दो शाखाएं दोपहर में मुरझा जाती हैं और सुबह ठीक दिखती हैं।",
            "कुछ दिन में पूरी बेल अचानक सूख जाती है; तना चीरने पर भूरी धारी दिखती है।"
        ],
        "symptomTags": ["बेल मुरझाना", "अचानक सूखना", "उकठा रोग", "तने में भूरी धारी"],
        "organicRemedy": "ट्राइकोडर्मा विरिडी 5 ग्राम प्रति गड्ढा गोबर के साथ दें।",
        "chemicalMedicine": "कार्बेंडाजिम 50% WP (2 ग्राम/लीटर) से जड़ों की ड्रेन्चिंग",
        "sprayDosage": "ड्रेन्चिंग: 2 ग्राम प्रति लीटर पानी (प्रति पौधा 500 मिली घोल)।",
        "precautions": "बलुई मिट्टी में अधिक ताप और जलभराव से बचें।",
        "preventionTips": ["फसल चक्र में कम से कम 4 वर्ष कद्दूवर्गीय फसल न लगाएं।"],
        "icon": "🍉"
    }
]

def main():
    json_path = os.path.join(os.path.dirname(__file__), '..', 'assets', 'data', 'crop_diseases.json')
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    existing_ids = {d['id'] for d in data['diseases']}
    added_count = 0
    for d in ADDITIONAL_DISEASES:
        if d['id'] not in existing_ids:
            data['diseases'].append(d)
            existing_ids.add(d['id'])
            added_count += 1
            
    data['totalCount'] = len(data['diseases'])
    data['updatedAt'] = "2026-09-20"
    
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        
    print(f"Added {added_count} new diseases. Total diseases now: {len(data['diseases'])}")

if __name__ == '__main__':
    main()
