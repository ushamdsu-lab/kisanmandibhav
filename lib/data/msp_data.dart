class MspItem {
  final String cropId;
  final String nameHindi;
  final String nameEng;
  final double mspPrice; // per Quintal (₹/Qtl)
  final String season;
  final String category; // 'rabi', 'kharif', 'commercial', 'baseline'
  final bool isOfficialMsp; // True if mandated under Govt CACP MSP / FRP
  final String icon;

  const MspItem({
    required this.cropId,
    required this.nameHindi,
    required this.nameEng,
    required this.mspPrice,
    required this.season,
    required this.category,
    this.isOfficialMsp = true,
    this.icon = '🌾',
  });
}

class MspDatabase {
  static const List<MspItem> mspList = [
    // --- Rabi Crops (रबी फसलें CACP Govt Official MSP) ---
    MspItem(cropId: 'wheat', nameHindi: 'गेहूं', nameEng: 'Wheat', mspPrice: 2275, season: 'रबी 2024-25', category: 'rabi', isOfficialMsp: true, icon: '🌾'),
    MspItem(cropId: 'mustard', nameHindi: 'सरसों / रायड़ा', nameEng: 'Mustard / Rape Seed', mspPrice: 5650, season: 'रबी 2024-25', category: 'rabi', isOfficialMsp: true, icon: '🌻'),
    MspItem(cropId: 'chana', nameHindi: 'चना (देसी/काबुली)', nameEng: 'Chana / Bengal Gram', mspPrice: 5440, season: 'रबी 2024-25', category: 'rabi', isOfficialMsp: true, icon: '🌱'),
    MspItem(cropId: 'barley', nameHindi: 'जौ', nameEng: 'Barley', mspPrice: 1850, season: 'रबी 2024-25', category: 'rabi', isOfficialMsp: true, icon: '🌾'),
    MspItem(cropId: 'masoor', nameHindi: 'मसूर दाल', nameEng: 'Lentil (Masur)', mspPrice: 6425, season: 'रबी 2024-25', category: 'rabi', isOfficialMsp: true, icon: '🌱'),
    MspItem(cropId: 'safflower', nameHindi: 'कुसुम', nameEng: 'Safflower', mspPrice: 5800, season: 'रबी 2024-25', category: 'rabi', isOfficialMsp: true, icon: '🌼'),
    MspItem(cropId: 'taramira', nameHindi: 'तारामीरा', nameEng: 'Taramira', mspPrice: 5350, season: 'रबी 2024-25', category: 'rabi', isOfficialMsp: true, icon: '🌱'),

    // --- Kharif Crops (खरीफ फसलें CACP Govt Official MSP) ---
    MspItem(cropId: 'rice', nameHindi: 'धान (सामान्य)', nameEng: 'Paddy Common', mspPrice: 2300, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌾'),
    MspItem(cropId: 'rice_a', nameHindi: 'धान (ग्रेड-ए)', nameEng: 'Paddy Grade-A', mspPrice: 2320, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌾'),
    MspItem(cropId: 'moong', nameHindi: 'मूंग', nameEng: 'Moong (Green Gram)', mspPrice: 8558, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌱'),
    MspItem(cropId: 'urad', nameHindi: 'उड़द', nameEng: 'Urad (Black Gram)', mspPrice: 7400, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌱'),
    MspItem(cropId: 'arhar', nameHindi: 'अरहर / तुअर', nameEng: 'Arhar / Toor', mspPrice: 7550, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌱'),
    MspItem(cropId: 'bajra', nameHindi: 'बाजरा', nameEng: 'Bajra (Pearl Millet)', mspPrice: 2625, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌽'),
    MspItem(cropId: 'maize', nameHindi: 'मक्का', nameEng: 'Maize / Corn', mspPrice: 2225, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌽'),
    MspItem(cropId: 'jowar', nameHindi: 'ज्वार (हायब्रिड)', nameEng: 'Jowar Hybrid', mspPrice: 3371, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌾'),
    MspItem(cropId: 'jowar_m', nameHindi: 'ज्वार (मालदंडी)', nameEng: 'Jowar Maldandi', mspPrice: 3421, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌾'),
    MspItem(cropId: 'ragi', nameHindi: 'रागी / मडुआ', nameEng: 'Ragi', mspPrice: 4290, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌾'),
    MspItem(cropId: 'groundnut', nameHindi: 'मूंगफली', nameEng: 'Groundnut', mspPrice: 6783, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🥜'),
    MspItem(cropId: 'soybean', nameHindi: 'सोयाबीन (पीला)', nameEng: 'Soybean Yellow', mspPrice: 4892, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌱'),
    MspItem(cropId: 'sunflower', nameHindi: 'सूरजमुखी', nameEng: 'Sunflower Seed', mspPrice: 7280, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌻'),
    MspItem(cropId: 'sesame', nameHindi: 'तिल (सफेद/काला)', nameEng: 'Sesame (Til)', mspPrice: 9267, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌱'),
    MspItem(cropId: 'nigerseed', nameHindi: 'रामतिल', nameEng: 'Nigerseed', mspPrice: 8717, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '🌱'),
    MspItem(cropId: 'cotton', nameHindi: 'कपास (मध्यम रेशा)', nameEng: 'Cotton Medium', mspPrice: 7121, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '☁️'),
    MspItem(cropId: 'cotton_l', nameHindi: 'कपास (लंबा रेशा)', nameEng: 'Cotton Long Staple', mspPrice: 7521, season: 'खरीफ 2024-25', category: 'kharif', isOfficialMsp: true, icon: '☁️'),

    // --- Commercial Crops (CACP / FRP Rates) ---
    MspItem(cropId: 'sugarcane', nameHindi: 'गन्ना (सरकारी FRP दर)', nameEng: 'Sugarcane FRP', mspPrice: 340, season: '2024-25', category: 'commercial', isOfficialMsp: true, icon: '🎋'),
    MspItem(cropId: 'jute', nameHindi: 'कच्चा जूट / पटसन', nameEng: 'Raw Jute', mspPrice: 5335, season: '2024-25', category: 'commercial', isOfficialMsp: true, icon: '🌿'),
    MspItem(cropId: 'copra', nameHindi: 'खोपरा (सूखा नारियल)', nameEng: 'Copra', mspPrice: 11160, season: '2024-25', category: 'commercial', isOfficialMsp: true, icon: '🥥'),

    // --- Market Benchmark Reference Rates (मसाले व वाणिज्यिक - बाजार संदर्भ दर) ---
    MspItem(cropId: 'guar', nameHindi: 'ग्वार बीज (बाजार संदर्भ)', nameEng: 'Guar Seed', mspPrice: 5200, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌾'),
    MspItem(cropId: 'castor', nameHindi: 'अरंडी / कैस्टर', nameEng: 'Castor Seed', mspPrice: 6100, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌱'),
    MspItem(cropId: 'jeera', nameHindi: 'जीरा (बाजार बेंचमार्क)', nameEng: 'Jeera / Cumin', mspPrice: 21000, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌿'),
    MspItem(cropId: 'isabgol', nameHindi: 'इसबगोल (बाजार संदर्भ)', nameEng: 'Isabgol / Psyllium', mspPrice: 14500, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌿'),
    MspItem(cropId: 'dhaniya', nameHindi: 'धनिया (बाजार संदर्भ)', nameEng: 'Coriander / Dhaniya', mspPrice: 7600, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌿'),
    MspItem(cropId: 'saunf', nameHindi: 'सौंफ (बाजार संदर्भ)', nameEng: 'Saunf / Fennel', mspPrice: 11500, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌿'),
    MspItem(cropId: 'methi', nameHindi: 'मेथी दाना', nameEng: 'Methi Seeds', mspPrice: 6200, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌱'),
    MspItem(cropId: 'garlic', nameHindi: 'लहसुन (औसत आधार)', nameEng: 'Garlic', mspPrice: 9500, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🧄'),
    MspItem(cropId: 'onion', nameHindi: 'प्याज (औसत आधार)', nameEng: 'Onion', mspPrice: 2000, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🧅'),
    MspItem(cropId: 'potato', nameHindi: 'आलू (औसत आधार)', nameEng: 'Potato', mspPrice: 1500, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🥔'),
    MspItem(cropId: 'chilli', nameHindi: 'लाल मिर्च (सूखी)', nameEng: 'Red Chilli', mspPrice: 12500, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌶️'),
    MspItem(cropId: 'turmeric', nameHindi: 'हल्दी (गांठ)', nameEng: 'Turmeric', mspPrice: 7800, season: '2024-25', category: 'baseline', isOfficialMsp: false, icon: '🌿'),
  ];

  /// Finds MSP item for any raw commodity string from API or user input
  static MspItem? getMspForCrop(String cropNameOrId) {
    if (cropNameOrId.trim().isEmpty) return null;
    final clean = cropNameOrId.toLowerCase().trim();

    for (final item in mspList) {
      if (item.cropId == clean ||
          item.nameEng.toLowerCase() == clean ||
          item.nameHindi == cropNameOrId.trim()) {
        return item;
      }
    }

    for (final item in mspList) {
      if (clean.contains(item.cropId) ||
          clean.contains(item.nameEng.toLowerCase()) ||
          clean.contains(item.nameHindi) ||
          item.nameEng.toLowerCase().contains(clean)) {
        return item;
      }
    }

    // Keyword match fallbacks
    if (clean.contains('wheat') || clean.contains('gehu')) return getMspForCrop('wheat');
    if (clean.contains('mustard') || clean.contains('rai') || clean.contains('sarson')) return getMspForCrop('mustard');
    if (clean.contains('chana') || clean.contains('gram')) return getMspForCrop('chana');
    if (clean.contains('moong') || clean.contains('green gram')) return getMspForCrop('moong');
    if (clean.contains('urad') || clean.contains('black gram')) return getMspForCrop('urad');
    if (clean.contains('rice') || clean.contains('paddy') || clean.contains('dhan')) return getMspForCrop('rice');
    if (clean.contains('cotton') || clean.contains('kapas')) return getMspForCrop('cotton');
    if (clean.contains('guar') || clean.contains('gawar')) return getMspForCrop('guar');
    if (clean.contains('soybean') || clean.contains('soyabean')) return getMspForCrop('soybean');
    if (clean.contains('bajra')) return getMspForCrop('bajra');
    if (clean.contains('maize') || clean.contains('makka')) return getMspForCrop('maize');
    if (clean.contains('groundnut') || clean.contains('mungfali')) return getMspForCrop('groundnut');
    if (clean.contains('jeera') || clean.contains('cummin')) return getMspForCrop('jeera');
    if (clean.contains('isabgol') || clean.contains('psyllium')) return getMspForCrop('isabgol');
    if (clean.contains('dhaniya') || clean.contains('corriander')) return getMspForCrop('dhaniya');
    if (clean.contains('garlic') || clean.contains('lahsun')) return getMspForCrop('garlic');
    if (clean.contains('onion') || clean.contains('pyaj')) return getMspForCrop('onion');
    if (clean.contains('potato') || clean.contains('aloo')) return getMspForCrop('potato');

    return null;
  }
}
