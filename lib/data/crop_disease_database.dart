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
    CropDisease(
      id: 'wheat_yellow_rust',
      cropId: 'wheat',
      cropName: 'Wheat',
      cropHindi: 'गेहूं',
      diseaseNameHindi: 'पीला रतुआ / हल्दी रोग',
      diseaseNameEnglish: 'Yellow / Stripe Rust',
      pathogen: 'फफूंद (Puccinia striiformis)',
      severity: 'गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'पत्तियों पर हल्दी जैसा पीला पाउडर समानांतर धारियों में दिखता है।',
        'उंगलियों से छूने पर पीला चूर्ण हाथ में लग जाता है।',
        'पत्तियां पीली पड़कर सूखने लगती हैं और बालियां खाली रह जाती हैं।'
      ],
      symptomTags: ['पीला पाउडर / धारियां', 'हल्दी जैसा चूर्ण', 'पत्तियों का सूखना', 'पीला रतुआ'],
      organicRemedy: 'खट्टी छाछ (5 लीटर) + हींग (50 ग्राम) 200 लीटर पानी में मिलाकर प्रति एकड़ छिड़कें।',
      chemicalMedicine: 'प्रोपिकोनाज़ोल 25% EC (टिल्ट / Tilt) या टेबुकोनाज़ोल',
      sprayDosage: '200 मिली प्रति एकड़ (15 से 20 मिली प्रति 15 लीटर पंप) 200 लीटर पानी में घोलकर।',
      precautions: 'रोग के शुरुआती लक्षण दिखते ही छिड़काव करें, तेज धूप में छिड़काव न करें।',
      preventionTips: [
        'रतुआ प्रतिरोधी किस्में (HD 2967, DBW 187, DBW 222) लगाएं।',
        'यूरिया का अत्यधिक प्रयोग न करें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'wheat_brown_rust',
      cropId: 'wheat',
      cropName: 'Wheat',
      cropHindi: 'गेहूं',
      diseaseNameHindi: 'भूरा रतुआ / पत्ती का रतुआ',
      diseaseNameEnglish: 'Brown / Leaf Rust',
      pathogen: 'फफूंद (Puccinia triticina)',
      severity: 'मध्यम से गंभीर',
      confidenceScore: 94.5,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर गोल-अंडाकार भूरे या कत्थई रंग के फफोले।',
        'फफोले अनियमित रूप से पूरी पत्ती पर बिखरे रहते हैं।'
      ],
      symptomTags: ['भूरे फफोले', 'कत्थई चूर्ण', 'पत्ती पर धब्बे'],
      organicRemedy: 'नीम का तेल (5 मिली/लीटर) + गोमूत्र (10%) का छिड़काव।',
      chemicalMedicine: 'टेबुकोनाज़ोल 25.9% EC (फॉलीकुर) या मैंकोजेब 75% WP',
      sprayDosage: 'टेबुकोनाज़ोल: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।',
      precautions: 'तापमान बढ़ने (फरवरी-मार्च) पर विशेष निगरानी रखें।',
      preventionTips: [
        'संतुलित पोटाश व फास्फोरस का प्रयोग करें।'
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
        'हवा चलने पर काला पाउडर उड़कर केवल डंडी बचती है।'
      ],
      symptomTags: ['काली बालियां', 'कोयले जैसा चूर्ण', 'दाना न बनना'],
      organicRemedy: 'बीज को तेज धूप में 4 घंटे सुखाएं और बीजामृत से शोधित करें।',
      chemicalMedicine: 'कार्बोक्सिन 37.5% + थीरम 37.5% (विटावैक्स)',
      sprayDosage: 'बीज उपचार: 2.5 ग्राम प्रति किलो बीज।',
      precautions: 'रोगी बालियों को पॉलीथिन से ढककर उखाड़ें और जला दें।',
      preventionTips: [
        'प्रमाणित और उपचारित बीज ही बोएं।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'wheat_karnal_bunt',
      cropId: 'wheat',
      cropName: 'Wheat',
      cropHindi: 'गेहूं',
      diseaseNameHindi: 'करनाल बंट रोग',
      diseaseNameEnglish: 'Karnal Bunt (Tilletia indica)',
      pathogen: 'फफूंद (Tilletia indica)',
      severity: 'मध्यम',
      confidenceScore: 91.5,
      symptoms: [
        'बाली के कुछ दाने आंशिक रूप से काले चूर्ण में बदल जाते हैं।',
        'दानों को मसलने पर सड़ी हुई मछली जैसी दुर्गंध आती है।'
      ],
      symptomTags: ['सड़ी मछली जैसी गंध', 'आंशिक काले दाने'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी से बीज व मृदा उपचार करें।',
      chemicalMedicine: 'प्रोपिकोनाज़ोल 25% EC',
      sprayDosage: '200 मिली प्रति एकड़ (बाली निकलने के समय)।',
      precautions: 'पुष्पन अवस्था में अधिक सिंचाई से बचें।',
      preventionTips: [
        '3 वर्ष का फसल चक्र अपनाएं।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'wheat_powdery_mildew',
      cropId: 'wheat',
      cropName: 'Wheat',
      cropHindi: 'गेहूं',
      diseaseNameHindi: 'चूर्णी फफूंद / छाछ्या रोग',
      diseaseNameEnglish: 'Powdery Mildew',
      pathogen: 'फफूंद (Blumeria graminis)',
      severity: 'मध्यम',
      confidenceScore: 92.0,
      symptoms: [
        'पत्तियों, तनों और बालियों पर सफेद रुई जैसा चूर्ण दिखाई देता है।',
        'बाद में चूर्ण धूसर-भूरा हो जाता है और पत्तियां सूख जाती हैं।'
      ],
      symptomTags: ['सफेद रुई जैसा चूर्ण', 'छाछ्या रोग', 'पत्ती पर सफेद पाउडर'],
      organicRemedy: 'घुलनशील गंधक (सल्फर 80% WDG) 3 ग्राम प्रति लीटर पानी।',
      chemicalMedicine: 'हेक्साकोनाज़ोल 5% SC या डाइफेनोकोनाज़ोल',
      sprayDosage: 'हेक्साकोनाज़ोल: 2 मिली प्रति लीटर पानी।',
      precautions: 'घनी बुवाई न करें, हवा का आवागमन बना रहे।',
      preventionTips: [
        'खेत में जलभराव न होने दें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'wheat_termite',
      cropId: 'wheat',
      cropName: 'Wheat',
      cropHindi: 'गेहूं',
      diseaseNameHindi: 'दीमक प्रकोप (Termite)',
      diseaseNameEnglish: 'Termite Infestation',
      pathogen: 'कीट (Microtermes obesi)',
      severity: 'गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'पौधे पीले पड़कर सूखने लगते हैं और खींचने पर आसानी से उखड़ जाते हैं।',
        'जड़ों व तने के निचले भाग को दीमक अंदर से खा जाती है।'
      ],
      symptomTags: ['पौधों का सूखना', 'जड़ों का कटना', 'दीमक'],
      organicRemedy: 'नीम खली 100 किलो प्रति एकड़ बुवाई के समय खेत में मिलाएं।',
      chemicalMedicine: 'क्लोरपायरीफॉस 20% EC या फिप्रोनिल 0.3% GR',
      sprayDosage: 'क्लोरपायरीफॉस: 1 लीटर प्रति एकड़ सिंचाई पानी के साथ।',
      precautions: 'कच्ची गोबर की खाद कभी न डालें।',
      preventionTips: [
        'बुवाई पूर्व बीज उपचार क्लोरपायरीफॉस से करें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'paddy_blast',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान / चावल',
      diseaseNameHindi: 'धान का झुलसा / ब्लास्ट रोग',
      diseaseNameEnglish: 'Rice Blast (Pyricularia oryzae)',
      pathogen: 'फफूंद (Magnaporthe oryzae)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पत्तियों पर आंख या नाव के आकार के बीच में राख जैसे धब्बे।',
        'धब्बों के किनारे कत्थई या भूरे होते हैं।',
        'गर्दन ब्लास्ट में बाली की गर्दन काली होकर टूट जाती है।'
      ],
      symptomTags: ['नाव जैसे धब्बे', 'ब्लास्ट रोग', 'गर्दन टूटना', 'पत्ती झुलसना'],
      organicRemedy: 'स्यूडोमोनास फ्लोरोसेंस (10 ग्राम/लीटर) का पर्णीय छिड़काव।',
      chemicalMedicine: 'ट्राइसाइक्लाजोल 75% WP (बाम / Beam) या कसूगामाइसिन',
      sprayDosage: 'ट्राइसाइक्लाजोल: 120 ग्राम प्रति एकड़ 200 लीटर पानी में।',
      precautions: 'रोग दिखते ही यूरिया का छिड़काव तुरंत रोक दें।',
      preventionTips: [
        'ब्लास्ट प्रतिरोधी किस्में लगाएं।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'paddy_sheath_blight',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान / चावल',
      diseaseNameHindi: 'शीथ ब्लाइट / तना झुलसा रोग',
      diseaseNameEnglish: 'Sheath Blight',
      pathogen: 'फफूंद (Rhizoctonia solani)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.2,
      symptoms: [
        'जलस्तर के पास पर्ण-आवरण पर सर्पिलाकार भूरे-सफेद धब्बे।',
        'धब्बे ऊपर की पत्तियों तक फैलकर पूरे पौधे को सुखा देते हैं।'
      ],
      symptomTags: ['तने पर सर्पिलाकार धब्बे', 'पर्ण आवरण का सूखना', 'शीथ ब्लाइट'],
      organicRemedy: 'खेत से पानी निकालकर 2-3 दिन हवा लगने दें।',
      chemicalMedicine: 'वैलिडामाइसिन 3% L (शीथमार) या हेक्साकोनाज़ोल 5% SC',
      sprayDosage: 'वैलिडामाइसिन: 2.5 मिली प्रति लीटर (500 मिली प्रति एकड़)।',
      precautions: 'जलभराव अधिक दिनों तक न रहने दें।',
      preventionTips: [
        'संतुलित पोटाश खाद डालें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'paddy_brown_spot',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान / चावल',
      diseaseNameHindi: 'भूरा धब्बा रोग (Brown Spot)',
      diseaseNameEnglish: 'Brown Spot (Bipolaris oryzae)',
      pathogen: 'फफूंद (Helminthosporium oryzae)',
      severity: 'मध्यम',
      confidenceScore: 94.0,
      symptoms: [
        'पत्तियों पर गोल-अंडाकार तिल जैसे छोटे भूरे धब्बे।',
        'धब्बों के चारों ओर पीला छल्ला (Halo) बन जाता है।'
      ],
      symptomTags: ['तिल जैसे भूरे धब्बे', 'पीला छल्ला', 'भूरा धब्बा'],
      organicRemedy: 'गोमूत्र (10%) + खट्टी छाछ का छिड़काव।',
      chemicalMedicine: 'मैंकोजेब 75% WP या प्रोपिकोनाज़ोल 25% EC',
      sprayDosage: 'मैंकोजेब: 2.5 ग्राम प्रति लीटर पानी।',
      precautions: 'पोषक तत्वों की कमी वाली जमीन में यह रोग अधिक फैलता है।',
      preventionTips: [
        'मृदा परीक्षण अनुसार पोटाश व जिंक दें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'paddy_bacterial_blight',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान / चावल',
      diseaseNameHindi: 'जीवाणु झुलसा (BLB / Bacterial Leaf Blight)',
      diseaseNameEnglish: 'Bacterial Leaf Blight',
      pathogen: 'जीवाणु (Xanthomonas oryzae)',
      severity: 'गंभीर',
      confidenceScore: 95.8,
      symptoms: [
        'पत्तियों के किनारों से शुरू होकर अंदर की ओर लहरदार पीली-सफेद धारियां।',
        'पत्तियां सूखकर भूसे के रंग की हो जाती हैं।'
      ],
      symptomTags: ['लहरदार पीली धारियां', 'पत्ती के किनारे सूखना', 'बैक्टीरियल ब्लाइट'],
      organicRemedy: 'ताजा गोबर का अर्क (20 किलो गोबर 200 लीटर पानी में छानकर)।',
      chemicalMedicine: 'स्ट्रेप्टोसाइक्लिन (6 ग्राम) + कॉपर ऑक्सीक्लोराइड 50% WP (500 ग्राम)',
      sprayDosage: '6 ग्राम स्ट्रेप्टोसाइक्लिन + 500 ग्राम COC प्रति एकड़।',
      precautions: 'रोगग्रस्त खेत का पानी दूसरे स्वस्थ खेत में न जाने दें।',
      preventionTips: [
        'बीज उपचार स्ट्रेप्टोसाइक्लिन से अवश्य करें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'paddy_khaira',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान / चावल',
      diseaseNameHindi: 'खैरा रोग (जिंक की कमी)',
      diseaseNameEnglish: 'Khaira Disease (Zinc Deficiency)',
      pathogen: 'पोषक तत्व विकार (Zinc Deficiency)',
      severity: 'मध्यम',
      confidenceScore: 93.0,
      symptoms: [
        'निचली पत्तियों पर कत्थई या लाल-भूरे रंग के अनियमित धब्बे।',
        'पौधों की बढ़वार रुक जाती है और जड़ें भूरी-काली हो जाती हैं।'
      ],
      symptomTags: ['कत्थई धब्बे', 'बौनापन', 'जिंक की कमी', 'खैरा'],
      organicRemedy: 'जिंक सल्फेट 21% (5 किलो) + बुझा हुआ चूना (2.5 किलो) प्रति एकड़ छिड़काव।',
      chemicalMedicine: 'चिलेटेड जिंक EDTA 12% (Chelated Zinc)',
      sprayDosage: 'चिलेटेड जिंक: 1 ग्राम प्रति लीटर पानी (200 ग्राम प्रति एकड़)।',
      precautions: 'फास्फेट खाद के तुरंत साथ जिंक न मिलाएं।',
      preventionTips: [
        'रोपाई के समय 10 किलो जिंक सल्फेट प्रति एकड़ डालें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'paddy_stem_borer',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान / चावल',
      diseaseNameHindi: 'तना छेदक कीट (Yellow Stem Borer)',
      diseaseNameEnglish: 'Yellow Stem Borer',
      pathogen: 'कीट (Scirpophaga incertulas)',
      severity: 'गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'कल्ले निकलने के समय मृत गोभ (Dead Heart) बनती है।',
        'बाली आने के समय सफेद बाली (White Earhead) दिखती है जिसमें दाना नहीं होता।'
      ],
      symptomTags: ['सफेद बाली', 'डेड हार्ट', 'तना छेदक', 'सूखी गोभ'],
      organicRemedy: 'फेरोमोन ट्रैप (8 प्रति एकड़) लगाएं और ट्राइकोग्रामा कार्ड छोड़ें।',
      chemicalMedicine: 'क्लोरानट्रानिलिप्रोल 0.4% GR (फर्टेरा) या कार्टाप हाइड्रोक्लोराइड 4% G',
      sprayDosage: 'फर्टेरा: 4 किलो प्रति एकड़ रेत में मिलाकर डालें।',
      precautions: 'तितली दिखने के 7 दिन के अंदर दानेदार कीटनाशक डालें।',
      preventionTips: [
        'रोपाई से पहले पौध की पत्तियों की नोक तोड़ दें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'mustard_white_rust',
      cropId: 'mustard',
      cropName: 'Mustard',
      cropHindi: 'सरसों / राई',
      diseaseNameHindi: 'सफेद रतुआ / सफेद रोली (White Rust)',
      diseaseNameEnglish: 'White Rust',
      pathogen: 'फफूंद (Albugo candida)',
      severity: 'गंभीर',
      confidenceScore: 95.2,
      symptoms: [
        'पत्तियों की निचली सतह पर उभरे हुए सफेद या मलाईदार फफोले।',
        'फूल व तना विकृत होकर फूल जाते हैं (हिरणखुरी)।'
      ],
      symptomTags: ['सफेद रतुआ', 'सफेद फफोले', 'सफेद रोली', 'फूलों का मोटा होना'],
      organicRemedy: 'ट्राइकोडर्मा (5 ग्राम/लीटर) + नीम तेल (5 मिली/लीटर)।',
      chemicalMedicine: 'रिडोमिल गोल्ड (Metalaxyl 4% + Mancozeb 64%)',
      sprayDosage: '2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'बादल छाए रहने व ओस के समय तुरंत छिड़कें।',
      preventionTips: [
        '15 से 25 अक्टूबर के बीच अगेती बुवाई करें।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'mustard_alternaria_blight',
      cropId: 'mustard',
      cropName: 'Mustard',
      cropHindi: 'सरसों / राई',
      diseaseNameHindi: 'आल्टरनेरिया झुलसा रोग',
      diseaseNameEnglish: 'Alternaria Leaf Blight',
      pathogen: 'फफूंद (Alternaria brassicae)',
      severity: 'गंभीर',
      confidenceScore: 94.8,
      symptoms: [
        'पत्तियों और फलियों पर संकेन्द्री छल्लों (Rings) वाले गोल भूरे-काले धब्बे।',
        'फलियां काली पड़कर चटकने लगती हैं और दाने सिकुड़ जाते हैं।'
      ],
      symptomTags: ['संकेन्द्री छल्ले', 'काले धब्बे', 'फलियों का काला पड़ना'],
      organicRemedy: 'खट्टी छाछ + गोमूत्र का 15 दिन के अंतराल पर छिड़काव।',
      chemicalMedicine: 'आईप्रोडियोन 50% WP या मैंकोजेब 75% WP',
      sprayDosage: 'मैंकोजेब: 2.5 ग्राम प्रति लीटर (500 ग्राम प्रति एकड़)।',
      precautions: 'दिसंबर-जनवरी में मौसम नम होने पर निगरानी रखें।',
      preventionTips: [
        'रोगमुक्त प्रमाणित बीज का प्रयोग करें।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'mustard_aphids',
      cropId: 'mustard',
      cropName: 'Mustard',
      cropHindi: 'सरसों / राई',
      diseaseNameHindi: 'माहू / चेपा कीट प्रकोप (Mustard Aphid)',
      diseaseNameEnglish: 'Mustard Aphid',
      pathogen: 'कीट (Lipaphis erysimi)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.5,
      symptoms: [
        'कोमल टहनियों, फूलों और फलियों पर हरे-पीले छोटे कीटों का झुंड।',
        'कीट रस चूसते हैं और चिपचिपा तरल छोड़ते हैं जिससे काली फफूंद जमती है।'
      ],
      symptomTags: ['कीटों का झुंड', 'चिपचिपा रस', 'चेपा / माहू', 'फूल सूखना'],
      organicRemedy: 'नीम का काढ़ा (5%) या साबुन का घोल 10 ग्राम प्रति लीटर।',
      chemicalMedicine: 'डाइमेथोएट 30% EC (रोगोर) या इमिडाक्लोप्रिड 17.8% SL',
      sprayDosage: 'इमिडाक्लोप्रिड: 0.5 मिली प्रति लीटर (70 मिली प्रति एकड़)।',
      precautions: 'मधुमक्खियों की सुरक्षा हेतु छिड़काव शाम 4 बजे के बाद करें।',
      preventionTips: [
        'पीले चिपचिपे कार्ड (Yellow Sticky Traps) लगाएं।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'mustard_downy_mildew',
      cropId: 'mustard',
      cropName: 'Mustard',
      cropHindi: 'सरसों / राई',
      diseaseNameHindi: 'डाउनी मिल्ड्यू / मृदुरोमिल आसिता',
      diseaseNameEnglish: 'Downy Mildew',
      pathogen: 'फफूंद (Hyaloperonospora parasitica)',
      severity: 'मध्यम',
      confidenceScore: 92.5,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर पीले कोणीय धब्बे।',
        'निचली सतह पर मटमैली रुई जैसी फफूंद उग आती है।'
      ],
      symptomTags: ['पीले कोणीय धब्बे', 'पत्ती के नीचे रुई', 'डाउनी मिल्ड्यू'],
      organicRemedy: 'ताम्रयुक्त छाछ का छिड़काव करें।',
      chemicalMedicine: 'मेटालैक्सिल 35% WS (बीज उपचार) या कॉपर ऑक्सीक्लोराइड',
      sprayDosage: 'COC: 2.5 ग्राम प्रति लीटर पानी।',
      precautions: 'खेत में वायु संचार अच्छा रखें।',
      preventionTips: [
        'सफेद रोली व डाउनी मिल्ड्यू का मिश्रित उपचार करें।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'gram_wilt',
      cropId: 'gram',
      cropName: 'Gram / Chickpea',
      cropHindi: 'चना',
      diseaseNameHindi: 'उकठा / उखटा रोग (Fusarium Wilt)',
      diseaseNameEnglish: 'Fusarium Wilt',
      pathogen: 'फफूंद (Fusarium oxysporum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पौधों की पत्तियां मुरझाकर पीली पड़ने लगती हैं।',
        'तने को चीरकर देखने पर अंदर की संवहन नलियां काली-भूरी दिखती हैं।'
      ],
      symptomTags: ['पौधा अचानक सूखना', 'उकठा रोग', 'तने में काली धारी'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 2 किलो प्रति एकड़ गोबर खाद में मिलाकर बुवाई पूर्व दें।',
      chemicalMedicine: 'कार्बेंडाजिम 50% WP (बाविस्टिन) से बीज व जड़ उपचार',
      sprayDosage: 'बीज उपचार: 2 ग्राम प्रति किलो बीज। ड्रेन्चिंग: 2 ग्राम/लीटर।',
      precautions: 'खड़े पौधे में रोग आने पर रासायनिक छिड़काव कम असर करता है, जल निकास रखें।',
      preventionTips: [
        'उकठा प्रतिरोधी किस्में (JG 11, GNG 1581, RVG 202) लगाएं।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'gram_pod_borer',
      cropId: 'gram',
      cropName: 'Gram / Chickpea',
      cropHindi: 'चना',
      diseaseNameHindi: 'फली छेदक इल्ली (Gram Pod Borer / Helicoverpa)',
      diseaseNameEnglish: 'Gram Pod Borer',
      pathogen: 'कीट (Helicoverpa armigera)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.8,
      symptoms: [
        'हरी-भूरी इल्लियां पत्तियों व कलियों को खाती हैं।',
        'फलियों में गोल छेद करके आधा शरीर अंदर डालकर दाना चट कर जाती हैं।'
      ],
      symptomTags: ['फली में छेद', 'फलियों में गोल छेद', 'हरी इल्ली', 'दाना गायब', 'फली छेदक'],
      organicRemedy: 'नीम बीज अर्क 5% या NPV (250 LE प्रति एकड़) या \'T\' खूंटियां लगाएं।',
      chemicalMedicine: 'कोराजन (क्लोरेंट्रानिलिप्रोल 18.5% SC) या एमामेक्टिन बेंजोएट 5% SG',
      sprayDosage: 'कोराजन 60 मिली प्रति एकड़ (0.3 मिली/लीटर) या एमामेक्टिन 100 ग्राम प्रति एकड़।',
      precautions: 'फूल आने और छोटी फली बनने के समय तुरंत पहला स्प्रे करें।',
      preventionTips: [
        'खेत में 5 फेरोमोन ट्रैप प्रति एकड़ लगाएं।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'gram_collar_rot',
      cropId: 'gram',
      cropName: 'Gram / Chickpea',
      cropHindi: 'चना',
      diseaseNameHindi: 'कॉलर सड़न रोग (Collar Rot)',
      diseaseNameEnglish: 'Collar Rot',
      pathogen: 'फफूंद (Sclerotium rolfsii)',
      severity: 'गंभीर',
      confidenceScore: 93.5,
      symptoms: [
        'जमीन की सतह के पास तने का भाग काला पड़कर सड़ जाता है।',
        'सड़े हुए भाग पर सरसों के दाने जैसे भूरे स्कलेरोशिया दिखते हैं।'
      ],
      symptomTags: ['जमीन के पास तना सड़ना', 'सरसों जैसे दाने', 'कॉलर रॉट'],
      organicRemedy: 'ट्राइकोडर्मा हरजिएनम से मृदा उपचार करें।',
      chemicalMedicine: 'कार्बोक्सिन 37.5% + थीरम 37.5% (विटावैक्स)',
      sprayDosage: 'जड़ों के पास ड्रेन्चिंग: 2 ग्राम प्रति लीटर पानी।',
      precautions: 'कच्ची खाद न डालें, खेत समतल रखें।',
      preventionTips: [
        'गहरी जुताई कर धूप लगने दें।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'gram_ascochyta_blight',
      cropId: 'gram',
      cropName: 'Gram / Chickpea',
      cropHindi: 'चना',
      diseaseNameHindi: 'एस्कोकाइटा झुलसा रोग',
      diseaseNameEnglish: 'Ascochyta Blight',
      pathogen: 'फफूंद (Ascochyta rabiei)',
      severity: 'मध्यम',
      confidenceScore: 92.0,
      symptoms: [
        'पत्तियों, तनों और फलियों पर छोटे गहरे भूरे गोल धब्बे।',
        'धब्बों के बीच में काले बिंदु दिखते हैं और टहनियां मुड़ जाती हैं।'
      ],
      symptomTags: ['गहरे भूरे धब्बे', 'टहनियों का टूटना', 'एस्कोकाइटा'],
      organicRemedy: 'नीम का तेल + गोमूत्र का छिड़काव।',
      chemicalMedicine: 'क्लोरोथैलोनिल 75% WP या मैंकोजेब',
      sprayDosage: 'क्लोरोथैलोनिल: 2 ग्राम प्रति लीटर पानी।',
      precautions: 'वर्षा और ठंडे मौसम में रोग तेजी से फैलता है।',
      preventionTips: [
        'प्रमाणित रोगमुक्त बीज का ही प्रयोग करें।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'soybean_yellow_mosaic',
      cropId: 'soybean',
      cropName: 'Soybean',
      cropHindi: 'सोयाबीन',
      diseaseNameHindi: 'पीला मोज़ेक वायरस (YMV)',
      diseaseNameEnglish: 'Yellow Mosaic Virus',
      pathogen: 'सफेद मक्खी जनित वायरस (Geminivirus)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'पत्तियों पर पीले और हरे रंग के चितकबरे चकत्ते बनते हैं।',
        'पूरी पत्ती सुनहरी पीली हो जाती है, फलियों में दाने नहीं बनते।'
      ],
      symptomTags: ['पीली चितकबरी पत्तियां', 'पीला मोज़ेक', 'सफेद मक्खी', 'फलियों में दाना न बनना'],
      organicRemedy: 'नीम तेल (5 मिली/लीटर) + पीले चिपचिपे प्रपंच (Sticky Traps)।',
      chemicalMedicine: 'थियामेथोक्सम 25% WG या बीटा-साइफ्लूथ्रिन + इमिडाक्लोप्रिड',
      sprayDosage: 'थियामेथोक्सम: 80 ग्राम प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'सफेद मक्खी दिखते ही प्रारंभिक अवस्था में कीटनाशक डालें।',
      preventionTips: [
        'YMV प्रतिरोधी किस्में (JS 20-34, JS 20-69) लगाएं।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'soybean_stem_fly',
      cropId: 'soybean',
      cropName: 'Soybean',
      cropHindi: 'सोयाबीन',
      diseaseNameHindi: 'तना मक्खी व गर्डल बीटल',
      diseaseNameEnglish: 'Stem Fly & Girdle Beetle',
      pathogen: 'कीट (Melanagromyza sojae / Obereopsis brevis)',
      severity: 'गंभीर',
      confidenceScore: 94.5,
      symptoms: [
        'तने पर दो अंगूठी जैसे छल्ले बनते हैं और ऊपर का भाग लटक जाता है।',
        'तना अंदर से खोखला व लाल-भूरा हो जाता है।'
      ],
      symptomTags: ['तने पर छल्ले', 'शाखाओं का लटकना', 'खोखला तना', 'गर्डल बीटल'],
      organicRemedy: 'लक्षण दिखते ही प्रभावित टहनियों को काटकर नष्ट करें।',
      chemicalMedicine: 'थियामेथोक्सम + लैम्ब्डा साइहलोथ्रिन (एम्पलीगो) या क्लोरेंट्रानिलिप्रोल',
      sprayDosage: 'एम्पलीगो: 80 मिली प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'बुवाई के 15-20 दिन बाद पहली निगरानी शुरू करें।',
      preventionTips: [
        'बुवाई पूर्व बीज उपचार थियामेथोक्सम 30 FS से करें।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'soybean_charcoal_rot',
      cropId: 'soybean',
      cropName: 'Soybean',
      cropHindi: 'सोयाबीन',
      diseaseNameHindi: 'चारकोल सड़न रोग (Charcoal Rot)',
      diseaseNameEnglish: 'Charcoal Rot',
      pathogen: 'फफूंद (Macrophomina phaseolina)',
      severity: 'गंभीर',
      confidenceScore: 93.2,
      symptoms: [
        'तने के निचले भाग की छाल छीलने पर काले कोयले जैसा चूर्ण दिखता है।',
        'सूखे के समय पत्तियां ऊपर लगी रहकर पौधा अचानक सूख जाता है।'
      ],
      symptomTags: ['कोयले जैसा चूर्ण', 'छाल के नीचे कालापन', 'अचानक सूखना'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 2 किलो प्रति एकड़ बुवाई के समय डालें।',
      chemicalMedicine: 'कार्बेंडाजिम 12% + मैंकोजेब 63% WP (साफ)',
      sprayDosage: '2 ग्राम प्रति लीटर पानी में ड्रेन्चिंग या स्प्रे।',
      precautions: 'फूल आने के समय खेत में नमी की कमी न होने दें।',
      preventionTips: [
        'फसल चक्र में ज्वार या मक्का शामिल करें।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'soybean_rust',
      cropId: 'soybean',
      cropName: 'Soybean',
      cropHindi: 'सोयाबीन',
      diseaseNameHindi: 'सोयाबीन रस्ट / गेरुआ रोग',
      diseaseNameEnglish: 'Soybean Rust',
      pathogen: 'फफूंद (Phakopsora pachyrhizi)',
      severity: 'गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'पत्तियों की निचली सतह पर छोटे भूरे-लाल दानेदार उभार।',
        'पत्तियां समय से पहले पीली पड़कर झड़ जाती हैं।'
      ],
      symptomTags: ['भूरे-लाल दाने', 'पत्ती झड़ना', 'सोयाबीन रस्ट'],
      organicRemedy: 'नीम तेल 5 मिली प्रति लीटर पानी।',
      chemicalMedicine: 'हेक्साकोनाज़ोल 5% EC या प्रोपिकोनाज़ोल 25% EC',
      sprayDosage: '1 मिली प्रति लीटर (200 मिली प्रति एकड़)।',
      precautions: 'लगातार वर्षा के बाद धूप निकलने पर तुरंत छिड़कें।',
      preventionTips: [
        'प्रतिरोधी किस्में ही चुनें।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'cotton_leaf_curl',
      cropId: 'cotton',
      cropName: 'Cotton',
      cropHindi: 'कपास / नरमा',
      diseaseNameHindi: 'पत्ता मरोड़ रोग (CLCuD) व सफेद मक्खी',
      diseaseNameEnglish: 'Cotton Leaf Curl Virus (CLCuD)',
      pathogen: 'सफेद मक्खी जनित वायरस (Begomovirus)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 95.7,
      symptoms: [
        'पत्तियों की नसें मोटी होकर नीचे की सतह पर उभर जाती हैं।',
        'पत्तियां ऊपर या नीचे की ओर मुड़कर उल्टी कटोरी जैसी बन जाती हैं।',
        'पौधा बौना रह जाता है और टिंडे नहीं बनते।'
      ],
      symptomTags: ['मोटी नसें', 'पत्तियों का मुड़ना', 'सफेद मक्खी', 'कुकड़ा रोग'],
      organicRemedy: 'नीम बीज अर्क (NSKE 5%) + 10 लीटर गोमूत्र प्रति एकड़।',
      chemicalMedicine: 'फ्लोनिकैमिड 50% WG (उलाला) या पाइरीप्रोक्सीफेन 10% EC',
      sprayDosage: 'उलाला: 60 ग्राम प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'शुरुआती अवस्था में सफेद मक्खी को 10 कीट/पत्ती से ऊपर न जाने दें।',
      preventionTips: [
        'सीएलसीयूडी प्रतिरोधी बीटी हाइब्रिड ही लगाएं।'
      ],
      icon: '⚪',
    ),
    CropDisease(
      id: 'cotton_pink_bollworm',
      cropId: 'cotton',
      cropName: 'Cotton',
      cropHindi: 'कपास / नरमा',
      diseaseNameHindi: 'गुलाबी सुंडी (Pink Bollworm)',
      diseaseNameEnglish: 'Pink Bollworm (Pectinophora gossypiella)',
      pathogen: 'कीट (Pectinophora gossypiella)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.4,
      symptoms: [
        'फूल बंद रहकर गुलाब के फूल जैसी आकृति (Rosette Flower) बन जाती है।',
        'टिंडों के अंदर छोटी गुलाबी सुंडी बिनौले खाती है और रुई काली हो जाती है।'
      ],
      symptomTags: ['गुलाबी सुंडी', 'रोजेट फूल', 'टिंडा खराब', 'रुई काली पड़ना'],
      organicRemedy: 'फेरोमोन ट्रैप (गॉसीप्लूर) 8-10 प्रति एकड़ लगाएं।',
      chemicalMedicine: 'प्रोफेनोफॉस 40% + साइपरमेथ्रिन 4% EC या स्पिनटोरम 11.7% SC',
      sprayDosage: 'प्रोफेनोफॉस + साइपर: 400 मिली प्रति एकड़।',
      precautions: '45 से 60 दिन की फसल होने पर फेरोमोन ट्रैप से निगरानी अनिवार्य है।',
      preventionTips: [
        'फसल समाप्ति पर बकरियां या भेड़ें चराएं ताकि अवशेष नष्ट हों।'
      ],
      icon: '⚪',
    ),
    CropDisease(
      id: 'cotton_bacterial_blight',
      cropId: 'cotton',
      cropName: 'Cotton',
      cropHindi: 'कपास / नरमा',
      diseaseNameHindi: 'जीवाणु झुलसा / काला हाथ रोग (Black Arm)',
      diseaseNameEnglish: 'Bacterial Blight / Angular Leaf Spot',
      pathogen: 'जीवाणु (Xanthomonas citri pv. malvacearum)',
      severity: 'गंभीर',
      confidenceScore: 94.0,
      symptoms: [
        'पत्तियों पर नसों से घिरे कोणीय गहरे भूरे धब्बे।',
        'टहनियों और तने पर लंबे काले घाव बनते हैं जिससे टहनी टूट जाती है।'
      ],
      symptomTags: ['कोणीय काले धब्बे', 'काला हाथ', 'ब्लैक आर्म'],
      organicRemedy: 'ताम्र भस्म या तांबे के बर्तन में रखी छाछ का छिड़काव।',
      chemicalMedicine: 'कॉपर ऑक्सीक्लोराइड 50% WP + स्ट्रेप्टोसाइक्लिन',
      sprayDosage: 'COC: 500 ग्राम + स्ट्रेप्टोसाइक्लिन 6 ग्राम प्रति एकड़।',
      precautions: 'वर्षा के बाद गर्म और नम मौसम में तुरंत छिड़काव करें।',
      preventionTips: [
        'एसिड डी-लिंटेड बीज ही बोएं।'
      ],
      icon: '⚪',
    ),
    CropDisease(
      id: 'cotton_wilt',
      cropId: 'cotton',
      cropName: 'Cotton',
      cropHindi: 'कपास / नरमा',
      diseaseNameHindi: 'पैरा-विल्ट / आकस्मिक उकठा (Tirak / Para Wilt)',
      diseaseNameEnglish: 'Para Wilt & Sudden Collapse',
      pathogen: 'शारीरिक विकार व फफूंद (Fusarium / Waterlogging)',
      severity: 'गंभीर',
      confidenceScore: 93.0,
      symptoms: [
        'बारिश के तुरंत बाद तेज धूप निकलने पर हरे पौधे अचानक लटक कर सूख जाते हैं।',
        'पत्तियां हरी ही सूख जाती हैं।'
      ],
      symptomTags: ['अचानक लटकना', 'पैरा विल्ट', 'पौधों का गिरना'],
      organicRemedy: 'खेत से तुरंत अतिरिक्त पानी निकालें और जड़ों के पास गुड़ाई करें।',
      chemicalMedicine: 'कोबाल्ट क्लोराइड (10 ppm) या डीएपी (2%) + पोटाश का पर्णीय स्प्रे',
      sprayDosage: 'डीएपी 20 ग्राम + यूरिया 10 ग्राम प्रति लीटर पानी।',
      precautions: 'भारी मिट्टी में जलभराव न होने दें।',
      preventionTips: [
        'खेत में उचित ढलान और जल निकास बनाएं।'
      ],
      icon: '⚪',
    ),
    CropDisease(
      id: 'tomato_early_blight',
      cropId: 'tomato',
      cropName: 'Tomato',
      cropHindi: 'टमाटर',
      diseaseNameHindi: 'अगेती झुलसा रोग (Early Blight)',
      diseaseNameEnglish: 'Early Blight (Alternaria solani)',
      pathogen: 'फफूंद (Alternaria solani)',
      severity: 'गंभीर',
      confidenceScore: 96.2,
      symptoms: [
        'निचली पत्तियों पर छल्लेदार (Target Board / Concentric Rings) काले-भूरे धब्बे।',
        'धब्बों के चारों ओर पीलापन और पत्तियां सूखकर नीचे गिरती हैं।',
        'तने और फल के डंठल पर काले धंसे हुए घाव।'
      ],
      symptomTags: ['छल्लेदार काले धब्बे', 'टारगेट बोर्ड', 'अगेती झुलसा', 'पत्तियों का पीला पड़ना'],
      organicRemedy: 'खट्टी छाछ (5%) + लहसुन अर्क (2%) का छिड़काव।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC (स्कोर / Score) या एज़ोक्सीस्ट्रोबिन + डाइफेनोकोनाज़ोल',
      sprayDosage: 'स्कोर: 0.5 से 1 मिली प्रति लीटर (100 मिली प्रति एकड़)।',
      precautions: 'पौधों के नीचे की संक्रमित पत्तियां तोड़कर नष्ट करें।',
      preventionTips: [
        'ड्रिप सिंचाई अपनाएं ताकि पत्तियां सूखी रहें।'
      ],
      icon: '🍅',
    ),
    CropDisease(
      id: 'tomato_late_blight',
      cropId: 'tomato',
      cropName: 'Tomato',
      cropHindi: 'टमाटर',
      diseaseNameHindi: 'पछेती झुलसा रोग (Late Blight)',
      diseaseNameEnglish: 'Late Blight (Phytophthora infestans)',
      pathogen: 'फफूंद (Phytophthora infestans)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'पत्तियों पर पानी से भीगे हुए बड़े-बड़े गहरे भूरे-काले धब्बे।',
        'पत्तियों की निचली सतह पर सफेद रुई जैसी फफूंद दिखती है।',
        'कच्चे फलों पर भूरे कड़े चकत्ते पड़ जाते हैं।'
      ],
      symptomTags: ['पानी से भीगे धब्बे', 'पछेती झुलसा', 'कच्चे फल पर कड़े धब्बे'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी (5 ग्राम/लीटर) पत्तियों पर छिड़कें।',
      chemicalMedicine: 'साइमोक्सानिल 8% + मैंकोजेब 64% (कर्जेट) या फिमॉक्साडोन + साइमोक्सानिल (इक्वेशन प्रो)',
      sprayDosage: 'कर्जेट: 2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'कोहरा और 90% से अधिक नमी होने पर फौरन छिड़कें।',
      preventionTips: [
        'प्रतिरोधी किस्मों की रोपाई करें।'
      ],
      icon: '🍅',
    ),
    CropDisease(
      id: 'tomato_leaf_curl',
      cropId: 'tomato',
      cropName: 'Tomato',
      cropHindi: 'टमाटर',
      diseaseNameHindi: 'पत्ता मरोड़ / कुकड़ा रोग (ToLCV)',
      diseaseNameEnglish: 'Tomato Leaf Curl Virus (ToLCV)',
      pathogen: 'सफेद मक्खी जनित वायरस (Begomovirus)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 95.8,
      symptoms: [
        'पत्तियां ऊपर की ओर मुड़कर छोटी, मोटी और खुरदरी हो जाती हैं।',
        'पौधा झाड़ीनुमा बौना हो जाता है और फूल-फल झड़ जाते हैं।'
      ],
      symptomTags: ['पत्तियों का मुड़ना', 'पत्ता मरोड़', 'कुकड़ा रोग', 'सफेद मक्खी'],
      organicRemedy: 'नीम तेल 5 मिली + 10 मिली गोमूत्र प्रति लीटर।',
      chemicalMedicine: 'डायफेंथियूरॉन 50% WP (पेगासस) या एसिटामिप्रिड 20% SP',
      sprayDosage: 'पेगासस: 1.2 ग्राम प्रति लीटर (250 ग्राम प्रति एकड़)।',
      precautions: 'नर्सरी स्तर पर ही नायलॉन नेट (40 मेश) से पौध ढकें।',
      preventionTips: [
        'पीले चिपचिपे कार्ड खेत में लगाएं।'
      ],
      icon: '🍅',
    ),
    CropDisease(
      id: 'tomato_bacterial_wilt',
      cropId: 'tomato',
      cropName: 'Tomato',
      cropHindi: 'टमाटर',
      diseaseNameHindi: 'जीवाणु उकठा / झुलसा (Bacterial Wilt)',
      diseaseNameEnglish: 'Bacterial Wilt (Ralstonia solanacearum)',
      pathogen: 'जीवाणु (Ralstonia solanacearum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 94.2,
      symptoms: [
        'हरा-भरा पौधा बिना पीला पड़े दोपहर में अचानक मुरझा जाता है।',
        'तने का निचला हिस्सा काटकर पानी के गिलास में डालने पर सफेद दूधिया धागे (Ooze) निकलते हैं।'
      ],
      symptomTags: ['हरा पौधा सूखना', 'बैक्टीरियल उकठा', 'दूधिया धागे'],
      organicRemedy: 'स्यूडोमोनास फ्लोरोसेंस (10 ग्राम/लीटर) से रोपाई पूर्व जड़ उपचार।',
      chemicalMedicine: 'कॉपर हाइड्रोक्साइड 53.8% DF + स्ट्रेप्टोसाइक्लिन',
      sprayDosage: 'ड्रेन्चिंग: कॉपर हाइड्रोक्साइड 2 ग्राम + स्ट्रेप्टोसाइक्लिन 0.1 ग्राम प्रति लीटर।',
      precautions: 'बीमार पौधों को उखाड़कर गड्ढे में चूना डालकर दबाएं।',
      preventionTips: [
        'टमाटर की ग्राफ्टिंग जंगली बैंगन रूटस्टॉक पर करें।'
      ],
      icon: '🍅',
    ),
    CropDisease(
      id: 'tomato_fruit_borer',
      cropId: 'tomato',
      cropName: 'Tomato',
      cropHindi: 'टमाटर',
      diseaseNameHindi: 'फल छेदक इल्ली (Tomato Fruit Borer)',
      diseaseNameEnglish: 'Fruit Borer (Helicoverpa armigera)',
      pathogen: 'कीट (Helicoverpa armigera)',
      severity: 'गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'फलों पर गोल छेद दिखाई देते हैं और फल अंदर से सड़ जाते हैं।',
        'इल्ली छेद पर अपना सिर रखकर अंदर का गूदा खाती है।'
      ],
      symptomTags: ['फलों में गोल छेद', 'इल्ली', 'फल छेदक'],
      organicRemedy: 'गेंदे के पौधे (Trap Crop) टमाटर की हर 16 कतार के बाद 1 कतार लगाएं।',
      chemicalMedicine: 'क्लोरेंट्रानिलिप्रोल 18.5% SC (कोराजन) या फ्लूबेंडियामाइड',
      sprayDosage: 'कोराजन: 60 मिली प्रति एकड़ 200 लीटर पानी में।',
      precautions: 'फलों की तुड़ाई के कम से कम 3 दिन पहले तक छिड़काव न करें।',
      preventionTips: [
        'फेरोमोन ट्रैप 5 प्रति एकड़ लगाएं।'
      ],
      icon: '🍅',
    ),
    CropDisease(
      id: 'potato_late_blight',
      cropId: 'potato',
      cropName: 'Potato',
      cropHindi: 'आलू',
      diseaseNameHindi: 'आलू का पछेती झुलसा (Late Blight)',
      diseaseNameEnglish: 'Late Blight of Potato',
      pathogen: 'फफूंद (Phytophthora infestans)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.5,
      symptoms: [
        'पत्तियों के किनारों से शुरू होकर तेजी से फैलने वाले काले-पानीदार धब्बे।',
        'पत्तियों की निचली सतह पर सफेद फफूंदी। 3-4 दिन में पूरा खेत जलने जैसा दिखता है।',
        'कंदों पर कड़े भूरे-बैंगनी चकत्ते।'
      ],
      symptomTags: ['पछेती झुलसा', 'काले पानीदार धब्बे', 'खेत जलना', 'सफेद फफूंद'],
      organicRemedy: 'तांबा युक्त छाछ (कांस्य पात्र) का 7 दिन पर छिड़काव।',
      chemicalMedicine: 'मैंडीप्रोपामिड 23.4% SC (रेवस / Revus) या साइमोक्सानिल + मैंकोजेब',
      sprayDosage: 'रेवस: 200 मिली प्रति एकड़ 200 लीटर पानी में।',
      precautions: 'कोहरा छाने पर रोग आने से पहले ही प्रोफिलैक्टिक मैंकोजेब छिड़कें।',
      preventionTips: [
        'खुदाई से 10 दिन पहले बेल (Dhaul) काट दें।'
      ],
      icon: '🥔',
    ),
    CropDisease(
      id: 'potato_early_blight',
      cropId: 'potato',
      cropName: 'Potato',
      cropHindi: 'आलू',
      diseaseNameHindi: 'आलू का अगेती झुलसा (Early Blight)',
      diseaseNameEnglish: 'Early Blight of Potato',
      pathogen: 'फफूंद (Alternaria solani)',
      severity: 'मध्यम से गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'निचली पत्तियों पर गोल संकेन्द्री छल्लों वाले कत्थई धब्बे।',
        'पत्तियां कागज की तरह खड़खड़ाकर सूख जाती हैं।'
      ],
      symptomTags: ['संकेन्द्री छल्ले', 'अगेती झुलसा', 'कत्थई धब्बे'],
      organicRemedy: 'नीम तेल 5 मिली/लीटर का छिड़काव।',
      chemicalMedicine: 'मेटिराम 55% + पाइराक्लोस्ट्रोबिन 5% WG (कैब्रियो टॉप)',
      sprayDosage: 'कैब्रियो टॉप: 600 ग्राम प्रति एकड़।',
      precautions: 'पोटाश खाद की पर्याप्त मात्रा दें।',
      preventionTips: [
        'प्रमाणित कंदों का ही प्रयोग करें।'
      ],
      icon: '🥔',
    ),
    CropDisease(
      id: 'potato_black_scurf',
      cropId: 'potato',
      cropName: 'Potato',
      cropHindi: 'आलू',
      diseaseNameHindi: 'ब्लैक स्कर्फ / काली पपड़ी रोग',
      diseaseNameEnglish: 'Black Scurf (Rhizoctonia solani)',
      pathogen: 'फफूंद (Rhizoctonia solani)',
      severity: 'मध्यम',
      confidenceScore: 93.8,
      symptoms: [
        'आलू के कंदों की सतह पर काले कोयले जैसे कड़े पपड़ीदार दाने चिपक जाते हैं।',
        'धोने पर भी यह काले दाने कंद से नहीं छूटते।'
      ],
      symptomTags: ['काली पपड़ी', 'काले कड़े दाने', 'कंद पर कालापन'],
      organicRemedy: 'ट्राइकोडर्मा से कंद उपचार बुवाई से पहले करें।',
      chemicalMedicine: 'पेनफ्लुफेन 240 FS (एमिस्टो प्राइम) या पेंसीक्यूरॉन 250 SC',
      sprayDosage: 'एमिस्टो प्राइम: 100 मिली प्रति 1 टन बीज कंद।',
      precautions: 'कच्ची गोबर की खाद में यह फफूंद तेजी से पनपती है।',
      preventionTips: [
        'कंद उपचार हमेशा बुवाई से 24 घंटे पहले करें।'
      ],
      icon: '🥔',
    ),
    CropDisease(
      id: 'onion_purple_blotch',
      cropId: 'onion',
      cropName: 'Onion',
      cropHindi: 'प्याज',
      diseaseNameHindi: 'जामुनी धब्बा / पुरपल ब्लोच',
      diseaseNameEnglish: 'Purple Blotch (Alternaria porri)',
      pathogen: 'फफूंद (Alternaria porri)',
      severity: 'गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'पत्तियों और बीज डंडियों पर धंसे हुए जामुनी-बैंगनी रंग के लंबे धब्बे।',
        'धब्बों के किनारे पीले होते हैं और पत्तियां बीच से टूटकर लटक जाती हैं।'
      ],
      symptomTags: ['जामुनी धब्बे', 'बैंगनी धब्बा', 'पत्ती लटकना', 'पुरपल ब्लोच'],
      organicRemedy: 'नीम का तेल (5 मिली) + स्टीकर/सर्फ का घोल मिलाकर छिड़कें।',
      chemicalMedicine: 'टेबुकोनाज़ोल 50% + ट्राइफ्लॉक्सीस्ट्रोबिन 25% WG (नैटिवो) या कस्टोडिया',
      sprayDosage: 'नैटिवो: 120 ग्राम प्रति एकड़ 200 लीटर पानी में (स्टीकर अवश्य मिलाएं)।',
      precautions: 'प्याज की पत्तियों पर मोमी परत होती है, अतः चिपकने वाला पदार्थ (Sticker) जरूर मिलाएं।',
      preventionTips: [
        'रोपाई 15x10 सेमी की दूरी पर करें।'
      ],
      icon: '🧅',
    ),
    CropDisease(
      id: 'onion_thrips',
      cropId: 'onion',
      cropName: 'Onion',
      cropHindi: 'प्याज',
      diseaseNameHindi: 'थ्रिप्स / मरोड़िया कीट',
      diseaseNameEnglish: 'Onion Thrips (Thrips tabaci)',
      pathogen: 'कीट (Thrips tabaci)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'पत्तियों पर सफेद-चांदी जैसी चमकीली धारियां और बिंदियां।',
        'पत्तियां ऊपर से मुड़कर सूखने लगती हैं (जलेबी रोग)।'
      ],
      symptomTags: ['चांदी जैसी धारियां', 'थ्रिप्स', 'सफेद लकीरें', 'पत्ती सूखना'],
      organicRemedy: 'नीले चिपचिपे कार्ड (Blue Sticky Traps) 15-20 प्रति एकड़ लगाएं।',
      chemicalMedicine: 'फिप्रोनिल 5% SC (रीजेंट) या स्पिनटोरम 11.7% SC (डेलिगेट)',
      sprayDosage: 'फिप्रोनिल: 2 मिली प्रति लीटर पानी (400 मिली प्रति एकड़)।',
      precautions: 'दोपहर की तेज धूप में छिड़काव न करें।',
      preventionTips: [
        'खेत की मेड़ों पर मक्का की 2 कतारें अवरोधक के रूप में लगाएं।'
      ],
      icon: '🧅',
    ),
    CropDisease(
      id: 'garlic_purple_blotch',
      cropId: 'garlic',
      cropName: 'Garlic',
      cropHindi: 'लहसुन',
      diseaseNameHindi: 'लहसुन का बैंगनी धब्बा रोग',
      diseaseNameEnglish: 'Purple Blotch of Garlic',
      pathogen: 'फफूंद (Alternaria porri)',
      severity: 'गंभीर',
      confidenceScore: 95.5,
      symptoms: [
        'लहसुन की पत्तियों पर लंबे अंडाकार बैंगनी-जामुनी रंग के घाव।',
        'पत्तियों के सिरे पीले पड़कर सूखते हैं और कंद का आकार छोटा रह जाता है।'
      ],
      symptomTags: ['बैंगनी घाव', 'लहसुन की पत्ती सूखना', 'छोटा कंद'],
      organicRemedy: 'खट्टी छाछ में कॉपर का तार डालकर तैयार घोल 50 मिली/पंप छिड़कें।',
      chemicalMedicine: 'एज़ोक्सीस्ट्रोबिन 18.2% + डाइफेनोकोनाज़ोल 11.4% SC (अमीस्टार टॉप)',
      sprayDosage: 'अमीस्टार टॉप: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।',
      precautions: 'सिंचाई के तुरंत बाद छिड़काव करें जब मिट्टी में नमी हो।',
      preventionTips: [
        'स्वस्थ और बड़े आकार की पुत्तियों (Cloves) की ही बुवाई करें।'
      ],
      icon: '🧄',
    ),
    CropDisease(
      id: 'chilli_leaf_curl',
      cropId: 'chilli',
      cropName: 'Chilli',
      cropHindi: 'मिर्च',
      diseaseNameHindi: 'मुरदा रोग / पत्ती मरोड़ (Chilli Leaf Curl & Thrips)',
      diseaseNameEnglish: 'Chilli Leaf Curl Virus & Thrips/Mites',
      pathogen: 'थ्रिप्स व माइट जनित वायरस',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.5,
      symptoms: [
        'पत्तियां ऊपर की ओर नाव जैसी मुड़ती हैं (थ्रिप्स का प्रकोप)।',
        'पत्तियां नीचे की ओर उल्टे कटोरे जैसी मुड़ती हैं (माइट का प्रकोप)।',
        'पौधा झाड़ीनुमा हो जाता है, फूल झड़ते हैं।'
      ],
      symptomTags: ['पत्ती मरोड़', 'मुरदा रोग', 'नाव जैसी पत्ती', 'थ्रिप्स', 'माइट'],
      organicRemedy: 'लहसुन-मिर्च-अदरक का काढ़ा + नीम तेल (5 मिली/लीटर)।',
      chemicalMedicine: 'फेनपाइरोक्सीमेट 5% EC (सेडोना) या स्पिनोसैड 45% SC',
      sprayDosage: 'स्पिनोसैड: 0.3 मिली प्रति लीटर (60-70 मिली प्रति एकड़)।',
      precautions: 'थ्रिप्स और माइट दोनों के लिए मिश्रित कीटनाशक/माइटिसाइड चुनें।',
      preventionTips: [
        'नीले व पीले स्टिकी ट्रैप 20 प्रति एकड़ लगाएं।'
      ],
      icon: '🌶️',
    ),
    CropDisease(
      id: 'chilli_anthracnose',
      cropId: 'chilli',
      cropName: 'Chilli',
      cropHindi: 'मिर्च',
      diseaseNameHindi: 'फल सड़न व डाईबैक (Anthracnose / Dieback)',
      diseaseNameEnglish: 'Anthracnose / Die Back',
      pathogen: 'फफूंद (Colletotrichum capsici)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'पकी लाल मिर्च पर गोल धंसे हुए काले धब्बे (आंख जैसे)।',
        'शाखाएं ऊपर से नीचे की ओर सूखने लगती हैं (डाई-बैक)।'
      ],
      symptomTags: ['फल सड़न', 'डाईबैक', 'शाखाओं का सूखना', 'काले गोल धब्बे'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 5 ग्राम प्रति लीटर पानी का छिड़काव।',
      chemicalMedicine: 'एज़ोक्सीस्ट्रोबिन 23% SC (एमिस्टार) या टेबुकोनाज़ोल',
      sprayDosage: 'एमिस्टार: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।',
      precautions: 'संक्रमित फलों को तोड़कर खेत से दूर नष्ट करें।',
      preventionTips: [
        'फल पकने के समय पोटाश की सही मात्रा दें।'
      ],
      icon: '🌶️',
    ),
    CropDisease(
      id: 'brinjal_shoot_fruit_borer',
      cropId: 'brinjal',
      cropName: 'Brinjal',
      cropHindi: 'बैंगन',
      diseaseNameHindi: 'तना व फल छेदक कीट (Shoot & Fruit Borer)',
      diseaseNameEnglish: 'Shoot and Fruit Borer',
      pathogen: 'कीट (Leucinodes orbonalis)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'शुरुआत में कोमल शाखाओं की नोक मुरझाकर लटक जाती है।',
        'फलों में टेढ़े-मेढ़े छेद और अंदर इल्ली व विष्ठा दिखाई देती है।'
      ],
      symptomTags: ['शाखा की नोक लटकना', 'फलों में छेद', 'फल छेदक'],
      organicRemedy: 'मुरझाई शाखाओं को काटकर नष्ट करें + फेरोमोन ल्योर (ल्यूसिन ल्योर) लगाएं।',
      chemicalMedicine: 'एमामेक्टिन बेंजोएट 5% SG + क्लोरेंट्रानिलिप्रोल',
      sprayDosage: 'एमामेक्टिन: 80 ग्राम प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'तुड़ाई के ठीक पहले कीटनाशक न छिड़कें।',
      preventionTips: [
        'प्रति सप्ताह फेरोमोन ट्रैप की ल्योर बदलें।'
      ],
      icon: '🍆',
    ),
    CropDisease(
      id: 'brinjal_little_leaf',
      cropId: 'brinjal',
      cropName: 'Brinjal',
      cropHindi: 'बैंगन',
      diseaseNameHindi: 'छोटी पत्ती रोग (Little Leaf of Brinjal)',
      diseaseNameEnglish: 'Little Leaf Disease',
      pathogen: 'फाइटोप्लाज्मा (लीफहॉपर द्वारा प्रसारित)',
      severity: 'गंभीर',
      confidenceScore: 94.0,
      symptoms: [
        'पत्तियां बहुत छोटी, पतली और कोमल हो जाती हैं।',
        'पौधा झाड़ी जैसा हो जाता है और उस पर फल नहीं लगते।'
      ],
      symptomTags: ['छोटी पत्तियां', 'झाड़ीनुमा पौधा', 'फल न लगना', 'लिटिल लीफ'],
      organicRemedy: 'रोगी पौधों को तुरंत उखाड़कर जमीन में गाड़ दें।',
      chemicalMedicine: 'डाइमेथोएट 30% EC (रोगोर) - लीफहॉपर नियंत्रण हेतु',
      sprayDosage: 'रोगोर: 1.5 मिली प्रति लीटर पानी।',
      precautions: 'वाहक कीट (Leafhopper) का नियंत्रण नर्सरी से ही करें।',
      preventionTips: [
        'नर्सरी में कीटनाशक का हल्का छिड़काव रखें।'
      ],
      icon: '🍆',
    ),
    CropDisease(
      id: 'okra_yellow_vein_mosaic',
      cropId: 'okra',
      cropName: 'Okra / Bhindi',
      cropHindi: 'भिंडी',
      diseaseNameHindi: 'पीली नस मोज़ेक रोग (YVMV)',
      diseaseNameEnglish: 'Yellow Vein Mosaic Virus',
      pathogen: 'सफेद मक्खी जनित वायरस (Begomovirus)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'पत्तियों की नसें स्पष्ट रूप से पीली हो जाती हैं और जाल जैसा दिखता है।',
        'भिंडी छोटी, कड़ी, पीली और विकृत हो जाती है जो बिकती नहीं।'
      ],
      symptomTags: ['पीली नसें', 'नसों का जाल', 'पीली भिंडी', 'सफेद मक्खी'],
      organicRemedy: 'नीम का तेल (5 मिली/लीटर) + पीले चिपचिपे ट्रैप 20 प्रति एकड़।',
      chemicalMedicine: 'एसिटामिप्रिड 20% SP या थायमेथॉक्सम 25% WG',
      sprayDosage: 'एसिटामिप्रिड: 0.5 ग्राम प्रति लीटर (80 ग्राम प्रति एकड़)।',
      precautions: 'सफेद मक्खी को तुरंत रोकें, यह वायरस फैलाती है।',
      preventionTips: [
        'YVMV प्रतिरोधी किस्में (अर्का अनामिका, परभणी क्रांति) लगाएं।'
      ],
      icon: '🌿',
    ),
    CropDisease(
      id: 'jeera_blight',
      cropId: 'jeera',
      cropName: 'Jeera / Cumin',
      cropHindi: 'जीरा',
      diseaseNameHindi: 'जीरे का झुलसा रोग (Alternaria Blight)',
      diseaseNameEnglish: 'Cumin Blight',
      pathogen: 'फफूंद (Alternaria burnsi)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.2,
      symptoms: [
        'बादल छाने पर पत्तियों और तने पर भूरे-काले धब्बे बनते हैं।',
        'पौधा ऊपर से नीचे की ओर झुलस जाता है और दाना नहीं भरता।'
      ],
      symptomTags: ['झुलसा रोग', 'जीरे का काला पड़ना', 'दाना न बनना'],
      organicRemedy: 'खट्टी छाछ + गोमूत्र का मौसम खराब होने से पहले स्प्रे।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC (स्कोर) या अजोक्सीस्ट्रोबिन + टेबुकोनाज़ोल (कस्टोडिया)',
      sprayDosage: 'कस्टोडिया: 1.5 मिली प्रति लीटर पानी (300 मिली प्रति एकड़)।',
      precautions: 'जनवरी-फरवरी में बादल छाते ही बिना लक्षण दिखे भी छिड़काव करें।',
      preventionTips: [
        'बीज उपचार थीरम या बाविस्टिन से अनिवार्यतः करें।'
      ],
      icon: '🌿',
    ),
    CropDisease(
      id: 'jeera_powdery_mildew',
      cropId: 'jeera',
      cropName: 'Jeera / Cumin',
      cropHindi: 'जीरा',
      diseaseNameHindi: 'छाछ्या / चूर्णी फफूंद (Powdery Mildew)',
      diseaseNameEnglish: 'Powdery Mildew of Cumin',
      pathogen: 'फफूंद (Erysiphe polygoni)',
      severity: 'गंभीर',
      confidenceScore: 95.8,
      symptoms: [
        'पत्तियों, तनों और छतरियों पर सफेद चूर्ण जम जाता है।',
        'दाना बनने से पहले ही पौधा सूख जाता है।'
      ],
      symptomTags: ['सफेद पाउडर', 'छाछ्या', 'छतरियों पर सफेद चूर्ण'],
      organicRemedy: 'सल्फर डस्ट (300 मेश) 10 किलो प्रति एकड़ सुबह ओस के समय भुरकें।',
      chemicalMedicine: 'घुलनशील सल्फर 80% WDG या हेक्साकोनाज़ोल 5% EC',
      sprayDosage: 'सल्फर 80%: 2.5 ग्राम प्रति लीटर पानी (500 ग्राम प्रति एकड़)।',
      precautions: 'फूल आने के समय गंधक का भुरकाव सर्वोत्तम परिणाम देता है।',
      preventionTips: [
        'खेत में उचित दूरी रखें।'
      ],
      icon: '🌿',
    ),
    CropDisease(
      id: 'jeera_wilt',
      cropId: 'jeera',
      cropName: 'Jeera / Cumin',
      cropHindi: 'जीरा',
      diseaseNameHindi: 'जीरे का उकठा / जड़ गलन (Fusarium Wilt)',
      diseaseNameEnglish: 'Fusarium Wilt of Cumin',
      pathogen: 'फफूंद (Fusarium oxysporum f.sp. cumini)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.4,
      symptoms: [
        'खेत में चकत्तों में पौधे मुरझाकर सूख जाते हैं।',
        'जड़ें भूरी-काली होकर सड़ जाती हैं।'
      ],
      symptomTags: ['चकत्तों में सूखना', 'जड़ सड़न', 'उकठा रोग'],
      organicRemedy: 'ट्राइकोडर्मा हरजिएनम 2 किलो प्रति एकड़ बुवाई पूर्व गोबर खाद में मिलाकर दें।',
      chemicalMedicine: 'कार्बेंडाजिम 50% WP से ड्रेन्चिंग',
      sprayDosage: '2 ग्राम प्रति लीटर पानी।',
      precautions: 'लगातार उसी खेत में जीरा न बोएं (फसल चक्र अपनाएं)।',
      preventionTips: [
        'गर्मियों में गहरी जुताई करें।'
      ],
      icon: '🌿',
    ),
    CropDisease(
      id: 'pomegranate_bacterial_blight',
      cropId: 'pomegranate',
      cropName: 'Pomegranate',
      cropHindi: 'अनार',
      diseaseNameHindi: 'तेला / बैक्टीरियल ब्लाइट (Telya)',
      diseaseNameEnglish: 'Bacterial Blight / Telya',
      pathogen: 'जीवाणु (Xanthomonas axonopodis pv. punicae)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.8,
      symptoms: [
        'पत्तियों पर काले कोणीय पानी से भीगे धब्बे।',
        'फलों पर \'L\' या \'Y\' आकार की गहरी दरारें और काले तेलिया धब्बे पड़ना।'
      ],
      symptomTags: ['तेलिया धब्बे', 'फलों का फटना', 'L या Y आकार की दरारें', 'काला तेला'],
      organicRemedy: 'बोर्डो मिश्रण 1% (Bordeaux Mixture) का नियमित छिड़काव।',
      chemicalMedicine: 'स्ट्रेप्टोसाइक्लिन (50 ग्राम/1000L) + कॉपर ऑक्सीक्लोराइड 500 ग्राम',
      sprayDosage: '0.5 ग्राम स्ट्रेप्टोसाइक्लिन + 2.5 ग्राम COC प्रति लीटर पानी।',
      precautions: 'कैंची और प्रूनर को डेटॉल या सैनिटाइज़र से साफ करके ही छंटाई करें।',
      preventionTips: [
        'रोगग्रस्त फल-पत्तियां इकट्ठा करके जलाएं।'
      ],
      icon: '🍎',
    ),
    CropDisease(
      id: 'maize_fall_armyworm',
      cropId: 'maize',
      cropName: 'Maize',
      cropHindi: 'मक्का',
      diseaseNameHindi: 'फॉल आर्मीवर्म / सैनिक सुंडी (FAW)',
      diseaseNameEnglish: 'Fall Armyworm (Spodoptera frugiperda)',
      pathogen: 'कीट (Spodoptera frugiperda)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'गोभ (Whorl) की पत्तियों में बड़े-बड़े छेद और लकड़ी के बुरादे जैसी विष्ठा।',
        'सुंडी के सिर पर उल्टा \'Y\' का निशान और शरीर के पीछे 4 बिंदु।'
      ],
      symptomTags: ['गोभ में बुरादा', 'पत्तियों में बड़े छेद', 'आर्मीवर्म', 'सैनिक सुंडी'],
      organicRemedy: 'गोभ में सूखी बारीक रेत + चूना (9:1) का मिश्रण डालें।',
      chemicalMedicine: 'क्लोरानट्रानिलिप्रोल 18.5% SC या स्पिनिटोरम 11.7% SC',
      sprayDosage: 'स्पिनिटोरम: 0.5 मिली प्रति लीटर सीधे गोभ के अंदर स्प्रे करें।',
      precautions: 'स्प्रे का नोजल सीधे मक्के की गोभ (Whorl) पर केंद्रित करें।',
      preventionTips: [
        'बुवाई के 10 दिन बाद से ही नियमित निरीक्षण करें।'
      ],
      icon: '🌽',
    ),
    CropDisease(
      id: 'bajra_green_ear',
      cropId: 'bajra',
      cropName: 'Bajra',
      cropHindi: 'बाजरा',
      diseaseNameHindi: 'हरित बाली / जोगिया रोग (Green Ear Disease)',
      diseaseNameEnglish: 'Green Ear Disease / Downy Mildew',
      pathogen: 'फफूंद (Sclerospora graminicola)',
      severity: 'गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'बाजरे की बाली दानों की जगह हरी पत्तियों के गुच्छे में बदल जाती है।',
        'पत्तियों की निचली सतह पर सफेद फफूंद और पीली धारियां।'
      ],
      symptomTags: ['बाली में पत्तियां बनना', 'जोगिया रोग', 'हरित बाली', 'दाना न बनना'],
      organicRemedy: 'रोगी पौधों को फूल आने से पहले ही उखाड़कर दबा दें।',
      chemicalMedicine: 'मेटालैक्सिल 35% WS से बीज उपचार या रिडोमिल 2 ग्राम/लीटर',
      sprayDosage: 'रिडोमिल: 2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'उसी खेत में लगातार बाजरा न बोएं।',
      preventionTips: [
        'मेटालैक्सिल से बीज उपचार 6 ग्राम/किलो बीज करें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'bajra_ergot',
      cropId: 'bajra',
      cropName: 'Bajra',
      cropHindi: 'बाजरा',
      diseaseNameHindi: 'अर्गट / गूंदिया रोग (Ergot)',
      diseaseNameEnglish: 'Ergot of Bajra',
      pathogen: 'फफूंद (Claviceps fusiformis)',
      severity: 'गंभीर',
      confidenceScore: 94.2,
      symptoms: [
        'फूल आते समय बाली से शहद जैसा चिपचिपा गुलाबी-भूरा तरल टपकता है।',
        'बाद में तरल सूखकर कड़े काले पिंड (Sclerotia) बन जाते हैं जो विषैले होते हैं।'
      ],
      symptomTags: ['शहद जैसा चिपचिपा तरल', 'गोंद टपकना', 'अर्गट', 'काले कड़े दाने'],
      organicRemedy: 'बीज को 10% नमक के घोल में डालें; तैरने वाले हल्के दानों को निकालकर नष्ट करें।',
      chemicalMedicine: 'कॉपर ऑक्सीक्लोराइड 50% WP या कार्बेंडाजिम',
      sprayDosage: 'COC: 2.5 ग्राम प्रति लीटर पानी।',
      precautions: 'अर्गट प्रभावित दाने पशुओं या मनुष्यों को न खिलाएं (जहरीले होते हैं)।',
      preventionTips: [
        'नमक के पानी से तैरने वाले बीज हटाकर शुद्ध बीज ही बोएं।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'sugarcane_red_rot',
      cropId: 'sugarcane',
      cropName: 'Sugarcane',
      cropHindi: 'गन्ना',
      diseaseNameHindi: 'लाल सड़न रोग / गन्ने का कैंसर (Red Rot)',
      diseaseNameEnglish: 'Red Rot of Sugarcane',
      pathogen: 'फफूंद (Colletotrichum falcatum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'तीसरी और चौथी पत्ती सूखने लगती है।',
        'गन्ने को बीच से चीरने पर अंदर का गूदा लाल दिखता है जिसमें सफेद आड़ी पट्टियां होती हैं।',
        'गन्ने से शराब जैसी खट्टी गंध आती है।'
      ],
      symptomTags: ['अंदर से लाल गूदा', 'खट्टी शराब जैसी गंध', 'लाल सड़न', 'गन्ने का कैंसर'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी से टुकड़ों का उपचार और जल निकास का प्रबंध।',
      chemicalMedicine: 'कार्बेंडाजिम 50% WP (बाविस्टिन) 2 ग्राम/लीटर में टुकड़े डुबोएं',
      sprayDosage: 'टुकड़ा उपचार: 2 ग्राम प्रति लीटर पानी में 15 मिनट।',
      precautions: 'लाल गूदे वाले गन्ने के टुकड़ों को बीज के रूप में कदापि न लगाएं।',
      preventionTips: [
        'रेड रॉट प्रतिरोधी किस्में (Co 0238, Co 0118 आदि) लगाएं।'
      ],
      icon: '🎋',
    ),
    CropDisease(
      id: 'groundnut_tikka',
      cropId: 'groundnut',
      cropName: 'Groundnut',
      cropHindi: 'मूंगफली',
      diseaseNameHindi: 'टिक्का रोग / पर्ण चित्ती (Tikka Disease)',
      diseaseNameEnglish: 'Tikka Leaf Spot',
      pathogen: 'फफूंद (Cercospora personata / arachidicola)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'पत्तियों पर गोल गहरे भूरे से काले धब्बे जिनके चारों ओर पीला छल्ला (Halo) होता है।',
        'पत्तियां समय से पहले पीली पड़कर तेजी से झड़ जाती हैं और दाना छोटा रह जाता है।'
      ],
      symptomTags: ['काले गोल धब्बे', 'पीला छल्ला', 'टिक्का रोग', 'पत्ती झड़ना'],
      organicRemedy: 'खट्टी छाछ (5 लीटर) + नीम तेल (5 मिली/लीटर) का 15 दिन के अंतराल पर छिड़काव।',
      chemicalMedicine: 'कार्बेंडाजिम 12% + मैंकोजेब 63% WP (साफ / Saaf) या हेक्साकोनाज़ोल 5% SC',
      sprayDosage: 'साफ: 2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़ 200 लीटर पानी में)।',
      precautions: 'बुवाई के 35-40 दिन बाद पहला लक्षण दिखते ही स्प्रे करें।',
      preventionTips: [
        'बीज को थीरम या बाविस्टिन 2 ग्राम/किलो से उपचारित करें।'
      ],
      icon: '🥜',
    ),
    CropDisease(
      id: 'groundnut_collar_rot',
      cropId: 'groundnut',
      cropName: 'Groundnut',
      cropHindi: 'मूंगफली',
      diseaseNameHindi: 'कॉलर सड़न / तना गलन (Collar Rot)',
      diseaseNameEnglish: 'Collar Rot of Groundnut',
      pathogen: 'फफूंद (Aspergillus niger)',
      severity: 'गंभीर',
      confidenceScore: 94.5,
      symptoms: [
        'अंकुरण के समय जमीन की सतह पर तने का भाग काला पड़कर सड़ जाता है।',
        'सड़े हुए भाग पर काला चूर्ण उग आता है और पौधा गिरकर सूख जाता है।'
      ],
      symptomTags: ['तने का सड़ना', 'काला चूर्ण', 'कॉलर सड़न', 'पौधा गिरना'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 2 किलो प्रति एकड़ गोबर खाद में मिलाकर बुवाई से पहले डालें।',
      chemicalMedicine: 'कार्बोक्सिन 37.5% + थीरम 37.5% (विटावैक्स)',
      sprayDosage: 'बीज उपचार: 2.5 ग्राम प्रति किलो बीज।',
      precautions: 'खेत में कच्ची गोबर खाद न डालें।',
      preventionTips: [
        'बीज की गहराई 5 सेमी से अधिक न रखें।'
      ],
      icon: '🥜',
    ),
    CropDisease(
      id: 'groundnut_white_grub',
      cropId: 'groundnut',
      cropName: 'Groundnut',
      cropHindi: 'मूंगफली',
      diseaseNameHindi: 'सफेद लट (White Grub)',
      diseaseNameEnglish: 'White Grub (Holotrichia consanguinea)',
      pathogen: 'कीट (Holotrichia consanguinea)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.2,
      symptoms: [
        'पौधे अचानक कतारों में सूखने लगते हैं और आसानी से उखड़ जाते हैं।',
        'जड़ों को अंग्रेजी के \'C\' आकार की सफेद सुंडी पूरी तरह काट देती है।'
      ],
      symptomTags: ['कतार में पौधे सूखना', 'जड़ कटना', 'सफेद लट', 'C आकार की सुंडी'],
      organicRemedy: 'बवेरिया बैसियाना 2 किलो प्रति एकड़ गोबर खाद में मिलाकर दें।',
      chemicalMedicine: 'क्लोथियानिडिन 50% WDG (डेंटोट्सु) या फिप्रोनिल 40% + इमिडाक्लोप्रिड 40% WG',
      sprayDosage: 'क्लोथियानिडिन: 100 ग्राम प्रति एकड़ बुवाई पूर्व या सिंचाई के साथ।',
      precautions: 'पहली बारिश के बाद प्रकाश प्रपंच (Light Trap) लगाकर भृंगों को नष्ट करें।',
      preventionTips: [
        'खेत की मेड़ों पर लगे खेजड़ी/बबूल के पेड़ों पर मोनोक्रोटोफॉस का छिड़काव करें।'
      ],
      icon: '🥜',
    ),
    CropDisease(
      id: 'moong_yellow_mosaic',
      cropId: 'moong',
      cropName: 'Moong',
      cropHindi: 'मूंग',
      diseaseNameHindi: 'पीला मोज़ेक वायरस (YMV of Moong)',
      diseaseNameEnglish: 'Yellow Mosaic Virus of Moong',
      pathogen: 'सफेद मक्खी जनित वायरस (Mungbean Yellow Mosaic Virus)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पत्तियों पर पीले-हरे रंग के चकत्ते बनते हैं जो बाद में पूरी पत्ती को सुनहरा पीला कर देते हैं।',
        'पौधों में फलियां बहुत कम लगती हैं और दाना बारीक रह जाता है।'
      ],
      symptomTags: ['पीली पत्ती', 'पीला मोज़ेक', 'सफेद मक्खी', 'मूंग का पीलापन'],
      organicRemedy: 'नीम तेल 5 मिली/लीटर + 15 पीले चिपचिपे कार्ड प्रति एकड़ लगाएं।',
      chemicalMedicine: 'थियामेथोक्सम 25% WG या डायफेंथियूरॉन 50% WP',
      sprayDosage: 'थियामेथोक्सम: 80 ग्राम प्रति एकड़ 150 लीटर पानी में।',
      precautions: 'सफेद मक्खी की पहली पीढ़ी को तुरंत रोकें।',
      preventionTips: [
        'YMV प्रतिरोधी किस्में (IPM 02-3, GM 4, SML 668) लगाएं।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'moong_powdery_mildew',
      cropId: 'moong',
      cropName: 'Moong',
      cropHindi: 'मूंग',
      diseaseNameHindi: 'चूर्णी फफूंद / छाछ्या रोग (Powdery Mildew)',
      diseaseNameEnglish: 'Powdery Mildew of Green Gram',
      pathogen: 'फफूंद (Erysiphe polygoni)',
      severity: 'मध्यम से गंभीर',
      confidenceScore: 94.0,
      symptoms: [
        'पत्तियों की ऊपरी व निचली सतह पर सफेद आटे जैसा चूर्ण जम जाता है।',
        'पत्तियां पीली पड़कर सूखती हैं और फलियों का विकास रुक जाता है।'
      ],
      symptomTags: ['सफेद चूर्ण', 'आटे जैसा पाउडर', 'छाछ्या रोग'],
      organicRemedy: 'घुलनशील गंधक (सल्फर 80% WDG) 3 ग्राम प्रति लीटर।',
      chemicalMedicine: 'हेक्साकोनाज़ोल 5% EC या माइक्लोब्यूटानिल 10% WP',
      sprayDosage: 'हेक्साकोनाज़ोल: 2 मिली प्रति लीटर (400 मिली प्रति एकड़)।',
      precautions: 'सुबह के समय ओस सूखने के बाद छिड़काव करें।',
      preventionTips: [
        'फसल की कटाई के बाद अवशेष जलाएं।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'urad_cercospora_leaf_spot',
      cropId: 'urad',
      cropName: 'Urad',
      cropHindi: 'उड़द',
      diseaseNameHindi: 'सर्कोस्पोरा पत्ती धब्बा रोग (Leaf Spot)',
      diseaseNameEnglish: 'Cercospora Leaf Spot of Black Gram',
      pathogen: 'फफूंद (Cercospora canescens)',
      severity: 'मध्यम',
      confidenceScore: 93.0,
      symptoms: [
        'पत्तियों पर कोणीय या गोल लाल-भूरे धब्बे जिनके केंद्र राख के रंग के होते हैं।',
        'अधिक प्रकोप होने पर पत्तियां समय से पहले गिर जाती हैं।'
      ],
      symptomTags: ['लाल-भूरे धब्बे', 'राख जैसा केंद्र', 'पत्ती धब्बा'],
      organicRemedy: 'गोमूत्र 10% + नीम पत्ती अर्क का छिड़काव।',
      chemicalMedicine: 'कार्बेंडाजिम 50% WP (बाविस्टिन) या मैंकोजेब',
      sprayDosage: 'कार्बेंडाजिम: 1 ग्राम प्रति लीटर (200 ग्राम प्रति एकड़)।',
      precautions: 'वर्षा ऋतु में रोग दिखते ही पहला छिड़काव करें।',
      preventionTips: [
        'संतुलित फास्फोरस का उपयोग करें।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'pea_powdery_mildew',
      cropId: 'pea',
      cropName: 'Pea',
      cropHindi: 'मटर',
      diseaseNameHindi: 'मटर का चूर्णी फफूंद / सफेद फफूंदी',
      diseaseNameEnglish: 'Powdery Mildew of Pea',
      pathogen: 'फफूंद (Erysiphe pisi)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'पत्तियों, तनों और फलियों पर सफेद चूने जैसा पाउडर छा जाता है।',
        'फलियां काली पड़ जाती हैं और दानों का स्वाद खराब हो जाता है।'
      ],
      symptomTags: ['सफेद पाउडर', 'चूने जैसा चूर्ण', 'काली फलियां', 'छाछ्या'],
      organicRemedy: 'सल्फर डस्ट (गंधक चूर्ण) 10 किलो प्रति एकड़ भुरकें।',
      chemicalMedicine: 'डिनोकैप 48% EC (कराथेन) या अजोक्सीस्ट्रोबिन 23% SC',
      sprayDosage: 'कराथेन: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।',
      precautions: 'फरवरी में तापमान 20°C से ऊपर जाते ही विशेष सावधानी रखें।',
      preventionTips: [
        'चूर्णी फफूंद प्रतिरोधी किस्में (अर्का अजीत, रचना, मालवीय 15) लगाएं।'
      ],
      icon: '🫛',
    ),
    CropDisease(
      id: 'pea_rust',
      cropId: 'pea',
      cropName: 'Pea',
      cropHindi: 'मटर',
      diseaseNameHindi: 'मटर का गेरुआ / रतुआ रोग',
      diseaseNameEnglish: 'Pea Rust (Uromyces fabae)',
      pathogen: 'फफूंद (Uromyces fabae)',
      severity: 'गंभीर',
      confidenceScore: 94.0,
      symptoms: [
        'पत्तियों की दोनों सतहों पर पीले-भूरे उभरे हुए दाने (Pustules)।',
        'बाद में दाने गहरे काले हो जाते हैं और पत्तियां सूखकर गिर जाती हैं।'
      ],
      symptomTags: ['पीले-भूरे दाने', 'रतुआ रोग', 'मटर का रस्ट'],
      organicRemedy: 'नीम का काढ़ा + खट्टी छाछ का छिड़काव।',
      chemicalMedicine: 'मैंकोजेब 75% WP (इंडोफिल एम-45) या प्रोपिकोनाज़ोल',
      sprayDosage: 'मैंकोजेब: 2.5 ग्राम प्रति लीटर पानी।',
      precautions: 'लक्षण दिखते ही 10 दिन के अंतराल पर 2 स्प्रे करें।',
      preventionTips: [
        'अगेती बुवाई करें।'
      ],
      icon: '🫛',
    ),
    CropDisease(
      id: 'cabbage_black_rot',
      cropId: 'cauliflower',
      cropName: 'Cauliflower / Cabbage',
      cropHindi: 'फूलगोभी / पत्तागोभी',
      diseaseNameHindi: 'काला सड़न रोग (Black Rot)',
      diseaseNameEnglish: 'Black Rot of Crucifers',
      pathogen: 'जीवाणु (Xanthomonas campestris pv. campestris)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पत्तियों के किनारे से \'V\' आकार के पीले-भूरे धब्बे अंदर की ओर बढ़ते हैं।',
        'पत्तियों की नसें काली पड़ जाती हैं और तने को काटने पर काला छल्ला दिखता है।'
      ],
      symptomTags: ['V आकार के धब्बे', 'काली नसें', 'काला सड़न', 'फूल सड़ना'],
      organicRemedy: 'गर्म पानी उपचार (50°C पर 30 मिनट बीज डुबोएं)।',
      chemicalMedicine: 'स्ट्रेप्टोसाइक्लिन (6 ग्राम) + कॉपर ऑक्सीक्लोराइड (500 ग्राम)',
      sprayDosage: 'स्ट्रेप्टोसाइक्लिन 1 ग्राम प्रति 10 लीटर + COC 2.5 ग्राम/लीटर।',
      precautions: 'वर्षा के समय खेत में पानी जमा न होने दें।',
      preventionTips: [
        'गर्म जल से उपचारित बीज ही लगाएं।'
      ],
      icon: '🥦',
    ),
    CropDisease(
      id: 'cabbage_diamond_back_moth',
      cropId: 'cauliflower',
      cropName: 'Cauliflower / Cabbage',
      cropHindi: 'फूलगोभी / पत्तागोभी',
      diseaseNameHindi: 'डायमंड बैक मोथ / डीबीएम इल्ली (DBM)',
      diseaseNameEnglish: 'Diamond Back Moth (Plutella xylostella)',
      pathogen: 'कीट (Plutella xylostella)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.4,
      symptoms: [
        'पत्तियों की निचली सतह को खुरचकर इल्ली जाली (Windowing) बना देती है।',
        'फूल के अंदर इल्ली घुसकर उसे गंदा और खाने योग्य नहीं छोड़ती।'
      ],
      symptomTags: ['पत्ती पर जाली', 'हरी छोटी इल्ली', 'डीबीएम', 'फूल में छेद'],
      organicRemedy: 'सरसों को जाल फसल (Trap Crop) के रूप में गोभी के चारों ओर लगाएं।',
      chemicalMedicine: 'स्पिनटोरम 11.7% SC (डेलिगेट) या क्लोरेंट्रानिलिप्रोल (कोराजन)',
      sprayDosage: 'डेलिगेट: 0.9 मिली प्रति लीटर (180 मिली प्रति एकड़)।',
      precautions: 'कीटनाशक बदलते रहें ताकि इल्लियों में प्रतिरोधक क्षमता न बने।',
      preventionTips: [
        'फेरोमोन ट्रैप 10 प्रति एकड़ लगाएं।'
      ],
      icon: '🥦',
    ),
    CropDisease(
      id: 'coriander_stem_gall',
      cropId: 'coriander',
      cropName: 'Coriander',
      cropHindi: 'धनिया',
      diseaseNameHindi: 'गलका / लौंगिया रोग (Stem Gall of Coriander)',
      diseaseNameEnglish: 'Stem Gall / Tumour Disease',
      pathogen: 'फफूंद (Protomyces macrosporus)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'तनों, पत्तियों और फलों पर लौंग या मस्से जैसे उभरे हुए फोड़े बन जाते हैं।',
        'दाना विकृत होकर फूल जाता है जिससे तेल की मात्रा खत्म हो जाती है।'
      ],
      symptomTags: ['लौंग जैसे फोड़े', 'गलका रोग', 'लौंगिया', 'फूले हुए दाने'],
      organicRemedy: 'ट्राइकोडर्मा 2 किलो प्रति एकड़ बुवाई पूर्व गोबर में मिलाकर दें।',
      chemicalMedicine: 'क्लोरोथैलोनिल 75% WP या कार्बेन्डाजिम + मैंकोजेब',
      sprayDosage: 'क्लोरोथैलोनिल: 2 ग्राम प्रति लीटर (400 ग्राम प्रति एकड़)।',
      precautions: 'फूल आने के समय नमी अधिक होने पर तुरंत पहला स्प्रे करें।',
      preventionTips: [
        'गलका प्रतिरोधी किस्में (आरसीआर 41, आरसीआर 436) लगाएं।'
      ],
      icon: '🌿',
    ),
    CropDisease(
      id: 'coriander_powdery_mildew',
      cropId: 'coriander',
      cropName: 'Coriander',
      cropHindi: 'धनिया',
      diseaseNameHindi: 'धनिया का छाछ्या रोग (Powdery Mildew)',
      diseaseNameEnglish: 'Powdery Mildew of Coriander',
      pathogen: 'फफूंद (Erysiphe polygoni)',
      severity: 'गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'पत्तियों और फूल की छतरियों पर सफेद चूर्ण जम जाता है।',
        'दाना बनने से पहले ही फूल सूखकर गिर जाते हैं।'
      ],
      symptomTags: ['सफेद चूर्ण', 'छाछ्या', 'छतरियों पर पाउडर'],
      organicRemedy: 'सल्फर 80% WDG 2.5 ग्राम प्रति लीटर पानी।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC (स्कोर) या हेक्साकोनाज़ोल',
      sprayDosage: 'स्कोर: 0.5 मिली प्रति लीटर पानी।',
      precautions: 'तेज धूप में सल्फर का स्प्रे न करें।',
      preventionTips: [
        'संतुलित खाद और सही बुवाई दूरी रखें।'
      ],
      icon: '🌿',
    ),
    CropDisease(
      id: 'fennel_ramularia_blight',
      cropId: 'fennel',
      cropName: 'Fennel',
      cropHindi: 'सौंफ',
      diseaseNameHindi: 'सौंफ का झुलसा रोग (Ramularia Blight)',
      diseaseNameEnglish: 'Ramularia Blight of Fennel',
      pathogen: 'फफूंद (Ramularia foeniculi)',
      severity: 'गंभीर',
      confidenceScore: 95.2,
      symptoms: [
        'पत्तियों और फूल की छतरियों पर छोटे-छोटे भूरे-काले धब्बे।',
        'छतरियां काली पड़कर सूख जाती हैं और दाना नहीं बनता।'
      ],
      symptomTags: ['काली छतरियां', 'झुलसा रोग', 'सौंफ काली पड़ना'],
      organicRemedy: 'खट्टी छाछ + गोमूत्र का 10 दिन के अंतराल पर छिड़काव।',
      chemicalMedicine: 'अजोक्सीस्ट्रोबिन 18.2% + डाइफेनोकोनाज़ोल 11.4% SC',
      sprayDosage: '1 मिली प्रति लीटर पानी (200 मिली प्रति एकड़)।',
      precautions: 'बादल छाने और कोहरा होने पर बिना देरी किए छिड़कें।',
      preventionTips: [
        'प्रमाणित किस्म (आरएफ 101, आरएफ 125) बोएं।'
      ],
      icon: '🌿',
    ),
    CropDisease(
      id: 'fenugreek_downy_mildew',
      cropId: 'fenugreek',
      cropName: 'Fenugreek',
      cropHindi: 'मेथी',
      diseaseNameHindi: 'मेथी का तुलासिता / डाउनी मिल्ड्यू',
      diseaseNameEnglish: 'Downy Mildew of Fenugreek',
      pathogen: 'फफूंद (Peronospora trigonellae)',
      severity: 'मध्यम से गंभीर',
      confidenceScore: 93.8,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर पीले चकत्ते और निचली सतह पर बैगनी-धूसर फफूंदी।',
        'पत्तियां पीली पड़कर नीचे गिर जाती हैं।'
      ],
      symptomTags: ['पीले चकत्ते', 'बैगनी फफूंदी', 'डाउनी मिल्ड्यू'],
      organicRemedy: 'तांबे के बर्तन में रखी छाछ का स्प्रे।',
      chemicalMedicine: 'रिडोमिल गोल्ड (Metalaxyl + Mancozeb)',
      sprayDosage: '2 ग्राम प्रति लीटर पानी।',
      precautions: 'घनी बुवाई से बचें ताकि पौधों में धूप लगे।',
      preventionTips: [
        'जल निकास की अच्छी व्यवस्था रखें।'
      ],
      icon: '🌿',
    ),
    CropDisease(
      id: 'ginger_rhizome_rot',
      cropId: 'ginger',
      cropName: 'Ginger',
      cropHindi: 'अदरक',
      diseaseNameHindi: 'प्रकंद सड़न / सॉफ्ट रॉट (Rhizome Rot)',
      diseaseNameEnglish: 'Rhizome Rot / Soft Rot of Ginger',
      pathogen: 'फफूंद (Pythium aphanidermatum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.2,
      symptoms: [
        'पत्तियां किनारों से पीली पड़कर सूखती हैं और पौधा गिर जाता है।',
        'जमीन के नीचे अदरक का प्रकंद (गांठ) पिलपिला होकर सड़ जाता है और बदबू आती है।'
      ],
      symptomTags: ['गांठ सड़ना', 'पिलपिला प्रकंद', 'बदबूदार सड़न', 'प्रकंद सड़न'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 5 किलो प्रति एकड़ खेत में गोबर के साथ दें।',
      chemicalMedicine: 'मेटालैक्सिल 8% + मैंकोजेब 64% WP से ड्रेन्चिंग',
      sprayDosage: '2.5 ग्राम प्रति लीटर पानी से पौधों की जड़ों में ड्रेन्चिंग करें।',
      precautions: 'खेत में तनिक भी जलभराव न होने दें।',
      preventionTips: [
        'गांठों को रोपाई से पहले 30 मिनट कवकनाशी में डुबोएं।'
      ],
      icon: '🫚',
    ),
    CropDisease(
      id: 'turmeric_leaf_spot',
      cropId: 'turmeric',
      cropName: 'Turmeric',
      cropHindi: 'हल्दी',
      diseaseNameHindi: 'हल्दी का पर्ण चित्ती रोग (Colletotrichum Leaf Spot)',
      diseaseNameEnglish: 'Leaf Spot of Turmeric',
      pathogen: 'फफूंद (Colletotrichum capsici)',
      severity: 'गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'पत्तियों पर भूरे-काले अंडाकार धब्बे जिनके बीच का भाग धूसर होता है।',
        'धब्बे आपस में मिलकर पूरी पत्ती को सुखा देते हैं।'
      ],
      symptomTags: ['अंडाकार धब्बे', 'धूसर केंद्र', 'पत्ती सूखना'],
      organicRemedy: 'नीम तेल 5 मिली + खट्टी छाछ का छिड़काव।',
      chemicalMedicine: 'टेबुकोनाज़ोल 25.9% EC या मैंकोजेब 75% WP',
      sprayDosage: 'टेबुकोनाज़ोल: 1 मिली प्रति लीटर (200 मिली प्रति एकड़)।',
      precautions: 'मानसून के समय हर 20 दिन में सुरक्षात्मक स्प्रे करें।',
      preventionTips: [
        'रोगमुक्त गांठों का चयन करें।'
      ],
      icon: '🟡',
    ),
    CropDisease(
      id: 'citrus_canker',
      cropId: 'citrus',
      cropName: 'Citrus / Lemon',
      cropHindi: 'संतरा / नींबू',
      diseaseNameHindi: 'नींबू का कैंकर रोग (Citrus Canker)',
      diseaseNameEnglish: 'Citrus Canker (Xanthomonas citri)',
      pathogen: 'जीवाणु (Xanthomonas axonopodis pv. citri)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.6,
      symptoms: [
        'पत्तियों, टहनियों और फलों पर उभरे हुए खुरदरे भूरे-काले मस्से (खुरंड)।',
        'धब्बों के चारों ओर पीला छल्ला दिखता है और फल बदसूरत हो जाते हैं।'
      ],
      symptomTags: ['खुरदरे मस्से', 'खुरंड', 'सिट्रस कैंकर', 'पीला छल्ला'],
      organicRemedy: 'बोर्डो मिश्रण 1% (1 किलो चूना + 1 किलो नीला थोथा 100 लीटर पानी में)।',
      chemicalMedicine: 'स्ट्रेप्टोसाइक्लिन (10 ग्राम) + कॉपर ऑक्सीक्लोराइड (500 ग्राम/200L)',
      sprayDosage: 'स्ट्रेप्टोसाइक्लिन 1 ग्राम प्रति 20 लीटर + COC 2.5 ग्राम/लीटर।',
      precautions: 'लीफ माइनर कीट का नियंत्रण करें क्योंकि वह घाव बनाता है जहां से कैंकर फैलता है।',
      preventionTips: [
        'संक्रमित टहनियों को काटकर बोर्डो पेस्ट लगाएं।'
      ],
      icon: '🍋',
    ),
    CropDisease(
      id: 'citrus_dieback',
      cropId: 'citrus',
      cropName: 'Citrus / Lemon',
      cropHindi: 'संतरा / नींबू',
      diseaseNameHindi: 'डाईबैक / टहनी सुखा रोग',
      diseaseNameEnglish: 'Citrus Dieback',
      pathogen: 'फफूंद (Colletotrichum gloeosporioides)',
      severity: 'गंभीर',
      confidenceScore: 94.5,
      symptoms: [
        'टहनियां ऊपरी सिरे से नीचे की ओर सूखने लगती हैं।',
        'सूखी टहनी पर पत्तियां गिर जाती हैं और पौधा धीरे-धीरे कमजोर होता है।'
      ],
      symptomTags: ['ऊपर से नीचे सूखना', 'डाईबैक', 'सूखी टहनी'],
      organicRemedy: 'सूखी टहनी को 2 इंच हरे भाग सहित काटकर बोर्डो पेस्ट लगाएं।',
      chemicalMedicine: 'कॉपर ऑक्सीक्लोराइड 50% WP या कार्बेंडाजिम',
      sprayDosage: 'COC: 3 ग्राम प्रति लीटर पानी।',
      precautions: 'बरसात शुरू होने से पहले प्रूनिंग अवश्य करें।',
      preventionTips: [
        'जिंक व कॉपर सूक्ष्म पोषक तत्वों की कमी न होने दें।'
      ],
      icon: '🍋',
    ),
    CropDisease(
      id: 'mango_powdery_mildew',
      cropId: 'mango',
      cropName: 'Mango',
      cropHindi: 'आम',
      diseaseNameHindi: 'आम का बौर छाछ्या (Powdery Mildew of Mango)',
      diseaseNameEnglish: 'Powdery Mildew of Mango',
      pathogen: 'फफूंद (Oidium mangiferae)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'मंजर (फूलों के गुच्छे) पर सफेद-धूसर चूर्ण जम जाता है।',
        'फूल और छोटे मटर दाने जैसे फल सूखकर काले होकर झड़ जाते हैं।'
      ],
      symptomTags: ['बौर पर सफेद पाउडर', 'फूल झड़ना', 'आम का छाछ्या'],
      organicRemedy: 'घुलनशील सल्फर 80% WDG (2 ग्राम/लीटर) मंजर खिलने से पूर्व छिड़कें।',
      chemicalMedicine: 'हेक्साकोनाज़ोल 5% SC (कंटाफ) या डिनोकैप 48% EC',
      sprayDosage: 'हेक्साकोनाज़ोल: 1.5 मिली प्रति लीटर पानी।',
      precautions: 'फूल खिलने (पूर्ण पुष्पन) के समय अत्यधिक दबाव से स्प्रे न करें।',
      preventionTips: [
        'पहला स्प्रे बौर आने पर और दूसरा फल बनने पर करें।'
      ],
      icon: '🥭',
    ),
    CropDisease(
      id: 'mango_anthracnose',
      cropId: 'mango',
      cropName: 'Mango',
      cropHindi: 'आम',
      diseaseNameHindi: 'एन्थ्रेक्नोज़ / फल चित्ती रोग',
      diseaseNameEnglish: 'Mango Anthracnose',
      pathogen: 'फफूंद (Colletotrichum gloeosporioides)',
      severity: 'गंभीर',
      confidenceScore: 95.4,
      symptoms: [
        'पत्तियों पर काले-भूरे धब्बे और टहनियों का सूखना।',
        'पके फलों पर बड़े-बड़े काले धंसे हुए दाग पड़ते हैं जिससे फल सड़ जाते हैं।'
      ],
      symptomTags: ['फलों पर काले दाग', 'एन्थ्रेक्नोज़', 'फल सड़ना'],
      organicRemedy: 'गर्म जल उपचार (फलों को 52°C पर 5 मिनट डुबोएं)।',
      chemicalMedicine: 'अजोक्सीस्ट्रोबिन 23% SC या कॉपर ऑक्सीक्लोराइड',
      sprayDosage: 'अजोक्सीस्ट्रोबिन: 1 मिली प्रति लीटर पानी।',
      precautions: 'बरसात के मौसम में फल तुड़ाई के 15 दिन पहले स्प्रे करें।',
      preventionTips: [
        'पेड़ के अंदर धूप व हवा आने हेतु कटाई-छंटाई रखें।'
      ],
      icon: '🥭',
    ),
    CropDisease(
      id: 'mango_hopper',
      cropId: 'mango',
      cropName: 'Mango',
      cropHindi: 'आम',
      diseaseNameHindi: 'आम का भुनगा / फुदका कीट (Mango Hopper)',
      diseaseNameEnglish: 'Mango Hopper',
      pathogen: 'कीट (Amritodus atkinsoni)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'बौर पर छोटे भूरे फुदके रस चूसते हैं जिससे मंजर सूख जाता है।',
        'कीटों के मल से चिपचिपा रस निकलता है जिस पर काली फफूंद (Sooty Mold) जम जाती है।'
      ],
      symptomTags: ['काली फफूंद', 'बौर सूखना', 'चिपचिपा रस', 'आम का फुदका'],
      organicRemedy: 'नीम बीज अर्क 5% या वर्टिसिलियम लेकानी 5 ग्राम/लीटर।',
      chemicalMedicine: 'इमिडाक्लोप्रिड 17.8% SL या थायमेथॉक्सम 25% WG',
      sprayDosage: 'इमिडाक्लोप्रिड: 0.5 मिली प्रति लीटर पानी।',
      precautions: 'बौर आने की प्रारंभिक अवस्था में ही छिड़काव कर दें।',
      preventionTips: [
        'पेड़ के तने के आसपास छंटाई रखें।'
      ],
      icon: '🥭',
    ),
    CropDisease(
      id: 'guava_wilt',
      cropId: 'guava',
      cropName: 'Guava',
      cropHindi: 'अमरूद',
      diseaseNameHindi: 'अमरूद का उकठा रोग (Guava Wilt)',
      diseaseNameEnglish: 'Guava Wilt',
      pathogen: 'फफूंद (Fusarium oxysporum f.sp. psidii)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.2,
      symptoms: [
        'पेड़ की एक शाखा या पूरा पेड़ अचानक पत्तियां पीली पड़कर सूखने लगता है।',
        'पत्तियां झड़ जाती हैं और फल कड़े होकर पेड़ पर ही सूख जाते हैं।'
      ],
      symptomTags: ['पेड़ का अचानक सूखना', 'उकठा रोग', 'कड़े सूखे फल'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 25 ग्राम प्रति पेड़ की थाली में गोबर के साथ डालें।',
      chemicalMedicine: 'कार्बेंडाजिम 50% WP से तने के चारों ओर ड्रेन्चिंग',
      sprayDosage: '2 ग्राम प्रति लीटर पानी से थाली की मिट्टी तर करें।',
      precautions: 'संक्रमित पेड़ की जड़ों को काटकर खेत में न फैलाएं।',
      preventionTips: [
        'उकठा प्रतिरोधी रूटस्टॉक (Psidium friedrichsthalianum) का प्रयोग करें।'
      ],
      icon: '🍈',
    ),
    CropDisease(
      id: 'papaya_ringspot_virus',
      cropId: 'papaya',
      cropName: 'Papaya',
      cropHindi: 'पपीता',
      diseaseNameHindi: 'पपीता का रिंगस्पॉट वायरस (PRSV)',
      diseaseNameEnglish: 'Papaya Ringspot Virus',
      pathogen: 'एफिड द्वारा प्रसारित वायरस (Potyvirus)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'पत्तियों की डंडियों पर गहरे हरे रंग की तैलीय धारियां।',
        'फलों की सतह पर गोल छल्ले (Rings) बन जाते हैं और पत्तियों का आकार छोटा हो जाता है।'
      ],
      symptomTags: ['फलों पर छल्ले', 'तैलीय धारियां', 'रिंगस्पॉट वायरस', 'पत्ती सिकुड़ना'],
      organicRemedy: 'रोगी पौधों को तुरंत उखाड़कर नष्ट करें।',
      chemicalMedicine: 'डाइमेथोएट 30% EC या इमिडाक्लोप्रिड (वाहक माहू कीट नियंत्रण)',
      sprayDosage: 'इमिडाक्लोप्रिड: 0.5 मिली प्रति लीटर पानी।',
      precautions: 'पपीते के पास कद्दू वर्गीय फसलें न लगाएं (एफिड का घर)।',
      preventionTips: [
        'किनारों पर मक्का या बाजरा की 3 कतारें बॉर्डर क्रॉप के रूप में लगाएं।'
      ],
      icon: '🍈',
    ),
    CropDisease(
      id: 'watermelon_downy_mildew',
      cropId: 'watermelon',
      cropName: 'Watermelon / Muskmelon',
      cropHindi: 'तरबूज / खरबूजा',
      diseaseNameHindi: 'डाउनी मिल्ड्यू / पीला झुलसा',
      diseaseNameEnglish: 'Downy Mildew of Cucurbits',
      pathogen: 'फफूंद (Pseudoperonospora cubensis)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर नसों से बंधे कोणीय पीले धब्बे।',
        'निचली सतह पर जामुनी-धूसर फफूंदी उग आती है और बेल 2 दिन में सूख जाती है।'
      ],
      symptomTags: ['कोणीय पीले धब्बे', 'डाउनी मिल्ड्यू', 'बेल सूखना', 'जामुनी फफूंद'],
      organicRemedy: 'नीम तेल 5 मिली + खट्टी छाछ का साप्ताहिक छिड़काव।',
      chemicalMedicine: 'साइमोक्सानिल 8% + मैंकोजेब 64% (कर्जेट) या एमिस्टार टॉप',
      sprayDosage: 'कर्जेट: 2 ग्राम प्रति लीटर (400 ग्राम प्रति एकड़)।',
      precautions: 'बेलों के ऊपर फव्वारा सिंचाई न करें, ड्रिप से पानी दें।',
      preventionTips: [
        'प्रतिरोधी हाइब्रिड किस्मों का चयन करें।'
      ],
      icon: '🍉',
    ),
    CropDisease(
      id: 'cucurbit_fruit_fly',
      cropId: 'watermelon',
      cropName: 'Cucurbits',
      cropHindi: 'तरबूज / लौकी / खीरा',
      diseaseNameHindi: 'फल मक्खी प्रकोप (Fruit Fly)',
      diseaseNameEnglish: 'Melon Fruit Fly (Bactrocera cucurbitae)',
      pathogen: 'कीट (Bactrocera cucurbitae)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'छोटे फलों पर मक्खी डंक मारती है जहां से भूरा गोंद निकलता है।',
        'फल अंदर से टेढ़ा होकर सड़ जाता है और उसमें सफेद कीड़े (मैगट) निकलते हैं।'
      ],
      symptomTags: ['फलों पर डंक', 'गोंद निकलना', 'फल सड़ना', 'फल मक्खी'],
      organicRemedy: 'मिथाइल यूजीनॉल फेरोमोन ट्रैप (क्यू-ल्योर) 10 प्रति एकड़ लगाएं।',
      chemicalMedicine: 'मैलाथियान 50% EC + गुड़ का विष प्रलोभन (Poison Bait)',
      sprayDosage: '20 ग्राम गुड़ + 2 मिली मैलाथियान प्रति लीटर पानी का छिड़काव।',
      precautions: 'डंक लगे गिरे हुए फलों को जमीन में गहरा दबाएं।',
      preventionTips: [
        'फलों को अखबार या पेपर बैग से ढकें।'
      ],
      icon: '🍉',
    ),
    CropDisease(
      id: 'banana_panama_wilt',
      cropId: 'banana',
      cropName: 'Banana',
      cropHindi: 'केला',
      diseaseNameHindi: 'पनामा विल्ट / उकठा रोग',
      diseaseNameEnglish: 'Panama Wilt (Fusarium oxysporum f.sp. cubense)',
      pathogen: 'फफूंद (Fusarium oxysporum f.sp. cubense)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.8,
      symptoms: [
        'निचली पत्तियां किनारों से पीली पड़कर डंठल के पास से लटक जाती हैं (स्कर्ट जैसी)।',
        'तने को चीरने पर संवहन बंडल लाल-भूरे रंग के सड़े दिखते हैं।'
      ],
      symptomTags: ['पत्तियों का लटकना', 'पनामा विल्ट', 'तने में लाल धारी'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 50 ग्राम प्रति पौधा रोपाई के समय गड्ढे में दें।',
      chemicalMedicine: 'कार्बेंडाजिम 50% WP (2 ग्राम/लीटर) से गड्ढों की ड्रेन्चिंग',
      sprayDosage: 'जड़ों के पास 3 से 5 लीटर घोल प्रति पौधा डालें।',
      precautions: 'संक्रमित बाग से पुत्ती (Suckers) कभी न लें।',
      preventionTips: [
        'टिशू कल्चर (G-9 किस्म) के रोगमुक्त पौधे लगाएं।'
      ],
      icon: '🍌',
    ),
    CropDisease(
      id: 'banana_sigatoka',
      cropId: 'banana',
      cropName: 'Banana',
      cropHindi: 'केला',
      diseaseNameHindi: 'सिगाटोका पत्ती धब्बा रोग',
      diseaseNameEnglish: 'Sigatoka Leaf Spot',
      pathogen: 'फफूंद (Mycosphaerella musicola)',
      severity: 'गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'पत्तियों पर नाव के आकार के पीले-भूरे धब्बे जिनके केंद्र राख जैसे होते हैं।',
        'धब्बे आपस में मिलकर पूरी पत्ती को सुखा देते हैं जिससे घौद (Bunch) छोटा रहता है।'
      ],
      symptomTags: ['नाव जैसे धब्बे', 'सिगाटोका', 'पत्ती सूखना'],
      organicRemedy: 'मिनरल ऑयल (कृषि तेल) 10 मिली प्रति लीटर का छिड़काव।',
      chemicalMedicine: 'प्रोपिकोनाज़ोल 25% EC (टिल्ट) या टेबुकोनाज़ोल',
      sprayDosage: '1 मिली प्रति लीटर + मिनरल ऑयल 10 मिली प्रति लीटर पानी।',
      precautions: 'खेत में वायु संचार हेतु अतिरिक्त पुत्तियों को काटते रहें।',
      preventionTips: [
        'सूखी संक्रमित पत्तियों को काटकर नष्ट करें।'
      ],
      icon: '🍌',
    ),
    CropDisease(
      id: 'apple_scab',
      cropId: 'apple',
      cropName: 'Apple',
      cropHindi: 'सेब',
      diseaseNameHindi: 'सेब का स्कैब / पपड़ी रोग (Apple Scab)',
      diseaseNameEnglish: 'Apple Scab (Venturia inaequalis)',
      pathogen: 'फफूंद (Venturia inaequalis)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.5,
      symptoms: [
        'पत्तियों और फलों पर मखमली जैतूनी-हरे से काले गोल धब्बे।',
        'फलों की त्वचा खुरदरी, पपड़ीदार होकर फट जाती है।'
      ],
      symptomTags: ['जैतूनी-काले धब्बे', 'पपड़ीदार फल', 'फलों का फटना', 'सेब स्कैब'],
      organicRemedy: 'पतझड़ के समय गिरी पत्तियों पर 5% यूरिया का छिड़काव ताकि फफूंद सड़ जाए।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC (स्कोर) या मैंकोजेब 75% WP',
      sprayDosage: 'स्कोर: 0.3 मिली प्रति लीटर (60 मिली प्रति 200 लीटर पानी)।',
      precautions: 'कली खिलने (Pink Bud) अवस्था में पहला सुरक्षात्मक छिड़काव करें।',
      preventionTips: [
        'स्कैब पूर्वानुमान प्रणाली (Mills Table) के अनुसार छिड़कें।'
      ],
      icon: '🍎',
    ),
    CropDisease(
      id: 'guar_bacterial_blight',
      cropId: 'guar',
      cropName: 'Guar',
      cropHindi: 'ग्वार',
      diseaseNameHindi: 'जीवाणु झुलसा / अंगमारी (Bacterial Blight of Guar)',
      diseaseNameEnglish: 'Bacterial Blight of Cluster Bean',
      pathogen: 'जीवाणु (Xanthomonas axonopodis pv. cyamopsidis)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'पत्तियों पर नसों से घिरे काले-भूरे कोणीय धब्बे।',
        'तना काला पड़कर लंबवत फट जाता है और पौधा झुककर सूख जाता है।'
      ],
      symptomTags: ['कोणीय काले धब्बे', 'तना फटना', 'जीवाणु झुलसा'],
      organicRemedy: 'तांबे के तार वाली खट्टी छाछ का छिड़काव।',
      chemicalMedicine: 'स्ट्रेप्टोसाइक्लिन (6 ग्राम) + कॉपर ऑक्सीक्लोराइड (400 ग्राम)',
      sprayDosage: '6 ग्राम स्ट्रेप्टोसाइक्लिन + 400 ग्राम COC प्रति एकड़।',
      precautions: 'बारिश के बाद धूप खिलते ही तुरंत छिड़काव करें।',
      preventionTips: [
        'बीज उपचार स्ट्रेप्टोसाइक्लिन 1 ग्राम/10 किलो बीज करें।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'guar_alternaria_leaf_spot',
      cropId: 'guar',
      cropName: 'Guar',
      cropHindi: 'ग्वार',
      diseaseNameHindi: 'आल्टरनेरिया पत्ती धब्बा रोग',
      diseaseNameEnglish: 'Alternaria Leaf Spot of Guar',
      pathogen: 'फफूंद (Alternaria cyamopsidis)',
      severity: 'मध्यम',
      confidenceScore: 93.5,
      symptoms: [
        'पत्तियों पर संकेन्द्री छल्लेदार गहरे भूरे गोल धब्बे।',
        'पत्तियां समय से पहले पीली होकर गिर जाती हैं।'
      ],
      symptomTags: ['संकेन्द्री छल्ले', 'भूरे धब्बे', 'पत्ती गिरना'],
      organicRemedy: 'नीम तेल 5 मिली प्रति लीटर पानी।',
      chemicalMedicine: 'मैंकोजेब 75% WP (इंडोफिल) 2.5 ग्राम प्रति लीटर',
      sprayDosage: '500 ग्राम प्रति एकड़ 200 लीटर पानी में।',
      precautions: 'फूल आने के समय रोग की निगरानी रखें।',
      preventionTips: [
        'ग्वार की प्रमाणित किस्में (HG 365, RGC 936, RGC 1003) लगाएं।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'isabgol_downy_mildew',
      cropId: 'isabgol',
      cropName: 'Isabgol',
      cropHindi: 'इसबगोल',
      diseaseNameHindi: 'इसबगोल का डाउनी मिल्ड्यू / छाछ्या',
      diseaseNameEnglish: 'Downy Mildew of Isabgol',
      pathogen: 'फफूंद (Peronospora plantaginis)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पत्तियों पर पीले-सफेद धब्बे और निचली सतह पर धूसर फफूंदी।',
        'बालियां निकलने से पहले ही पौधा सूखकर काला पड़ जाता है।'
      ],
      symptomTags: ['पीले धब्बे', 'धूसर फफूंदी', 'इसबगोल सूखना'],
      organicRemedy: 'खट्टी छाछ 5 लीटर प्रति एकड़ छिड़कें।',
      chemicalMedicine: 'रिडोमिल गोल्ड (Metalaxyl + Mancozeb)',
      sprayDosage: '2 ग्राम प्रति लीटर पानी (400 ग्राम प्रति एकड़)।',
      precautions: 'ओस और बादल छाने पर बिना देरी किए पहला स्प्रे करें।',
      preventionTips: [
        'प्रतिरोधी किस्में (जीआई 2) लगाएं।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'castor_semilooper',
      cropId: 'castor',
      cropName: 'Castor',
      cropHindi: 'अरंडी',
      diseaseNameHindi: 'अरंडी की सेमीलूपर इल्ली (Castor Semilooper)',
      diseaseNameEnglish: 'Castor Semilooper (Achaea janata)',
      pathogen: 'कीट (Achaea janata)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'काली-भूरी लंबी इल्लियां लूप (कुबड़) बनाकर चलती हैं।',
        'पत्तियों की केवल नसें छोड़ती हैं और पूरे पौधे को कंकाल बना देती हैं।'
      ],
      symptomTags: ['कुबड़ वाली इल्ली', 'पत्तियों का कंकाल', 'सेमीलूपर'],
      organicRemedy: 'नीम बीज अर्क 5% या \'T\' आकार की चिड़िया खूंटियां 10 प्रति एकड़ लगाएं।',
      chemicalMedicine: 'क्लोरपायरीफॉस 20% EC या प्रोफेनोफॉस 50% EC',
      sprayDosage: 'प्रोफेनोफॉस: 2 मिली प्रति लीटर (400 मिली प्रति एकड़)।',
      precautions: 'इल्लियां छोटी अवस्था में ही आसानी से मरती हैं।',
      preventionTips: [
        'अंडों के गुच्छों को पत्तियों से तोड़कर नष्ट करें।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'sunflower_head_rot',
      cropId: 'sunflower',
      cropName: 'Sunflower',
      cropHindi: 'सूरजमुखी',
      diseaseNameHindi: 'फूल सड़न / हेड रॉट (Head Rot)',
      diseaseNameEnglish: 'Rhizopus Head Rot',
      pathogen: 'फफूंद (Rhizopus oryzae)',
      severity: 'गंभीर',
      confidenceScore: 94.0,
      symptoms: [
        'फूल के पीछे की थाली भूरी पड़कर पिलपिली हो जाती है।',
        'फूल पर सफेद-काली रोएंदार फफूंद जमती है और दाने सड़ जाते हैं।'
      ],
      symptomTags: ['फूल सड़न', 'हेड रॉट', 'पिलपिली थाली'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी का फूल पर छिड़काव।',
      chemicalMedicine: 'मैंकोजेब 75% WP या कॉपर ऑक्सीक्लोराइड',
      sprayDosage: '2.5 ग्राम प्रति लीटर पानी।',
      precautions: 'चिड़ियों या कीड़ों द्वारा फूल पर घाव होने से बचाएं।',
      preventionTips: [
        'फूल खिलने के बाद पानी का भराव न होने दें।'
      ],
      icon: '🌻',
    ),
    CropDisease(
      id: 'sesame_phyllody',
      cropId: 'sesame',
      cropName: 'Sesame',
      cropHindi: 'तिल',
      diseaseNameHindi: 'तिल का फाइलोडी / बांझपन रोग',
      diseaseNameEnglish: 'Sesame Phyllody',
      pathogen: 'फाइटोप्लाज्मा (लीफहॉपर द्वारा प्रसारित)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'फूलों के अंग हरी पत्तियों के गुच्छे में बदल जाते हैं (Witches\' Broom)।',
        'पौधे में कोई फलियां या बीज नहीं बनते और पौधा बांझ रह जाता है।'
      ],
      symptomTags: ['फूलों की जगह पत्तियां', 'बांझ पौधा', 'फाइलोडी'],
      organicRemedy: 'रोगी पौधों को देखते ही तुरंत उखाड़कर जला दें।',
      chemicalMedicine: 'इमिडाक्लोप्रिड 17.8% SL (लीफहॉपर नियंत्रण हेतु)',
      sprayDosage: '0.5 मिली प्रति लीटर (100 मिली प्रति एकड़)।',
      precautions: 'वाहक कीड़े को बुवाई के 30 दिन के अंदर नियंत्रित करें।',
      preventionTips: [
        'अंतरवर्तीय फसल के रूप में अरहर या मूंग लगाएं।'
      ],
      icon: '⚪',
    ),
    CropDisease(
      id: 'barley_covered_smut',
      cropId: 'barley',
      cropName: 'Barley',
      cropHindi: 'जौ',
      diseaseNameHindi: 'जौ का आवृत कंडुवा रोग (Covered Smut)',
      diseaseNameEnglish: 'Covered Smut of Barley',
      pathogen: 'फफूंद (Ustilago hordei)',
      severity: 'गंभीर',
      confidenceScore: 94.0,
      symptoms: [
        'बाली के दाने पतली पारदर्शी झिल्ली में बंद काले चूर्ण में बदल जाते हैं।',
        'कटाई-मड़ाई के समय झिल्ली फटकर काला चूर्ण स्वस्थ दानों पर चिपक जाता है।'
      ],
      symptomTags: ['झिल्लीदार काले दाने', 'कंडुवा रोग', 'जौ का स्मट'],
      organicRemedy: 'बीज को बीजामृत या गोमूत्र से शोधित करके बोएं।',
      chemicalMedicine: 'थीरम 75% WS या विटावैक्स',
      sprayDosage: 'बीज उपचार: 2.5 ग्राम प्रति किलो बीज।',
      precautions: 'उपचारित बीज ही खेत में डालें।',
      preventionTips: [
        'फसल चक्र अपनाएं।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'jowar_grain_smut',
      cropId: 'jowar',
      cropName: 'Jowar / Sorghum',
      cropHindi: 'ज्वार',
      diseaseNameHindi: 'दाना कंडुवा / स्मट (Grain Smut)',
      diseaseNameEnglish: 'Grain Smut of Sorghum',
      pathogen: 'फफूंद (Sphacelotheca sorghi)',
      severity: 'गंभीर',
      confidenceScore: 94.8,
      symptoms: [
        'बाली के कुछ या सभी दाने लम्बे-अंडाकार धूसर रंग के थैलों में बदल जाते हैं।',
        'थैली फोड़ने पर अंदर से काला कोयले जैसा चूर्ण निकलता है।'
      ],
      symptomTags: ['धूसर थैले', 'काला चूर्ण', 'दाना कंडुवा'],
      organicRemedy: 'गंधक चूर्ण 4 ग्राम प्रति किलो बीज से बीज उपचार।',
      chemicalMedicine: 'कार्बेंडाजिम 50% WP (बाविस्टिन)',
      sprayDosage: 'बीज उपचार: 2 ग्राम प्रति किलो बीज।',
      precautions: 'खेत में रोग दिखने पर बालियां तोड़कर जलाएं।',
      preventionTips: [
        'प्रमाणित किस्मों का चयन करें।'
      ],
      icon: '🌾',
    ),
    CropDisease(
      id: 'arhar_wilt',
      cropId: 'arhar',
      cropName: 'Pigeon Pea / Arhar',
      cropHindi: 'अरहर / तुअर',
      diseaseNameHindi: 'अरहर का उकठा रोग (Fusarium Wilt)',
      diseaseNameEnglish: 'Fusarium Wilt of Pigeon Pea',
      pathogen: 'फफूंद (Fusarium udum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'फूल व फली आने के समय पूरा पौधा या एक तरफ की शाखाएं सूख जाती हैं।',
        'तने की छाल छीलने पर अंदर गहरी काली-बैंगनी संवहन धारियां दिखती हैं।'
      ],
      symptomTags: ['अचानक पौधा सूखना', 'तने में काली धारी', 'उकठा रोग'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 2 किलो प्रति एकड़ गोबर खाद में मिलाकर दें।',
      chemicalMedicine: 'कार्बेंडाजिम 2 ग्राम/लीटर से जड़ ड्रेन्चिंग',
      sprayDosage: 'ड्रेन्चिंग: 2 ग्राम प्रति लीटर पानी।',
      precautions: 'लगातार 3 साल तक उसी खेत में अरहर न लगाएं।',
      preventionTips: [
        'उकठा प्रतिरोधी किस्में (आशा / ICPL 87119, मारुति, बहार) लगाएं।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'arhar_sterility_mosaic',
      cropId: 'arhar',
      cropName: 'Pigeon Pea / Arhar',
      cropHindi: 'अरहर / तुअर',
      diseaseNameHindi: 'बांझपन मोज़ेक रोग (Sterility Mosaic Disease)',
      diseaseNameEnglish: 'Sterility Mosaic Disease (SMD)',
      pathogen: 'माइट जनित वायरस (Eriophyid mite transmitted)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 95.8,
      symptoms: [
        'पत्तियां छोटी, हल्की हरी-पीली चितकबरी हो जाती हैं।',
        'पौधों पर फूल और फलियां बिल्कुल नहीं लगतीं, पौधा बांझ रह जाता है।'
      ],
      symptomTags: ['बांझ पौधा', 'फूल-फली न लगना', 'छोटी चितकबरी पत्तियां', 'एसएमडी'],
      organicRemedy: 'नीम तेल 5 मिली प्रति लीटर पानी।',
      chemicalMedicine: 'फेनाज़ाक्विन 10% EC (मैजिस्टार) या प्रोपरगाइट 57% EC',
      sprayDosage: 'फेनाज़ाक्विन: 2 मिली प्रति लीटर पानी।',
      precautions: 'शुरुआती 45 दिनों में माइट का नियंत्रण आवश्यक है।',
      preventionTips: [
        'एसएमडी प्रतिरोधी किस्में लगाएं।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'lentil_rust',
      cropId: 'lentil',
      cropName: 'Lentil',
      cropHindi: 'मसूर',
      diseaseNameHindi: 'मसूर का गेरुआ / रतुआ (Lentil Rust)',
      diseaseNameEnglish: 'Rust of Lentil (Uromyces viciae-fabae)',
      pathogen: 'फफूंद (Uromyces viciae-fabae)',
      severity: 'गंभीर',
      confidenceScore: 94.5,
      symptoms: [
        'पत्तियों और तनों पर छोटे भूरे-नारंगी दाने (पस्ट्यूल्स)।',
        'पत्तियां पीली पड़कर सूखती हैं और पौधा समय से पहले मर जाता है।'
      ],
      symptomTags: ['भूरे-नारंगी दाने', 'मसूर का रतुआ', 'पत्ती सूखना'],
      organicRemedy: 'खट्टी छाछ 5 लीटर प्रति एकड़।',
      chemicalMedicine: 'हेक्साकोनाज़ोल 5% EC या मैंकोजेब 75% WP',
      sprayDosage: 'मैंकोजेब: 2 ग्राम प्रति लीटर पानी।',
      precautions: 'दिसंबर-जनवरी में ओस के समय निगरानी रखें।',
      preventionTips: [
        'रतुआ प्रतिरोधी किस्में (पंत एल 406, पूसा वैभव) लगाएं।'
      ],
      icon: '🫘',
    ),
    CropDisease(
      id: 'cucumber_powdery_mildew',
      cropId: 'chaulai',
      cropName: 'Cucurbits / Gourds',
      cropHindi: 'खीरा / लौकी / कद्दू',
      diseaseNameHindi: 'चूर्णी फफूंद / छाछ्या रोग (Powdery Mildew)',
      diseaseNameEnglish: 'Powdery Mildew of Cucurbits',
      pathogen: 'फफूंद (Podosphaera xanthii)',
      severity: 'गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'पत्तियों की दोनों सतहों पर सफेद आटे जैसा चूर्ण छा जाता है।',
        'पत्तियां पीली पड़कर सूखती हैं और फल कड़वे या छोटे रह जाते हैं।'
      ],
      symptomTags: ['सफेद पाउडर', 'आटे जैसा चूर्ण', 'छाछ्या रोग', 'पत्ती पीली पड़ना'],
      organicRemedy: 'बेकिंग सोडा (मीठा सोडा) 5 ग्राम + 5 मिली नीम तेल प्रति लीटर पानी।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC या अजोक्सीस्ट्रोबिन 23% SC',
      sprayDosage: 'डाइफेनोकोनाज़ोल: 0.5 मिली प्रति लीटर पानी।',
      precautions: 'बेलों को मचान (Trellis) पर चढ़ाएं ताकि जमीन से हवा लगे।',
      preventionTips: [
        'रोगमुक्त संकर बीज बोएं।'
      ],
      icon: '🥒',
    ),
    CropDisease(
      id: 'gourd_mosaic_virus',
      cropId: 'chaulai',
      cropName: 'Cucurbits / Gourds',
      cropHindi: 'खीरा / लौकी / करेला',
      diseaseNameHindi: 'ककड़ी मोज़ेक वायरस (CMV)',
      diseaseNameEnglish: 'Cucumber Mosaic Virus (CMV)',
      pathogen: 'माहू / एफिड जनित वायरस',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 95.5,
      symptoms: [
        'पत्तियों पर गहरे और हल्के हरे रंग के चितकबरे चकत्ते और पत्तियों का सिकुड़ना।',
        'फल टेढ़े-मेढ़े, खुरदुरे और गांठदार हो जाते हैं।'
      ],
      symptomTags: ['चितकबरी पत्तियां', 'गांठदार फल', 'मोज़ेक वायरस', 'सिकुड़ी पत्ती'],
      organicRemedy: 'नीम बीज अर्क (NSKE 5%) + 15 पीले स्टिकी ट्रैप प्रति एकड़।',
      chemicalMedicine: 'इमिडाक्लोप्रिड 17.8% SL या एसिटामिप्रिड 20% SP',
      sprayDosage: 'इमिडाक्लोप्रिड: 0.5 मिली प्रति लीटर पानी।',
      precautions: 'संक्रमित बेलों को तुरंत उखाड़कर नष्ट करें।',
      preventionTips: [
        'नर्सरी में कीट जाल (Insect Net) का प्रयोग करें।'
      ],
      icon: '🥒',
    ),
    CropDisease(
      id: 'grapes_downy_mildew',
      cropId: 'grapes',
      cropName: 'Grapes',
      cropHindi: 'अंगूर',
      diseaseNameHindi: 'अंगूर का डाउनी मिल्ड्यू (Downy Mildew of Grapes)',
      diseaseNameEnglish: 'Downy Mildew of Grapes (Plasmopara viticola)',
      pathogen: 'फफूंद (Plasmopara viticola)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.5,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर पीले तैलीय धब्बे (Oil Spots)।',
        'निचली सतह पर सफेद घनी रोएंदार फफूंद और अंगूर के गुच्छों का सूखकर भूरा-कड़ा होना।'
      ],
      symptomTags: ['तैलीय धब्बे', 'सफेद फफूंद', 'अंगूर सूखना', 'डाउनी मिल्ड्यू'],
      organicRemedy: 'बोर्डो मिश्रण 1% (1 किलो चूना + 1 किलो नीला थोथा 100 लीटर पानी) का नियमित छिड़काव।',
      chemicalMedicine: 'डाइमेथोमॉर्फ 50% WP (एक्यूबेट) या साइमोक्सानिल + मैंकोजेब (कर्जेट)',
      sprayDosage: 'डाइमेथोमॉर्फ: 1 ग्राम प्रति लीटर (200 ग्राम प्रति एकड़)।',
      precautions: 'वर्षा ऋतु में पत्तियां भीगने के 24 घंटे के अंदर सुरक्षात्मक स्प्रे करें।',
      preventionTips: [
        'अंगूर के मंडप (Bower) में धूप और हवा का संचार बनाए रखें।'
      ],
      icon: '🍇',
    ),
    CropDisease(
      id: 'grapes_powdery_mildew',
      cropId: 'grapes',
      cropName: 'Grapes',
      cropHindi: 'अंगूर',
      diseaseNameHindi: 'अंगूर का चूर्णी फफूंद / छाछ्या (Powdery Mildew)',
      diseaseNameEnglish: 'Powdery Mildew of Grapes (Uncinula necator)',
      pathogen: 'फफूंद (Uncinula necator)',
      severity: 'गंभीर',
      confidenceScore: 96.0,
      symptoms: [
        'पत्तियों, शाखाओं और मणियों (फलों) पर सफेद राख जैसा पाउडर छा जाता है।',
        'दाने फट जाते हैं और उनमें दरारें पड़ जाती हैं।'
      ],
      symptomTags: ['सफेद पाउडर', 'दाने फटना', 'छाछ्या', 'मणियों पर चूर्ण'],
      organicRemedy: 'घुलनशील गंधक (सल्फर 80% WDG) 2 ग्राम प्रति लीटर पानी।',
      chemicalMedicine: 'टेबुकोनाज़ोल 25.9% EC (फॉलीकुर) या पेनकोनाज़ोल 10% EC (टोपाज)',
      sprayDosage: 'टोपाज: 0.5 मिली प्रति लीटर पानी।',
      precautions: 'तापमान 30°C से ऊपर जाने पर सल्फर का उपयोग न करें।',
      preventionTips: [
        'छंटाई के बाद तनों पर बोर्डो पेस्ट लगाएं।'
      ],
      icon: '🍇',
    ),
    CropDisease(
      id: 'ber_powdery_mildew',
      cropId: 'ber',
      cropName: 'Ber / Jujube',
      cropHindi: 'बेर',
      diseaseNameHindi: 'बेर का छाछ्या रोग (Powdery Mildew of Ber)',
      diseaseNameEnglish: 'Powdery Mildew of Ber (Oidium erysiphoides)',
      pathogen: 'फफूंद (Oidium erysiphoides f.sp. zizyphi)',
      severity: 'गंभीर',
      confidenceScore: 95.2,
      symptoms: [
        'छोटे फलों और पत्तियों पर सफेद चूर्ण जम जाता है।',
        'फलों की त्वचा कत्थई-भूरी, खुरदरी और कॉर्क जैसी हो जाती है और फल फट जाते हैं।'
      ],
      symptomTags: ['सफेद चूर्ण', 'खुरदरे फल', 'फल फटना', 'छाछ्या'],
      organicRemedy: 'गंधक चूर्ण (सल्फर डस्ट) 25 किलो प्रति हेक्टेयर भुरकें।',
      chemicalMedicine: 'डिनोकैप 48% EC (कराथेन) या घुलनशील सल्फर 80% WDG',
      sprayDosage: 'कराथेन: 1 मिली प्रति लीटर पानी।',
      precautions: 'पहला छिड़काव अक्टूबर के अंत में फल बनने पर करें।',
      preventionTips: [
        'छंटाई समय पर (मई-जून) करें।'
      ],
      icon: '🍈',
    ),
    CropDisease(
      id: 'pomegranate_fruit_borer',
      cropId: 'pomegranate',
      cropName: 'Pomegranate',
      cropHindi: 'अनार',
      diseaseNameHindi: 'अनार की तितली / फल छेदक (Anar Butterfly)',
      diseaseNameEnglish: 'Pomegranate Butterfly / Fruit Borer (Deudorix isocrates)',
      pathogen: 'कीट (Deudorix isocrates)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 97.0,
      symptoms: [
        'फलों पर गोल छेद होता है जिससे बदबूदार चिपचिपा विष्ठा (मल) बाहर निकलता है।',
        'फल अंदर से पूरी तरह सड़कर भूरा हो जाता है और गिर जाता है।'
      ],
      symptomTags: ['फलों पर गोल छेद', 'बदबूदार मल निकलना', 'अनार तितली', 'फल सड़ना'],
      organicRemedy: 'बटर पेपर बैग से छोटे फलों को बांधें (Bagging)।',
      chemicalMedicine: 'स्पिनोसैड 45% SC या क्लोरेंट्रानिलिप्रोल 18.5% SC',
      sprayDosage: 'स्पिनोसैड: 0.4 मिली प्रति लीटर पानी।',
      precautions: 'फूल आने के समय तितलियां दिखने पर तुरंत पहला स्प्रे करें।',
      preventionTips: [
        'प्रभावित फलों को तोड़कर गड्ढे में गहरा दबाएं।'
      ],
      icon: '🍎',
    ),
    CropDisease(
      id: 'tea_red_rust',
      cropId: 'tea',
      cropName: 'Tea',
      cropHindi: 'चाय',
      diseaseNameHindi: 'चाय का लाल रतुआ (Red Rust of Tea)',
      diseaseNameEnglish: 'Red Rust of Tea (Cephaleuros parasiticus)',
      pathogen: 'शैवाल (Alga - Cephaleuros virescens)',
      severity: 'गंभीर',
      confidenceScore: 94.0,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर गोल उभरे हुए नारंगी-लाल मखमली धब्बे।',
        'टहनियां सूखने लगती हैं और चाय की पत्तियों की गुणवत्ता घट जाती है।'
      ],
      symptomTags: ['नारंगी-लाल मखमली धब्बे', 'रेड रस्ट', 'पत्तियां सूखना'],
      organicRemedy: 'ताम्रयुक्त घोल का सुरक्षात्मक छिड़काव।',
      chemicalMedicine: 'कॉपर ऑक्सीक्लोराइड 50% WP (2.5 ग्राम/लीटर)',
      sprayDosage: '500 ग्राम प्रति एकड़ 200 लीटर पानी में।',
      precautions: 'छायादार पेड़ों की अत्यधिक छंटाई न करें।',
      preventionTips: [
        'उचित जल निकास और पोटाश खाद का संतुलित प्रयोग करें।'
      ],
      icon: '☕',
    ),
    CropDisease(
      id: 'coffee_leaf_rust',
      cropId: 'coffee',
      cropName: 'Coffee',
      cropHindi: 'कॉफ़ी',
      diseaseNameHindi: 'कॉफ़ी का पर्ण रतुआ (Coffee Leaf Rust)',
      diseaseNameEnglish: 'Coffee Leaf Rust (Hemileia vastatrix)',
      pathogen: 'फफूंद (Hemileia vastatrix)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पत्तियों की निचली सतह पर नारंगी-पीले दानेदार फफोले (Pustules)।',
        'पत्तियां तेजी से झड़ जाती हैं और केवल नंगी शाखाएं बचती हैं।'
      ],
      symptomTags: ['नारंगी-पीले फफोले', 'पत्ती झड़ना', 'कॉफ़ी रस्ट'],
      organicRemedy: 'बोर्डो मिश्रण 0.5% का मानसून पूर्व और पश्चात छिड़काव।',
      chemicalMedicine: 'प्रोपिकोनाज़ोल 25% EC या हेक्साकोनाज़ोल 5% SC',
      sprayDosage: '1 मिली प्रति लीटर पानी।',
      precautions: 'मानसून से पहले पहला स्प्रे अनिवार्य है।',
      preventionTips: [
        'रतुआ प्रतिरोधी किस्में (कावेरी, चयन 9) लगाएं।'
      ],
      icon: '☕',
    ),
    CropDisease(
      id: 'cauliflower_clubroot',
      cropId: 'cauliflower',
      cropName: 'Cauliflower / Cabbage',
      cropHindi: 'फूलगोभी / पत्तागोभी',
      diseaseNameHindi: 'क्लब रॉट / गांठ रोग (Clubroot)',
      diseaseNameEnglish: 'Clubroot (Plasmodiophora brassicae)',
      pathogen: 'फफूंद (Plasmodiophora brassicae)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 95.8,
      symptoms: [
        'जड़ें अनियमित रूप से फूलकर गांठदार और गदा (Club) जैसी मोटी हो जाती हैं।',
        'दोपहर में धूप में पौधा मुरझा जाता है और शाम को पुनः सामान्य दिखता है।'
      ],
      symptomTags: ['गांठदार जड़ें', 'दोपहर में मुरझाना', 'क्लब रॉट', 'फूल न बनना'],
      organicRemedy: 'अम्लीय मिट्टी में बुझा हुआ चूना (2 टन/हेक्टेयर) मिलाकर pH 7.2 से ऊपर रखें।',
      chemicalMedicine: 'फ्लुअज़िनम 40% SC या ट्राइकोडर्मा से पौध जड़ उपचार',
      sprayDosage: 'फ्लुअज़िनम: 1.5 मिली प्रति लीटर पानी से ड्रेन्चिंग।',
      precautions: 'संक्रमित खेत के औजार दूसरे खेत में न ले जाएं।',
      preventionTips: [
        'कम से कम 5 वर्ष का फसल चक्र अपनाएं।'
      ],
      icon: '🥦',
    ),
    CropDisease(
      id: 'carrot_alternaria_blight',
      cropId: 'carrot',
      cropName: 'Carrot',
      cropHindi: 'गाजर',
      diseaseNameHindi: 'गाजर का आल्टरनेरिया झुलसा (Leaf Blight of Carrot)',
      diseaseNameEnglish: 'Alternaria Leaf Blight (Alternaria dauci)',
      pathogen: 'फफूंद (Alternaria dauci)',
      severity: 'गंभीर',
      confidenceScore: 94.5,
      symptoms: [
        'पत्तियों के किनारों पर काले-भूरे धब्बे जिनके चारों ओर पीलापन होता है।',
        'पत्तियां झुलसकर जलने जैसी दिखती हैं और कंद (गाजर) की बढ़वार रुक जाती है।'
      ],
      symptomTags: ['पत्तियों पर काले-भूरे धब्बे', 'झुलसा', 'गाजर पतली रहना'],
      organicRemedy: 'नीम का तेल (5 मिली) + गोमूत्र (10%) का छिड़काव।',
      chemicalMedicine: 'डाइफेनोकोनाज़ोल 25% EC या क्लोरोथैलोनिल 75% WP',
      sprayDosage: 'क्लोरोथैलोनिल: 2 ग्राम प्रति लीटर पानी।',
      precautions: 'शाम के समय पत्तियां ज्यादा देर गीली न रहने दें।',
      preventionTips: [
        'रोगमुक्त प्रमाणित बीज ही बोएं।'
      ],
      icon: '🥕',
    ),
    CropDisease(
      id: 'radish_white_rust',
      cropId: 'radish',
      cropName: 'Radish',
      cropHindi: 'मूली',
      diseaseNameHindi: 'मूली का सफेद रोली रोग (White Rust of Radish)',
      diseaseNameEnglish: 'White Rust of Radish (Albugo candida)',
      pathogen: 'फफूंद (Albugo candida)',
      severity: 'मध्यम',
      confidenceScore: 93.8,
      symptoms: [
        'पत्तियों की निचली सतह पर सफेद उभरे हुए चमकीले फफोले।',
        'पत्तियां विकृत होकर मुड़ जाती हैं और मूली में स्वाद कड़वा हो जाता है।'
      ],
      symptomTags: ['सफेद फफोले', 'सफेद रोली', 'पत्ती मुड़ना'],
      organicRemedy: 'ताम्रयुक्त खट्टी छाछ का छिड़काव।',
      chemicalMedicine: 'मैंकोजेब 75% WP या रिडोमिल गोल्ड',
      sprayDosage: 'मैंकोजेब: 2.5 ग्राम प्रति लीटर पानी।',
      precautions: 'सुबह ओस सूखने के बाद ही स्प्रे करें।',
      preventionTips: [
        'घनी बुवाई न करें, पौध से पौध दूरी 8 सेमी रखें।'
      ],
      icon: '🌱',
    ),
    CropDisease(
      id: 'bottle_gourd_anthracnose',
      cropId: 'bottle_gourd',
      cropName: 'Bottle Gourd',
      cropHindi: 'लौकी / घिया',
      diseaseNameHindi: 'लौकी का एन्थ्रेक्नोज़ / फल सड़न रोग',
      diseaseNameEnglish: 'Anthracnose of Bottle Gourd (Colletotrichum orbiculare)',
      pathogen: 'फफूंद (Colletotrichum orbiculare)',
      severity: 'गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'फलों पर गोल धंसे हुए पानीदार काले चकत्ते।',
        'नमी में धब्बों पर गुलाबी रंग का चिपचिपा द्रव निकलता है और फल सड़ जाता है।'
      ],
      symptomTags: ['गोल धंसे काले चकत्ते', 'गुलाबी चिपचिपा द्रव', 'लौकी सड़ना'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 5 ग्राम प्रति लीटर पानी का छिड़काव।',
      chemicalMedicine: 'अजोक्सीस्ट्रोबिन 18.2% + डाइफेनोकोनाज़ोल 11.4% SC (अमीस्टार टॉप)',
      sprayDosage: '1 मिली प्रति लीटर पानी (200 मिली प्रति एकड़)।',
      precautions: 'फलों को जमीन पर सीधा न टिकने दें, मचान या सूखी घास बिछाएं।',
      preventionTips: [
        'बीज को कार्बेन्डाजिम से उपचारित करके लगाएं।'
      ],
      icon: '🥒',
    ),
    CropDisease(
      id: 'bitter_gourd_mosaic',
      cropId: 'bitter_gourd',
      cropName: 'Bitter Gourd',
      cropHindi: 'करेला',
      diseaseNameHindi: 'करेला का मोज़ेक वायरस (Mosaic Virus of Bitter Gourd)',
      diseaseNameEnglish: 'Bitter Gourd Mosaic Virus',
      pathogen: 'माहू / एफिड जनित वायरस',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.2,
      symptoms: [
        'पत्तियों पर गहरे व हल्के हरे रंग के चितकबरे चकत्ते और पत्तियों का सिकुड़ना।',
        'करेले का आकार छोटा, टेढ़ा और गांठदार हो जाता है।'
      ],
      symptomTags: ['चितकबरी पत्तियां', 'गांठदार करेला', 'मोज़ेक वायरस'],
      organicRemedy: 'नीम का तेल (5 मिली) + पीले चिपचिपे कार्ड 15 प्रति एकड़।',
      chemicalMedicine: 'डायफेंथियूरॉन 50% WP (पेगासस) या एसिटामिप्रिड 20% SP',
      sprayDosage: 'पेगासस: 1.2 ग्राम प्रति लीटर पानी।',
      precautions: 'संक्रमित बेलों को खेत से तुरंत उखाड़कर नष्ट करें।',
      preventionTips: [
        'मचान विधि से खेती करें।'
      ],
      icon: '🥒',
    ),
    CropDisease(
      id: 'spinach_downy_mildew',
      cropId: 'spinach',
      cropName: 'Spinach',
      cropHindi: 'पालक',
      diseaseNameHindi: 'पालक का डाउनी मिल्ड्यू / पीली चित्ती',
      diseaseNameEnglish: 'Downy Mildew of Spinach (Peronospora effusa)',
      pathogen: 'फफूंद (Peronospora effusa)',
      severity: 'गंभीर',
      confidenceScore: 94.5,
      symptoms: [
        'पत्तियों की ऊपरी सतह पर हल्के पीले धब्बे।',
        'निचली सतह पर बैगनी-धूसर मखमली फफूंदी उग आती है और पत्ती सड़ जाती है।'
      ],
      symptomTags: ['पीले धब्बे', 'बैगनी मखमली फफूंदी', 'पालक सड़ना'],
      organicRemedy: 'नीम पत्ती का काढ़ा 10% का छिड़काव।',
      chemicalMedicine: 'कॉपर ऑक्सीक्लोराइड 50% WP या मैंकोजेब',
      sprayDosage: '2 ग्राम प्रति लीटर पानी।',
      precautions: 'कटाई के 7 दिन पहले रासायनिक छिड़काव बंद कर दें।',
      preventionTips: [
        'जलभराव वाली भूमि में पालक न बोएं।'
      ],
      icon: '🥬',
    ),
    CropDisease(
      id: 'capsicum_powdery_mildew',
      cropId: 'capsicum',
      cropName: 'Capsicum',
      cropHindi: 'शिमला मिर्च',
      diseaseNameHindi: 'शिमला मिर्च का चूर्णी फफूंद (Powdery Mildew)',
      diseaseNameEnglish: 'Powdery Mildew of Capsicum (Leveillula taurica)',
      pathogen: 'फफूंद (Leveillula taurica)',
      severity: 'गंभीर',
      confidenceScore: 95.5,
      symptoms: [
        'पत्तियों की निचली सतह पर सफेद चूर्ण और ऊपरी सतह पर पीले चकत्ते।',
        'पत्तियां समय से पहले पीली पड़कर तेजी से गिर जाती हैं।'
      ],
      symptomTags: ['सफेद पाउडर', 'पीले चकत्ते', 'पत्ती झड़ना'],
      organicRemedy: 'घुलनशील गंधक 2.5 ग्राम प्रति लीटर पानी।',
      chemicalMedicine: 'पेनकोनाज़ोल 10% EC (टोपाज) या माइक्लोब्यूटानिल 10% WP',
      sprayDosage: 'टोपाज: 0.5 मिली प्रति लीटर (100 मिली प्रति एकड़)।',
      precautions: 'पॉलीहाउस में वेंटिलेशन खुला रखें।',
      preventionTips: [
        'संतुलित नाइट्रोजन व पोटाश का प्रयोग करें।'
      ],
      icon: '🫑',
    ),
    CropDisease(
      id: 'date_palm_leaf_spot',
      cropId: 'date_palm',
      cropName: 'Date Palm',
      cropHindi: 'खजूर',
      diseaseNameHindi: 'खजूर का ग्राफिओला पर्ण चित्ती (Graphiola Leaf Spot)',
      diseaseNameEnglish: 'Graphiola Leaf Spot (False Smut)',
      pathogen: 'फफूंद (Graphiola phoenicis)',
      severity: 'मध्यम',
      confidenceScore: 93.0,
      symptoms: [
        'पत्तियों (पिंडों) की दोनों सतहों पर छोटे कड़े काले मस्सेदार उभार।',
        'उभार फटने पर पीले बीजाणु निकलते हैं और पत्तियां पीली पड़कर सूखती हैं।'
      ],
      symptomTags: ['काले मस्से', 'पीले बीजाणु', 'खजूर की पत्ती सूखना'],
      organicRemedy: 'संक्रमित निचली सूखी पत्तियों की नियमित छंटाई कर जलाएं।',
      chemicalMedicine: 'कॉपर ऑक्सीक्लोराइड 50% WP (3 ग्राम/लीटर)',
      sprayDosage: '3 ग्राम प्रति लीटर पानी।',
      precautions: 'छंटाई के बाद कटे भाग पर बोर्डो पेस्ट लगाएं।',
      preventionTips: [
        'हवा व धूप का आवागमन बनाए रखें।'
      ],
      icon: '🌴',
    ),
    CropDisease(
      id: 'apple_powdery_mildew',
      cropId: 'apple',
      cropName: 'Apple',
      cropHindi: 'सेब',
      diseaseNameHindi: 'सेब का चूर्णी फफूंद (Powdery Mildew of Apple)',
      diseaseNameEnglish: 'Powdery Mildew of Apple (Podosphaera leucotricha)',
      pathogen: 'फफूंद (Podosphaera leucotricha)',
      severity: 'गंभीर',
      confidenceScore: 95.0,
      symptoms: [
        'कोमल टहनियों और पत्तियों पर सफेद-धूसर मखमली पाउडर छा जाता है।',
        'पत्तियां संकरी, मुड़ी हुई और चांदी जैसी दिखती हैं; फल पर जालीदार दाग पड़ते हैं।'
      ],
      symptomTags: ['सफेद पाउडर', 'मुड़ी हुई पत्तियां', 'जालीदार फल'],
      organicRemedy: 'घुलनशील सल्फर 80% WDG 2.5 ग्राम प्रति लीटर।',
      chemicalMedicine: 'पेनकोनाज़ोल 10% EC या ट्राइफ्लॉक्सीस्ट्रोबिन + टेबुकोनाज़ोल (नैटिवो)',
      sprayDosage: 'नैटिवो: 0.4 ग्राम प्रति लीटर पानी।',
      precautions: 'सर्दियों में छंटाई के समय सफेद कवक लगी टहनियों को काटकर जलाएं।',
      preventionTips: [
        'कली फटने की अवस्था में पहला स्प्रे करें।'
      ],
      icon: '🍎',
    ),
    CropDisease(
      id: 'watermelon_fusarium_wilt',
      cropId: 'watermelon',
      cropName: 'Watermelon',
      cropHindi: 'तरबूज',
      diseaseNameHindi: 'तरबूज का उकठा / फ्यूजेरियम विल्ट (Fusarium Wilt)',
      diseaseNameEnglish: 'Fusarium Wilt of Watermelon',
      pathogen: 'फफूंद (Fusarium oxysporum f.sp. niveum)',
      severity: 'अत्यंत गंभीर',
      confidenceScore: 96.4,
      symptoms: [
        'बेल की एक या दो शाखाएं दोपहर में मुरझा जाती हैं और सुबह ठीक दिखती हैं।',
        'कुछ दिन में पूरी बेल अचानक सूख जाती है; तना चीरने पर भूरी धारी दिखती है।'
      ],
      symptomTags: ['बेल मुरझाना', 'अचानक सूखना', 'उकठा रोग', 'तने में भूरी धारी'],
      organicRemedy: 'ट्राइकोडर्मा विरिडी 5 ग्राम प्रति गड्ढा गोबर के साथ दें।',
      chemicalMedicine: 'कार्बेंडाजिम 50% WP (2 ग्राम/लीटर) से जड़ों की ड्रेन्चिंग',
      sprayDosage: 'ड्रेन्चिंग: 2 ग्राम प्रति लीटर पानी (प्रति पौधा 500 मिली घोल)।',
      precautions: 'बलुई मिट्टी में अधिक ताप और जलभराव से बचें।',
      preventionTips: [
        'फसल चक्र में कम से कम 4 वर्ष कद्दूवर्गीय फसल न लगाएं।'
      ],
      icon: '🍉',
    ),
    CropDisease(
      id: 'paddy_bph',
      cropId: 'paddy',
      cropName: 'Paddy / Rice',
      cropHindi: 'धान/चावल',
      diseaseNameHindi: 'भूरा फुदका / भूरा माहू (BPH / Brown Plant Hopper)',
      diseaseNameEnglish: 'Brown Plant Hopper (BPH)',
      pathogen: 'रस चूसक कीट (Nilaparvata lugens)',
      severity: 'अति गंभीर',
      confidenceScore: 96.5,
      symptoms: [
        'पौधे के तने के निचले हिस्से पर भूरे छोटे कीड़े झुंड में रस चूसते हैं।',
        'खेत में जगह-जगह पौधे झुलसकर सूख जाते हैं (हॉपर बर्न / Hopper Burn)।',
        'पत्तियां पीली व भूरी होकर समय से पहले सूख जाती हैं।'
      ],
      symptomTags: ['तने पर भूरे छोटे कीड़े', 'हॉपर बर्न', 'भूरा फुदका', 'BPH', 'पौधे का सूखना'],
      organicRemedy: 'नीम का तेल (5 मिली/लीटर) या 5% नीम बीज अर्क (NSKE) का तने के पास छिड़काव करें। खेत से पानी तुरंत निकाल दें।',
      chemicalMedicine: 'पाइमेट्रोज़िन 50% WG (चेस / Chess) या ट्राइफ्लुमेज़ोपायरीम 10% SC (पेक्सलोन / Pexalon)',
      sprayDosage: 'चेस 120 ग्राम प्रति एकड़ या पेक्सलोन 94 मिली प्रति एकड़ 200 लीटर पानी में मिलाकर तने के आधार पर स्प्रे करें।',
      precautions: 'स्प्रे करते समय नोजल को पौधों के निचले तने की ओर रखें, अत्यधिक यूरिया के प्रयोग से बचें।',
      preventionTips: [
        'खेत में हर 2-3 मीटर पर 30 सेमी की खाली गली (एली वेज़) छोड़ें।',
        'खेत में लगातार पानी भरा न रखें, बीच-बीच में सुखाएं।'
      ],
      icon: '🌾',
    ),
  ];

  /// Normalize regional crop names to canonical IDs
  static String normalizeCropId(String cropId) {
    final c = cropId.toLowerCase().trim();
    if (c.contains('wheat') || c.contains('gehu') || c.contains('गेहूं') || c.contains('गेहू')) return 'wheat';
    if (c.contains('paddy') || c.contains('rice') || c.contains('dhan') || c.contains('chawal') || c.contains('धान') || c.contains('चावल')) return 'paddy';
    if (c.contains('mustard') || c.contains('sarson') || c.contains('sarso') || c.contains('राई') || c.contains('सरसों')) return 'mustard';
    if (c.contains('cotton') || c.contains('kapas') || c.contains('narma') || c.contains('कपास') || c.contains('नरमा')) return 'cotton';
    if (c.contains('soybean') || c.contains('सोयाबीन')) return 'soybean';
    if (c.contains('gram') || c.contains('chana') || c.contains('चना')) return 'gram';
    if (c.contains('tomato') || c.contains('tamatar') || c.contains('टमाटर')) return 'tomato';
    if (c.contains('potato') || c.contains('aloo') || c.contains('alu') || c.contains('आलू')) return 'potato';
    if (c.contains('chilli') || c.contains('chili') || c.contains('mirch') || c.contains('मिर्च')) return 'chilli';
    if (c.contains('onion') || c.contains('pyaj') || c.contains('pyaaj') || c.contains('प्याज')) return 'onion';
    if (c.contains('garlic') || c.contains('lahsun') || c.contains('लहसुन')) return 'garlic';
    if (c.contains('groundnut') || c.contains('mungfali') || c.contains('मूंगफली')) return 'groundnut';
    if (c.contains('maize') || c.contains('makka') || c.contains('मक्का')) return 'maize';
    if (c.contains('bajra') || c.contains('बाजरा')) return 'bajra';
    if (c.contains('moong') || c.contains('mung') || c.contains('मूंग')) return 'moong';
    if (c.contains('urad') || c.contains('उड़द')) return 'urad';
    if (c.contains('arhar') || c.contains('tur') || c.contains('अरहर') || c.contains('तुअर')) return 'arhar';
    if (c.contains('cauliflower') || c.contains('gobhi') || c.contains('gobi') || c.contains('गोभी')) return 'cauliflower';
    if (c.contains('brinjal') || c.contains('baingan') || c.contains('बैंगन')) return 'brinjal';
    if (c.contains('okra') || c.contains('bhindi') || c.contains('भिंडी')) return 'okra';
    if (c.contains('pea') || c.contains('matar') || c.contains('मटर')) return 'pea';
    if (c.contains('jeera') || c.contains('cumin') || c.contains('जीरा')) return 'jeera';
    if (c.contains('coriander') || c.contains('dhaniya') || c.contains('धनिया')) return 'coriander';
    if (c.contains('fennel') || c.contains('saunf') || c.contains('सौंफ')) return 'fennel';
    if (c.contains('fenugreek') || c.contains('methi') || c.contains('मेथी')) return 'fenugreek';
    if (c.contains('ginger') || c.contains('adrak') || c.contains('अदरक')) return 'ginger';
    if (c.contains('turmeric') || c.contains('haldi') || c.contains('हल्दी')) return 'turmeric';
    if (c.contains('sugarcane') || c.contains('ganna') || c.contains('गन्ना')) return 'sugarcane';
    if (c.contains('guar') || c.contains('ग्वार')) return 'guar';
    if (c.contains('isabgol') || c.contains('इसबगोल')) return 'isabgol';
    if (c.contains('pomegranate') || c.contains('anar') || c.contains('अनार')) return 'pomegranate';
    if (c.contains('citrus') || c.contains('nimbu') || c.contains('santra') || c.contains('संतरा') || c.contains('नींबू')) return 'citrus';
    if (c.contains('mango') || c.contains('aam') || c.contains('आम')) return 'mango';
    if (c.contains('guava') || c.contains('amrood') || c.contains('अमरूद')) return 'guava';
    if (c.contains('papaya') || c.contains('papita') || c.contains('पपीता')) return 'papaya';
    if (c.contains('watermelon') || c.contains('tarbooj') || c.contains('तरबूज') || c.contains('kharbooza') || c.contains('खरबूजा')) return 'watermelon';
    if (c.contains('castor') || c.contains('arandi') || c.contains('अरंडी')) return 'castor';
    if (c.contains('sunflower') || c.contains('surajmukhi') || c.contains('सूरजमुखी')) return 'sunflower';
    if (c.contains('sesame') || c.contains('til') || c.contains('तिल')) return 'sesame';
    if (c.contains('banana') || c.contains('kela') || c.contains('केला')) return 'banana';
    if (c.contains('apple') || c.contains('seb') || c.contains('सेब')) return 'apple';
    if (c.contains('grapes') || c.contains('angoor') || c.contains('अंगूर')) return 'grapes';
    if (c.contains('carrot') || c.contains('gajar') || c.contains('गाजर')) return 'carrot';
    if (c.contains('radish') || c.contains('mooli') || c.contains('मूली')) return 'radish';
    if (c.contains('spinach') || c.contains('palak') || c.contains('पालक')) return 'spinach';
    if (c.contains('capsicum') || c.contains('shimla') || c.contains('शिमला मिर्च')) return 'capsicum';
    if (c.contains('bottle_gourd') || c.contains('lauki') || c.contains('ghiya') || c.contains('लौकी')) return 'bottle_gourd';
    if (c.contains('bitter_gourd') || c.contains('karela') || c.contains('करेला')) return 'bitter_gourd';
    if (c.contains('cholai') || c.contains('chaulai') || c.contains('chawli') || c.contains('lobia') || c.contains('chawla') || c.contains('चौलाई') || c.contains('चंवला') || c.contains('लोबिया')) return 'chaulai';
    return c;
  }

static List<CropDisease> getDiseasesByCrop(String cropId) {
    final c = cropId.toLowerCase().trim();
    if (c == 'auto' || c == 'all' || c.isEmpty) {
      return diseases;
    }
    final norm = normalizeCropId(cropId);
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
    final c = cropId.toLowerCase().trim();
    if (c == 'auto' || c == 'all' || c.isEmpty) {
      return [
        'पत्तियों पर भूरे-काले धब्बे / झुलसा',
        'पत्तियों का पीला पड़ना / मोजेक',
        'सफेद पाउडर / फंगस (चूर्णी)',
        'पत्तियां मुड़ना व सुकड़ना (लीफ कर्ल)',
        'पत्तियों पर रतुआ / रोली के धब्बे',
        'तना सड़न / पौधा सूखना (विल्ट)',
        'फलों / बालियों में सड़न व कालापन',
        'कीट / सुंडी / इल्ली का प्रकोप',
        'रस चूसक कीट (माहू / थ्रिप्स)',
      ];
    }
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
