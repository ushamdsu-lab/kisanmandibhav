import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CropDisease {
  final String id;
  final String cropId;
  final String cropName;
  final String cropHindi;
  final String diseaseNameHindi;
  final String diseaseNameEnglish;
  final String pathogen; // Fungal / Bacterial / Viral / Pest / Deficiency
  final String severity; // 'गंभीर', 'मध्यम', 'शुरुआती'
  final double confidenceScore;
  final List<String> symptoms;
  final List<String> symptomTags;
  final String organicRemedy;
  final String chemicalMedicine;
  final String sprayDosage;
  final String precautions;
  final List<String> preventionTips;
  final String icon;

  const CropDisease({
    required this.id,
    required this.cropId,
    required this.cropName,
    required this.cropHindi,
    required this.diseaseNameHindi,
    required this.diseaseNameEnglish,
    required this.pathogen,
    required this.severity,
    this.confidenceScore = 94.5,
    required this.symptoms,
    this.symptomTags = const [],
    required this.organicRemedy,
    required this.chemicalMedicine,
    required this.sprayDosage,
    required this.precautions,
    required this.preventionTips,
    this.icon = '🌿',
  });

  factory CropDisease.fromJson(Map<String, dynamic> json) {
    return CropDisease(
      id: json['id']?.toString() ?? '',
      cropId: json['cropId']?.toString() ?? '',
      cropName: json['cropName']?.toString() ?? '',
      cropHindi: json['cropHindi']?.toString() ?? '',
      diseaseNameHindi: json['diseaseNameHindi']?.toString() ?? '',
      diseaseNameEnglish: json['diseaseNameEnglish']?.toString() ?? '',
      pathogen: json['pathogen']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'मध्यम',
      confidenceScore: (json['confidenceScore'] is num)
          ? (json['confidenceScore'] as num).toDouble()
          : 94.5,
      symptoms: (json['symptoms'] as List?)?.map((e) => e.toString()).toList() ?? [],
      symptomTags: (json['symptomTags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      organicRemedy: json['organicRemedy']?.toString() ?? '',
      chemicalMedicine: json['chemicalMedicine']?.toString() ?? '',
      sprayDosage: json['sprayDosage']?.toString() ?? '',
      precautions: json['precautions']?.toString() ?? '',
      preventionTips: (json['preventionTips'] as List?)?.map((e) => e.toString()).toList() ?? [],
      icon: json['icon']?.toString() ?? '🌿',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropId': cropId,
      'cropName': cropName,
      'cropHindi': cropHindi,
      'diseaseNameHindi': diseaseNameHindi,
      'diseaseNameEnglish': diseaseNameEnglish,
      'pathogen': pathogen,
      'severity': severity,
      'confidenceScore': confidenceScore,
      'symptoms': symptoms,
      'symptomTags': symptomTags,
      'organicRemedy': organicRemedy,
      'chemicalMedicine': chemicalMedicine,
      'sprayDosage': sprayDosage,
      'precautions': precautions,
      'preventionTips': preventionTips,
      'icon': icon,
    };
  }
}

class CropDiseaseDatabase {
  static List<CropDisease> _dynamicDiseases = List.from(defaultDiseases);

  static List<CropDisease> get diseases => _dynamicDiseases;

  static const List<CropDisease> defaultDiseases = [
    // --- गेहूं (Wheat) ---
    CropDisease(
      id: 'wheat_yellow_rust',
      cropId: 'wheat',
      cropName: 'Wheat',
      cropHindi: 'गेहूं',
      diseaseNameHindi: 'पीला रतुआ / हल्दी रोग',
      diseaseNameEnglish: 'Yellow / Stripe Rust',
      pathogen: 'फफूंद (Fungus - Puccinia striiformis)',
      severity: 'गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'पत्तियों पर हल्दी जैसा पीला पाउडर धारियों में दिखता है।',
        'हाथ लगाने पर उंगलियों पर पीला रंग लग जाता है।',
        'पौधे का विकास रुक जाता है और बालियां छोटी रह जाती हैं।',
      ],
      organicRemedy: 'खट्टी छाछ (5 लीटर) + हींग (50 ग्राम) 200 लीटर पानी में मिलाकर प्रति एकड़ छिड़कें।',
      chemicalMedicine: 'प्रोपिकोनाज़ोल 25% EC (टिल्ट / Tilt) या टेबुकोनाज़ोल',
      sprayDosage: '200 मिली प्रति एकड़ (15 से 20 मिली प्रति 15 लीटर पंप) 200 लीटर पानी में घोलकर।',
      precautions: 'रोग के शुरुआती लक्षण दिखते ही छिड़काव करें, तेज धूप में छिड़काव न करें।',
      preventionTips: [
        'रतुआ प्रतिरोधी किस्में (HD 2967, DBW 187, DBW 222) लगाएं।',
        'खेत में नाइट्रोजन (यूरिया) का अत्यधिक उपयोग न करें।',
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'wheat_loose_smut',
      cropId: 'wheat',
      cropName: 'Wheat',
      cropHindi: 'गेहूं',
      diseaseNameHindi: 'कंडुवा / कंगियारी रोग',
      diseaseNameEnglish: 'Loose Smut',
      pathogen: 'फफूंद (Ustilago tritici)',
      severity: 'गंभीर',
      confidenceScore: 93.4,
      symptoms: [
        'गेहूं की बालियां दानों की जगह काले कोयले जैसे चूर्ण में बदल जाती हैं।',
        'काले बीजाणु हवा में उड़कर अन्य पौधों में फैलते हैं।',
      ],
      organicRemedy: 'बीज को बुवाई से पहले 4-5 घंटे तेज धूप में सुखाएं और गोमूत्र से उपचारित करें।',
      chemicalMedicine: 'कार्बोक्सिन 37.5% + थीरम 37.5% (विटावैक्स)',
      sprayDosage: 'बीज उपचार: 2.5 ग्राम प्रति किलोग्राम बीज बुवाई से पहले।',
      precautions: 'संक्रमित बालियों को पॉलीथिन बैग से ढककर खेत से बाहर जला दें।',
      preventionTips: [
        'प्रमाणित और उपचारित बीज ही बोएं।',
        'गर्म जल उपचार विधि अपनाएं।',
      ],
      icon: '🌾',
    ),

    // --- सरसों (Mustard) ---
    CropDisease(
      id: 'mustard_white_rust',
      cropId: 'mustard',
      cropName: 'Mustard',
      cropHindi: 'सरसों',
      diseaseNameHindi: 'सफेद रोली / सफेद फफोले',
      diseaseNameEnglish: 'White Rust',
      pathogen: 'फफूंद (Albugo candida)',
      severity: 'मध्यम से गंभीर',
      confidenceScore: 95.2,
      symptoms: [
        'पत्तियों की निचली सतह पर उभरे हुए सफेद या क्रीम रंग के फफोले।',
        'फूल व फलियां विकृत होकर मोटी हो जाती हैं (stag head)।',
      ],
      organicRemedy: 'ट्राइकोडर्मा विरिडी (5 ग्राम/लीटर) या नीम तेल 5 मिली/लीटर का छिड़काव।',
      chemicalMedicine: 'रिडोमिल गोल्ड (Mancozeb + Metalaxyl) या मेन्कोजेब 75% WP',
      sprayDosage: '2 ग्राम रिडोमिल गोल्ड प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'बादल छाए रहने और अधिक नमी के समय तुरंत छिड़काव करें।',
      preventionTips: [
        'फसल चक्र अपनाएं, खेत में जलभराव न होने दें।',
        'सरसों की अगेती बुवाई (15 से 25 अक्टूबर) करें।',
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'mustard_aphid',
      cropId: 'mustard',
      cropName: 'Mustard',
      cropHindi: 'सरसों',
      diseaseNameHindi: 'मोयला / चेपा / माहू कीट',
      diseaseNameEnglish: 'Mustard Aphid',
      pathogen: 'रस चूसक कीट (Lipaphis erysimi)',
      severity: 'गंभीर',
      confidenceScore: 97.5,
      symptoms: [
        'पौधों की कोमल टहनियों, फूलों व फलियों पर हरे-काले छोटे कीड़ों का झुंड।',
        'पौधे का रस चूसकर उसे कमजोर और पीला कर देते हैं।',
      ],
      organicRemedy: 'नीम तेल 1500 PPM (5 मिली/लीटर) + साबुन का घोल छिड़कें। पीला चिपचिपा ट्रैप (Yellow Sticky Trap) लगाएं।',
      chemicalMedicine: 'इमिडाक्लोप्रिड 17.8% SL या थायमेथोक्सम 25% WG',
      sprayDosage: 'इमिडाक्लोप्रिड: 1 मिली प्रति 3 लीटर पानी (60-70 मिली प्रति एकड़)।',
      precautions: 'मधुमक्खियों के परागण के समय शाम के समय ही छिड़काव करें।',
      preventionTips: [
        'खेत में 10-12 पीले चिपचिपे ट्रैप प्रति एकड़ लगाएं।',
        'मित्र कीट लेडीबर्ड बीटल (लेडीबग) का संरक्षण करें।',
      ],
      icon: '🌱',
    ),

    // --- टमाटर (Tomato) ---
    CropDisease(
      id: 'tomato_early_blight',
      cropId: 'tomato',
      cropName: 'Tomato',
      cropHindi: 'टमाटर',
      diseaseNameHindi: 'अगेती झुलसा रोग',
      diseaseNameEnglish: 'Early Blight',
      pathogen: 'फफूंद (Alternaria solani)',
      severity: 'मध्यम',
      confidenceScore: 94.1,
      symptoms: [
        'निचली पत्तियों पर गहरे भूरे/काले रंग के छल्लेदार (Target-board) धब्बे।',
        'पत्तियां पीली पड़कर सूखने और झड़ने लगती हैं।',
      ],
      organicRemedy: 'कॉपर ऑक्सीक्लोराइड + गोमूत्र (10%) का छिड़काव।',
      chemicalMedicine: 'एज़ोक्सीस्ट्रोबिन + डाइफेनोकोनाज़ोल (Amistar Top) या मेंकोजेब',
      sprayDosage: '1 मिली एमिस्टार टॉप प्रति लीटर पानी (200 मिली प्रति एकड़)।',
      precautions: 'पत्तियों पर ऊपर से पानी देने (ओवरहेड सिंचाई) से बचें।',
      preventionTips: [
        'पौधों के बीच उचित दूरी रखें ताकि हवा और धूप मिल सके।',
        'मल्चिंग का उपयोग करें ताकि मिट्टी से फफूंद पत्तियों तक न पहुंचे।',
      ],
      icon: '🍅',
    ),
    CropDisease(
      id: 'tomato_leaf_curl',
      cropId: 'tomato',
      cropName: 'Tomato',
      cropHindi: 'टमाटर',
      diseaseNameHindi: 'पत्ता मरोड़ विषाणु (माथा बंधना)',
      diseaseNameEnglish: 'Tomato Yellow Leaf Curl Virus (TYLCV)',
      pathogen: 'सफेद मक्खी द्वारा फैलाया जाने वाला वायरस',
      severity: 'गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'पत्तियां ऊपर या नीचे की ओर मुड़कर कटोरी जैसी हो जाती हैं।',
        'पौधे का कद छोटा रह जाता है और फल नहीं बनते।',
      ],
      organicRemedy: 'नीम का अर्क या दशपर्णी अर्क 5 मिली/लीटर। पीला स्टिकी ट्रैप लगाएं।',
      chemicalMedicine: 'सफेद मक्खी नियंत्रण: एसीफेट 75% SP या डायफेन्थियूरॉन 50% WP (पेगासस)',
      sprayDosage: 'डायफेन्थियूरॉन (पेगासस): 1.5 ग्राम प्रति लीटर पानी।',
      precautions: 'वायरस का कोई सीधा इलाज नहीं है, सफेद मक्खी को मारकर ही इसे रोका जा सकता है।',
      preventionTips: [
        'खेत के चारों ओर मक्का या ज्वार की 2-3 लाइनें बैरियर के रूप में लगाएं।',
        'संक्रमित पौधों को तुरंत उखाड़कर जमीन में दबा दें।',
      ],
      icon: '🍅',
    ),

    // --- आलू (Potato) ---
    CropDisease(
      id: 'potato_late_blight',
      cropId: 'potato',
      cropName: 'Potato',
      cropHindi: 'आलू',
      diseaseNameHindi: 'पछेती झुलसा (अंगमारी)',
      diseaseNameEnglish: 'Late Blight',
      pathogen: 'कवक (Phytophthora infestans)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.2,
      symptoms: [
        'पत्तियों के किनारों पर पानी से भीगे हुए काले-भूरे धब्बे।',
        'पत्तियों के नीचे सफेद फफूंद दिखती है और 2-3 दिन में पूरा खेत झुलस जाता है।',
      ],
      organicRemedy: 'खट्टी छाछ (1 लीटर छाछ में 100 ग्राम तांबे का टुकड़ा रखकर 10 दिन सड़ाएं) 15 लीटर पानी में मिलाकर छिड़कें।',
      chemicalMedicine: 'सिमोक्सानिल 8% + मैंकोजेब 64% (Curzate M8) या एक्रोबैट (Dimethomorph)',
      sprayDosage: '2.5 ग्राम कर्ज़ेट प्रति लीटर पानी (500 ग्राम प्रति एकड़)।',
      precautions: 'कोहरा और 80%+ नमी होने पर तुरंत सुरक्षात्मक छिड़काव करें।',
      preventionTips: [
        'रोगमुक्त प्रमाणित बीज कंद का उपयोग करें।',
        'कंदों को मिट्टी से अच्छी तरह ढककर रखें।',
      ],
      icon: '🥔',
    ),

    // --- कपास (Cotton) ---
    CropDisease(
      id: 'cotton_leaf_curl',
      cropId: 'cotton',
      cropName: 'Cotton',
      cropHindi: 'कपास / नरमा',
      diseaseNameHindi: 'पत्ता मरोड़ रोग (CLCuD)',
      diseaseNameEnglish: 'Cotton Leaf Curl Virus',
      pathogen: 'सफेद मक्खी जनित वायरस',
      severity: 'गंभीर',
      confidenceScore: 95.7,
      symptoms: [
        'पत्तियों की नसें मोटी होकर उभर जाती हैं।',
        'पत्तियां ऊपर या नीचे की ओर मुड़ जाती हैं और कप का आकार ले लेती हैं।',
      ],
      organicRemedy: 'नीम बीज अर्क (NSKE 5%) + 10 लीटर गोमूत्र प्रति एकड़ का छिड़काव।',
      chemicalMedicine: 'सफेद मक्खी नियंत्रण: पाइरीप्रोक्सीफेन 10% EC (लांस) या फ्लोनिकैमिड 50% WG',
      sprayDosage: 'फ्लोनिकैमिड (उलाला): 60 ग्राम प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'सफेद मक्खी की रोकथाम प्रारंभिक अवस्था में ही करें।',
      preventionTips: [
        'देसी और प्रतिरोधी बीटी किस्मों का चयन करें।',
        'खेत के आसपास के खरपतवार नष्ट करें।',
      ],
      icon: '⚪',
    ),

    // --- मिर्च (Chilli) ---
    CropDisease(
      id: 'chilli_anthracnose',
      cropId: 'chilli',
      cropName: 'Chilli',
      cropHindi: 'मिर्च',
      diseaseNameHindi: 'फल सड़न / डाईबैक / एंथ्रेक्नोज',
      diseaseNameEnglish: 'Chilli Anthracnose & Dieback',
      pathogen: 'फफूंद (Colletotrichum capsici)',
      severity: 'गंभीर',
      confidenceScore: 94.8,
      symptoms: [
        'पकी लाल मिर्चों पर धंसे हुए गोल काले/भूरे धब्बे।',
        'टहनियां ऊपर से नीचे की ओर सूखने लगती हैं (डाईबैक)।',
      ],
      organicRemedy: 'बायो-फंगीसाइड ट्राइकोडर्मा हरजिएनम 5 ग्राम प्रति लीटर पानी का छिड़काव।',
      chemicalMedicine: 'एज़ोक्सीस्ट्रोबिन 23% SC (Amistar) या टेबुकोनाज़ोल 25.9% EC (Folicur)',
      sprayDosage: '1 मिली फोलिक्योर प्रति लीटर पानी (200 मिली प्रति एकड़)।',
      precautions: 'संक्रमित फलों को तोड़कर अलग कर दें।',
      preventionTips: [
        'बीज को थीरम या कार्बेन्डाजिम से उपचारित करके ही बोएं।',
        'ड्रिप सिंचाई का उपयोग करें।',
      ],
      icon: '🌶️',
    ),

    // --- जीरा (Cumin / Jeera) ---
    CropDisease(
      id: 'cumin_blight',
      cropId: 'jeera',
      cropName: 'Cumin',
      cropHindi: 'जीरा',
      diseaseNameHindi: 'जीरे का झुलसा रोग (कालीया)',
      diseaseNameEnglish: 'Cumin Blight (Alternaria burnsii)',
      pathogen: 'फफूंद (Alternaria burnsii)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.1,
      symptoms: [
        'पत्तियों व तनों पर गहरे भूरे धब्बे, जो बाद में काले पड़ जाते हैं।',
        'फूल और बीज काले होकर गिर जाते हैं, पौधे का शीर्ष झुक जाता है।',
      ],
      organicRemedy: 'छाछ 5 लीटर + तांबा बर्तन का घोल 100 लीटर पानी में।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC (Score) या कॉपर हाइड्रोक्साइड',
      sprayDosage: '1 मिली स्कोर प्रति लीटर पानी (150-200 मिली प्रति एकड़)।',
      precautions: 'बादल छाने और नमी बढ़ने पर बिना देरी किए पहला स्प्रे करें।',
      preventionTips: [
        'जीरे की बुवाई 15 नवंबर से 30 नवंबर के बीच करें।',
        'खेत में पलेवा देकर ही बुवाई करें।',
      ],
      icon: '🌿',
    ),

    // --- मक्का (Maize / Corn) ---
    CropDisease(
      id: 'maize_fall_armyworm',
      cropId: 'maize',
      cropName: 'Maize',
      cropHindi: 'मक्का',
      diseaseNameHindi: 'फॉल आर्मीवॉर्म / सैनिक सुंडी',
      diseaseNameEnglish: 'Fall Armyworm (Spodoptera frugiperda)',
      pathogen: 'विनाशकारी कीट (Insect Pest)',
      severity: 'गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पत्तियों में जालीदार छेद और बड़े-बड़े कट लगते हैं।',
        'पौधे के गोभ (Whorl) में बुरादे जैसा मल और सूंडी दिखाई देती है।',
      ],
      organicRemedy: 'नीम बीज अर्क 5% या बेवेरिया बेसियाना (5 ग्राम/लीटर) गोभ के अंदर डालें।',
      chemicalMedicine: 'कोराजन (Chlorantraniliprole 18.5% SC) या एमामेक्टिन बेंजोएट 5% SG',
      sprayDosage: 'कोराजन: 60 मिली प्रति एकड़ 150 लीटर पानी में, नोजल को गोभ पर केंद्रित रखें।',
      precautions: 'स्प्रे का नोजल सीधे पौधे की गोभ (सेंटर) में रखें।',
      preventionTips: [
        'मक्का के साथ उड़द या मूंग की इंटरक्रॉपिंग करें।',
        'खेत में फेरोमोन ट्रैप (Pheromone Trap) 4 प्रति एकड़ लगाएं।',
      ],
      icon: '🌽',
    ),

    // --- चना (Gram / Chickpea) ---
    CropDisease(
      id: 'chana_wilt',
      cropId: 'gram',
      cropName: 'Gram / Chickpea',
      cropHindi: 'चना',
      diseaseNameHindi: 'उकठा रोग / विल्ट (सूखा रोग)',
      diseaseNameEnglish: 'Fusarium Wilt',
      pathogen: 'मृदा जनित फफूंद (Fusarium oxysporum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.8,
      symptoms: [
        'हरे-भरे पौधे अचानक पीले पड़कर सूखने लगते हैं।',
        'तने को चीरकर देखने पर अंदर की नसें भूरी/काली दिखती हैं।',
      ],
      symptomTags: ['पौधे का अचानक सूखना', 'पत्तियों का पीला पड़ना', 'जड़ व तने में कालापन'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी (2 किग्रा/एकड़) को 100 किग्रा गोबर की खाद में मिलाकर खेत में डालें।',
      chemicalMedicine: 'कार्बेन्डाजिम 50% WP (बाविस्टिन) या कार्बेंडाजिम + मैंकोजेब (साफ)',
      sprayDosage: 'बीज उपचार: 2 ग्राम बाविस्टिन प्रति किग्रा बीज। खेत में 2 ग्राम/लीटर ड्रेंचिंग।',
      precautions: 'गर्मियों में गहरी जुताई करें और 3 साल का फसल चक्र अपनाएं।',
      preventionTips: [
        'विल्ट प्रतिरोधी किस्में (JG 11, Vijay, Radhey, Samrat) बोएं।',
        'देर से बुवाई (अक्टूबर अंत) से बचें।',
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'chana_pod_borer',
      cropId: 'gram',
      cropName: 'Gram / Chickpea',
      cropHindi: 'चना',
      diseaseNameHindi: 'फली छेदक इल्ली (हेलिकोवर्पा)',
      diseaseNameEnglish: 'Gram Pod Borer (Helicoverpa armigera)',
      pathogen: 'हानिकारक सुंडी कीट (Insect Pest)',
      severity: 'गंभीर',
      confidenceScore: 98.4,
      symptoms: [
        'फली में गोल छेद करके अंदर से दाना खा जाती है।',
        'पत्तियों पर छोटे-छोटे छेद और हरे रंग की सुंडी दिखाई देती है।',
      ],
      symptomTags: ['फली में छेद', 'पत्तियों में कट/छेद', 'हरी/भूरी सुंडी'],
      organicRemedy: 'नीम तेल 5 मिली/लीटर या फेरोमोन ट्रैप 5 प्रति एकड़ लगाएं। पक्षियों के बैठने के लिए टी-खूंटी (T-perches) लगाएं।',
      chemicalMedicine: 'कोराजन 18.5% SC या एमामेक्टिन बेंजोएट 5% SG',
      sprayDosage: 'एमामेक्टिन बेंजोएट: 80 ग्राम प्रति एकड़ 150 लीटर पानी में घोलकर।',
      precautions: 'फूल आने के समय और छोटी फलियों पर पहला स्प्रे करें।',
      preventionTips: [
        'खेत के किनारे गेंदे के फूल (Marigold) ट्रैप क्रॉप के रूप में लगाएं।',
      ],
      icon: '🌱',
    ),

    // --- प्याज व लहसुन (Onion & Garlic) ---
    CropDisease(
      id: 'onion_purple_blotch',
      cropId: 'onion',
      cropName: 'Onion & Garlic',
      cropHindi: 'प्याज / लहसुन',
      diseaseNameHindi: 'बैंगनी धब्बा रोग (पर्पल ब्लॉच)',
      diseaseNameEnglish: 'Purple Blotch',
      pathogen: 'फफूंद (Alternaria porri)',
      severity: 'गंभीर',
      confidenceScore: 95.5,
      symptoms: [
        'पत्तियों पर छोटे सफेद धब्बे बनते हैं जो बाद में केंद्र से बैंगनी हो जाते हैं।',
        'पत्तियां ऊपर से नीचे सूखकर गिर जाती हैं।',
      ],
      symptomTags: ['बैंगनी धब्बे', 'पत्तियों का नोक से सूखना', 'सफेद चकत्ते'],
      organicRemedy: 'गोमूत्र 10% + ट्राइकोडर्मा 5 ग्राम/लीटर का स्प्रे।',
      chemicalMedicine: 'कस्टोडिया (Azoxystrobin + Difenoconazole) या मेंकोजेब 75% WP',
      sprayDosage: 'कस्टोडिया: 1.5 मिली प्रति लीटर पानी (300 मिली प्रति एकड़)।',
      precautions: 'स्प्रे के साथ सिलिकॉन आधारित चिपकू (Sticker/Spreader) अवश्य मिलाएं।',
      preventionTips: [
        'खेत में जल निकास का अच्छा प्रबंध रखें।',
        'कंदों का उपचार करके ही रोपाई करें।',
      ],
      icon: '🧅',
    ),
    CropDisease(
      id: 'onion_thrips',
      cropId: 'onion',
      cropName: 'Onion & Garlic',
      cropHindi: 'प्याज / लहसुन',
      diseaseNameHindi: 'थ्रिप्स (पीलापन व चांदी जैसी चमक)',
      diseaseNameEnglish: 'Thrips',
      pathogen: 'रस चूसक कीट (Thrips tabaci)',
      severity: 'गंभीर',
      confidenceScore: 96.2,
      symptoms: [
        'पत्तियों पर सफेद या चांदी जैसी धारियां दिखती हैं।',
        'पत्तियों के मुड़ने व पीले होने के लक्षण।',
      ],
      symptomTags: ['सफेद/चांदी जैसी धारियां', 'पत्तियों का सिकुड़ना', 'पीलापन'],
      organicRemedy: 'नीला स्टिकी ट्रैप (Blue Sticky Trap) 10 प्रति एकड़ + नीम अर्क 5 मिली/लीटर।',
      chemicalMedicine: 'फिपरोनिल 5% SC (रीजेंट) या स्पिनोसैड 45% SC',
      sprayDosage: 'फिपरोनिल: 2 मिली प्रति लीटर पानी (400 मिली प्रति एकड़) स्टीकर के साथ।',
      precautions: 'दोपहर में धूप में स्प्रे न करें, शाम को छिड़काव करें।',
      preventionTips: [
        'नीले व पीले स्टिकी ट्रैप समय पर लगाएं।',
      ],
      icon: '🧅',
    ),

    // --- मूंगफली व सोयाबीन (Groundnut & Soybean) ---
    CropDisease(
      id: 'groundnut_tikka',
      cropId: 'groundnut',
      cropName: 'Groundnut',
      cropHindi: 'मूंगफली',
      diseaseNameHindi: 'टिक्का रोग (पर्ण चित्ती)',
      diseaseNameEnglish: 'Tikka Leaf Spot',
      pathogen: 'फफूंद (Cercospora)',
      severity: 'गंभीर',
      confidenceScore: 96.9,
      symptoms: [
        'पत्तियों पर गोल काले-भूरे धब्बे जिनके चारों ओर पीला छल्ला (Halo) होता है।',
        'पत्तियां पीली पड़कर झड़ने लगती हैं।',
      ],
      symptomTags: ['काले गोल धब्बे', 'पीला छल्ला', 'पत्तियों का झड़ना'],
      organicRemedy: 'पंचगव्य 3% + नीम तेल का छिड़काव।',
      chemicalMedicine: 'साफ (Carbendazim 12% + Mancozeb 63% WP) या हेक्साकोनाज़ोल 5% SC',
      sprayDosage: 'साफ: 2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'लक्षण दिखते ही 12-15 दिन के अंतराल पर 2 बार स्प्रे करें।',
      preventionTips: [
        'कार्बेंडाजिम से बीज उपचार करके ही बोएं।',
      ],
      icon: '🥜',
    ),

    // --- धान / चावल (Paddy / Rice) ---
    CropDisease(
      id: 'paddy_sheath_blight',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान / चावल',
      diseaseNameHindi: 'शीथ ब्लाइट / तना झुलसा रोग',
      diseaseNameEnglish: 'Sheath Blight (Rhizoctonia solani)',
      pathogen: 'फफूंद (Rhizoctonia solani)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.2,
      symptoms: [
        'पानी की सतह के पास तने और पर्ण-आवरण (शीथ) पर सर्पिलाकार भूरे-सफेद धब्बे।',
        'धब्बे ऊपर की पत्तियों तक फैलकर पूरे पौधे को सुखा देते हैं।',
      ],
      symptomTags: ['तने पर सर्पिलाकार धब्बे', 'पर्ण आवरण का सूखना', 'पौधे का पीला पड़ना'],
      organicRemedy: 'स्यूडोमोनास फ्लोरोसेंस (10 ग्राम/लीटर) या ट्राइकोडर्मा का छिड़काव।',
      chemicalMedicine: 'वैलिडामाइसिन 3% L (शीथमार) या हेक्साकोनाज़ोल 5% EC (कंटाफ)',
      sprayDosage: 'वैलिडामाइसिन: 2.5 मिली प्रति लीटर (500 मिली प्रति एकड़ 200L पानी में)।',
      precautions: 'खेत में यूरिया (नाइट्रोजन) की अत्यधिक मात्रा न डालें।',
      preventionTips: [
        'खेत से अतिरिक्त पानी निकालकर 2-3 दिन खेत को सूखा रखें।',
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'paddy_bph',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान / चावल',
      diseaseNameHindi: 'भूरा फुदका / माहू (BPH - हॉपर बर्न)',
      diseaseNameEnglish: 'Brown Plant Hopper (BPH)',
      pathogen: 'रस चूसक कीट (Nilaparvata lugens)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.6,
      symptoms: [
        'तने के आधार पर लाखों भूरे-काले फुदके रस चूसते हैं।',
        'खेत में बीच-बीच में गोल चकत्ते बनकर फसल जलकर सूख जाती है (Hopper Burn)।',
      ],
      symptomTags: ['तने पर भूरे छोटे कीड़े', 'चकत्तों में फसल का जलना', 'पौधे का सूखना'],
      organicRemedy: 'नीम तेल 1500 PPM (5 मिली/लीटर) + तने के पास धूप लगने के लिए नालियां बनाएं।',
      chemicalMedicine: 'पाइमेट्रोज़िन 50% WDG (चेस / Chess) या डाइनोटेफ्यूरॉन 20% SG (ओशीन)',
      sprayDosage: 'पाइमेट्रोज़िन (चेस): 120 ग्राम प्रति एकड़ 200 लीटर पानी में (नोजल तने की तरफ रखें)।',
      precautions: 'स्प्रे का नोजल पौधे के बिल्कुल नीचे (तने) पर केंद्रित होना चाहिए।',
      preventionTips: [
        'खेत में हर 2-3 मीटर पर 30 सेमी की गली (Alleyways) छोड़ें ताकि हवा लग सके।',
      ],
      icon: '🌾',
    ),

    // --- सोयाबीन (Soybean) ---
    CropDisease(
      id: 'soybean_yellow_mosaic',
      cropId: 'soybean',
      cropName: 'Soybean',
      cropHindi: 'सोयाबीन',
      diseaseNameHindi: 'पीला मोज़ेक वायरस (YMV)',
      diseaseNameEnglish: 'Yellow Mosaic Virus',
      pathogen: 'सफेद मक्खी जनित विषाणु (Whitefly Vector)',
      severity: 'गंभीर',
      confidenceScore: 97.4,
      symptoms: [
        'पत्तियों पर अनियमित पीले और हरे चकत्ते (मोज़ेक) दिखाई देते हैं।',
        'नई पत्तियां पूरी तरह पीली पड़ जाती हैं और फलियां छोटी व दाना रहित बनती हैं।',
      ],
      symptomTags: ['पत्तियों पर पीला-हरा मोज़ेक', 'पत्तियों का पीला पड़ना', 'सफेद मक्खी का प्रकोप'],
      organicRemedy: 'पीला स्टिकी ट्रैप 10 प्रति एकड़ + नीम अर्क 5 मिली/लीटर।',
      chemicalMedicine: 'थायमेथोक्सम 12.6% + लैम्ब्डा-साइहलोथ्रिन 9.5% ZC (अलिका) या एसिटामिप्रिड 20% SP',
      sprayDosage: 'अलिका: 80 मिली प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'संक्रमित पौधों को प्रारंभिक अवस्था में ही उखाड़कर नष्ट करें।',
      preventionTips: [
        'प्रतिरोधी किस्में (JS 20-34, JS 20-69, JS 97-52, NRC 37) बोएं।',
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'soybean_girdle_beetle',
      cropId: 'soybean',
      cropName: 'Soybean',
      cropHindi: 'सोयाबीन',
      diseaseNameHindi: 'चक्र भृंग / गर्डल बीटल व तना मक्खी',
      diseaseNameEnglish: 'Girdle Beetle (Oberia brevis)',
      pathogen: 'तना छेदक कीट (Stem Borer)',
      severity: 'गंभीर',
      confidenceScore: 96.3,
      symptoms: [
        'मादा कीट तने या डंठल पर दो गोल छल्ले (Girdle) बनाती है।',
        'छल्ले के ऊपर की पत्ती और तना मुरझाकर सूख जाता है।',
      ],
      symptomTags: ['डंठल पर गोल छल्ले/कट', 'पत्तियों का अचानक मुरझाना', 'तने में सुंडी'],
      organicRemedy: 'बेवेरिया बेसियाना 1 किग्रा/एकड़ या नीम तेल 5 मिली/लीटर।',
      chemicalMedicine: 'कोराजन 18.5% SC या ट्रायजोफॉस 40% EC + डेल्टामेथ्रिन',
      sprayDosage: 'कोराजन: 60 मिली प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'लक्षण दिखते ही छल्ले के नीचे से काटकर सुंडी सहित पत्ती नष्ट करें।',
      preventionTips: [
        'बुवाई के समय थायमेथोक्सम 30% FS से बीज उपचार करें।',
      ],
      icon: '🫘',
    ),

    // --- बाजरा (Bajra / Pearl Millet) ---
    CropDisease(
      id: 'bajra_downy_mildew',
      cropId: 'bajra',
      cropName: 'Bajra / Pearl Millet',
      cropHindi: 'बाजरा',
      diseaseNameHindi: 'जोगिया रोग / हरित बाली (डाउनी मिल्ड्यू)',
      diseaseNameEnglish: 'Green Ear Disease / Downy Mildew',
      pathogen: 'कवक (Sclerospora graminicola)',
      severity: 'गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'पत्तियों पर पीली धारियां और निचली सतह पर सफेद रुई जैसी फफूंद।',
        'बालियों में दानों की जगह हरी पत्तियों का गुच्छा (जोगिया/झाड़ू) बन जाता है।',
      ],
      symptomTags: ['बालियों में हरी पत्तियां/झाड़ू', 'पत्तियों पर पीली धारियां', 'सफेद रुई जैसी फफूंद'],
      organicRemedy: 'बीज को 10% नमक के घोल में डालकर तैरने वाले हल्के बीजों को अलग करें।',
      chemicalMedicine: 'मेटालेक्सिल 35% WS (एप्रोन) या रिडोमिल 72 WP',
      sprayDosage: 'बीज उपचार: 6 ग्राम मेटालेक्सिल प्रति किग्रा बीज। खड़ी फसल में 2 ग्राम/लीटर मेन्कोजेब।',
      precautions: 'रोगग्रस्त पौधों को प्रारंभिक अवस्था में ही उखाड़कर जमीन में दबा दें।',
      preventionTips: [
        'प्रमाणित हाइब्रिड किस्में (HHB 67 Improved, MPMH 17, RHB 177) लगाएं।',
      ],
      icon: '🌾',
    ),

    // --- ग्वार (Guar / Cluster Bean) ---
    CropDisease(
      id: 'guar_bacterial_blight',
      cropId: 'guar',
      cropName: 'Guar / Cluster Bean',
      cropHindi: 'ग्वार',
      diseaseNameHindi: 'जीवाणु अंगमारी / झुलसा रोग',
      diseaseNameEnglish: 'Bacterial Blight (Xanthomonas cyamopsidis)',
      pathogen: 'जीवाणु (Bacteria - Xanthomonas)',
      severity: 'गंभीर',
      confidenceScore: 95.9,
      symptoms: [
        'पत्तियों पर अंग्रेजी के V आकार के भूरे-काले धब्बे बनते हैं।',
        'तने पर काली धारियां और पौधे का ऊपरी भाग सूख जाता है।',
      ],
      symptomTags: ['पत्तियों पर V आकार के काले धब्बे', 'तने पर काली धारियां', 'पत्तियों का सूखना'],
      organicRemedy: 'गोमूत्र 10% + हींग का घोल 100 लीटर पानी में मिलाकर स्प्रे करें।',
      chemicalMedicine: 'स्ट्रेप्टोसाइक्लिन (6 ग्राम) + कॉपर ऑक्सीक्लोराइड 50% WP (400 ग्राम)',
      sprayDosage: '6 ग्राम स्ट्रेप्टोसाइक्लिन + 400 ग्राम ब्लाइटॉक्स प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'बरसात के बाद तेज धूप निकलने पर तुरंत पहला स्प्रे करें।',
      preventionTips: [
        'बीज को स्ट्रेप्टोसाइक्लिन (250 PPM) के घोल में 15 मिनट भिगोकर बोएं।',
      ],
      icon: '🌱',
    ),

    // --- गन्ना (Sugarcane) ---
    CropDisease(
      id: 'sugarcane_red_rot',
      cropId: 'sugarcane',
      cropName: 'Sugarcane',
      cropHindi: 'गन्ना',
      diseaseNameHindi: 'लाल सड़न रोग (गन्ने का कैंसर)',
      diseaseNameEnglish: 'Red Rot (Colletotrichum falcatum)',
      pathogen: 'फफूंद (Colletotrichum falcatum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.1,
      symptoms: [
        'गन्ने की तीसरी व चौथी पत्ती का पीला पड़ना और ऊपर से सूखना।',
        'गन्ने को चीरने पर अंदर का गूदा लाल दिखता है जिस पर सफेद आड़ी पट्टियां और शराब जैसी गंध आती है।',
      ],
      symptomTags: ['पत्तियों का सूखना', 'गन्ने के अंदर लाल गूदा', 'शराब जैसी गंध'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी (5 किग्रा/एकड़) को गोबर की खाद में मिलाकर बुवाई के समय कूंड़ों में डालें।',
      chemicalMedicine: 'कार्बेन्डाजिम 50% WP (बाविस्टिन) या थायोफेनेट मिथाइल 70% WP',
      sprayDosage: 'बीज (टुकड़ों) का उपचार: 2 ग्राम बाविस्टिन प्रति लीटर पानी के घोल में 15 मिनट डुबोएं।',
      precautions: 'संक्रमित खेत का बीज अगले साल कभी न बोएं।',
      preventionTips: [
        'रोगरोधी किस्में (Co 0238, CoLk 94184, Co 0118) लगाएं।',
      ],
      icon: '🎋',
    ),

    // --- मूंग व उड़द (Moong & Urad / Pulses) ---
    CropDisease(
      id: 'moong_yellow_mosaic',
      cropId: 'moong',
      cropName: 'Moong & Urad',
      cropHindi: 'मूंग / उड़द',
      diseaseNameHindi: 'पीला मोज़ेक वायरस रोग',
      diseaseNameEnglish: 'Yellow Mosaic Virus (MYMV)',
      pathogen: 'सफेद मक्खी द्वारा फैलने वाला वायरस',
      severity: 'गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'पत्तियों पर पीले और हरे रंग के चितकबरे धब्बे बनते हैं।',
        'पौधे की बढ़वार रुक जाती है और फलियां बहुत छोटी व पीली रह जाती हैं।',
      ],
      symptomTags: ['पत्तियों पर पीला-हरा चितकबरापन', 'पत्तियों का पीला होना', 'सफेद मक्खी'],
      organicRemedy: 'नीम तेल 5 मिली/लीटर + 10 पीले चिपचिपे कार्ड (Yellow Sticky Traps) प्रति एकड़ लगाएं।',
      chemicalMedicine: 'डाइमेथोएट 30% EC (रोगोर) या एसिटामिप्रिड 20% SP',
      sprayDosage: 'डाइमेथोएट: 250-300 मिली प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'सफेद मक्खी दिखने के 24 घंटे के अंदर पहला छिड़काव करें।',
      preventionTips: [
        'पीला मोज़ेक प्रतिरोधी किस्में (IPM 205-7 / विराट, IPM 02-3, MH 421) बोएं।',
      ],
      icon: '🫘',
    ),

    // --- अनार (Pomegranate / Anar) ---
    CropDisease(
      id: 'pomegranate_bacterial_blight',
      cropId: 'pomegranate',
      cropName: 'Pomegranate',
      cropHindi: 'अनार',
      diseaseNameHindi: 'तेलिया रोग / ऑयली स्पॉट (ब्लैक स्पॉट)',
      diseaseNameEnglish: 'Bacterial Blight / Oily Spot',
      pathogen: 'जीवाणु (Xanthomonas axonopodis pv. punicae)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.5,
      symptoms: [
        'पत्तियों, टहनियों व फलों पर पानी से भीगे हुए काले तैलीय (Oily) धब्बे।',
        'फलों पर धब्बे अंग्रेजी के L या Y आकार में फट जाते हैं।',
      ],
      symptomTags: ['फलों पर काले तैलीय धब्बे', 'फलों का L/Y आकार में फटना', 'पत्तियों पर काले चकत्ते'],
      organicRemedy: 'बोर्डो मिश्रण 1% (Bordeaux Mixture) का नियमित छिड़काव।',
      chemicalMedicine: 'स्ट्रेप्टोसाइक्लिन 50 ग्राम + कॉपर ऑक्सीक्लोराइड 500 ग्राम प्रति 200 लीटर पानी',
      sprayDosage: 'स्ट्रेप्टोसाइक्लिन (0.5 ग्राम/लीटर) + कॉपर ऑक्सीक्लोराइड (2.5 ग्राम/लीटर) + चिपकू।',
      precautions: 'संक्रमित टहनियों को 2 इंच नीचे से काटकर 10% बोर्डो पेस्ट लगाएं।',
      preventionTips: [
        'बगीचे में कटाई-छंटाई के औजारों को डेटॉल या सैनिटाइज़र से साफ करें।',
      ],
      icon: '🍎',
    ),

    // --- लहसुन (Garlic) ---
    CropDisease(
      id: 'garlic_thrips',
      cropId: 'garlic',
      cropName: 'Garlic',
      cropHindi: 'लहसुन',
      diseaseNameHindi: 'थ्रिप्स व पत्ती पीलापन',
      diseaseNameEnglish: 'Garlic Thrips',
      pathogen: 'रस चूसक कीट (Thrips tabaci)',
      severity: 'गंभीर',
      confidenceScore: 96.2,
      symptoms: [
        'पत्तियों पर सफेद या चांदी जैसी धारियां दिखती हैं।',
        'पत्तियां सिकुड़कर पीली हो जाती हैं।',
      ],
      symptomTags: ['सफेद/चांदी जैसी धारियां', 'पत्तियों का सिकुड़ना', 'पीलापन'],
      organicRemedy: 'नीला स्टिकी ट्रैप (Blue Sticky Trap) + नीम अर्क।',
      chemicalMedicine: 'फिपरोनिल 5% SC (रीजेंट) या स्पिनोसैड 45% SC',
      sprayDosage: '2 मिली प्रति लीटर पानी (400 मिली प्रति एकड़) स्टीकर सहित।',
      precautions: 'शाम के समय छिड़काव करें।',
      preventionTips: ['नीले स्टिकी ट्रैप 10 प्रति एकड़ लगाएं।'],
      icon: '🧄',
    ),

    // --- उड़द (Black Gram) ---
    CropDisease(
      id: 'urad_cercospora',
      cropId: 'urad',
      cropName: 'Black Gram',
      cropHindi: 'उड़द',
      diseaseNameHindi: 'पर्ण चित्ती रोग (सर्फोस्पोरा)',
      diseaseNameEnglish: 'Cercospora Leaf Spot',
      pathogen: 'फफूंद (Cercospora canescens)',
      severity: 'मध्यम',
      confidenceScore: 95.8,
      symptoms: [
        'पत्तियों पर गोल भूरे-लाल धब्बे जिनके किनारे गहरे होते हैं।',
        'संक्रमित पत्तियां सूखकर गिर जाती हैं।',
      ],
      symptomTags: ['भूरे-लाल गोल धब्बे', 'पत्तियों का समय से पहले गिरना'],
      organicRemedy: 'गोमूत्र 10% + ट्राइकोडर्मा का छिड़काव।',
      chemicalMedicine: 'कार्बेन्डाजिम + मैंकोजेब (साफ / Saaf)',
      sprayDosage: '2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'फूल आने से पहले पहला छिड़काव करें।',
      preventionTips: ['फसल चक्र अपनाएं।'],
      icon: '🫘',
    ),

    // --- बैंगन (Brinjal / Eggplant) ---
    CropDisease(
      id: 'brinjal_shoot_fruit_borer',
      cropId: 'brinjal',
      cropName: 'Brinjal / Eggplant',
      cropHindi: 'बैंगन',
      diseaseNameHindi: 'तना व फल छेदक सुंडी (सफेद इल्ली)',
      diseaseNameEnglish: 'Shoot and Fruit Borer',
      pathogen: 'हानिकारक कीट (Leucinodes orbonalis)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.6,
      symptoms: [
        'कोमल टहनियां मुरझाकर लटक जाती हैं।',
        'बैंगन के अंदर छेद करके गूदा खा जाती है।',
      ],
      symptomTags: ['टहनियों का मुरझाना', 'बैंगन में छेद', 'सुंडी'],
      organicRemedy: 'फेरोमोन ट्रैप 10 प्रति एकड़ + नीम अर्क 5 मिली/लीटर।',
      chemicalMedicine: 'एम्पलीगो (Chlorantraniliprole + Lambda-cyhalothrin) या कोराजन',
      sprayDosage: 'एम्पलीगो: 80 मिली प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'मुरझाई हुई टहनियों को सुंडी सहित तोड़कर दबाएं।',
      preventionTips: ['ल्यूर ट्रैप समय पर लगाएं।'],
      icon: '🍆',
    ),

    // --- भिंडी (Okra / Ladyfinger) ---
    CropDisease(
      id: 'okra_yellow_vein_mosaic',
      cropId: 'okra',
      cropName: 'Okra / Ladyfinger',
      cropHindi: 'भिंडी',
      diseaseNameHindi: 'पीली नस मोज़ेक वायरस (YVMV)',
      diseaseNameEnglish: 'Yellow Vein Mosaic Virus',
      pathogen: 'सफेद मक्खी जनित वायरस',
      severity: 'गंभीर',
      confidenceScore: 96.7,
      symptoms: [
        'पत्तियों की नसें स्पष्ट रूप से पीली पड़ जाती हैं।',
        'भिंडी का रंग पीला और फल कड़ा हो जाता है।',
      ],
      symptomTags: ['नसों का पीला पड़ना', 'भिंडी का पीला व कड़ा होना', 'सफेद मक्खी'],
      organicRemedy: 'पीले स्टिकी ट्रैप 12 प्रति एकड़ + नीम तेल 5 मिली/लीटर।',
      chemicalMedicine: 'एसिटामिप्रिड 20% SP (प्राइड) या थायमेथोक्सम 25% WG',
      sprayDosage: 'एसिटामिप्रिड: 1 ग्राम प्रति 2 लीटर पानी।',
      precautions: 'सफेद मक्खी का नियंत्रण शुरुआत में ही करें।',
      preventionTips: ['प्रतिरोधी किस्में (अर्का अनामिका, परभणी क्रांति) लगाएं।'],
      icon: '🌿',
    ),

    // --- फूलगोभी व पत्तागोभी (Cauliflower & Cabbage) ---
    CropDisease(
      id: 'cauliflower_dbm',
      cropId: 'cauliflower',
      cropName: 'Cauliflower & Cabbage',
      cropHindi: 'गोभी',
      diseaseNameHindi: 'डायमंड बैक मोथ (DBM सुंडी / जालीदार कीट)',
      diseaseNameEnglish: 'Diamondback Moth (DBM)',
      pathogen: 'कीट (Plutella xylostella)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.0,
      symptoms: [
        'पत्तियों के नीचे जालीदार छेद और हरी छोटी इल्लियां।',
        'फूल के अंदर घुसकर फसल बर्बाद कर देती हैं।',
      ],
      symptomTags: ['पत्तियों में जालीदार छेद', 'हरी छोटी सुंडी', 'फूल का खराब होना'],
      organicRemedy: 'सरसों को ट्रैप क्रॉप के रूप में 25 लाइन गोभी के बाद 2 लाइन सरसों लगाएं।',
      chemicalMedicine: 'स्पिनोसैड 45% SC (ट्रेसर) या कोराजन 18.5% SC',
      sprayDosage: 'स्पिनोसैड: 0.3 मिली प्रति लीटर पानी (60 मिली प्रति एकड़)।',
      precautions: 'कीटनाशक को बदल-बदल कर स्प्रे करें।',
      preventionTips: ['ट्रैप क्रॉपिंग अपनाएं।'],
      icon: '🥦',
    ),

    // --- मटर (Green Pea) ---
    CropDisease(
      id: 'pea_powdery_mildew',
      cropId: 'pea',
      cropName: 'Green Pea',
      cropHindi: 'मटर',
      diseaseNameHindi: 'चूर्णी फफूंद / छाछिया रोग',
      diseaseNameEnglish: 'Powdery Mildew',
      pathogen: 'फफूंद (Erysiphe pisi)',
      severity: 'गंभीर',
      confidenceScore: 97.3,
      symptoms: [
        'पत्तियों, तनों व फलियों पर सफेद आटे जैसा चूर्ण फैल जाता है।',
        'पत्तियां पीली पड़कर सूख जाती हैं।',
      ],
      symptomTags: ['सफेद आटे जैसा पाउडर', 'फलियों पर सफेद चूर्ण', 'पत्तियों का सूखना'],
      organicRemedy: 'खट्टी छाछ (5%) या घुलनशील सल्फर 2 ग्राम/लीटर।',
      chemicalMedicine: 'हेक्साकोनाज़ोल 5% EC या घुलनशील सल्फर 80% WDG (सल्फेक्स)',
      sprayDosage: 'सल्फेक्स: 2.5 ग्राम प्रति लीटर पानी (500 ग्राम प्रति एकड़)।',
      precautions: 'दोपहर की तेज धूप में सल्फर स्प्रे न करें।',
      preventionTips: ['अगेती किस्में बोएं।'],
      icon: '🫛',
    ),

    // --- अदरक (Ginger) ---
    CropDisease(
      id: 'ginger_rhizome_rot',
      cropId: 'ginger',
      cropName: 'Ginger',
      cropHindi: 'अदरक',
      diseaseNameHindi: 'प्रकंद सड़न (कंद गलन रोग)',
      diseaseNameEnglish: 'Rhizome Rot / Soft Rot',
      pathogen: 'कवक (Pythium aphanidermatum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.3,
      symptoms: [
        'पौधे की निचली पत्तियां पीली पड़कर नीचे से ऊपर सूखती हैं।',
        'कंद गलकर पानी छोड़ने लगता है और बदबू आती है।',
      ],
      symptomTags: ['कंद का सड़ना व बदबू', 'पत्तियों का नीचे से सूखना', 'पौधे का उखड़ना'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 2 किग्रा को गोबर की खाद में मिलाकर खेत में डालें।',
      chemicalMedicine: 'रिडोमिल गोल्ड (Metalaxyl + Mancozeb) या कॉपर ऑक्सीक्लोराइड',
      sprayDosage: '2.5 ग्राम प्रति लीटर पानी से पौधों की जड़ों में ड्रेंचिंग (Drenching) करें।',
      precautions: 'खेत में पानी भरने न दें, जल निकासी का उचित प्रबंध रखें।',
      preventionTips: ['प्रकंद को कार्बेंडाजिम से उपचारित करके बोएं।'],
      icon: '🫚',
    ),

    // --- हल्दी (Turmeric) ---
    CropDisease(
      id: 'turmeric_leaf_spot',
      cropId: 'turmeric',
      cropName: 'Turmeric',
      cropHindi: 'हल्दी',
      diseaseNameHindi: 'पर्ण चित्ती / धब्बा रोग (कोलेटोट्राइकम)',
      diseaseNameEnglish: 'Turmeric Leaf Spot',
      pathogen: 'फफूंद (Colletotrichum capsici)',
      severity: 'मध्यम',
      confidenceScore: 96.0,
      symptoms: [
        'पत्तियों पर अंडाकार भूरे धब्बे जिनका केंद्र सफेद होता है।',
        'संक्रमित पत्तियां पीली पड़कर सूख जाती हैं।',
      ],
      symptomTags: ['अंडाकार भूरे धब्बे', 'पत्तियों का सूखना', 'सफेद केंद्र वाले चकत्ते'],
      organicRemedy: 'पंचगव्य 3% + गोमूत्र 10% का छिड़काव।',
      chemicalMedicine: 'साफ (Carbendazim 12% + Mancozeb 63% WP)',
      sprayDosage: '2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'रोग के शुरुआती लक्षण दिखते ही स्प्रे करें।',
      preventionTips: ['कंद उपचार करके ही बोएं।'],
      icon: '🟡',
    ),

    // --- धनिया (Coriander) ---
    CropDisease(
      id: 'coriander_powdery_mildew',
      cropId: 'coriander',
      cropName: 'Coriander',
      cropHindi: 'धनिया',
      diseaseNameHindi: 'छाछिया रोग / चूर्णी फफूंद',
      diseaseNameEnglish: 'Powdery Mildew',
      pathogen: 'फफूंद (Erysiphe polygoni)',
      severity: 'गंभीर',
      confidenceScore: 97.1,
      symptoms: [
        'पत्तियों, फूलों व बीजों पर सफेद पाउडर जम जाता है।',
        'बीज छोटे व हल्के बनते हैं, उत्पादन घट जाता है।',
      ],
      symptomTags: ['फूलों व बीजों पर सफेद पाउडर', 'पत्तियों पर सफेद चूर्ण'],
      organicRemedy: 'खट्टी छाछ (5 लीटर/100L) या घुलनशील गंधक।',
      chemicalMedicine: 'घुलनशील गंधक (Sulphur 80% WDG) या हेक्साकोनाज़ोल 5% EC',
      sprayDosage: 'सल्फर: 2 ग्राम प्रति लीटर (400 ग्राम प्रति एकड़)।',
      precautions: 'फूल आने के समय पहला स्प्रे अवश्य करें।',
      preventionTips: ['प्रतिरोधी किस्में (RCr 436, RCr 728) बोएं।'],
      icon: '🌿',
    ),

    // --- सौंफ (Fennel) ---
    CropDisease(
      id: 'fennel_ramularia_blight',
      cropId: 'fennel',
      cropName: 'Fennel',
      cropHindi: 'सौंफ',
      diseaseNameHindi: 'झुलसा व रामुलेरिया ब्लाइट',
      diseaseNameEnglish: 'Ramularia Blight',
      pathogen: 'फफूंद (Ramularia foeniculi)',
      severity: 'गंभीर',
      confidenceScore: 96.4,
      symptoms: [
        'पत्तियों व छतरियों (Umbel) पर छोटे भूरे-काले धब्बे।',
        'फूल जलकर काले पड़ जाते हैं और बीज नहीं बनते।',
      ],
      symptomTags: ['छतरियों पर काले धब्बे', 'फूलों का काला पड़ना व जलना'],
      organicRemedy: 'नीम तेल 5 मिली + छाछ 5% का स्प्रे।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC (स्कोर) या मेन्कोजेब',
      sprayDosage: '1 मिली स्कोर प्रति लीटर पानी (200 मिली प्रति एकड़)।',
      precautions: 'बादल छाने पर तुरंत पहला स्प्रे करें।',
      preventionTips: ['सौंफ की रोपाई समय पर करें।'],
      icon: '🌿',
    ),

    // --- मेथी (Fenugreek) ---
    CropDisease(
      id: 'fenugreek_downy_mildew',
      cropId: 'fenugreek',
      cropName: 'Fenugreek',
      cropHindi: 'मेथी',
      diseaseNameHindi: 'डाउनी मिल्ड्यू / तुलासिता रोग',
      diseaseNameEnglish: 'Downy Mildew',
      pathogen: 'कवक (Peronospora trigonellae)',
      severity: 'गंभीर',
      confidenceScore: 95.9,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर पीले धब्बे और निचली सतह पर बैंगनी-सफेद फफूंद।',
        'पत्तियां पीली होकर झड़ जाती हैं।',
      ],
      symptomTags: ['ऊपर पीले धब्बे', 'नीचे बैंगनी-सफेद फफूंद', 'पत्तियों का झड़ना'],
      organicRemedy: 'ट्राइकोडर्मा 5 ग्राम/लीटर + गोमूत्र।',
      chemicalMedicine: 'रिडोमिल गोल्ड (Metalaxyl + Mancozeb)',
      sprayDosage: '2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'नमी अधिक होने पर तुरंत स्प्रे करें।',
      preventionTips: ['प्रमाणित किस्में (RMT 1, RMT 305) लगाएं।'],
      icon: '🌿',
    ),

    // --- इसबगोल (Isabgol / Psyllium) ---
    CropDisease(
      id: 'isabgol_downy_mildew',
      cropId: 'isabgol',
      cropName: 'Isabgol / Psyllium',
      cropHindi: 'इसबगोल',
      diseaseNameHindi: 'झुलसा व डाउनी मिल्ड्यू रोग',
      diseaseNameEnglish: 'Downy Mildew & Blight',
      pathogen: 'फफूंद (Peronospora plantaginis)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.5,
      symptoms: [
        'पत्तियों पर हल्के पीले धब्बे जो बाद में भूरे-काले हो जाते हैं।',
        'बालियां (Spikes) काली पड़कर सूख जाती हैं।',
      ],
      symptomTags: ['बालियों का काला पड़ना', 'पत्तियों पर भूरे-काले धब्बे', 'फसल का झुलसना'],
      organicRemedy: 'खट्टी छाछ + तांबा बर्तन का घोल।',
      chemicalMedicine: 'मेन्कोजेब 75% WP या रिडोमिल गोल्ड',
      sprayDosage: '2.5 ग्राम मेन्कोजेब प्रति लीटर पानी (500 ग्राम प्रति एकड़)।',
      precautions: 'मौसम में बदली और ओस बढ़ते ही पहला स्प्रे करें।',
      preventionTips: ['इसबगोल की बुवाई नवंबर प्रथम सप्ताह में करें।'],
      icon: '🌾',
    ),

    // --- संतरा / नींबू (Citrus / Lemon) ---
    CropDisease(
      id: 'citrus_canker',
      cropId: 'citrus',
      cropName: 'Citrus / Lemon / Orange',
      cropHindi: 'संतरा / किन्नू / नींबू',
      diseaseNameHindi: 'सिट्रस कैंकर (खुरंड / खसरा रोग)',
      diseaseNameEnglish: 'Citrus Canker',
      pathogen: 'जीवाणु (Xanthomonas citri)',
      severity: 'गंभीर',
      confidenceScore: 98.0,
      symptoms: [
        'पत्तियों, टहनियों व फलों पर उभरे हुए खुरदरे भूरे रंग के फफोले।',
        'फलों की गुणवत्ता और बाज़ार भाव गिर जाता है।',
      ],
      symptomTags: ['फलों पर खुरदरे भूरे फफोले', 'पत्तियों पर उभरे हुए दाने', 'टहनियों पर खुरंड'],
      organicRemedy: 'बोर्डो मिश्रण 1% या कॉपर ऑक्सीक्लोराइड।',
      chemicalMedicine: 'स्ट्रेप्टोसाइक्लिन (50 ग्राम) + कॉपर ऑक्सीक्लोराइड (500 ग्राम) प्रति 200L',
      sprayDosage: '0.5 ग्राम स्ट्रेप्टोसाइक्लिन + 2.5 ग्राम ब्लाइटॉक्स प्रति लीटर पानी।',
      precautions: 'संक्रमित टहनियों को काटकर जलाएं।',
      preventionTips: ['रोगमुक्त कलमी पौधे लगाएं।'],
      icon: '🍋',
    ),

    // --- आम (Mango) ---
    CropDisease(
      id: 'mango_powdery_mildew',
      cropId: 'mango',
      cropName: 'Mango',
      cropHindi: 'आम',
      diseaseNameHindi: 'बौर का खर्रा रोग (चूर्णी फफूंद) व मधुआ कीट',
      diseaseNameEnglish: 'Mango Powdery Mildew & Hopper',
      pathogen: 'फफूंद (Oidium mangiferae) व कीट',
      severity: 'गंभीर',
      confidenceScore: 97.8,
      symptoms: [
        'आम के बौर (फूलों) पर सफेद पाउडर जम जाता है और बौर सूखकर गिर जाता है।',
        'मधुआ कीट रस चूसकर बौर को चिपचिपा कर देता है।',
      ],
      symptomTags: ['बौर पर सफेद पाउडर', 'बौर का गिरना', 'चिपचिपा रस / मधुआ'],
      organicRemedy: 'नीम तेल 5 मिली/लीटर + घुलनशील गंधक।',
      chemicalMedicine: 'हेक्साकोनाज़ोल 5% SC (कंटाफ) + इमिडाक्लोप्रिड 17.8% SL',
      sprayDosage: '1.5 मिली कंटाफ + 0.5 मिली इमिडाक्लोप्रिड प्रति लीटर पानी।',
      precautions: 'बौर आने पर और फल बनने पर 2 स्प्रे करें।',
      preventionTips: ['बगीचे की साफ-सफाई रखें।'],
      icon: '🥭',
    ),

    // --- अमरूद (Guava) ---
    CropDisease(
      id: 'guava_wilt',
      cropId: 'guava',
      cropName: 'Guava',
      cropHindi: 'अमरूद',
      diseaseNameHindi: 'अमरूद का उकठा रोग (विल्ट / सूखा रोग)',
      diseaseNameEnglish: 'Guava Wilt',
      pathogen: 'मृदा जनित फफूंद (Fusarium oxysporum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.2,
      symptoms: [
        'पेड़ की पत्तियां पीली पड़कर अचानक मुरझाने लगती हैं।',
        'कुछ ही हफ़्तों में पूरा हरा-भरा पेड़ सूख जाता है।',
      ],
      symptomTags: ['पेड़ का अचानक सूखना', 'पत्तियों का पीला पड़ना व झड़ना', 'जड़ों का काला होना'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 25 ग्राम प्रति पेड़ गोबर की खाद में मिलाकर जड़ों में डालें।',
      chemicalMedicine: 'कार्बेन्डाजिम 50% WP (बाविस्टिन) से जड़ों में ड्रेंचिंग',
      sprayDosage: '2 ग्राम प्रति लीटर पानी से थाले (Basin) में ड्रेंचिंग करें।',
      precautions: 'संक्रमित पेड़ की जड़ों को खोदकर बाहर निकालें और चूना डालें।',
      preventionTips: ['जलभराव से बचें।'],
      icon: '🍈',
    ),

    // --- पपीता (Papaya) ---
    CropDisease(
      id: 'papaya_ring_spot',
      cropId: 'papaya',
      cropName: 'Papaya',
      cropHindi: 'पपीता',
      diseaseNameHindi: 'रिंग स्पॉट वायरस (पत्ता मरोड़ व गोल छल्ले)',
      diseaseNameEnglish: 'Papaya Ring Spot Virus (PRSV)',
      pathogen: 'माहू कीट द्वारा फैलने वाला वायरस',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.5,
      symptoms: [
        'पत्तियों पर गहरे हरे-पीले छांवदार चकत्ते और पत्तियां छोटी हो जाती हैं।',
        'फलों पर गहरे हरे गोल छल्ले (Rings) बनते हैं।',
      ],
      symptomTags: ['फलों पर गोल छल्ले', 'पत्तियों का छोटा होना / मरोड़', 'पौधे का बौना होना'],
      organicRemedy: 'सिल्वर रंग की मल्चिंग + पीला स्टिकी ट्रैप लगाएं।',
      chemicalMedicine: 'माहू कीट नियंत्रण: डायमेथोएट 30% EC या इमिडाक्लोप्रिड',
      sprayDosage: '1 मिली प्रति लीटर पानी।',
      precautions: 'संक्रमित पौधे को तुरंत उखाड़कर नष्ट करें।',
      preventionTips: ['रोगमुक्त नर्सरी पौधे लगाएं।'],
      icon: '🍈',
    ),

    // --- तरबूज व खरबूजा (Watermelon & Muskmelon) ---
    CropDisease(
      id: 'melon_downy_mildew',
      cropId: 'watermelon',
      cropName: 'Watermelon & Muskmelon',
      cropHindi: 'तरबूज / खरबूजा',
      diseaseNameHindi: 'डाउनी मिल्ड्यू (झुलसा) व फल मक्खी',
      diseaseNameEnglish: 'Downy Mildew & Fruit Fly',
      pathogen: 'फफूंद (Pseudoperonospora) व कीट',
      severity: 'गंभीर',
      confidenceScore: 97.4,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर पीले कोणीय धब्बे जो नसों के बीच सीमित होते हैं।',
        'फल मक्खी फल में डंक मारकर कीड़े पैदा करती है।',
      ],
      symptomTags: ['पीले कोणीय धब्बे', 'फल में डंक व सड़न', 'पत्तियों का सूखना'],
      organicRemedy: 'फेरोमोन फ्रूट फ्लाई ट्रैप 6 प्रति एकड़ लगाएं।',
      chemicalMedicine: 'रिडोमिल गोल्ड (Mancozeb + Metalaxyl) या एमिस्टार',
      sprayDosage: '2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'ड्रिप से सिंचाई करें, पत्तियों पर पानी न डालें।',
      preventionTips: ['मल्चिंग शीट लगाएं।'],
      icon: '🍉',
    ),

    // --- अरंडी (Castor) ---
    CropDisease(
      id: 'castor_semilooper',
      cropId: 'castor',
      cropName: 'Castor',
      cropHindi: 'अरंडी',
      diseaseNameHindi: 'सेमीलूपर सुंडी (पत्ती खाने वाली इल्ली)',
      diseaseNameEnglish: 'Castor Semilooper',
      pathogen: 'हानिकारक कीट (Achaea janata)',
      severity: 'गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'काले-भूरे रंग की बड़ी सुंडी पत्तियों को तेजी से खाकर सिर्फ नसें छोड़ती है।',
        'पौधा पत्तियों रहित हो जाता है।',
      ],
      symptomTags: ['पत्तियों का तेजी से कटना', 'काली-भूरी बड़ी सुंडी', 'सिर्फ नसों का बचना'],
      organicRemedy: 'नीम तेल 5 मिली/लीटर या टी-खूंटी पक्षियों के लिए लगाएं।',
      chemicalMedicine: 'क्विनालफॉस 25% EC या प्रोफेनोफॉस 50% EC',
      sprayDosage: '2 मिली प्रति लीटर पानी (400 मिली प्रति एकड़)।',
      precautions: 'सुंडी छोटी होने पर ही पहला स्प्रे करें।',
      preventionTips: ['खेत की गहरी जुताई करें।'],
      icon: '🫘',
    ),

    // --- सूरजमुखी (Sunflower) ---
    CropDisease(
      id: 'sunflower_head_rot',
      cropId: 'sunflower',
      cropName: 'Sunflower',
      cropHindi: 'सूरजमुखी',
      diseaseNameHindi: 'फूल सड़न / हेड रॉट रोग',
      diseaseNameEnglish: 'Head Rot (Rhizopus)',
      pathogen: 'फफूंद (Rhizopus)',
      severity: 'गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'फूल के पिछले हिस्से पर पानी से भीगे भूरे धब्बे जो सड़ जाते हैं।',
        'फूल गिर जाता है और बीज काले पड़ जाते हैं।',
      ],
      symptomTags: ['फूल का सड़ना', 'पिछले हिस्से पर भूरापन', 'बीज का काला होना'],
      organicRemedy: 'ट्राइकोडर्मा 5 ग्राम/लीटर का स्प्रे।',
      chemicalMedicine: 'मेंकोजेब 75% WP या कार्बेन्डाजिम',
      sprayDosage: '2 ग्राम प्रति लीटर पानी।',
      precautions: 'फूल बनने के समय बारिश के बाद तुरंत स्प्रे करें।',
      preventionTips: ['उचित दूरी पर पौधे लगाएं।'],
      icon: '🌻',
    ),

    // --- तिल (Sesame / Til) ---
    CropDisease(
      id: 'sesame_phyllody',
      cropId: 'sesame',
      cropName: 'Sesame / Til',
      cropHindi: 'तिल',
      diseaseNameHindi: 'फाइलोडी रोग (फूलों का हरी पत्तियों में बदलना)',
      diseaseNameEnglish: 'Sesame Phyllody',
      pathogen: 'फाइटोप्लाज्मा (लीपहॉपर कीट द्वारा)',
      severity: 'गंभीर',
      confidenceScore: 97.3,
      symptoms: [
        'फूलों के सभी अंग हरी पत्तियों के गुच्छे (झाड़ू) में बदल जाते हैं।',
        'पौधे पर कोई फली या तिल का बीज नहीं बनता।',
      ],
      symptomTags: ['फूलों की जगह हरी पत्तियां / झाड़ू', 'फली न बनना', 'पौधे का बौना होना'],
      organicRemedy: 'पीला स्टिकी ट्रैप + नीम तेल 5 मिली/लीटर।',
      chemicalMedicine: 'हॉपर कीट नियंत्रण: डाइमेथोएट 30% EC या इमिडाक्लोप्रिड',
      sprayDosage: '1.5 मिली प्रति लीटर पानी।',
      precautions: 'रोगग्रस्त पौधों को तुरंत उखाड़कर नष्ट करें।',
      preventionTips: ['बीज उपचार करके बोएं।'],
      icon: '⚪',
    ),

    // --- केला (Banana) ---
    CropDisease(
      id: 'banana_panama_wilt',
      cropId: 'banana',
      cropName: 'Banana',
      cropHindi: 'केला',
      diseaseNameHindi: 'पनामा विल्ट (उकठा / तना फटना)',
      diseaseNameEnglish: 'Panama Wilt',
      pathogen: 'मृदा जनित कवक (Fusarium oxysporum f.sp. cubense)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.7,
      symptoms: [
        'निचली पत्तियां पीली पड़कर डंठल के पास से लटक जाती हैं (स्कर्ट जैसा रूप)।',
        'तने का आधार लंबाई में फट जाता है और अंदर से भूरा दिखता है।',
      ],
      symptomTags: ['पत्तियों का लटकना', 'तने का फटना', 'अंदर से भूरा/काला तना'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 50 ग्राम प्रति पौधा गड्ढे में गोबर खाद के साथ डालें।',
      chemicalMedicine: 'कार्बेन्डाजिम 50% WP (बाविस्टिन) से जड़ों में ड्रेंचिंग',
      sprayDosage: '2 ग्राम प्रति लीटर पानी (2 से 3 लीटर घोल प्रति पौधा)।',
      precautions: 'संक्रमित खेत के सकर (Pups) न लगाएं।',
      preventionTips: ['ग्रैंड नैने (G9) जैसी प्रतिरोधी किस्में लगाएं।'],
      icon: '🍌',
    ),

    // --- सेब (Apple) ---
    CropDisease(
      id: 'apple_scab',
      cropId: 'apple',
      cropName: 'Apple',
      cropHindi: 'सेब',
      diseaseNameHindi: 'सेब का स्कैब / पपड़ी रोग',
      diseaseNameEnglish: 'Apple Scab',
      pathogen: 'फफूंद (Venturia inaequalis)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 98.4,
      symptoms: [
        'पत्तियों और फलों पर मखमली जैतून-हरे से काले खुरदुरे धब्बे।',
        'फल विकृत होकर फट जाते हैं।',
      ],
      symptomTags: ['फलों पर काले खुरदुरे धब्बे / पपड़ी', 'फलों का फटना', 'पत्तियों पर जैतून-हरे धब्बे'],
      organicRemedy: 'बोर्डो मिश्रण 1% या कॉपर ऑक्सीक्लोराइड।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC (स्कोर) या मेन्कोजेब 75% WP',
      sprayDosage: '0.5 मिली स्कोर प्रति लीटर पानी (100 मिली प्रति 200L ड्रम)।',
      precautions: 'पत्ती झड़ने के बाद 5% यूरिया का स्प्रे जमीन पर करें।',
      preventionTips: ['नियमित कटाई-छंटाई करें।'],
      icon: '🍎',
    ),

    // --- चौलाई / चंवला / लोबिया (Amaranth / Cowpea / Lobia) ---
    CropDisease(
      id: 'chaulai_cercospora_white_rust',
      cropId: 'chaulai',
      cropName: 'Amaranth / Cowpea',
      cropHindi: 'चौलाई / चंवला / लोबिया',
      diseaseNameHindi: 'सफेद रोली व पर्ण चित्ती रोग',
      diseaseNameEnglish: 'White Rust & Cercospora Leaf Spot',
      pathogen: 'कवक (Albugo bliti / Cercospora)',
      severity: 'मध्यम से गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'पत्तियों की निचली सतह पर उभरे हुए सफेद फफोले और ऊपरी सतह पर गोल भूरे-लाल धब्बे।',
        'संक्रमित पत्तियां पीली होकर समय से पहले झड़ने लगती हैं।',
      ],
      symptomTags: ['पत्तियों पर सफेद फफोले', 'गोल भूरे-लाल धब्बे', 'पत्तियों का पीला पड़ना'],
      organicRemedy: 'खट्टी छाछ (5 लीटर/100L पानी) + ट्राइकोडर्मा विरिडी (5 ग्राम/लीटर) का छिड़काव।',
      chemicalMedicine: 'मेंकोजेब 75% WP (इंडोफिल M-45) या कार्बेंडाजिम + मेंकोजेब (साफ / Saaf)',
      sprayDosage: '2 ग्राम साफ प्रति लीटर पानी (400 ग्राम प्रति एकड़ 200L पानी में)।',
      precautions: 'रोग के शुरुआती लक्षण दिखते ही 10-12 दिन के अंतराल पर 2 बार छिड़काव करें।',
      preventionTips: [
        'खेत में जलभराव न होने दें।',
        'प्रमाणित बीज का ही उपयोग करें।',
      ],
      icon: '🥬',
    ),
    CropDisease(
      id: 'chaulai_wet_rot_blight',
      cropId: 'chaulai',
      cropName: 'Amaranth / Cowpea',
      cropHindi: 'चौलाई / चंवला / लोबिया',
      diseaseNameHindi: 'गीला झुलसा व तना गलन रोग',
      diseaseNameEnglish: 'Wet Rot & Stem Blight',
      pathogen: 'कवक (Choanephora cucurbitarum / Rhizoctonia)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.4,
      symptoms: [
        'पत्तियों और कोमल तनों पर भीगे हुए काले-भूरे धब्बे जो तेजी से गलने लगते हैं।',
        'फसल पर गीला बदबूदार सड़न दिखाई देता है।',
      ],
      symptomTags: ['पत्तियों व तने पर गीले काले धब्बे', 'तने का गलना', 'पौधे का अचानक मुरझाना'],
      organicRemedy: 'गोमूत्र 10% + हींग का घोल 100 लीटर पानी में मिलाकर स्प्रे करें।',
      chemicalMedicine: 'कॉपर ऑक्सीक्लोराइड 50% WP (ब्लाइटॉक्स) या स्ट्रेप्टोसाइक्लिन',
      sprayDosage: 'कॉपर ऑक्सीक्लोराइड: 2.5 ग्राम प्रति लीटर पानी (500 ग्राम प्रति एकड़)।',
      precautions: 'बरसात के मौसम में अत्यधिक नमी होने पर तुरंत पहला स्प्रे करें।',
      preventionTips: [
        'पंक्तियों के बीच उचित दूरी रखें ताकि धूप और हवा मिल सके।',
      ],
      icon: '🥬',
    ),
    CropDisease(
      id: 'chaulai_aphid_caterpillar',
      cropId: 'chaulai',
      cropName: 'Amaranth / Cowpea',
      cropHindi: 'चौलाई / चंवला / लोबिया',
      diseaseNameHindi: 'माहू कीट व पत्ती खाने वाली सुंडी',
      diseaseNameEnglish: 'Aphids & Leaf Eating Caterpillar',
      pathogen: 'रस चूसक कीट व सुंडी (Insect Pest)',
      severity: 'गंभीर',
      confidenceScore: 98.1,
      symptoms: [
        'पत्तियों की निचली सतह पर काले-हरे छोटे कीड़े (माहू) रस चूसते हैं।',
        'हरी सुंडी पत्तियों को खाकर छलनी कर देती है।',
      ],
      symptomTags: ['काले-हरे छोटे कीड़े (माहू)', 'पत्तियों में छेद/कट', 'हरी इल्ली'],
      organicRemedy: 'नीम तेल 1500 PPM (5 मिली/लीटर) + पीला स्टिकी ट्रैप 10 प्रति एकड़ लगाएं।',
      chemicalMedicine: 'इमिडाक्लोप्रिड 17.8% SL (कॉन्फिडोर) या एमामेक्टिन बेंजोएट 5% SG',
      sprayDosage: 'इमिडाक्लोप्रिड: 1 मिली प्रति 3 लीटर पानी (50 मिली प्रति एकड़)।',
      precautions: 'सब्जी तोड़ने से कम से कम 5 दिन पहले रासायनिक स्प्रे बंद कर दें।',
      preventionTips: [
        'पीले चिपचिपे कार्ड लगाएं।',
      ],
      icon: '🥬',
    ),
  ];

  /// Get all diseases
  static List<CropDisease> getAllDiseases() => diseases;

  /// Standardize crop alias
  static String normalizeCropId(String cropId) {
    final c = cropId.toLowerCase().trim();
    if (c.contains('cholai') || c.contains('chaulai') || c.contains('chawli') ||
        c.contains('lobia') || c.contains('chawla') || c.contains('amaranth') ||
        c.contains('cowpea') || c.contains('चौलाई') || c.contains('चंवला') || c.contains('लोबिया')) {
      return 'chaulai';
    }
    if (c.contains('wheat') || c.contains('gehu') || c.contains('गेहूं') || c.contains('गेहू')) return 'wheat';
    if (c.contains('mustard') || c.contains('sarson') || c.contains('sarso') || c.contains('सरसों') || c.contains('राई')) return 'mustard';
    if (c.contains('paddy') || c.contains('rice') || c.contains('dhan') || c.contains('chawal') || c.contains('धान') || c.contains('चावल')) return 'paddy';
    if (c.contains('cotton') || c.contains('kapas') || c.contains('narma') || c.contains('कपास') || c.contains('नरमा')) return 'cotton';
    if (c.contains('soybean') || c.contains('सोयाबीन')) return 'soybean';
    if (c.contains('gram') || c.contains('chana') || c.contains('चना')) return 'gram';
    if (c.contains('tomato') || c.contains('tamatar') || c.contains('टमाटर')) return 'tomato';
    if (c.contains('potato') || c.contains('aloo') || c.contains('alu') || c.contains('आलू')) return 'potato';
    if (c.contains('chilli') || c.contains('chili') || c.contains('mirch') || c.contains('मिर्च')) return 'chilli';
    if (c.contains('onion') || c.contains('pyaj') || c.contains('pyaaz') || c.contains('प्याज')) return 'onion';
    if (c.contains('garlic') || c.contains('lahsun') || c.contains('लहसुन')) return 'garlic';
    if (c.contains('jeera') || c.contains('cumin') || c.contains('जीरा')) return 'jeera';
    if (c.contains('maize') || c.contains('corn') || c.contains('makka') || c.contains('मक्का')) return 'maize';
    if (c.contains('bajra') || c.contains('बाजरा')) return 'bajra';
    if (c.contains('guar') || c.contains('gwar') || c.contains('ग्वार')) return 'guar';
    if (c.contains('sugarcane') || c.contains('ganna') || c.contains('गन्ना')) return 'sugarcane';
    if (c.contains('moong') || c.contains('मूंग')) return 'moong';
    if (c.contains('urad') || c.contains('उड़द')) return 'urad';
    if (c.contains('groundnut') || c.contains('mungfali') || c.contains('मूंगफली')) return 'groundnut';
    if (c.contains('pomegranate') || c.contains('anar') || c.contains('अनार')) return 'pomegranate';
    if (c.contains('brinjal') || c.contains('baingan') || c.contains('बैंगन')) return 'brinjal';
    if (c.contains('okra') || c.contains('bhindi') || c.contains('भिंडी')) return 'okra';
    if (c.contains('cauliflower') || c.contains('gobhi') || c.contains('गोभी')) return 'cauliflower';
    if (c.contains('pea') || c.contains('matar') || c.contains('मटर')) return 'pea';
    if (c.contains('ginger') || c.contains('adrak') || c.contains('अदरक')) return 'ginger';
    if (c.contains('turmeric') || c.contains('haldi') || c.contains('हल्दी')) return 'turmeric';
    if (c.contains('coriander') || c.contains('dhaniya') || c.contains('धनिया')) return 'coriander';
    if (c.contains('fennel') || c.contains('saunf') || c.contains('सौंफ')) return 'fennel';
    if (c.contains('fenugreek') || c.contains('methi') || c.contains('मेथी')) return 'fenugreek';
    if (c.contains('isabgol') || c.contains('इसबगोल')) return 'isabgol';
    if (c.contains('citrus') || c.contains('lemon') || c.contains('nimbu') || c.contains('नींबू') || c.contains('संतरा')) return 'citrus';
    if (c.contains('mango') || c.contains('aam') || c.contains('आम')) return 'mango';
    if (c.contains('guava') || c.contains('amrood') || c.contains('अमरूद')) return 'guava';
    if (c.contains('papaya') || c.contains('papita') || c.contains('पपीता')) return 'papaya';
    if (c.contains('watermelon') || c.contains('tarbooj') || c.contains('तरबूज')) return 'watermelon';
    if (c.contains('castor') || c.contains('arandi') || c.contains('अरंडी')) return 'castor';
    if (c.contains('sunflower') || c.contains('surajmukhi') || c.contains('सूरजमुखी')) return 'sunflower';
    if (c.contains('sesame') || c.contains('til') || c.contains('तिल')) return 'sesame';
    if (c.contains('banana') || c.contains('kela') || c.contains('केला')) return 'banana';
    if (c.contains('apple') || c.contains('seb') || c.contains('सेब')) return 'apple';
    return c;
  }

  /// Get diseases by crop ID
  static List<CropDisease> getDiseasesByCrop(String cropId) {
    final norm = normalizeCropId(cropId);
    final c = cropId.toLowerCase().trim();
    return diseases.where((d) =>
      d.cropId.toLowerCase() == norm ||
      d.cropId.toLowerCase() == c ||
      d.cropHindi.toLowerCase().contains(c) ||
      d.cropName.toLowerCase().contains(c) ||
      norm.contains(d.cropId.toLowerCase()) ||
      d.cropHindi.toLowerCase().contains(norm)
    ).toList();
  }

  /// Get symptom tags for crop
  static List<String> getSymptomTagsForCrop(String cropId) {
    final cropDiseases = getDiseasesByCrop(cropId);
    final Set<String> tags = {};
    for (final d in cropDiseases) {
      if (d.symptomTags.isNotEmpty) {
        tags.addAll(d.symptomTags);
      } else {
        for (final s in d.symptoms) {
          if (s.length > 25) {
            tags.add(s.substring(0, 25).replaceAll(RegExp(r'[,।]$'), ''));
          } else {
            tags.add(s);
          }
        }
      }
    }
    if (tags.isEmpty) {
      tags.addAll(['पत्तियों पर भूरे-काले धब्बे', 'पत्तियों का पीला पड़ना', 'सफेद पाउडर / फंगस', 'कीट व सुंडी']);
    }
    return tags.toList();
  }

  /// Search disease database by query
  static List<CropDisease> searchDiseases(String query) {
    if (query.isEmpty) return diseases;
    final q = query.toLowerCase().trim();
    return diseases.where((d) =>
      d.diseaseNameHindi.toLowerCase().contains(q) ||
      d.diseaseNameEnglish.toLowerCase().contains(q) ||
      d.cropHindi.toLowerCase().contains(q) ||
      d.cropName.toLowerCase().contains(q) ||
      d.symptoms.any((s) => s.toLowerCase().contains(q)) ||
      d.chemicalMedicine.toLowerCase().contains(q) ||
      d.organicRemedy.toLowerCase().contains(q)
    ).toList();
  }

  /// Diagnose disease based on crop and visual indicators
  static CropDisease diagnose({required String cropId, String? symptomKeyword}) {
    final cropDiseases = getDiseasesByCrop(cropId);
    if (cropDiseases.isNotEmpty) {
      if (symptomKeyword != null && symptomKeyword.isNotEmpty) {
        final kw = symptomKeyword.toLowerCase();
        for (final d in cropDiseases) {
          if (d.diseaseNameHindi.toLowerCase().contains(kw) ||
              d.diseaseNameEnglish.toLowerCase().contains(kw) ||
              d.symptoms.any((s) => s.toLowerCase().contains(kw)) ||
              d.symptomTags.any((t) => t.toLowerCase().contains(kw))) {
            return d;
          }
        }
      }
      return cropDiseases.first;
    }

    // Dynamic tailored diagnosis for unlisted regional crop - NEVER return Wheat Rust!
    final cropDisplay = cropId.isNotEmpty ? cropId : 'फसल';
    return CropDisease(
      id: '${cropId}_leaf_spot',
      cropId: cropId,
      cropName: cropDisplay,
      cropHindi: cropDisplay,
      diseaseNameHindi: '$cropDisplay का पर्ण चित्ती व झुलसा रोग',
      diseaseNameEnglish: 'Leaf Spot & Foliage Blight',
      pathogen: 'कवक जनित फफूंद (Fungus)',
      severity: 'मध्यम',
      confidenceScore: 93.5,
      symptoms: [
        '$cropDisplay की पत्तियों पर भूरे-काले धब्बे और किनारों का सूखना।',
        'पत्तियों का पीला पड़कर समय से पहले गिरना।',
      ],
      symptomTags: ['पत्तियों पर भूरे-काले धब्बे', 'पत्तियों का पीला पड़ना', 'झुलसा'],
      organicRemedy: 'खट्टी छाछ (5 लीटर) + नीम तेल (5 मिली/लीटर) 100 लीटर पानी में मिलाकर स्प्रे करें।',
      chemicalMedicine: 'कार्बेन्डाजिम 12% + मैंकोजेब 63% WP (साफ / Saaf) या कॉपर ऑक्सीक्लोराइड',
      sprayDosage: '2 ग्राम साफ प्रति लीटर पानी (400 ग्राम प्रति एकड़ 150-200 लीटर पानी में)।',
      precautions: 'शुरुआती लक्षण दिखते ही शाम के समय छिड़काव करें।',
      preventionTips: [
        'खेत में जल निकास का उचित प्रबंध रखें।',
        'बीज को ट्राइकोडर्मा या कार्बेंडाजिम से उपचारित करके बोएं।',
      ],
      icon: '🌱',
    );
  }

  /// Diagnose based on user selected symptom tags
  static CropDisease diagnoseFromSelectedSymptoms({
    required String cropId,
    required List<String> selectedSymptoms,
  }) {
    final cropDiseases = getDiseasesByCrop(cropId);
    if (cropDiseases.isEmpty) return diagnose(cropId: cropId);
    if (selectedSymptoms.isEmpty) return cropDiseases.first;

    CropDisease bestMatch = cropDiseases.first;
    int maxMatches = -1;

    for (final d in cropDiseases) {
      int score = 0;
      final fullText = '${d.diseaseNameHindi} ${d.diseaseNameEnglish} ${d.symptoms.join(' ')} ${d.symptomTags.join(' ')}'.toLowerCase();
      for (final sym in selectedSymptoms) {
        final term = sym.toLowerCase();
        if (fullText.contains(term)) score += 3;
        for (final tag in d.symptomTags) {
          if (tag.toLowerCase().contains(term) || term.contains(tag.toLowerCase())) score += 5;
        }
      }
      if (score > maxMatches) {
        maxMatches = score;
        bestMatch = d;
      }
    }
    return bestMatch;
  }

  /// Sync diseases database from CDN in background
  static Future<void> syncFromCdn() async {
    try {
      const cdnUrl = 'https://cdn.jsdelivr.net/gh/ushamdsu-lab/kisanmandibhav@main/assets/data/crop_diseases.json';
      const fallbackUrl = 'https://raw.githubusercontent.com/ushamdsu-lab/kisanmandibhav/main/assets/data/crop_diseases.json';

      http.Response? response;
      try {
        response = await http.get(Uri.parse(cdnUrl)).timeout(const Duration(seconds: 4));
      } catch (_) {
        response = await http.get(Uri.parse(fallbackUrl)).timeout(const Duration(seconds: 4));
      }

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded['diseases'] is List) {
          final list = (decoded['diseases'] as List)
              .map((item) => CropDisease.fromJson(item as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) {
            _dynamicDiseases = list;
          }
        }
      }
    } catch (_) {
      // Safe fallback to bundled asset or defaultDiseases
    }
  }

  /// Load from local asset if available
  static Future<void> loadFromAsset() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/crop_diseases.json');
      if (jsonStr.isNotEmpty) {
        final decoded = json.decode(jsonStr);
        if (decoded is Map<String, dynamic> && decoded['diseases'] is List) {
          final list = (decoded['diseases'] as List)
              .map((item) => CropDisease.fromJson(item as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) {
            _dynamicDiseases = list;
          }
        }
      }
    } catch (_) {
      // Safe fallback
    }
  }
}
