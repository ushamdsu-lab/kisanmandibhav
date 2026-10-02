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

  /// Ensure all 39,200+ national records are loaded in memory for instant multi-mandi search
  static Future<List<MandiRate>> _getMasterRates(List<MandiRate>? livePool) async {
    if (_masterNationalRates != null && _masterNationalRates!.isNotEmpty) {
      return _masterNationalRates!;
    }

    try {
      final jsonString = await rootBundle.loadString('assets/data/mandi_live_rates.json');
      final dynamic decoded = json.decode(jsonString);
      if (decoded is Map<String, dynamic> && decoded['records'] is List) {
        final List<dynamic> records = decoded['records'];
        _masterNationalRates = records.map((e) => MandiRate.fromJson(e)).toList();
      }
    } catch (_) {}

    _masterNationalRates ??= [];

    // Merge any live provider rates into national pool
    if (livePool != null && livePool.isNotEmpty) {
      final existingKeys = <String>{};
      for (final r in _masterNationalRates!) {
        existingKeys.add('${r.market}_${r.commodity}'.toLowerCase());
      }
      for (final lr in livePool) {
        final key = '${lr.market}_${lr.commodity}'.toLowerCase();
        if (!existingKeys.contains(key)) {
          _masterNationalRates!.insert(0, lr);
        }
      }
    }

    return _masterNationalRates!;
  }

  /// Comprehensive Hindi / English / Grammar inflection synonyms
  static const Map<String, List<String>> _cropKeywords = {
    'wheat': ['गेहूं', 'गेहू', 'गंहू', 'wheat', 'gehu'],
    'paddy': ['धान', 'चावल', 'चांवल', 'paddy', 'rice', 'dhan', 'chawal'],
    'gram': ['चना', 'चने', 'छोला', 'छोले', 'काबुली', 'gram', 'chana', 'chola', 'chickpea'],
    'mustard': ['सरसों', 'सरसो', 'राई', 'रायडा', 'लाहा', 'mustard', 'sarso', 'sarson'],
    'soybean': ['सोयाबीन', 'सोयाबिन', 'सोया', 'soyabean', 'soybean', 'soya'],
    'cotton': ['कपास', 'नरमा', 'रूई', 'cotton', 'kapas', 'narma'],
    'garlic': ['लहसुन', 'लहसन', 'आलन', 'garlic', 'lehsun', 'lahsun'],
    'onion': ['प्याज', 'प्याज़', 'कांदा', 'कांदे', 'onion', 'pyaj', 'pyaz', 'kanda'],
    'tomato': ['टमाटर', 'टमाटो', 'tomato', 'tamatar'],
    'potato': ['आलू', 'आलु', 'बटाटा', 'potato', 'aloo', 'aalu'],
    'chilli': ['मिर्च', 'मिर्ची', 'तीखी मिर्च', 'chilli', 'chili', 'mirch', 'mirchi'],
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
    'groundnut': ['मूंगफली', 'मूँगफली', 'सींगदाना', 'groundnut', 'peanut', 'mungfali'],
    'guar': ['ग्वार', 'गवार', 'guar', 'gwar'],
    'pomegranate': ['अनार', 'दाड़िम', 'pomegranate', 'anaar'],
    'citrus': ['संतरा', 'नींबू', 'नींबु', 'किन्नू', 'मौसमी', 'citrus', 'lemon', 'orange', 'nimbu'],
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

  /// Process User Message
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
            '2. रोग व दवा: फसल और बीमारी का नाम लिखें (उदा: "चने में इल्ली की रोकथाम" या "गेहूं में पीला रतुआ")\n\n'
            'नीचे दिए गए सुझावों पर भी क्लिक कर सकते हैं:',
        isUser: false,
        timestamp: now,
        type: ChatMessageType.suggestions,
        quickActions: [
          'नीमच में लहसुन का भाव',
          'इंदौर में सोयाबीन भाव',
          'चने में इल्ली की रोकथाम',
          'गेहूं में पीला रतुआ दवा',
          'टमाटर में झुलसा रोग',
          'सरसों में माहू (चेपा) स्प्रे',
        ],
      );
    }

    // 2. Identify Crop Key from input
    final matchedCropKey = _extractCropKey(query);

    // 3. Check for Disease Intent First (especially if disease keywords present: इल्ली, रतुआ, झुलसा, दवा, रोग, रोकथाम, आदि)
    final isDiseaseIntent = _hasDiseaseKeywords(query);
    if (isDiseaseIntent || (matchedCropKey != null && (query.contains('दवा') || query.contains('रोग') || query.contains('इलाज') || query.contains('रोकथाम') || query.contains('स्प्रे')))) {
      final diseaseResult = _handleDiseaseQuery(
        query: query,
        matchedCropKey: matchedCropKey,
        msgId: msgId,
        now: now,
      );
      if (diseaseResult != null) return diseaseResult;
    }

    // 4. Check for Mandi Bhav Intent
    final matchedMarket = _extractMarket(query);
    final isMandiQuery = query.contains('भाव') ||
        query.contains('रेट') ||
        query.contains('bhav') ||
        query.contains('mandi') ||
        query.contains('rate') ||
        query.contains('दाम') ||
        query.contains('कीमत') ||
        query.contains('बिक') ||
        matchedMarket != null;

    final nationalPool = await _getMasterRates(liveRates);

    // 4. Check for Mandi Bhav Intent (Triggers on market, 'भाव' keyword, or crop name)
    if (isMandiQuery || matchedMarket != null || matchedCropKey != null) {
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

    // 5. If Crop Disease was not matched above, try again before general fallback
    final secondDiseaseCheck = _handleDiseaseQuery(
      query: query,
      matchedCropKey: matchedCropKey,
      msgId: msgId,
      now: now,
    );
    if (secondDiseaseCheck != null) return secondDiseaseCheck;

    // 6. If only Crop was provided (e.g. "सोयाबीन" or "गेहूं")
    if (matchedCropKey != null) {
      final cropHindi = _getCropHindi(matchedCropKey);
      final diseases = CropDiseaseDatabase.getDiseasesByCrop(matchedCropKey);

      return ChatMessage(
        id: msgId,
        text: '$cropHindi के बारे में आप क्या जानना चाहते हैं?\n'
            '• क्या आप $cropHindi का ताज़ा मंडी भाव जानना चाहते हैं?\n'
            '• या $cropHindi के किसी रोग/कीट की दवा और खुराक जानना चाहते हैं?',
        isUser: false,
        timestamp: now,
        type: ChatMessageType.suggestions,
        quickActions: [
          '$cropHindi का मंडी भाव',
          if (diseases.isNotEmpty) '$cropHindi में ${diseases.first.diseaseNameHindi} की दवा',
          if (diseases.length > 1) '$cropHindi में ${diseases[1].diseaseNameHindi} की दवा',
        ],
      );
    }

    // 7. General Friendly Fallback
    return ChatMessage(
      id: msgId,
      text: 'किसान भाई, कृपया फसल का नाम और साथ में रोग या मंडी का नाम लिखें।\n\n'
          '👉 मंडी भाव के लिए: "नीमच लहसुन भाव" या "इंदौर सोयाबीन"\n'
          '👉 रोग के इलाज के लिए: "चने में इल्ली" या "गेहूं पीला रतुआ दवा"',
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
  // 🩺 DISEASE MATCHING ENGINE
  // ==========================================
  static bool _hasDiseaseKeywords(String q) {
    const keywords = [
      'इल्ली', 'सुंडी', 'लट', 'कीट', 'कीड़ा', 'borer', 'caterpillar',
      'रतुआ', 'रोली', 'rust', 'पीला रतुआ', 'सफेद रोली',
      'झुलसा', 'ब्लाइट', 'blight', 'अगेती', 'पछेती',
      'माहू', 'चेपा', 'एफिड', 'मोयिला', 'aphid',
      'मरोड़', 'पत्ती मरोड़', 'curl', 'curling',
      'उकठा', 'मुरझान', 'wilt',
      'सफेद मक्खी', 'whitefly',
      'छाछिया', 'चूर्णी', 'mildew', 'powdery',
      'मोज़ेक', 'पीला मोज़ेक', 'mosaic',
      'गलन', 'सड़न', 'rot', 'stem rot', 'root rot',
      'टिक्का', 'tikka',
      'चित्ती', 'धब्बा', 'spot',
      'दवा', 'इलाज', 'स्प्रे', 'रोकथाम', 'उपाय', 'कीटनाशक', 'फफूंदनाशक',
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

    CropDisease? matchedDisease;

    // A. Priority 1: Search within specific crop if detected
    if (matchedCropKey != null) {
      final cropDiseases = CropDiseaseDatabase.getDiseasesByCrop(matchedCropKey);

      for (final d in cropDiseases) {
        final hin = d.diseaseNameHindi.toLowerCase();
        final eng = d.diseaseNameEnglish.toLowerCase();
        final sym = d.symptoms.join(' ').toLowerCase();

        // 1. Pod Borer / Caterpillars / Spodoptera
        if ((query.contains('इल्ली') || query.contains('सुंडी') || query.contains('लट') || query.contains('कीट') || query.contains('कीड़ा')) &&
            (hin.contains('इल्ली') || hin.contains('सुंडी') || hin.contains('छेदक') || sym.contains('इल्ली') || sym.contains('सुंडी') || eng.contains('borer'))) {
          matchedDisease = d;
          break;
        }

        // 2. Rusts
        if ((query.contains('रतुआ') || query.contains('रोली') || query.contains('rust')) &&
            (hin.contains('रतुआ') || hin.contains('रोली') || eng.contains('rust'))) {
          matchedDisease = d;
          break;
        }

        // 3. Blights
        if ((query.contains('झुलसा') || query.contains('ब्लाइट') || query.contains('blight')) &&
            (hin.contains('झुलसा') || hin.contains('ब्लाइट') || eng.contains('blight'))) {
          matchedDisease = d;
          break;
        }

        // 4. Aphids / Mahu
        if ((query.contains('माहू') || query.contains('चेपा') || query.contains('मोयिला') || query.contains('एफिड')) &&
            (hin.contains('माहू') || hin.contains('चेपा') || hin.contains('एफिड') || sym.contains('रस') || eng.contains('aphid'))) {
          matchedDisease = d;
          break;
        }

        // 5. Leaf Curl
        if ((query.contains('मरोड़') || query.contains('curl')) &&
            (hin.contains('मरोड़') || eng.contains('curl'))) {
          matchedDisease = d;
          break;
        }

        // 6. Wilt
        if ((query.contains('उकठा') || query.contains('wilt')) &&
            (hin.contains('उकठा') || eng.contains('wilt'))) {
          matchedDisease = d;
          break;
        }

        // 7. Mosaic
        if ((query.contains('मोज़ेक') || query.contains('पीला') || query.contains('mosaic')) &&
            (hin.contains('मोज़ेक') || eng.contains('mosaic'))) {
          matchedDisease = d;
          break;
        }

        // 8. Powdery Mildew
        if ((query.contains('छाछिया') || query.contains('चूर्णी') || query.contains('mildew')) &&
            (hin.contains('छाछिया') || hin.contains('चूर्णी') || eng.contains('mildew'))) {
          matchedDisease = d;
          break;
        }

        // General word containment
        if (query.contains(hin) || hin.contains(query) || (eng.isNotEmpty && query.contains(eng))) {
          matchedDisease = d;
          break;
        }
      }

      // If user named a crop with "दवा" or "रोग" but didn't specify disease name
      if (matchedDisease == null && cropDiseases.isNotEmpty &&
          (query.contains('रोग') || query.contains('दवा') || query.contains('इलाज') || query.contains('स्प्रे') || query.contains('रोकथाम'))) {
        final cropHindi = _getCropHindi(matchedCropKey);
        return ChatMessage(
          id: msgId,
          text: '$cropHindi में मुख्य रूप से ये रोग लगते हैं। आप किस रोग का इलाज जानना चाहते हैं?',
          isUser: false,
          timestamp: now,
          type: ChatMessageType.suggestions,
          quickActions: cropDiseases.take(4).map((d) => '$cropHindi में ${d.diseaseNameHindi} की दवा').toList(),
        );
      }
    }

    // B. Priority 2: Global Search across all 100+ diseases
    if (matchedDisease == null) {
      for (final d in allDiseases) {
        final hin = d.diseaseNameHindi.toLowerCase();
        final eng = d.diseaseNameEnglish.toLowerCase();

        if (query.contains('इल्ली') && (hin.contains('इल्ली') || hin.contains('छेदक') || eng.contains('borer'))) {
          matchedDisease = d;
          break;
        }
        if (query.contains('रतुआ') && hin.contains('रतुआ')) {
          matchedDisease = d;
          break;
        }
        if (query.contains('झुलसा') && hin.contains('झुलसा')) {
          matchedDisease = d;
          break;
        }
        if ((query.contains('माहू') || query.contains('चेपा')) && (hin.contains('माहू') || hin.contains('चेपा'))) {
          matchedDisease = d;
          break;
        }
        if (query.contains(hin) || (eng.isNotEmpty && query.contains(eng))) {
          matchedDisease = d;
          break;
        }
      }
    }

    if (matchedDisease != null) {
      final d = matchedDisease;
      return ChatMessage(
        id: msgId,
        text: 'रोग: ${d.diseaseNameHindi} (${d.diseaseNameEnglish})\n'
            'फसल: ${d.cropHindi} | प्रकार: ${d.pathogen}\n\n'
            'रासायनिक दवा (CIBRC प्रमाणित):\n${d.chemicalMedicine}\n\n'
            'स्प्रे खुराक: ${d.sprayDosage}\n\n'
            'जैविक व देसी उपाय:\n${d.organicRemedy}\n\n'
            'सावधानी: ${d.precautions}',
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
  // 🌾 MANDI RATE LOOKUP ENGINE
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
          text: '${rate.market} मंडी (${rate.state}) में $cropName का ताज़ा भाव:\n\n'
              'मॉडल (औसत) भाव: ₹${rate.modalPrice.toInt()} / क्विंटल\n'
              'न्यूनतम - अधिकतम: ₹${rate.minPrice.toInt()} - ₹${rate.maxPrice.toInt()} / क्विंटल\n'
              'आवक स्थिति: ${rate.arrivalStatus}\n'
              'आवक तिथि: ${rate.arrivalDate}',
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
        // Market found, but specific crop not traded
        final marketRates = pool
            .where((r) => r.market.toLowerCase().contains(matchedMarket.toLowerCase()))
            .take(6)
            .toList();
        if (marketRates.isNotEmpty) {
          return ChatMessage(
            id: msgId,
            text: 'आज $matchedMarket मंडी में $cropHindi की सीधी आवक दर्ज नहीं हुई है।\n'
                '$matchedMarket मंडी के आज के अन्य मुख्य भाव:',
            isUser: false,
            timestamp: now,
            type: ChatMessageType.mandiRate,
            alternativeRates: marketRates,
            quickActions: [
              '$cropHindi के अन्य मंडियों के भाव',
            ],
          );
        }
      }
    }

    // Case 2: Only Specific Mandi (e.g. "नीमच मंडी भाव" or "इंदौर मंडी")
    if (matchedMarket != null && matchedCropKey == null) {
      final marketRates = pool
          .where((r) => r.market.toLowerCase().contains(matchedMarket.toLowerCase()))
          .take(6)
          .toList();

      if (marketRates.isNotEmpty) {
        return ChatMessage(
          id: msgId,
          text: '$matchedMarket मंडी के आज के प्रमुख भाव:',
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
          text: '$cropHindi के प्रमुख मंडियों में आज के ताज़ा भाव:',
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
  };

  static String? _extractMarket(String q) {
    for (final entry in _marketSynonyms.entries) {
      for (final syn in entry.value) {
        if (q.contains(syn.toLowerCase())) {
          return entry.key; // English canonical key e.g. 'indore', 'neemuch'
        }
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
      final matchesMarket = synonyms.any((syn) => rMarket.contains(syn.toLowerCase()) || mLower.contains(rMarket));
      if (matchesMarket) {
        if (_isCropMatch(r.commodity, cropKey, cropHindi)) {
          return r;
        }
      }
    }

    // Priority 2: District match
    for (final r in pool) {
      final rDistrict = r.district.toLowerCase();
      final matchesDistrict = synonyms.any((syn) => rDistrict.contains(syn.toLowerCase()));
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

    // Specific crop mapping
    if (cropKey == 'soybean' && (comm.contains('soya') || comm.contains('soybean') || commHindi.contains('सोया'))) {
      return true;
    }
    if (cropKey == 'gram' && (comm.contains('gram') || comm.contains('chana') || commHindi.contains('चना'))) {
      return true;
    }
    if (cropKey == 'garlic' && (comm.contains('garlic') || commHindi.contains('लहसुन'))) {
      return true;
    }
    if (cropKey == 'wheat' && (comm.contains('wheat') || commHindi.contains('गेहूं') || commHindi.contains('गेहू'))) {
      return true;
    }
    if (cropKey == 'mustard' && (comm.contains('mustard') || commHindi.contains('सरसों') || commHindi.contains('राई'))) {
      return true;
    }
    if (cropKey == 'cotton' && (comm.contains('cotton') || commHindi.contains('कपास') || commHindi.contains('नरमा'))) {
      return true;
    }
    if (cropKey == 'onion' && (comm.contains('onion') || commHindi.contains('प्याज') || commHindi.contains('कांदा'))) {
      return true;
    }
    if (cropKey == 'potato' && (comm.contains('potato') || commHindi.contains('आलू'))) {
      return true;
    }
    if (cropKey == 'tomato' && (comm.contains('tomato') || commHindi.contains('टमाटर'))) {
      return true;
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
