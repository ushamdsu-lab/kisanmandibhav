class CommodityHelper {
  // Mapping of official API English commodity names to Hindi names + type + keywords
  static final Map<String, _CropInfo> _cropMap = {
    // --- Grains, Pulses, Oilseeds, Spices & Cash Crops (अनाज, दलहन, तिलहन, मसाले व नकदी फसलें) ---
    'guar gum': _CropInfo('ग्वार गम', 'Guar Gum', 'guar gum gaur gam guargum gwardan', false),
    'guar seed(cluster beans seed)': _CropInfo('ग्वार बीज', 'Guar Seed', 'guar gwar gawar cluster bean gaur bij', false),
    'guar': _CropInfo('ग्वार', 'Guar', 'guar gwar gawar gaur', false),
    'guar churi': _CropInfo('ग्वार चूरी', 'Guar Churi', 'guar churi gaur churi', false),
    'guar korma': _CropInfo('ग्वार कोरमा', 'Guar Korma', 'guar korma gaur korma', false),
    'taramira': _CropInfo('तारामीरा', 'Taramira', 'taramira tara meera', false),
    'isabgul(psyllium)': _CropInfo('इसबगोल', 'Isabgol / Psyllium', 'isabgol isabgul psyllium', false),
    'isabgol bhusi': _CropInfo('इसबगोल भूसी', 'Psyllium Husk (Isabgol Bhusi)', 'isabgol bhusi psyllium husk', false),
    'cummin seed(jeera)': _CropInfo('जीरा', 'Jeera / Cumin', 'jeera jira cumin cummin', false),
    'cumin seed': _CropInfo('जीरा', 'Jeera / Cumin', 'jeera jira cumin', false),
    'soanf': _CropInfo('सौंफ', 'Saunf / Fennel', 'saunf soanf sonf fennel', false),
    'ajwain': _CropInfo('अजवाइन', 'Ajwain / Carom Seeds', 'ajwain ajvain carom seed', false),
    'kalonji': _CropInfo('कलौंजी', 'Kalonji / Black Cumin', 'kalonji nigella black cumin', false),
    'suva': _CropInfo('सुवा / सोया बीज', 'Suva / Dill Seed', 'suva sowa dill seed', false),
    'corriander seed': _CropInfo('धनिया बीज', 'Coriander Seeds (Dhaniya)', 'dhaniya coriander', false),
    'dhaniya dal': _CropInfo('धनिया दाल / ईगल', 'Coriander Split / Eagle Dhaniya', 'dhaniya dal eagle coriander split', false),
    'methi seeds': _CropInfo('मेथी दाना', 'Fenugreek Seeds (Methi)', 'methi fenugreek', false),
    'kasuri methi': _CropInfo('कसूरी मेथी', 'Kasuri Methi', 'kasuri methi', false),
    'mustard': _CropInfo('सरसों / रायड़ा', 'Mustard / Raida', 'sarson sarso raida rai mustard', false),
    'rape seed': _CropInfo('सरसों / राई', 'Rape Seed / Rai', 'sarson rai mustard', false),
    'mustard oil': _CropInfo('सरसों तेल', 'Mustard Oil', 'sarson tel mustard oil', false),
    'groundnut': _CropInfo('मूंगफली', 'Groundnut / Peanut', 'mungfali mugfali groundnut peanut mungphali moongfali', false),
    'groundnut pods (raw)': _CropInfo('मूंगफली (कच्ची)', 'Raw Groundnut', 'mungfali mugfali groundnut peanut', false),
    'groundnut (split)': _CropInfo('मूंगफली दाना', 'Groundnut Kernels', 'mungfali dana groundnut peanut', false),
    'sesamum(sesame,gingelly,til)': _CropInfo('तिल', 'Til / Sesame', 'til tili sesame sesamum gingelly', false),
    'sesamum': _CropInfo('तिल', 'Til / Sesame', 'til sesame sesamum', false),
    'til': _CropInfo('तिल', 'Til', 'til sesame', false),
    'green gram(moong)(whole)': _CropInfo('मूंग', 'Moong (Green Gram)', 'moong mung green gram mung', false),
    'moong(green gram)': _CropInfo('मूंग', 'Moong', 'moong mung green gram', false),
    'moth dal': _CropInfo('मोठ', 'Moth Bean', 'moth mot mothdal mataki', false),
    'moth': _CropInfo('मोठ', 'Moth', 'moth mot mataki', false),
    'mataki': _CropInfo('मोठ / मटकी', 'Mataki / Moth', 'moth mot mataki', false),
    'bengal gram(gram)(whole)': _CropInfo('चना', 'Chana / Bengal Gram', 'chana gram bengal gram', false),
    'kabuli chana': _CropInfo('काबुली चना / डॉलर', 'Kabuli Chana / Dollar Chana', 'kabuli chana dollar chana white gram', false),
    'black gram(urd beans)(whole)': _CropInfo('उड़द', 'Urad / Black Gram', 'urad mash black gram', false),
    'soyabean': _CropInfo('सोयाबीन', 'Soybean', 'soyabean soybean soya', false),
    'castor seed': _CropInfo('अरंडी (एरंड)', 'Castor Seed (Arandi)', 'arandi castor erand', false),
    'linseed': _CropInfo('अलसी', 'Linseed / Flaxseed (Alsi)', 'alsi linseed flaxseed', false),
    'cotton': _CropInfo('कपास / नरमा', 'Cotton / Narma', 'kapas narma cotton rui', false),
    'paddy(common)': _CropInfo('धान (चावल)', 'Paddy / Rice', 'dhan chawal rice paddy', false),
    'paddy(basmati)': _CropInfo('बासमती धान', 'Basmati Paddy', 'dhan basmati rice paddy', false),
    'rice': _CropInfo('चावल', 'Rice', 'chawal rice dhan', false),
    'wheat': _CropInfo('गेहूं', 'Wheat', 'gehu genhu wheat', false),
    'barley(jau)': _CropInfo('जौ', 'Barley (Jau)', 'jau barley', false),
    'bajra(pearl millet/cumbu)': _CropInfo('बाजरा', 'Bajra (Pearl Millet)', 'bajra bajri pearl millet', false),
    'maize': _CropInfo('मक्का', 'Maize / Corn', 'makka makki maize corn bhutta', false),
    'jowar(sorghum)': _CropInfo('ज्वार', 'Jowar / Sorghum', 'jowar jwar sorghum', false),
    'lentil(masur)(whole)': _CropInfo('मसूर', 'Masoor / Lentil', 'masoor masur lentil', false),
    'arhar (tur/red gram)(whole)': _CropInfo('अरहर / तुअर', 'Arhar / Toor Dal', 'arhar tuar toor red gram', false),
    'garlic': _CropInfo('लहसुन', 'Garlic (Lahsun)', 'lahsun lasun garlic', false),
    'onion': _CropInfo('प्याज', 'Onion (Pyaj)', 'pyaj kanda onion pyaz', false),
    'potato': _CropInfo('आलू', 'Potato (Aloo)', 'aloo alu potato batata', false),
    'chilli red': _CropInfo('लाल मिर्च', 'Red Chilli', 'mirch mirchi chilli red lal', false),
    'turmeric': _CropInfo('हल्दी', 'Turmeric (Haldi)', 'haldi turmeric', false),
    'ginger(dry)': _CropInfo('सोंठ (सूखा अदरक)', 'Dry Ginger (Sonth)', 'sonth ginger dry', false),
    'sugarcane': _CropInfo('गन्ना', 'Sugarcane', 'ganna sugarcane', false),
    'gur(jaggery)': _CropInfo('गुड़', 'Jaggery (Gur)', 'gur gud jaggery', false),

    // --- Vegetables & Fruits (सब्जियां व फल) ---
    'tomato': _CropInfo('टमाटर', 'Tomato', 'tamatar tomato', true),
    'green chilli': _CropInfo('हरी मिर्च', 'Green Chilli', 'mirch mirchi chilli green', true),
    'ginger(green)': _CropInfo('अदरक', 'Green Ginger (Adrak)', 'adrak ginger', true),
    'coriander(leaves)': _CropInfo('हरा धनिया', 'Green Coriander', 'dhaniya coriander', true),
    'methi(leaves)': _CropInfo('हरी मेथी', 'Green Methi', 'methi fenugreek', true),
    'bhindi(ladies finger)': _CropInfo('भिंडी', 'Bhindi (Okra)', 'bhindi okra ladies finger', true),
    'brinjal': _CropInfo('बैंगन', 'Brinjal / Eggplant', 'baingan brinjal eggplant', true),
    'cabbage': _CropInfo('पत्ता गोभी', 'Cabbage', 'patta gobhi cabbage', true),
    'cauliflower': _CropInfo('फूल गोभी', 'Cauliflower', 'phool gobhi cauliflower', true),
    'bottle gourd': _CropInfo('लौकी / घिया', 'Bottle Gourd (Lauki)', 'lauki ghiya bottle gourd', true),
    'bitter gourd': _CropInfo('करेला', 'Bitter Gourd (Karela)', 'karela bitter gourd', true),
    'sponge gourd': _CropInfo('तोरई / तोरी', 'Sponge Gourd (Torai)', 'torai tori sponge gourd', true),
    'ridgeguard(tori)': _CropInfo('तोरई (झिंगा)', 'Ridge Gourd (Tori)', 'torai tori ridge gourd', true),
    'tinda': _CropInfo('टिंडा', 'Tinda', 'tinda round gourd', true),
    'cluster beans': _CropInfo('ग्वार फली (सब्जी)', 'Cluster Beans (Gwar Phali)', 'guar phali cluster bean', true),
    'cucumbar(kheera)': _CropInfo('खीरा / ककड़ी', 'Cucumber (Kheera)', 'kheera kakdi cucumber', true),
    'pointed gourd(parval)': _CropInfo('परवल', 'Pointed Gourd (Parwal)', 'parwal parval pointed gourd', true),
    'colacasia': _CropInfo('अरबी', 'Colocasia (Arbi)', 'arbi arvi colocasia', true),
    'pumpkin': _CropInfo('कद्दू / सीताफल', 'Pumpkin (Kaddu)', 'kaddu sitaphal pumpkin', true),
    'carrot': _CropInfo('गाजर', 'Carrot (Gajar)', 'gajar carrot', true),
    'beetroot': _CropInfo('चुकंदर', 'Beetroot', 'chukandar beetroot', true),
    'spinach': _CropInfo('पालक', 'Spinach (Palak)', 'palak spinach', true),
    'mint(pudina)': _CropInfo('पुदीना', 'Mint (Pudina)', 'pudina mint', true),
    'water melon': _CropInfo('तरबूज', 'Watermelon (Tarbooj)', 'tarbooj watermelon matira', true),
    'musk melon': _CropInfo('खरबूजा', 'Muskmelon (Kharbooja)', 'kharbooja muskmelon', true),
    'papaya': _CropInfo('पपीता', 'Papaya (Papita)', 'papita papaya', true),
    'guava': _CropInfo('अमरूद', 'Guava (Amrood)', 'amrood guava', true),
    'pomegranate': _CropInfo('अनार', 'Pomegranate (Anaar)', 'anaar pomegranate', true),
    'apple': _CropInfo('सेब', 'Apple (Seb)', 'seb apple', true),
    'banana': _CropInfo('केला', 'Banana (Kela)', 'kela banana', true),
    'lemon': _CropInfo('नींबू', 'Lemon (Nimbu)', 'nimbu lemon', true),
    'orange': _CropInfo('संतरा', 'Orange (Santra)', 'santra orange', true),
    'mousambi(sweet lime)': _CropInfo('मौसमी / मौसंबी', 'Sweet Lime (Mousambi)', 'mousambi mosambi sweet lime', true),
    'grapes': _CropInfo('अंगूर', 'Grapes (Angoor)', 'angoor grapes', true),
    'pea pod/pea cod/हरी मटर': _CropInfo('हरी मटर', 'Green Peas (Matar)', 'matar peas green pea', true),
    'tender coconut': _CropInfo('नारियल (पानी वाला)', 'Tender Coconut', 'nariyal coconut tender', true),
    'plum': _CropInfo('आलूबुखारा / बेर', 'Plum / Ber', 'plum aloo bukhara ber', true),
    'gram raw(chholia)': _CropInfo('हरा चना (छोलिया)', 'Green Chana / Chholia', 'chana chholia gram', true),
  };

  /// Popular crop shortcuts for Crops / Grains category
  static const List<Map<String, String>> popularCrops = [
    {'name': 'ग्वार गम', 'key': 'guar gum', 'icon': '🏭'},
    {'name': 'ग्वार बीज', 'key': 'guar', 'icon': '🌿'},
    {'name': 'मूंगफली', 'key': 'groundnut', 'icon': '🥜'},
    {'name': 'मूंग', 'key': 'moong', 'icon': '🟢'},
    {'name': 'तिल', 'key': 'til', 'icon': '🌰'},
    {'name': 'मोठ', 'key': 'moth', 'icon': '🌾'},
    {'name': 'तारामीरा', 'key': 'taramira', 'icon': '🌱'},
    {'name': 'सरसों/रायड़ा', 'key': 'mustard', 'icon': '🟡'},
    {'name': 'जीरा', 'key': 'jeera', 'icon': '🌿'},
    {'name': 'इसबगोल', 'key': 'isabgul', 'icon': '🌾'},
    {'name': 'सौंफ', 'key': 'soanf', 'icon': '🌿'},
    {'name': 'अजवाइन', 'key': 'ajwain', 'icon': '🌿'},
    {'name': 'कलौंजी', 'key': 'kalonji', 'icon': '🌿'},
    {'name': 'चना', 'key': 'gram', 'icon': '🟤'},
    {'name': 'काबुली चना', 'key': 'kabuli chana', 'icon': '🟤'},
    {'name': 'गेहूं', 'key': 'wheat', 'icon': '🌾'},
    {'name': 'लहसुन', 'key': 'garlic', 'icon': '🧄'},
    {'name': 'सोयाबीन', 'key': 'soyabean', 'icon': '🫘'},
    {'name': 'बाजरा', 'key': 'bajra', 'icon': '🌾'},
    {'name': 'कपास/नरमा', 'key': 'cotton', 'icon': '⚪'},
    {'name': 'धनिया', 'key': 'dhaniya', 'icon': '🌿'},
    {'name': 'मेथी', 'key': 'methi', 'icon': '🌿'},
    {'name': 'प्याज', 'key': 'onion', 'icon': '🧅'},
    {'name': 'आलू', 'key': 'potato', 'icon': '🥔'},
  ];

  /// Popular shortcuts for Vegetables & Fruits category
  static const List<Map<String, String>> popularVegetables = [
    {'name': 'टमाटर', 'key': 'tomato', 'icon': '🍅'},
    {'name': 'हरी मिर्च', 'key': 'green chilli', 'icon': '🌶️'},
    {'name': 'भिंडी', 'key': 'bhindi', 'icon': '🥒'},
    {'name': 'बैंगन', 'key': 'brinjal', 'icon': '🍆'},
    {'name': 'पत्ता गोभी', 'key': 'cabbage', 'icon': '🥬'},
    {'name': 'फूल गोभी', 'key': 'cauliflower', 'icon': '🥦'},
    {'name': 'लौकी', 'key': 'bottle gourd', 'icon': '🥒'},
    {'name': 'करेला', 'key': 'bitter gourd', 'icon': '🥒'},
    {'name': 'खीरा', 'key': 'kheera', 'icon': '🥒'},
    {'name': 'अदरक', 'key': 'ginger', 'icon': '🫚'},
    {'name': 'हरा धनिया', 'key': 'coriander(leaves)', 'icon': '🌿'},
    {'name': 'गाजर', 'key': 'carrot', 'icon': '🥕'},
    {'name': 'तरबूज', 'key': 'water melon', 'icon': '🍉'},
    {'name': 'नींबू', 'key': 'lemon', 'icon': '🍋'},
    {'name': 'अनार', 'key': 'pomegranate', 'icon': '🍎'},
    {'name': 'केला', 'key': 'banana', 'icon': '🍌'},
  ];

  /// Check if commodity is a Vegetable or Fruit
  static bool isVegetableOrFruit(String rawCommodity) {
    final clean = rawCommodity.trim().toLowerCase();
    if (_cropMap.containsKey(clean)) {
      return _cropMap[clean]!.isVegetable;
    }
    for (final entry in _cropMap.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value.isVegetable;
      }
    }
    return clean.contains('vegetable') || clean.contains('fruit');
  }

  /// Get Hindi name for raw API commodity name
  static String getHindiName(String rawCommodity) {
    final clean = rawCommodity.trim().toLowerCase();
    
    if (_cropMap.containsKey(clean)) {
      return _cropMap[clean]!.hindiName;
    }

    for (final entry in _cropMap.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value.hindiName;
      }
    }

    return rawCommodity;
  }

  /// Get English display name
  static String getEnglishName(String rawCommodity) {
    final clean = rawCommodity.trim().toLowerCase();
    if (_cropMap.containsKey(clean)) {
      return _cropMap[clean]!.englishName;
    }
    for (final entry in _cropMap.entries) {
      if (clean.contains(entry.key) || entry.key.contains(clean)) {
        return entry.value.englishName;
      }
    }
    return rawCommodity;
  }

  /// Check if a commodity matches a search query (Hindi, Hinglish, or English)
  static bool matchesSearch(String rawCommodity, String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return true;

    final cleanComm = rawCommodity.trim().toLowerCase();
    
    // Check raw commodity name
    if (cleanComm.contains(cleanQuery)) return true;

    // Check mapped Hindi name, English name, and search keywords
    _CropInfo? info = _cropMap[cleanComm];
    if (info == null) {
      for (final entry in _cropMap.entries) {
        if (cleanComm.contains(entry.key) || entry.key.contains(cleanComm)) {
          info = entry.value;
          break;
        }
      }
    }

    if (info != null) {
      if (info.hindiName.toLowerCase().contains(cleanQuery)) return true;
      if (info.englishName.toLowerCase().contains(cleanQuery)) return true;
      if (info.searchKeywords.contains(cleanQuery)) return true;
    }

    return false;
  }

  /// Maps commodity to built-in crop ID if available for advisory & medicine section
  static String? getCropIdForCommodity(String rawCommodity) {
    final clean = rawCommodity.toLowerCase().trim();
    if (clean.contains('wheat') || clean.contains('gehu')) return 'wheat';
    if (clean.contains('mustard') || clean.contains('rape') || clean.contains('sarson')) return 'mustard';
    if (clean.contains('rice') || clean.contains('paddy') || clean.contains('dhan')) return 'rice';
    if (clean.contains('sugarcane') || clean.contains('ganna')) return 'sugarcane';
    if (clean.contains('cotton') || clean.contains('kapas')) return 'cotton';
    if (clean.contains('moong') || clean.contains('green gram')) return 'moong';
    if (clean.contains('chana') || clean.contains('bengal gram')) return 'chana';
    if (clean.contains('guar') || clean.contains('gawar')) return 'guar';
    if (clean.contains('tomato') || clean.contains('tamatar')) return 'tomato';
    if (clean.contains('chilli') || clean.contains('mirch')) return 'chilli';
    if (clean.contains('garlic') || clean.contains('lahsun')) return 'garlic';
    if (clean.contains('onion') || clean.contains('pyaj')) return 'onion';
    if (clean.contains('potato') || clean.contains('aloo')) return 'potato';
    return null;
  }
}

class _CropInfo {
  final String hindiName;
  final String englishName;
  final String searchKeywords;
  final bool isVegetable;

  const _CropInfo(this.hindiName, this.englishName, this.searchKeywords, this.isVegetable);
}
