class CropCalendarStage {
  final String id;
  final String stageName;
  final int startDay;
  final int endDay;
  final String irrigationAdvice;
  final String fertilizerAdvice;
  final String pestWarning;
  final String criticalTips;

  const CropCalendarStage({
    required this.id,
    required this.stageName,
    required this.startDay,
    required this.endDay,
    required this.irrigationAdvice,
    required this.fertilizerAdvice,
    required this.pestWarning,
    required this.criticalTips,
  });

  bool isCurrent(int daysSinceSowing) =>
      daysSinceSowing >= startDay && daysSinceSowing <= endDay;

  bool isPast(int daysSinceSowing) => daysSinceSowing > endDay;
  bool isUpcoming(int daysSinceSowing) => daysSinceSowing < startDay;
}

class CropCalendarTemplate {
  final String cropId;
  final String cropName;
  final String hindiName;
  final String emoji;
  final String season;
  final int totalDays;
  final List<CropCalendarStage> stages;

  const CropCalendarTemplate({
    required this.cropId,
    required this.cropName,
    required this.hindiName,
    required this.emoji,
    required this.season,
    required this.totalDays,
    required this.stages,
  });

  static const List<CropCalendarTemplate> defaultTemplates = [
    // 1. गेहूं (Wheat)
    CropCalendarTemplate(
      cropId: 'wheat',
      cropName: 'Wheat',
      hindiName: 'गेहूं',
      emoji: '🌾',
      season: 'रबी (Rabi)',
      totalDays: 125,
      stages: [
        CropCalendarStage(
          id: 'w_1',
          stageName: 'बुवाई व अंकुरण (Sowing & Emergence)',
          startDay: 0,
          endDay: 18,
          irrigationAdvice: 'बुवाई से पहले पलेवा (Pre-sowing irrigation) करें। बीज 4-5 सेमी गहराई पर बोएं।',
          fertilizerAdvice: 'आधार खाद (Basal): DAP 50-55 kg/एकड़ + पोटाश 20 kg/एकड़ + जिंक सल्फेट 10 kg/एकड़।',
          pestWarning: 'दीमक व जड़ माहू से बचाव हेतु क्लोरपायरीफॉस या थायमेथोक्सम से बीज उपचार अवश्य करें।',
          criticalTips: 'बीज अंकुरण 90% से अधिक रखने हेतु प्रमाणित बीज ही इस्तेमाल करें।',
        ),
        CropCalendarStage(
          id: 'w_2',
          stageName: 'ताज मूल अवस्था (CRI Stage - 20-25 दिन)',
          startDay: 19,
          endDay: 30,
          irrigationAdvice: '⚠️ सबसे महत्वपूर्ण सिंचाई (1st Irrigation)! इस समय पानी न मिलने पर कल्ले कम फूटेंगे।',
          fertilizerAdvice: 'पहली यूरिया टॉप-ड्रेसिंग: 35-40 kg यूरिया/एकड़ सिंचाई के तुरंत बाद दें।',
          pestWarning: 'दीमक का प्रकोप दिखने पर सिंचाई के पानी के साथ क्लोरपायरीफॉस 20 EC दें।',
          criticalTips: 'CRI अवस्था गेहूं की उपज तय करने वाली सबसे संवेदनशील अवस्था है।',
        ),
        CropCalendarStage(
          id: 'w_3',
          stageName: 'खरपतवार नियंत्रण (Weed Control - 30-35 दिन)',
          startDay: 31,
          endDay: 45,
          irrigationAdvice: 'खरपतवारनाशी का छिड़काव खेत में पर्याप्त ओट (नमी) होने पर ही करें।',
          fertilizerAdvice: 'संकरी पत्ती (गुल्ली डंडा): क्लोडिनाफॉप 15% WP (60g/एकड़)। चौड़ी पत्ती: 2,4-D या मेटसल्फ्यूरोन मिथाइल (20g/एकड़)।',
          pestWarning: 'गुल्ली डंडा (मण्डूसी) और बथुआ गेहूं की 30-40% खुराक छीन लेते हैं।',
          criticalTips: 'स्प्रे हमेशा फ्लैट-फैन नोजल से 150 लीटर पानी मिलाकर करें।',
        ),
        CropCalendarStage(
          id: 'w_4',
          stageName: 'कल्ले फूटना व गांठ बनना (Tillering & Jointing - 45-65 दिन)',
          startDay: 46,
          endDay: 65,
          irrigationAdvice: 'दूसरी सिंचाई 40-45 दिन व तीसरी सिंचाई 60-65 दिन पर करें।',
          fertilizerAdvice: 'दूसरी यूरिया टॉप-ड्रेसिंग: 35 kg यूरिया/एकड़ + NPK 19:19:19 का 1kg/एकड़ स्प्रे।',
          pestWarning: 'पीला रतुआ (Yellow Rust) के धब्बे दिखने पर प्रोपिकोनाजोल 25 EC (200ml/एकड़) का छिड़काव करें।',
          criticalTips: 'खेत में पानी भरने न दें, जल निकास सुनिश्चित करें।',
        ),
        CropCalendarStage(
          id: 'w_5',
          stageName: 'बालियां निकलना व फूल अवस्था (Heading & Flowering - 70-85 दिन)',
          startDay: 66,
          endDay: 85,
          irrigationAdvice: 'चौथी सिंचाई करें। बालियां निकलते समय नमी की कमी से दाना पिचक जाता है।',
          fertilizerAdvice: 'NPK 00:52:34 (1 kg/एकड़) + बोरॉन 20% (100 ग्राम/एकड़) का फोलियर स्प्रे करें।',
          pestWarning: 'माहू (Aphid) का प्रकोप दिखने पर थायमेथोक्सम 25 WG (80g/एकड़) का स्प्रे करें।',
          criticalTips: 'बोरॉन स्प्रे से परागण अच्छा होता है और बालियों में शत-प्रतिशत दाना भरता है।',
        ),
        CropCalendarStage(
          id: 'w_6',
          stageName: 'दूधिया अवस्था व दाना भराव (Milking & Dough - 86-110 दिन)',
          startDay: 86,
          endDay: 110,
          irrigationAdvice: 'हल्की सिंचाई तेज हवा बंद होने पर ही करें, ताकि फसल गिरे नहीं (Lodging risk)।',
          fertilizerAdvice: 'पोटाश NPK 00:00:50 (1 kg/एकड़) का स्प्रे दाने में वजन व चमक बढ़ाता है।',
          pestWarning: 'सैनिक कीट या बालियां काटने वाले कीड़े से सतर्क रहें।',
          criticalTips: 'तेज धूप और पछुआ हवा से दाना समय से पहले सूखने का खतरा रहता है।',
        ),
        CropCalendarStage(
          id: 'w_7',
          stageName: 'परिपक्वता व कटाई (Maturity & Harvest - 111-125 दिन)',
          startDay: 111,
          endDay: 125,
          irrigationAdvice: 'कटाई से 12-15 दिन पहले सिंचाई पूर्णतः बंद कर दें।',
          fertilizerAdvice: 'किसी खाद की आवश्यकता नहीं।',
          pestWarning: 'गोदाम भंडारण से पहले दाने को धूप में 10-12% नमी तक सुखाएं।',
          criticalTips: 'सुबह के समय कटाई करें ताकि दाने झड़े नहीं। कंबाइन हार्वेस्टर का सही आरपीएम रखें।',
        ),
      ],
    ),

    // 2. सरसों (Mustard)
    CropCalendarTemplate(
      cropId: 'mustard',
      cropName: 'Mustard',
      hindiName: 'सरसों',
      emoji: '🌼',
      season: 'रबी (Rabi)',
      totalDays: 130,
      stages: [
        CropCalendarStage(
          id: 'm_1',
          stageName: 'बुवाई व विरलीकरण (Thinning - Day 0-25)',
          startDay: 0,
          endDay: 25,
          irrigationAdvice: 'पहली सिंचाई बुवाई के 25-30 दिन बाद फूल आने से ठीक पहले करें।',
          fertilizerAdvice: 'बुवाई पर सल्फर 90% (10kg/एकड़) + SSP 3 कट्टे + यूरिया 25 kg। सरसों में सल्फर से 2-3% तेल बढ़ता है!',
          pestWarning: 'आरा मक्खी (Sawfly) व चितकबरा कीड़ा (Painted Bug) से बचाव हेतु मेलाथियान धूल डालें।',
          criticalTips: '15-20 दिन पर विरलीकरण (पौधों की दूरी 10-12 सेमी) जरूर करें।',
        ),
        CropCalendarStage(
          id: 'm_2',
          stageName: 'शाखाएं निकलना व फूल अवस्था (Branching & Flowering - Day 26-55)',
          startDay: 26,
          endDay: 55,
          irrigationAdvice: 'पूर्ण फूल आने पर सिंचाई से बचें, इससे फूल झड़ने का खतरा रहता है।',
          fertilizerAdvice: 'पहली सिंचाई पर यूरिया 35 kg/एकड़ की टॉप ड्रेसिंग करें।',
          pestWarning: 'चेपा / माहू (Aphid) का प्रकोप शुरू होता है। चिपचिपे पीले ट्रैप लगाएं।',
          criticalTips: 'मधुमक्खियों के परागण का समय है, रासायनिक कीटनाशक सुबह 11 बजे से पहले या शाम 4 बजे बाद ही छिड़कें।',
        ),
        CropCalendarStage(
          id: 'm_3',
          stageName: 'फलियां बनना व चेपा नियंत्रण (Pod Formation - Day 56-85)',
          startDay: 56,
          endDay: 85,
          irrigationAdvice: 'फलियां बनते समय दूसरी सिंचाई अवश्य करें।',
          fertilizerAdvice: 'घुलनशील सल्फर (0.2%) का फोलियर स्प्रे फलियों में दानों का आकार बढ़ाता है।',
          pestWarning: 'माहू (चेपा) अधिक हो तो डाइमेथोएट 30 EC (300ml/एकड़) या इमिडाक्लोप्रिड 17.8 SL (60ml/एकड़) का स्प्रे करें।',
          criticalTips: 'कोहरा या बादल छाने पर छाछ (मट्ठा) + हींग का देशी स्प्रे फफूंद से बचाता है।',
        ),
        CropCalendarStage(
          id: 'm_4',
          stageName: 'दाना भराव व कटाई (Maturity & Harvest - Day 86-130)',
          startDay: 86,
          endDay: 130,
          irrigationAdvice: 'सिंचाई पूर्णतः बंद करें।',
          fertilizerAdvice: 'कोई रासायनिक खाद न दें।',
          pestWarning: 'फलियां चटकने से बचाने के लिए 75% फलियां पीली पड़ते ही कटाई करें।',
          criticalTips: 'कटाई सुबह के समय ओस रहते करें ताकि फलियां खेत में न छिटकें।',
        ),
      ],
    ),

    // 3. सोयाबीन (Soybean)
    CropCalendarTemplate(
      cropId: 'soybean',
      cropName: 'Soybean',
      hindiName: 'सोयाबीन',
      emoji: '🌱',
      season: 'खरीफ (Kharif)',
      totalDays: 100,
      stages: [
        CropCalendarStage(
          id: 's_1',
          stageName: 'बुवाई व खरपतवार नियंत्रण (Day 0-20)',
          startDay: 0,
          endDay: 20,
          irrigationAdvice: 'मानसून की 75-100 मिमी अच्छी बारिश के बाद ही बुवाई करें।',
          fertilizerAdvice: 'राइजोबियम कल्चर से बीज उपचार + DAP 35kg/एकड़ + सल्फर 10kg/एकड़।',
          pestWarning: 'बुवाई के 48 घंटे के भीतर प्री-इमर्जेंस डाइक्लोसुलम या पेंडिमिथालिन स्प्रे करें।',
          criticalTips: 'बीज की अंकुरण क्षमता (Germination test) कम से कम 70% होनी चाहिए।',
        ),
        CropCalendarStage(
          id: 's_2',
          stageName: 'शाखाएं व फूल अवस्था (Day 21-50)',
          startDay: 21,
          endDay: 50,
          irrigationAdvice: 'बारिश न होने पर (सूखा पड़ने पर) स्प्रिंकलर से जीवनरक्षक सिंचाई दें।',
          fertilizerAdvice: 'फूल आने से ठीक पहले NPK 19:19:19 (1kg/एकड़) का स्प्रे।',
          pestWarning: 'गर्डल बीटल (चक्र भृंग) व सेमीलूपर इल्ली दिखने पर क्लोरेंट्रानिलिप्रोल (कोराजन) 60ml/एकड़ डालें।',
          criticalTips: 'पीला मोज़ेक वायरस फैलाने वाली सफेद मक्खी (Whitefly) पर तुरंत नियंत्रण करें।',
        ),
        CropCalendarStage(
          id: 's_3',
          stageName: 'फली दाना भराव व परिपक्वता (Day 51-100)',
          startDay: 51,
          endDay: 100,
          irrigationAdvice: 'फली में दाना भरते समय खेत में नमी आवश्यक है।',
          fertilizerAdvice: 'NPK 00:52:34 + बोरॉन स्प्रे दानों को सुडौल व चमकदार बनाता है।',
          pestWarning: 'फली छेदक कीट (Pod borer) से बचाव करें।',
          criticalTips: 'पत्तियां पीली होकर झड़ने लगें और फलियों का रंग भूरा हो जाए तब कटाई करें।',
        ),
      ],
    ),

    // 4. चना (Chickpea / Gram)
    CropCalendarTemplate(
      cropId: 'gram',
      cropName: 'Gram',
      hindiName: 'चना',
      emoji: '🧆',
      season: 'रबी (Rabi)',
      totalDays: 120,
      stages: [
        CropCalendarStage(
          id: 'g_1',
          stageName: 'बुवाई व खूंटाई (Nipping - Day 0-40)',
          startDay: 0,
          endDay: 40,
          irrigationAdvice: 'चना कम पानी की फसल है। भारी मिट्टी में केवल 1-2 सिंचाइयों की आवश्यकता होती है।',
          fertilizerAdvice: 'DAP 35kg + पोटाश 15kg/एकड़। बीज को ट्राइकोडर्मा (5g/kg) से उपचारित करें।',
          pestWarning: 'उकठा (Wilt) रोग से बचाव हेतु गहरी बुवाई (8-10 सेमी) करें।',
          criticalTips: 'बुवाई के 30-35 दिन बाद शीर्ष भाग (Nipping) तोड़ें, इससे शाखाएं दोगुनी फूटती हैं।',
        ),
        CropCalendarStage(
          id: 'g_2',
          stageName: 'फूल व फली छेदक नियंत्रण (Day 41-80)',
          startDay: 41,
          endDay: 80,
          irrigationAdvice: '⚠️ फूल आते समय सिंचाई कदापि न करें, वर्ना फूल झड़ जाएंगे व वानस्पतिक वृद्धि होगी।',
          fertilizerAdvice: '2% यूरिया घोल या NPK 19:19:19 का छिड़काव करें।',
          pestWarning: 'हेलिकोवर्पा इल्ली (फली छेदक) हेतु टी-आकार की खूंटियां (Bird perches) व फेरोमोन ट्रैप लगाएं।',
          criticalTips: 'इल्ली दिखने पर इमामेक्टिन बेंजोएट 5% SG (80g/एकड़) का स्प्रे करें।',
        ),
        CropCalendarStage(
          id: 'g_3',
          stageName: 'दाना भराव व कटाई (Day 81-120)',
          startDay: 81,
          endDay: 120,
          irrigationAdvice: 'फलियां बनते समय आवश्यकतानुसार एक हल्की सिंचाई कर सकते हैं।',
          fertilizerAdvice: '00:00:50 पोटाश स्प्रे से दाना मोटा बनता है।',
          pestWarning: 'कटाई के बाद भंडारण में खपरा भृंग से बचाव हेतु नीम पत्ती रखें।',
          criticalTips: 'फलियां सूखकर खड़खड़ाने लगें तब कटाई कर तुरंत थ्रेशिंग करें।',
        ),
      ],
    ),
  ];
}
