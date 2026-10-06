import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import '../data/crop_disease_database.dart';
import '../models/mandi_rate.dart';
import '../services/tts_service.dart';
import '../utils/commodity_helper.dart';

enum ChatMessageType {
  text,
  cropDisease,
  mandiRate,
  suggestions,
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChatMessageType type;
  final CropDisease? disease;
  final MandiRate? mandiRate;
  final List<MandiRate>? alternativeRates;
  final List<CropDisease>? alternativeDiseases;
  final List<String>? quickActions;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type = ChatMessageType.text,
    this.disease,
    this.mandiRate,
    this.alternativeRates,
    this.alternativeDiseases,
    this.quickActions,
  });
}

class KisanChatService {
  KisanChatService._();

  static List<MandiRate>? _masterNationalRates;

  /// Ensure national records are loaded and always prioritized with today's live Vercel rates
  static Future<List<MandiRate>> _getMasterRates(List<MandiRate>? livePool) async {
    if (_masterNationalRates == null || _masterNationalRates!.isEmpty) {
      try {
        final jsonString = await rootBundle.loadString('assets/data/mandi_live_rates.json');
        final dynamic decoded = json.decode(jsonString);
        if (decoded is Map<String, dynamic> && decoded['records'] is List) {
          final List<dynamic> records = decoded['records'];
          _masterNationalRates = records.map((e) => MandiRate.fromJson(e)).toList();
        }
      } catch (_) {}
      _masterNationalRates ??= [];
    }

    // Always merge and prioritize today's fresh live rates from MandiProvider / Vercel API
    if (livePool != null && livePool.isNotEmpty) {
      final liveKeys = <String>{};
      for (final lr in livePool) {
        liveKeys.add('${lr.market.toLowerCase()}_${lr.commodity.toLowerCase()}');
      }
      // Purge stale static records so today's live rate wins 100%
      _masterNationalRates!.removeWhere((r) =>
          liveKeys.contains('${r.market.toLowerCase()}_${r.commodity.toLowerCase()}'));
      // Prepend fresh live rates at the top
      _masterNationalRates!.insertAll(0, livePool);
    }

    return _masterNationalRates!;
  }

  /// Comprehensive Hindi / English / Hinglish Crop Keywords (covering all 56 crops in database)
  static const Map<String, List<String>> _cropKeywords = {
    'wheat': ['गेहूं', 'गेहू', 'गंहू', 'wheat', 'gehu', 'kanak'],
    'paddy': ['धान', 'चावल', 'चांवल', 'paddy', 'rice', 'dhan', 'chawal', 'basmati', 'बासमती'],
    'gram': ['चना', 'चने', 'छोला', 'छोले', 'काबुली', 'gram', 'chana', 'chola', 'chickpea'],
    'mustard': ['सरसों', 'सरसो', 'राई', 'रायडा', 'लाहा', 'तारामीरा', 'mustard', 'sarso', 'sarson', 'rai'],
    'soybean': ['सोयाबीन', 'सोयाबिन', 'सोया', 'soyabean', 'soybean', 'soya'],
    'cotton': ['कपास', 'नरमा', 'रूई', 'cotton', 'kapas', 'narma'],
    'garlic': ['लहसुन', 'लहसन', 'आलन', 'garlic', 'lehsun', 'lahsun'],
    'onion': ['प्याज', 'प्याज़', 'कांदा', 'कांदे', 'onion', 'pyaj', 'pyaz', 'kanda'],
    'tomato': ['टमाटर', 'टमाटो', 'tomato', 'tamatar'],
    'potato': ['आलू', 'आलु', 'बटाटा', 'potato', 'aloo', 'aalu'],
    'chilli': ['मिर्च', 'मिर्ची', 'तीखी मिर्च', 'लाल मिर्च', 'हरी मिर्च', 'chilli', 'chili', 'mirch', 'mirchi'],
    'jeera': ['जीरा', 'जीरे', 'jeera', 'jira', 'cumin'],
    'coriander': ['धनिया', 'धने', 'coriander', 'dhaniya'],
    'fennel': ['सौंफ', 'सॉफ', 'fennel', 'saunf'],
    'fenugreek': ['मेथी', 'दाना मेथी', 'fenugreek', 'methi'],
    'maize': ['मक्का', 'मकई', 'भुट्टा', 'maize', 'corn', 'makka'],
    'bajra': ['बाजरा', 'बाजरे', 'bajra', 'millet'],
    'jowar': ['ज्वार', 'ज्वारी', 'jowar', 'sorghum'],
    'moong': ['मूंग', 'मूँग', 'moong', 'mung'],
    'urad': ['उड़द', 'उरद', 'urad', 'mash'],
    'arhar': ['अरहर', 'तुअर', 'तूर', 'तुवर', 'arhar', 'tur', 'toor'],
    'groundnut': ['मूंगफली', 'मूँगफली', 'सींगदाना', 'मूंगफली दाना', 'groundnut', 'peanut', 'mungfali'],
    'guar': ['ग्वार', 'गवार', 'guar', 'gwar'],
    'pomegranate': ['अनार', 'दाड़िम', 'pomegranate', 'anaar'],
    'citrus': ['संतरा', 'नींबू', 'नींबु', 'किन्नू', 'मौसमी', 'citrus', 'lemon', 'orange', 'nimbu', 'kinnow'],
    'mango': ['आम', 'केरी', 'mango', 'aam'],
    'brinjal': ['बैंगन', 'बैगंन', 'भटा', 'brinjal', 'eggplant', 'baingan'],
    'okra': ['भिंडी', 'भिन्डी', 'okra', 'bhindi', 'ladies finger'],
    'pea': ['मटर', 'बटाना', 'pea', 'matar'],
    'ginger': ['अदरक', 'आदा', 'ginger', 'adrak'],
    'turmeric': ['हल्दी', 'turmeric', 'haldi'],
    'sugarcane': ['गन्ना', 'ईख', 'sugarcane', 'ganna'],
    'apple': ['सेब', 'apple', 'seb'],
    'banana': ['केला', 'banana', 'kela'],
    'watermelon': ['तरबूज', 'मतील', 'खरबूजा', 'watermelon', 'tarbooj'],
    'isabgol': ['इसबगोल', 'ईसबगोल', 'isabgol', 'psyllium'],
    'sesame': ['तिल', 'तिल्ली', 'sesame', 'til', 'tilli'],
    'sunflower': ['सूरजमुखी', 'sunflower', 'surajmukhi'],
    'castor': ['अरंडी', 'अरण्डी', 'castor', 'arandi'],
    'barley': ['जौ', 'बारले', 'barley', 'jau'],
    'lentil': ['मसूर', 'मसुर', 'lentil', 'masoor'],
    'papaya': ['पपीता', 'papaya', 'papita'],
    'guava': ['अमरूद', 'जामफल', 'guava', 'amrood'],
    'grapes': ['अंगूर', 'grapes', 'angoor'],
    'capsicum': ['शिमला मिर्च', 'capsicum', 'shimla mirch'],
    'cauliflower': ['फूलगोभी', 'गोभी', 'cauliflower', 'phoolgobhi', 'gobhi'],
    'carrot': ['गाजर', 'carrot', 'gajar'],
    'radish': ['मूली', 'radish', 'mooli'],
    'spinach': ['पालक', 'spinach', 'palak'],
    'bitter_gourd': ['करेला', 'bitter gourd', 'karela'],
    'bottle_gourd': ['लौकी', 'घिया', 'bottle gourd', 'lauki'],
    'chaulai': ['चौलाई', 'chaulai', 'amaranth'],
    'tea': ['चाय', 'tea', 'chai'],
    'coffee': ['कॉफ़ी', 'कॉफी', 'coffee'],
    'date_palm': ['खजूर', 'date palm', 'khajoor'],
    'ber': ['बेर', 'ber', 'jujube'],
  };

  /// Clean user input by removing symbols, punctuation, and emojis
  static String _cleanInput(String input) {
    return input
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}|\u{2600}-\u{26FF}|\u{2700}-\u{27BF}|👉|🩺|🌾|•|💡|📢|⚠️|💰|📈|📊|📅|🏛️|🌱|💊|💧|🍃|\*]', unicode: true), ' ')
        .replaceAll(RegExp(r'[?,!:;()"\-]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  /// Process User Message with Intelligent Intent Routing
  static Future<ChatMessage> processMessage(
    String rawQuery, {
    List<MandiRate>? liveRates,
  }) async {
    final query = _cleanInput(rawQuery);
    final now = DateTime.now();
    final msgId = 'msg_${now.millisecondsSinceEpoch}';

    if (query.isEmpty) {
      return ChatMessage(
        id: msgId,
        text: 'कृपया अपनी फसल, बीमारी या मंडी का नाम लिखें।',
        isUser: false,
        timestamp: now,
      );
    }

    // 1. Check for Greetings
    if (_isGreeting(query)) {
      return ChatMessage(
        id: msgId,
        text: 'राम राम किसान भाई! 🙏 मैं आपका किसान मित्र AI हूँ।\n\n'
            'आप मुझसे सीधे पूछ सकते हैं:\n'
            '1. मंडी भाव: मंडी और फसल का नाम लिखें (उदा: "नीमच में लहसुन भाव" या "इंदौर सोयाबीन")\n'
            '2. रोग व दवा: फसल और बीमारी या लक्षण लिखें (उदा: "लहसुन में पीलापन क्या डालें" या "चने में इल्ली दवा")\n\n'
            'नीचे दिए गए सुझावों पर भी क्लिक कर सकते हैं:',
        isUser: false,
        timestamp: now,
        type: ChatMessageType.suggestions,
        quickActions: [
          'नीमच में लहसुन का भाव',
          'इंदौर में सोयाबीन भाव',
          'लहसुन में पीलापन क्या डालें',
          'चने में इल्ली की रोकथाम',
          'गेहूं में पीला रतुआ दवा',
          'टमाटर में झुलसा रोग स्प्रे',
        ],
      );
    }

    // 2. Identify Crop Key from input
    final matchedCropKey = _extractCropKey(query);

    // 3. PRIORITY 1: Check for Disease / Symptom / Remedy Intent First
    final isDiseaseIntent = _hasDiseaseKeywords(query);
    if (isDiseaseIntent) {
      final diseaseResult = _handleDiseaseQuery(
        query: query,
        matchedCropKey: matchedCropKey,
        msgId: msgId,
        now: now,
      );
      if (diseaseResult != null) return diseaseResult;

      // If user clearly asked for disease/medicine but specific disease couldn't be pinpointed
      if (matchedCropKey != null) {
        final cropHindi = _getCropHindi(matchedCropKey);
        final cropDiseases = CropDiseaseDatabase.getDiseasesByCrop(matchedCropKey);
        if (cropDiseases.isNotEmpty) {
          return ChatMessage(
            id: msgId,
            text: 'किसान भाई, $cropHindi में मुख्य रूप से ये बीमारियाँ और कीट लगते हैं। आपकी फसल में कौन सा लक्षण दिख रहा है?',
            isUser: false,
            timestamp: now,
            type: ChatMessageType.suggestions,
            quickActions: cropDiseases.take(4).map((d) => '$cropHindi में ${d.diseaseNameHindi} दवा').toList(),
          );
        }
      }
    }

    // 4. PRIORITY 2: Check for Mandi Bhav Intent
    final nationalPool = await _getMasterRates(liveRates);
    final matchedMarket = _extractMarket(query, nationalPool);

    final isMandiQuery = query.contains('भाव') ||
        query.contains('रेट') ||
        query.contains('bhav') ||
        query.contains('mandi') ||
        query.contains('rate') ||
        query.contains('दाम') ||
        query.contains('कीमत') ||
        query.contains('बिक') ||
        matchedMarket != null;

    if (isMandiQuery || matchedMarket != null || (matchedCropKey != null && !isDiseaseIntent)) {
      final mandiResult = _handleMandiQuery(
        query: query,
        matchedMarket: matchedMarket,
        matchedCropKey: matchedCropKey,
        pool: nationalPool,
        msgId: msgId,
        now: now,
      );
      if (mandiResult != null) return mandiResult;
    }

    // 5. If Crop was detected but neither disease nor mandi matched cleanly
    if (matchedCropKey != null) {
      final cropHindi = _getCropHindi(matchedCropKey);
      final diseases = CropDiseaseDatabase.getDiseasesByCrop(matchedCropKey);

      return ChatMessage(
        id: msgId,
        text: '$cropHindi के बारे में आप क्या जानना चाहते हैं?\n\n'
            '• क्या आप $cropHindi का ताज़ा मंडी भाव जानना चाहते हैं?\n'
            '• या $cropHindi के किसी रोग/कीट की दवा और खुराक जानना चाहते हैं?',
        isUser: false,
        timestamp: now,
        type: ChatMessageType.suggestions,
        quickActions: [
          '$cropHindi का मंडी भाव',
          if (diseases.isNotEmpty) '$cropHindi में ${diseases.first.diseaseNameHindi} दवा',
          if (diseases.length > 1) '$cropHindi में ${diseases[1].diseaseNameHindi} दवा',
        ],
      );
    }

    // 6. General Friendly Fallback
    return ChatMessage(
      id: msgId,
      text: 'किसान भाई, कृपया फसल का नाम और साथ में रोग या मंडी का नाम लिखें।\n\n'
          '👉 मंडी भाव के लिए: "नीमच लहसुन भाव" या "इंदौर सोयाबीन"\n'
          '👉 रोग व दवा के लिए: "लहसुन में पीलापन" या "चने में इल्ली दवा"',
      isUser: false,
      timestamp: now,
      type: ChatMessageType.suggestions,
      quickActions: [
        'नीमच में लहसुन का भाव',
        'इंदौर में सोयाबीन भाव',
        'चने में इल्ली की रोकथाम',
        'गेहूं में पीला रतुआ दवा',
      ],
    );
  }

  // ==========================================
  // 🩺 DISEASE MATCHING & PRESCRIPTION ENGINE
  // ==========================================
  static bool _hasDiseaseKeywords(String q) {
    const keywords = [
      // Insects & Pests
      'इल्ली', 'सुंडी', 'लट', 'कीट', 'कीड़ा', 'कीड़े', 'borer', 'caterpillar', 'keeda', 'kida', 'sundi', 'illi',
      'माहू', 'चेपा', 'एफिड', 'मोयिला', 'aphid', 'mahu', 'chepa',
      'सफेद मक्खी', 'whitefly', 'मक्खी',
      'थ्रिप्स', 'thrips', 'माइट्स', 'mites', 'मकड़ी', 'दीमक', 'termite',
      // Fungal & Viral Diseases
      'रतुआ', 'रोली', 'rust', 'पीला रतुआ', 'सफेद रोली',
      'झुलसा', 'ब्लाइट', 'blight', 'अगेती', 'पछेती',
      'मरोड़', 'चुरड़ा', 'चुरडा', 'मरोड़िया', 'जलेबी', 'curl', 'curling', 'marod', 'jalebi',
      'उकठा', 'मुरझान', 'मुरझा', 'wilt', 'uktha',
      'छाछिया', 'चूर्णी', 'mildew', 'powdery',
      'मोज़ेक', 'पीला मोज़ेक', 'mosaic',
      'गलन', 'सड़न', 'rot', 'stem rot', 'root rot',
      'टिक्का', 'tikka', 'चित्ती', 'धब्बा', 'दाग', 'spot', 'blotch',
      'फफूंद', 'फफूंदी', 'फंगस', 'fungus', 'fungal',
      // Everyday Symptoms
      'पीलापन', 'पीली', 'पीला', 'peelapan', 'peela', 'pila',
      'सूखना', 'सूख', 'sukha', 'sukhta',
      'जलना', 'जल', 'jalna', 'काला', 'सफेद',
      // Remedies & Actions
      'दवा', 'दवाई', 'इलाज', 'स्प्रे', 'रोकथाम', 'उपाय', 'कीटनाशक', 'फफूंदनाशक',
      'मात्रा', 'डोज़', 'खुराक', 'बीमारी', 'रोग', 'लक्षण', 'डॉक्टर',
      'क्या डालें', 'क्या छिड़कें', 'क्या करें', 'dawa', 'dawai', 'ilaj', 'spray', 'roktham', 'bimari', 'rog',
    ];
    for (final kw in keywords) {
      if (q.contains(kw)) return true;
    }
    return false;
  }

  static ChatMessage? _handleDiseaseQuery({
    required String query,
    required String? matchedCropKey,
    required String msgId,
    required DateTime now,
  }) {
    final allDiseases = CropDiseaseDatabase.diseases;
    if (allDiseases.isEmpty) return null;

    final candidatePool = matchedCropKey != null
        ? CropDiseaseDatabase.getDiseasesByCrop(matchedCropKey)
        : allDiseases;

    if (candidatePool.isEmpty) return null;

    CropDisease? bestMatch;
    int highestScore = 0;

    for (final d in candidatePool) {
      int score = 0;
      final hin = d.diseaseNameHindi.toLowerCase();
      final eng = d.diseaseNameEnglish.toLowerCase();
      final sym = d.symptoms.join(' ').toLowerCase();
      final tags = d.symptomTags.join(' ').toLowerCase();

      // 1. Direct Name Match
      if (query.contains(hin) || hin.contains(query)) score += 10;
      if (eng.isNotEmpty && (query.contains(eng) || eng.contains(query))) score += 8;

      // 2. Specific Symptoms & Tags Scoring
      if ((query.contains('इल्ली') || query.contains('सुंडी') || query.contains('लट') || query.contains('कीड़ा') || query.contains('borer') || query.contains('caterpillar') || query.contains('illi')) &&
          (hin.contains('इल्ली') || hin.contains('सुंडी') || hin.contains('छेदक') || sym.contains('इल्ली') || tags.contains('इल्ली') || eng.contains('borer') || eng.contains('caterpillar'))) {
        score += 8;
      }

      if ((query.contains('रतुआ') || query.contains('रोली') || query.contains('rust')) &&
          (hin.contains('रतुआ') || hin.contains('रोली') || tags.contains('रतुआ') || eng.contains('rust'))) {
        score += 8;
      }

      if ((query.contains('पीलापन') || query.contains('पीली') || query.contains('पीला') || query.contains('peela') || query.contains('peelapan') || query.contains('pila')) &&
          (tags.contains('पीला') || sym.contains('पीली') || hin.contains('पीला') || hin.contains('मोज़ेक') || hin.contains('रतुआ'))) {
        score += 6;
      }

      if ((query.contains('झुलसा') || query.contains('ब्लाइट') || query.contains('blight') || query.contains('jalna') || query.contains('जल')) &&
          (hin.contains('झुलसा') || hin.contains('ब्लाइट') || tags.contains('झुलसा') || eng.contains('blight'))) {
        score += 8;
      }

      if ((query.contains('माहू') || query.contains('चेपा') || query.contains('मोयिला') || query.contains('एफिड') || query.contains('aphid') || query.contains('chepa')) &&
          (hin.contains('माहू') || hin.contains('चेपा') || hin.contains('एफिड') || sym.contains('रस') || tags.contains('माहू') || eng.contains('aphid'))) {
        score += 8;
      }

      if ((query.contains('मरोड़') || query.contains('जलेबी') || query.contains('चुरड़ा') || query.contains('मरोड़िया') || query.contains('curl') || query.contains('jalebi') || query.contains('marod')) &&
          (hin.contains('मरोड़') || hin.contains('चुरड़ा') || hin.contains('थ्रिप्स') || tags.contains('मरोड़') || tags.contains('जलेबी') || eng.contains('curl'))) {
        score += 8;
      }

      if ((query.contains('उकठा') || query.contains('मुरझान') || query.contains('मुरझा') || query.contains('wilt') || query.contains('uktha')) &&
          (hin.contains('उकठा') || hin.contains('मुरझान') || tags.contains('उकठा') || eng.contains('wilt'))) {
        score += 8;
      }

      if ((query.contains('छाछिया') || query.contains('चूर्णी') || query.contains('mildew') || query.contains('सफेद पाउडर')) &&
          (hin.contains('छाछिया') || hin.contains('चूर्णी') || tags.contains('पाउडर') || eng.contains('mildew'))) {
        score += 8;
      }

      if ((query.contains('गलन') || query.contains('सड़न') || query.contains('rot')) &&
          (hin.contains('गलन') || hin.contains('सड़न') || tags.contains('गलन') || tags.contains('सड़न') || eng.contains('rot'))) {
        score += 8;
      }

      if ((query.contains('धब्बा') || query.contains('चित्ती') || query.contains('दाग') || query.contains('spot') || query.contains('blotch')) &&
          (hin.contains('धब्बा') || hin.contains('चित्ती') || tags.contains('धब्बा') || eng.contains('spot') || eng.contains('blotch'))) {
        score += 6;
      }

      // Check against individual symptom tags
      for (final tag in d.symptomTags) {
        final t = tag.toLowerCase();
        if (t.length >= 3 && query.contains(t)) {
          score += 5;
        }
      }

      if (score > highestScore) {
        highestScore = score;
        bestMatch = d;
      }
    }

    // Return structured prescription card
    if (bestMatch != null && highestScore >= 4) {
      final d = bestMatch;
      return ChatMessage(
        id: msgId,
        text: '🩺 *रोग की पहचान:* ${d.diseaseNameHindi} (${d.diseaseNameEnglish})\n'
            '🌾 *फसल:* ${d.cropHindi} | *कारण:* ${d.pathogen}\n\n'
            '💊 *रासायनिक दवा (CIBRC प्रमाणित):*\n${d.chemicalMedicine}\n\n'
            '💧 *स्प्रे खुराक:* ${d.sprayDosage}\n\n'
            '🌿 *जैविक व देसी उपाय:*\n${d.organicRemedy}\n\n'
            '⚠️ *सावधानी:* ${d.precautions}',
        isUser: false,
        timestamp: now,
        type: ChatMessageType.cropDisease,
        disease: d,
        quickActions: [
          '${d.cropHindi} का मंडी भाव',
          '${d.cropHindi} के अन्य रोग',
        ],
      );
    }

    return null;
  }

  // ==========================================
  // 🌾 LIVE MANDI RATE LOOKUP ENGINE
  // ==========================================
  static ChatMessage? _handleMandiQuery({
    required String query,
    required String? matchedMarket,
    required String? matchedCropKey,
    required List<MandiRate> pool,
    required String msgId,
    required DateTime now,
  }) {
    if (pool.isEmpty) return null;

    // Case 1: Specific Mandi + Specific Crop (e.g. "नीमच में लहसुन भाव" or "इंदौर सोयाबीन")
    if (matchedMarket != null && matchedCropKey != null) {
      final cropHindi = _getCropHindi(matchedCropKey);
      final rate = _findRateByMarketAndCrop(pool, matchedMarket, matchedCropKey, cropHindi);

      if (rate != null) {
        final cropName = CommodityHelper.getHindiName(rate.commodity);
        return ChatMessage(
          id: msgId,
          text: '🏛️ *${rate.market} मंडी (${rate.state}) में $cropName का ताज़ा भाव:*\n\n'
              '💰 *मॉडल (औसत) भाव:* ₹${rate.modalPrice.toInt()} / क्विंटल\n'
              '📊 *न्यूनतम - अधिकतम:* ₹${rate.minPrice.toInt()} - ₹${rate.maxPrice.toInt()} / क्विंटल\n'
              '📈 *आवक स्थिति:* ${rate.arrivalStatus}\n'
              '📅 *आवक तिथि:* ${rate.arrivalDate}',
          isUser: false,
          timestamp: now,
          type: ChatMessageType.mandiRate,
          mandiRate: rate,
          quickActions: [
            '${rate.market} मंडी के अन्य भाव',
            '$cropName के अन्य मंडियों के भाव',
          ],
        );
      } else {
        // Market found, but specific crop not traded today
        final marketRates = pool
            .where((r) =>
                r.market.toLowerCase().contains(matchedMarket.toLowerCase()) ||
                r.district.toLowerCase().contains(matchedMarket.toLowerCase()))
            .take(6)
            .toList();

        final otherMandiRates = _findRatesByCrop(pool, matchedCropKey, cropHindi).take(4).toList();

        return ChatMessage(
          id: msgId,
          text: 'आज $matchedMarket मंडी में $cropHindi की सीधी आवक दर्ज नहीं हुई है।\n\n'
              '👉 $matchedMarket मंडी के आज के मुख्य भाव नीचे दिए गए हैं:',
          isUser: false,
          timestamp: now,
          type: ChatMessageType.mandiRate,
          alternativeRates: marketRates.isNotEmpty ? marketRates : otherMandiRates,
          quickActions: [
            '$cropHindi के अन्य मंडियों के भाव',
            if (marketRates.isNotEmpty) '${marketRates.first.market} मंडी के सभी भाव',
          ],
        );
      }
    }

    // Case 2: Only Specific Mandi (e.g. "नीमच मंडी भाव" or "इंदौर मंडी")
    if (matchedMarket != null && matchedCropKey == null) {
      final marketRates = pool
          .where((r) =>
              r.market.toLowerCase().contains(matchedMarket.toLowerCase()) ||
              r.district.toLowerCase().contains(matchedMarket.toLowerCase()))
          .take(6)
          .toList();

      if (marketRates.isNotEmpty) {
        return ChatMessage(
          id: msgId,
          text: '🏛️ *$matchedMarket मंडी के आज के प्रमुख भाव:*',
          isUser: false,
          timestamp: now,
          type: ChatMessageType.mandiRate,
          alternativeRates: marketRates,
          quickActions: marketRates.take(3).map((r) => '${r.market} में ${CommodityHelper.getHindiName(r.commodity)} भाव').toList(),
        );
      }
    }

    // Case 3: Only Crop (e.g. "सोयाबीन का मंडी भाव" or "लहसुन भाव")
    if (matchedCropKey != null) {
      final cropHindi = _getCropHindi(matchedCropKey);
      final cropRates = _findRatesByCrop(pool, matchedCropKey, cropHindi);

      if (cropRates.isNotEmpty) {
        return ChatMessage(
          id: msgId,
          text: '🌾 *$cropHindi के प्रमुख मंडियों में आज के ताज़ा भाव:*',
          isUser: false,
          timestamp: now,
          type: ChatMessageType.mandiRate,
          alternativeRates: cropRates.take(6).toList(),
          quickActions: cropRates.take(3).map((r) => '${r.market} में $cropHindi भाव').toList(),
        );
      }
    }

    return null;
  }

  // ==========================================
  // 🔍 HELPER EXTRACTION & MATCHERS
  // ==========================================
  static bool _isGreeting(String q) {
    return q == 'hi' ||
        q == 'hello' ||
        q == 'नमस्ते' ||
        q == 'राम राम' ||
        q == 'जय श्री राम' ||
        q == 'प्रणाम' ||
        q == 'help' ||
        q == 'मदद' ||
        q == 'शुरू';
  }

  static String? _extractCropKey(String q) {
    for (final entry in _cropKeywords.entries) {
      for (final synonym in entry.value) {
        if (q.contains(synonym.toLowerCase())) {
          return entry.key;
        }
      }
    }
    return null;
  }

  static String _getCropHindi(String cropKey) {
    final list = _cropKeywords[cropKey];
    if (list != null && list.isNotEmpty) {
      return list.first;
    }
    return cropKey;
  }

  static const Map<String, List<String>> _marketSynonyms = {
    'indore': ['इंदौर', 'इन्दौर', 'indore'],
    'neemuch': ['नीमच', 'neemuch'],
    'mandsaur': ['मंदसौर', 'मन्दसौर', 'mandsaur'],
    'kota': ['कोटा', 'kota'],
    'baran': ['बारां', 'बारा', 'baran'],
    'ujjain': ['उज्जैन', 'ujjain'],
    'jaipur': ['जयपुर', 'jaipur'],
    'jodhpur': ['जोधपुर', 'jodhpur'],
    'bikaner': ['बीकानेर', 'bikaner'],
    'nashik': ['नासिक', 'नाशिक', 'nashik'],
    'nagpur': ['नागपुर', 'nagpur'],
    'rajkot': ['राजकोट', 'rajkot'],
    'ahmedabad': ['अहमदाबाद', 'ahmedabad'],
    'ganganagar': ['गंगानगर', 'श्रीगंगानगर', 'ganganagar'],
    'hanumangarh': ['हनुमानगढ़', 'hanumangarh'],
    'ratlam': ['रतलाम', 'ratlam'],
    'vidisha': ['विदिशा', 'vidisha'],
    'sehore': ['सीहोर', 'sehore'],
    'khandwa': ['खंडवा', 'khandwa'],
    'dewas': ['देवास', 'dewas'],
    'merta': ['मेड़ता', 'merta'],
    'nagaur': ['नागौर', 'nagaur'],
    'guna': ['गुना', 'guna'],
    'jhalawar': ['झालावाड़', 'jhalawar'],
    'bundi': ['बूंदी', 'bundi'],
    'alwar': ['अलवर', 'alwar'],
    'bharatpur': ['भरतपुर', 'bharatpur'],
    'agra': ['आगरा', 'agra'],
    'kanpur': ['कानपुर', 'kanpur'],
    'hathras': ['हाथरस', 'hathras'],
    'karnal': ['करनाल', 'karnal'],
    'amritsar': ['अमृतसर', 'amritsar'],
    'ludhiana': ['लुधियाना', 'ludhiana'],
    'azadpur': ['आजादपुर', 'azadpur'],
    'anta': ['अंता', 'anta'],
    'atru': ['अटरू', 'atru'],
    'chhabra': ['छबड़ा', 'chhabra'],
    'salpura': ['कवाई', 'kawayi', 'salpura'],
    'chittorgarh': ['चित्तौड़गढ़', 'chittorgarh'],
    'bhopal': ['भोपाल', 'bhopal'],
    'jabalpur': ['जबलपुर', 'jabalpur'],
    'gwalior': ['ग्वालियर', 'gwalior'],
    'surat': ['सूरत', 'surat'],
    'vadodara': ['वडोदरा', 'बड़ौदा', 'vadodara'],
    'pune': ['पुणे', 'pune'],
    'mumbai': ['मुंबई', 'mumbai'],
    'harda': ['हरदा', 'harda'],
    'chhindwara': ['छिंदवाड़ा', 'chhindwara'],
    'shajapur': ['शाजापुर', 'shajapur'],
    'shujalpur': ['शुजालपुर', 'shujalpur'],
    'biaora': ['ब्यावरा', 'biaora'],
    'dhar': ['धार', 'dhar'],
    'khargone': ['खरगोन', 'khargone'],
    'barwani': ['बड़वानी', 'barwani'],
    'sikar': ['सीकर', 'sikar'],
    'bhilwara': ['भीलवाड़ा', 'bhilwara'],
    'ajmer': ['अजमेर', 'ajmer'],
    'tonk': ['टोंक', 'tonk'],
    'udaipur': ['उदयपुर', 'udaipur'],
  };

  static String? _extractMarket(String q, [List<MandiRate>? pool]) {
    // 1. Static known synonyms check
    for (final entry in _marketSynonyms.entries) {
      for (final syn in entry.value) {
        if (q.contains(syn.toLowerCase())) {
          return syn;
        }
      }
    }

    // 2. Dynamic check across live/national pool records
    if (pool != null) {
      for (final r in pool) {
        final m = r.market.toLowerCase();
        final d = r.district.toLowerCase();
        if (m.length >= 3 && q.contains(m)) return r.market;
        if (d.length >= 3 && q.contains(d)) return r.district;
      }
    }

    return null;
  }

  static MandiRate? _findRateByMarketAndCrop(
    List<MandiRate> pool,
    String marketKey,
    String cropKey,
    String cropHindi,
  ) {
    final mLower = marketKey.toLowerCase();
    final synonyms = _marketSynonyms[mLower] ?? [mLower];

    // Priority 1: Exact market name match
    for (final r in pool) {
      final rMarket = r.market.toLowerCase();
      final matchesMarket = synonyms.any((syn) => rMarket.contains(syn.toLowerCase()) || syn.toLowerCase().contains(rMarket)) ||
          rMarket.contains(mLower) || mLower.contains(rMarket);
      if (matchesMarket) {
        if (_isCropMatch(r.commodity, cropKey, cropHindi)) {
          return r;
        }
      }
    }

    // Priority 2: District match
    for (final r in pool) {
      final rDistrict = r.district.toLowerCase();
      final matchesDistrict = synonyms.any((syn) => rDistrict.contains(syn.toLowerCase())) ||
          rDistrict.contains(mLower) || mLower.contains(rDistrict);
      if (matchesDistrict) {
        if (_isCropMatch(r.commodity, cropKey, cropHindi)) {
          return r;
        }
      }
    }

    return null;
  }

  static List<MandiRate> _findRatesByCrop(
    List<MandiRate> pool,
    String cropKey,
    String cropHindi,
  ) {
    final List<MandiRate> matches = [];
    final Set<String> seenMarkets = {};

    for (final r in pool) {
      if (_isCropMatch(r.commodity, cropKey, cropHindi)) {
        if (!seenMarkets.contains(r.market)) {
          seenMarkets.add(r.market);
          matches.add(r);
        }
      }
    }

    // Sort by modal price descending
    matches.sort((a, b) => b.modalPrice.compareTo(a.modalPrice));
    return matches;
  }

  static bool _isCropMatch(String commodity, String cropKey, String cropHindi) {
    final comm = commodity.toLowerCase();
    final commHindi = CommodityHelper.getHindiName(commodity).toLowerCase();
    final cHindiLower = cropHindi.toLowerCase();

    // Direct match
    if (comm.contains(cropKey) || commHindi.contains(cHindiLower) || cHindiLower.contains(commHindi)) {
      return true;
    }

    // Synonyms match
    final synonyms = _cropKeywords[cropKey] ?? [];
    for (final syn in synonyms) {
      final s = syn.toLowerCase();
      if (comm.contains(s) || commHindi.contains(s)) {
        return true;
      }
    }

    return false;
  }

  /// Share formatted chat answer to WhatsApp
  static Future<void> shareToWhatsApp(ChatMessage msg) async {
    final buffer = StringBuffer();
    buffer.writeln('🌾 *किसान मित्र AI - कृषि समाधान* 🌾');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(msg.text);
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📲 *किसान मंडी भाव ऐप द्वारा प्रमाणित*');

    final encoded = Uri.encodeComponent(buffer.toString());
    final waUrl = Uri.parse('whatsapp://send?text=$encoded');
    final webUrl = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      if (await canLaunchUrl(waUrl)) {
        await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  /// Speak message via TTS
  static Future<void> speakMessage(ChatMessage msg) async {
    final cleanText = msg.text.replaceAll('*', '').replaceAll('•', '').replaceAll('👉', '');
    await TtsService().speak(cleanText, title: 'किसान मित्र AI');
  }
}
