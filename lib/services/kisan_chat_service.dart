import 'package:url_launcher/url_launcher.dart';
import '../data/crop_disease_database.dart';
import '../models/mandi_rate.dart';
import '../services/mandi_service.dart';
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

  /// Known Hindi synonyms for crops to ensure 100% natural conversational matching
  static const Map<String, String> _cropSynonyms = {
    'गेहूं': 'wheat', 'गेहू': 'wheat', 'gehu': 'wheat', 'wheat': 'wheat',
    'धान': 'paddy', 'चावल': 'paddy', 'dhan': 'paddy', 'chawal': 'paddy', 'paddy': 'paddy',
    'चना': 'gram', 'chana': 'gram', 'chola': 'gram', 'gram': 'gram',
    'सरसों': 'mustard', 'राई': 'mustard', 'sarso': 'mustard', 'sarson': 'mustard', 'mustard': 'mustard',
    'सोयाबीन': 'soybean', 'soyabean': 'soybean', 'soybean': 'soybean',
    'कपास': 'cotton', 'नरमा': 'cotton', 'kapas': 'cotton', 'cotton': 'cotton',
    'लहसुन': 'garlic', 'lehsun': 'garlic', 'lahsun': 'garlic', 'garlic': 'garlic',
    'प्याज': 'onion', 'कांदा': 'onion', 'pyaj': 'onion', 'pyaz': 'onion', 'onion': 'onion',
    'टमाटर': 'tomato', 'tamatar': 'tomato', 'tomato': 'tomato',
    'आलू': 'potato', 'aalu': 'potato', 'aloo': 'potato', 'potato': 'potato',
    'मिर्च': 'chilli', 'mirch': 'chilli', 'chilli': 'chilli', 'chili': 'chilli',
    'जीरा': 'jeera', 'jira': 'jeera', 'cumin': 'jeera',
    'धनिया': 'coriander', 'dhaniya': 'coriander', 'coriander': 'coriander',
    'सौंफ': 'fennel', 'saunf': 'fennel', 'fennel': 'fennel',
    'मेथी': 'fenugreek', 'methi': 'fenugreek',
    'मक्का': 'maize', 'makka': 'maize', 'bhutta': 'maize', 'corn': 'maize',
    'बाजरा': 'bajra', 'millet': 'bajra',
    'ज्वार': 'jowar', 'sorghum': 'jowar',
    'मूंग': 'moong', 'mung': 'moong',
    'उड़द': 'urad', 'mash': 'urad',
    'अरहर': 'arhar', 'तुअर': 'arhar', 'tur': 'arhar', 'toor': 'arhar',
    'मूंगफली': 'groundnut', 'mungfali': 'groundnut', 'peanut': 'groundnut',
    'ग्वार': 'guar', 'gwar': 'guar',
    'अनार': 'pomegranate', 'anaar': 'pomegranate',
    'संतरा': 'citrus', 'नींबू': 'citrus', 'nimbu': 'citrus', 'orange': 'citrus',
    'आम': 'mango', 'aam': 'mango',
    'बैंगन': 'brinjal', 'baingan': 'brinjal',
    'भिंडी': 'okra', 'bhindi': 'okra',
    'मटर': 'pea', 'matar': 'pea',
  };

  /// Main AI Chatbot Message Processing Method
  static Future<ChatMessage> processMessage(
    String userQuery, {
    List<MandiRate>? liveRates,
  }) async {
    final query = userQuery.trim().toLowerCase();
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
            '🌾 1. मंडी भाव: मंडी और फसल का नाम लिखें\n'
            '👉 उदा: "नीमच में लहसुन का भाव" या "इंदौर सोयाबीन"\n\n'
            '🩺 2. फसल रोग व दवा: फसल और रोग का नाम लिखें\n'
            '👉 उदा: "गेहूं में पीला रतुआ दवा" या "टमाटर में झुलसा"',
        isUser: false,
        timestamp: now,
        type: ChatMessageType.suggestions,
        quickActions: [
          'नीमच में लहसुन भाव',
          'इंदौर में सोयाबीन भाव',
          'गेहूं में पीला रतुआ दवा',
          'टमाटर में झुलसा का इलाज',
          'सरसों में माहू (चेपा) स्प्रे',
          'चने में इल्ली की रोकथाम',
        ],
      );
    }

    // 2. Check for Mandi Bhav Intent
    final isMandiQuery = query.contains('भाव') ||
        query.contains('रेट') ||
        query.contains('bhav') ||
        query.contains('mandi') ||
        query.contains('rate') ||
        query.contains('दाम') ||
        query.contains('कीमत') ||
        query.contains('बिक');

    final matchedMarket = _extractMarket(query);
    final matchedCropKey = _extractCropKey(query);

    // If query has Mandi indicator or matched a known Market name
    if (isMandiQuery || matchedMarket != null) {
      final mandiResult = await _handleMandiQuery(
        query: query,
        matchedMarket: matchedMarket,
        matchedCropKey: matchedCropKey,
        liveRates: liveRates,
        msgId: msgId,
        now: now,
      );
      if (mandiResult != null) return mandiResult;
    }

    // 3. Check for Crop Disease & Cure Intent
    final diseaseResult = _handleDiseaseQuery(
      query: query,
      matchedCropKey: matchedCropKey,
      msgId: msgId,
      now: now,
    );
    if (diseaseResult != null) return diseaseResult;

    // 4. If query matched Crop but neither Mandi nor Disease specifically found
    if (matchedCropKey != null) {
      final cropHindi = _getCropHindi(matchedCropKey);
      final diseases = CropDiseaseDatabase.getDiseasesByCrop(matchedCropKey);

      return ChatMessage(
        id: msgId,
        text: '🌾 $cropHindi के बारे में आप क्या जानना चाहते हैं?\n'
            '• क्या आप $cropHindi का मंडी भाव जानना चाहते हैं?\n'
            '• या $cropHindi के किसी रोग/कीट की दवा जानना चाहते हैं?',
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

    // 5. Intelligent Fallback
    return ChatMessage(
      id: msgId,
      text: 'किसान भाई, कृपया फसल का नाम और साथ में रोग या मंडी का नाम लिखें।\n\n'
          '👉 मंडी भाव के लिए: "नीमच लहसुन भाव" या "इंदौर सोयाबीन"\n'
          '👉 रोग के इलाज के लिए: "गेहूं पीला रतुआ" या "टमाटर झुलसा"',
      isUser: false,
      timestamp: now,
      type: ChatMessageType.suggestions,
      quickActions: [
        'नीमच में लहसुन भाव',
        'इंदौर में सोयाबीन भाव',
        'गेहूं में पीला रतुआ दवा',
        'टमाटर में झुलसा का इलाज',
      ],
    );
  }

  // ==========================================
  // 🌾 MANDI RATE QUERY HANDLER
  // ==========================================
  static Future<ChatMessage?> _handleMandiQuery({
    required String query,
    required String? matchedMarket,
    required String? matchedCropKey,
    List<MandiRate>? liveRates,
    required String msgId,
    required DateTime now,
  }) async {
    // 1. Fetch available rates pool
    List<MandiRate> pool = liveRates ?? [];
    if (pool.isEmpty) {
      try {
        pool = await MandiService.fetchMandiRates(limit: 5000);
      } catch (_) {}
    }

    if (pool.isEmpty) {
      return ChatMessage(
        id: msgId,
        text: 'मंडी भाव डेटा लोड हो रहा है, कृपया एक क्षण बाद पुनः पूछें।',
        isUser: false,
        timestamp: now,
      );
    }

    // Case A: Both Market & Crop specified (e.g., "नीमच में लहसुन भाव")
    if (matchedMarket != null && matchedCropKey != null) {
      final cropHindi = _getCropHindi(matchedCropKey);
      final rate = _findRateByMarketAndCrop(pool, matchedMarket, matchedCropKey, cropHindi);

      if (rate != null) {
        final cropName = CommodityHelper.getHindiName(rate.commodity);
        final trendText = rate.maxPrice > rate.modalPrice
            ? '🟢 मजबूत मांग (${rate.arrivalStatus})'
            : '⚪ सामान्य (${rate.arrivalStatus})';

        return ChatMessage(
          id: msgId,
          text: '🌾 ${rate.market} मंडी (${rate.state}) में $cropName का ताज़ा भाव:\n\n'
              '💰 मॉडल (औसत) भाव: ₹${rate.modalPrice.toInt()} / क्विंटल\n'
              '📈 न्यूनतम - अधिकतम: ₹${rate.minPrice.toInt()} - ₹${rate.maxPrice.toInt()} / क्विंटल\n'
              '📊 बाजार रुझान: $trendText\n'
              '📅 आवक तिथि: ${rate.arrivalDate}',
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
        // Market found, but specific crop not reported today
        final marketRates = pool.where((r) => r.market.toLowerCase().contains(matchedMarket.toLowerCase())).take(5).toList();
        final cropName = cropHindi;

        if (marketRates.isNotEmpty) {
          final listText = marketRates.map((r) => '• ${CommodityHelper.getHindiName(r.commodity)}: ₹${r.modalPrice.toInt()} / क्विंटल').join('\n');
          return ChatMessage(
            id: msgId,
            text: 'आज $matchedMarket मंडी में $cropName की आवक दर्ज नहीं हुई है।\n\n'
                '🏛️ $matchedMarket मंडी में आज के अन्य मुख्य भाव:\n$listText',
            isUser: false,
            timestamp: now,
            type: ChatMessageType.mandiRate,
            alternativeRates: marketRates,
            quickActions: [
              '$cropName के अन्य मंडियों के भाव',
            ],
          );
        }
      }
    }

    // Case B: Only Market specified (e.g. "नीमच मंडी का भाव")
    if (matchedMarket != null && matchedCropKey == null) {
      final marketRates = pool.where((r) => r.market.toLowerCase().contains(matchedMarket.toLowerCase())).take(6).toList();
      if (marketRates.isNotEmpty) {
        final listText = marketRates.map((r) => '• ${CommodityHelper.getHindiName(r.commodity)}: ₹${r.modalPrice.toInt()} / क्विंटल (न्यूनतम: ₹${r.minPrice.toInt()})').join('\n');
        return ChatMessage(
          id: msgId,
          text: '🏛️ $matchedMarket मंडी के आज के ताज़ा भाव:\n\n$listText',
          isUser: false,
          timestamp: now,
          type: ChatMessageType.mandiRate,
          alternativeRates: marketRates,
          quickActions: marketRates.take(3).map((r) => '${r.market} में ${CommodityHelper.getHindiName(r.commodity)} भाव').toList(),
        );
      }
    }

    // Case C: Only Crop specified with "भाव" (e.g. "लहसुन का भाव", "सोयाबीन भाव")
    if (matchedCropKey != null) {
      final cropHindi = _getCropHindi(matchedCropKey);
      final cropRates = pool.where((r) {
        final comm = r.commodity.toLowerCase();
        final commHindi = CommodityHelper.getHindiName(r.commodity);
        return comm.contains(matchedCropKey) || commHindi.contains(cropHindi) || cropHindi.contains(commHindi);
      }).take(5).toList();

      if (cropRates.isNotEmpty) {
        final listText = cropRates.map((r) => '• ${r.market} (${r.state}): ₹${r.modalPrice.toInt()} / क्विंटल').join('\n');
        return ChatMessage(
          id: msgId,
          text: '🌾 $cropHindi के प्रमुख मंडियों में ताज़ा भाव:\n\n$listText',
          isUser: false,
          timestamp: now,
          type: ChatMessageType.mandiRate,
          alternativeRates: cropRates,
          quickActions: cropRates.take(3).map((r) => '${r.market} में $cropHindi भाव').toList(),
        );
      }
    }

    return null;
  }

  // ==========================================
  // 🩺 CROP DISEASE & REMEDY HANDLER
  // ==========================================
  static ChatMessage? _handleDiseaseQuery({
    required String query,
    required String? matchedCropKey,
    required String msgId,
    required DateTime now,
  }) {
    final allDiseases = CropDiseaseDatabase.diseases;

    // Search for best disease match
    CropDisease? matchedDisease;

    // 1. If crop is known, search within that crop
    if (matchedCropKey != null) {
      final cropDiseases = CropDiseaseDatabase.getDiseasesByCrop(matchedCropKey);
      for (final d in cropDiseases) {
        final hin = d.diseaseNameHindi.toLowerCase();
        final eng = d.diseaseNameEnglish.toLowerCase();
        final sym = d.symptoms.join(' ').toLowerCase();

        // Check query matching disease name or symptom keywords
        if (query.contains(hin) ||
            hin.split(' ').any((w) => w.length > 2 && query.contains(w)) ||
            query.contains(eng) ||
            (query.contains('इल्ली') && (hin.contains('इल्ली') || sym.contains('इल्ली') || hin.contains('सुंडी'))) ||
            (query.contains('रतुआ') && hin.contains('रतुआ')) ||
            (query.contains('झुलसा') && hin.contains('झुलसा')) ||
            (query.contains('माहू') || query.contains('चेपा')) && (hin.contains('माहू') || hin.contains('एफिड') || sym.contains('रसचूसक')) ||
            (query.contains('मरोड़') && hin.contains('मरोड़')) ||
            (query.contains('छाछिया') && hin.contains('छाछिया')) ||
            (query.contains('उकठा') && hin.contains('उकठा'))) {
          matchedDisease = d;
          break;
        }
      }

      // If specific disease wasn't named, but "दवा", "रोग", "इलाज", "स्प्रे", "कीड़ा" is in query
      if (matchedDisease == null &&
          (query.contains('रोग') || query.contains('दवा') || query.contains('इलाज') || query.contains('स्प्रे') || query.contains('कीट') || query.contains('बीमारी'))) {
        if (cropDiseases.isNotEmpty) {
          final listText = cropDiseases.take(4).map((d) => '• ${d.diseaseNameHindi}').join('\n');
          final cropHindi = _getCropHindi(matchedCropKey);
          return ChatMessage(
            id: msgId,
            text: '🩺 **$cropHindi** में अक्सर ये प्रमुख रोग लगते हैं:\n\n$listText\n\n'
                'आप किस रोग की दवा और खुराक जानना चाहते हैं? नीचे से चुनें:',
            isUser: false,
            timestamp: now,
            type: ChatMessageType.suggestions,
            quickActions: cropDiseases.take(4).map((d) => '$cropHindi में ${d.diseaseNameHindi} की दवा').toList(),
          );
        }
      }
    }

    // 2. If crop wasn't specified, search across all 100+ diseases
    if (matchedDisease == null) {
      for (final d in allDiseases) {
        final hin = d.diseaseNameHindi.toLowerCase();
        final eng = d.diseaseNameEnglish.toLowerCase();
        if (query.contains(hin) || query.contains(eng)) {
          matchedDisease = d;
          break;
        }
      }
    }

    // If disease matched!
    if (matchedDisease != null) {
      final d = matchedDisease;
      return ChatMessage(
        id: msgId,
        text: '🩺 रोग: ${d.diseaseNameHindi} (${d.diseaseNameEnglish})\n'
            '🌱 फसल: ${d.cropHindi} | प्रकार: ${d.pathogen}\n\n'
            '🧪 अनुशंसित रासायनिक दवा (CIBRC प्रमाणित):\n${d.chemicalMedicine}\n\n'
            '💧 स्प्रे खुराक: ${d.sprayDosage}\n\n'
            '🍃 जैविक व देसी उपाय:\n${d.organicRemedy}\n\n'
            '⚠️ सावधानी: ${d.precautions}',
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
  // 🔍 HELPER EXTRACTION METHODS
  // ==========================================
  static bool _isGreeting(String q) {
    return q == 'hi' ||
        q == 'hello' ||
        q == 'नमस्ते' ||
        q == 'राम राम' ||
        q == 'जय श्री राम' ||
        q == 'प्रणाम' ||
        q == 'help' ||
        q.contains('मदद') ||
        q.contains('शुरू');
  }

  static String? _extractCropKey(String q) {
    for (final entry in _cropSynonyms.entries) {
      if (q.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  static String _getCropHindi(String cropKey) {
    for (final entry in _cropSynonyms.entries) {
      if (entry.value == cropKey) return entry.key;
    }
    return cropKey;
  }

  static String? _extractMarket(String q) {
    const popularMandis = [
      'नीमच', 'neemuch', 'इंदौर', 'indore', 'कोटा', 'kota', 'मंदसौर', 'mandsaur',
      'उज्जैन', 'ujjain', 'जयपुर', 'jaipur', 'जोधपुर', 'jodhpur', 'बीकानेर', 'bikaner',
      'नासिक', 'nashik', 'नागपुर', 'nagpur', 'राजकोट', 'rajkot', 'अहमदाबाद', 'ahmedabad',
      'गंगानगर', 'ganganagar', 'हनुमानगढ़', 'hanumangarh', 'रतलाम', 'ratlam', 'विदिशा', 'vidisha',
      'सीहोर', 'sehore', 'खंडवा', 'khandwa', 'देवास', 'dewas', 'मेड़ता', 'merta', 'नागौर', 'nagaur',
      'गुना', 'guna', 'झालावाड़', 'jhalawar', 'बारां', 'baran', 'बूंदी', 'bundi', 'अलवर', 'alwar',
      'भरतपुर', 'bharatpur', 'आगरा', 'agra', 'कानपुर', 'kanpur', 'हाथरस', 'hathras', 'करनाल', 'karnal',
      'अमृतसर', 'amritsar', 'लुधियाना', 'ludhiana', 'आजादपुर', 'azadpur',
    ];

    for (final m in popularMandis) {
      if (q.contains(m.toLowerCase())) {
        return m;
      }
    }
    return null;
  }

  static MandiRate? _findRateByMarketAndCrop(
    List<MandiRate> pool,
    String marketName,
    String cropKey,
    String cropHindi,
  ) {
    marketName = marketName.toLowerCase();
    for (final r in pool) {
      final rMarket = r.market.toLowerCase();
      if (rMarket.contains(marketName) || marketName.contains(rMarket)) {
        final comm = r.commodity.toLowerCase();
        final commHindi = CommodityHelper.getHindiName(r.commodity);
        if (comm.contains(cropKey) || commHindi.contains(cropHindi) || cropHindi.contains(commHindi)) {
          return r;
        }
      }
    }
    return null;
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
    // Strip markdown stars for speech clarity
    final cleanText = msg.text.replaceAll('*', '').replaceAll('•', '').replaceAll('👉', '');
    await TtsService().speak(cleanText, title: 'किसान मित्र AI');
  }
}
