class CityLocation {
  final String name;
  final String state;
  final String district;
  final String mandi;
  final double latitude;
  final double longitude;
  final String icon;

  const CityLocation({
    required this.name,
    required this.state,
    this.district = '',
    this.mandi = '',
    required this.latitude,
    required this.longitude,
    this.icon = '📍',
  });

  String get effectiveDistrict {
    if (district.isNotEmpty) return district;
    if (name.contains('(') && name.contains(')')) {
      final inside = name.substring(name.indexOf('(') + 1, name.indexOf(')')).trim();
      return inside;
    }
    return name.split(' ').first.trim();
  }
}

class CityDatabase {
  static const List<CityLocation> popularCities = [
    // --- Rajasthan ---
    CityLocation(name: 'जयपुर (Jaipur)', state: 'Rajasthan', latitude: 26.9124, longitude: 75.7873, icon: '🏰'),
    CityLocation(name: 'जोधपुर (Jodhpur)', state: 'Rajasthan', latitude: 26.2389, longitude: 73.0243, icon: '🏰'),
    CityLocation(name: 'बीकानेर (Bikaner)', state: 'Rajasthan', latitude: 28.0229, longitude: 73.3119, icon: '🏰'),
    CityLocation(name: 'कोटा (Kota)', state: 'Rajasthan', latitude: 25.2138, longitude: 75.8648, icon: '🌾'),
    CityLocation(name: 'उदयपुर (Udaipur)', state: 'Rajasthan', latitude: 24.5854, longitude: 73.7125, icon: '🏰'),
    CityLocation(name: 'नागौर (Nagaur)', state: 'Rajasthan', latitude: 27.2000, longitude: 73.7400, icon: '🌾'),
    CityLocation(name: 'श्रीगंगानगर (Ganganagar)', state: 'Rajasthan', latitude: 29.9038, longitude: 73.8772, icon: '🌾'),
    CityLocation(name: 'अलवर (Alwar)', state: 'Rajasthan', latitude: 27.5530, longitude: 76.6346, icon: '🌾'),
    CityLocation(name: 'सीकर (Sikar)', state: 'Rajasthan', latitude: 27.6100, longitude: 75.1400, icon: '🌾'),
    CityLocation(name: 'भरतपुर (Bharatpur)', state: 'Rajasthan', latitude: 27.2170, longitude: 77.4900, icon: '🌾'),

    // --- Madhya Pradesh ---
    CityLocation(name: 'इंदौर (Indore)', state: 'Madhya Pradesh', latitude: 22.7196, longitude: 75.8577, icon: '🌾'),
    CityLocation(name: 'भोपाल (Bhopal)', state: 'Madhya Pradesh', latitude: 23.2599, longitude: 77.4126, icon: '🏛️'),
    CityLocation(name: 'जबलपुर (Jabalpur)', state: 'Madhya Pradesh', latitude: 23.1815, longitude: 79.9864, icon: '🌾'),
    CityLocation(name: 'ग्वालियर (Gwalior)', state: 'Madhya Pradesh', latitude: 26.2183, longitude: 78.1828, icon: '🏰'),
    CityLocation(name: 'उज्जैन (Ujjain)', state: 'Madhya Pradesh', latitude: 23.1765, longitude: 75.7885, icon: '🛕'),
    CityLocation(name: 'नीमच (Neemuch)', state: 'Madhya Pradesh', latitude: 24.4700, longitude: 74.8700, icon: '🌾'),
    CityLocation(name: 'मंदसौर (Mandsaur)', state: 'Madhya Pradesh', latitude: 24.0700, longitude: 75.0700, icon: '🌾'),
    CityLocation(name: 'रतलाम (Ratlam)', state: 'Madhya Pradesh', latitude: 23.3315, longitude: 75.0367, icon: '🌾'),

    // --- Gujarat ---
    CityLocation(name: 'अहमदाबाद (Ahmedabad)', state: 'Gujarat', latitude: 23.0225, longitude: 72.5714, icon: '🏛️'),
    CityLocation(name: 'राजकोट (Rajkot)', state: 'Gujarat', latitude: 22.3039, longitude: 70.8022, icon: '🌾'),
    CityLocation(name: 'सूरत (Surat)', state: 'Gujarat', latitude: 21.1702, longitude: 72.8311, icon: '🏛️'),
    CityLocation(name: 'उंझा (Unjha)', state: 'Gujarat', latitude: 23.8000, longitude: 72.4000, icon: '🌿'),
    CityLocation(name: 'मेहसाणा (Mehsana)', state: 'Gujarat', latitude: 23.6000, longitude: 72.4000, icon: '🌾'),
    CityLocation(name: 'जामनगर (Jamnagar)', state: 'Gujarat', latitude: 22.4707, longitude: 70.0577, icon: '🌾'),

    // --- Punjab ---
    CityLocation(name: 'अमृतसर (Amritsar)', state: 'Punjab', latitude: 31.6340, longitude: 74.8723, icon: '🛕'),
    CityLocation(name: 'लुधियाना (Ludhiana)', state: 'Punjab', latitude: 30.9010, longitude: 75.8573, icon: '🌾'),
    CityLocation(name: 'जालंधर (Jalandhar)', state: 'Punjab', latitude: 31.3260, longitude: 75.5762, icon: '🌾'),
    CityLocation(name: 'पटियाला (Patiala)', state: 'Punjab', latitude: 30.3398, longitude: 76.3869, icon: '🏰'),
    CityLocation(name: 'बठिंडा (Bathinda)', state: 'Punjab', latitude: 30.2110, longitude: 74.9455, icon: '🌾'),
    CityLocation(name: 'खन्ना (Khanna)', state: 'Punjab', latitude: 30.7000, longitude: 76.2200, icon: '🌾'),

    // --- Haryana ---
    CityLocation(name: 'हिसार (Hisar)', state: 'Haryana', latitude: 29.1492, longitude: 75.7217, icon: '🌾'),
    CityLocation(name: 'करनाल (Karnal)', state: 'Haryana', latitude: 29.6857, longitude: 76.9905, icon: '🌾'),
    CityLocation(name: 'सिरसा (Sirsa)', state: 'Haryana', latitude: 29.5349, longitude: 75.0300, icon: '🌾'),
    CityLocation(name: 'रोहतक (Rohtak)', state: 'Haryana', latitude: 28.8955, longitude: 76.6066, icon: '🌾'),
    CityLocation(name: 'सोनीपत (Sonipat)', state: 'Haryana', latitude: 28.9931, longitude: 77.0151, icon: '🌾'),
    CityLocation(name: 'पानीपत (Panipat)', state: 'Haryana', latitude: 29.3909, longitude: 76.9635, icon: '🌾'),

    // --- Uttar Pradesh ---
    CityLocation(name: 'लखनऊ (Lucknow)', state: 'Uttar Pradesh', latitude: 26.8467, longitude: 80.9462, icon: '🏛️'),
    CityLocation(name: 'आगरा (Agra)', state: 'Uttar Pradesh', latitude: 27.1767, longitude: 78.0081, icon: '🏰'),
    CityLocation(name: 'कानपुर (Kanpur)', state: 'Uttar Pradesh', latitude: 26.4499, longitude: 80.3319, icon: '🌾'),
    CityLocation(name: 'वाराणसी (Varanasi)', state: 'Uttar Pradesh', latitude: 25.3176, longitude: 82.9739, icon: '🛕'),
    CityLocation(name: 'मथुरा (Mathura)', state: 'Uttar Pradesh', latitude: 27.4924, longitude: 77.6737, icon: '🛕'),
    CityLocation(name: 'मेरठ (Meerut)', state: 'Uttar Pradesh', latitude: 28.9845, longitude: 77.7064, icon: '🌾'),
    CityLocation(name: 'बरेली (Bareilly)', state: 'Uttar Pradesh', latitude: 28.3670, longitude: 79.4304, icon: '🌾'),
    CityLocation(name: 'गोरखपुर (Gorakhpur)', state: 'Uttar Pradesh', latitude: 26.7606, longitude: 83.3732, icon: '🌾'),

    // --- Maharashtra ---
    CityLocation(name: 'मुंबई (Mumbai)', state: 'Maharashtra', latitude: 19.0760, longitude: 72.8777, icon: '🏛️'),
    CityLocation(name: 'पुणे (Pune)', state: 'Maharashtra', latitude: 18.5204, longitude: 73.8567, icon: '🏛️'),
    CityLocation(name: 'नासिक (Nashik)', state: 'Maharashtra', latitude: 20.0063, longitude: 73.7935, icon: '🌾'),
    CityLocation(name: 'नागपुर (Nagpur)', state: 'Maharashtra', latitude: 21.1458, longitude: 79.0882, icon: '🏛️'),
    CityLocation(name: 'सोलापुर (Solapur)', state: 'Maharashtra', latitude: 17.6599, longitude: 75.9064, icon: '🌾'),
    CityLocation(name: 'कोल्हापुर (Kolhapur)', state: 'Maharashtra', latitude: 16.7050, longitude: 74.2433, icon: '🌾'),
    CityLocation(name: 'लातूर (Latur)', state: 'Maharashtra', latitude: 18.4088, longitude: 76.5604, icon: '🌾'),

    // --- Karnataka ---
    CityLocation(name: 'बेंगलुरु (Bengaluru)', state: 'Karnataka', latitude: 12.9716, longitude: 77.5946, icon: '🏛️'),
    CityLocation(name: 'हुबली (Hubli)', state: 'Karnataka', latitude: 15.3647, longitude: 75.1240, icon: '🌾'),
    CityLocation(name: 'मैसूरू (Mysuru)', state: 'Karnataka', latitude: 12.2958, longitude: 76.6394, icon: '🏰'),
    CityLocation(name: 'गुलबर्गा (Gulbarga)', state: 'Karnataka', latitude: 17.3297, longitude: 76.8343, icon: '🌾'),
    CityLocation(name: 'बेलगाम (Belgaum)', state: 'Karnataka', latitude: 15.8497, longitude: 74.4977, icon: '🌾'),
    CityLocation(name: 'दावणगेरे (Davangere)', state: 'Karnataka', latitude: 14.4644, longitude: 75.9218, icon: '🌾'),

    // --- Tamil Nadu ---
    CityLocation(name: 'चेन्नई (Chennai)', state: 'Tamil Nadu', latitude: 13.0827, longitude: 80.2707, icon: '🏛️'),
    CityLocation(name: 'कोयंबटूर (Coimbatore)', state: 'Tamil Nadu', latitude: 11.0168, longitude: 76.9558, icon: '🌾'),
    CityLocation(name: 'मदुरई (Madurai)', state: 'Tamil Nadu', latitude: 9.9252, longitude: 78.1198, icon: '🛕'),
    CityLocation(name: 'सेलम (Salem)', state: 'Tamil Nadu', latitude: 11.6643, longitude: 78.1460, icon: '🌾'),
    CityLocation(name: 'तंजावूर (Thanjavur)', state: 'Tamil Nadu', latitude: 10.7870, longitude: 79.1378, icon: '🛕'),

    // --- Andhra Pradesh ---
    CityLocation(name: 'गुंटूर (Guntur)', state: 'Andhra Pradesh', latitude: 16.3067, longitude: 80.4365, icon: '🌾'),
    CityLocation(name: 'विजयवाड़ा (Vijayawada)', state: 'Andhra Pradesh', latitude: 16.5062, longitude: 80.6480, icon: '🌾'),
    CityLocation(name: 'कुर्नूल (Kurnool)', state: 'Andhra Pradesh', latitude: 15.8281, longitude: 78.0373, icon: '🌾'),
    CityLocation(name: 'विशाखापट्टनम (Visakhapatnam)', state: 'Andhra Pradesh', latitude: 17.6868, longitude: 83.2185, icon: '🏛️'),
    CityLocation(name: 'तिरुपति (Tirupati)', state: 'Andhra Pradesh', latitude: 13.6288, longitude: 79.4192, icon: '🛕'),

    // --- Telangana ---
    CityLocation(name: 'हैदराबाद (Hyderabad)', state: 'Telangana', latitude: 17.3850, longitude: 78.4867, icon: '🏛️'),
    CityLocation(name: 'वारंगल (Warangal)', state: 'Telangana', latitude: 17.9784, longitude: 79.5941, icon: '🌾'),
    CityLocation(name: 'करीमनगर (Karimnagar)', state: 'Telangana', latitude: 18.4386, longitude: 79.1288, icon: '🌾'),
    CityLocation(name: 'निज़ामाबाद (Nizamabad)', state: 'Telangana', latitude: 18.6725, longitude: 78.0940, icon: '🌾'),

    // --- Bihar ---
    CityLocation(name: 'पटना (Patna)', state: 'Bihar', latitude: 25.6093, longitude: 85.1376, icon: '🏛️'),
    CityLocation(name: 'मुज़फ़्फ़रपुर (Muzaffarpur)', state: 'Bihar', latitude: 26.1209, longitude: 85.3647, icon: '🌾'),
    CityLocation(name: 'गया (Gaya)', state: 'Bihar', latitude: 24.7955, longitude: 84.9994, icon: '🛕'),
    CityLocation(name: 'भागलपुर (Bhagalpur)', state: 'Bihar', latitude: 25.2425, longitude: 86.9842, icon: '🌾'),

    // --- West Bengal ---
    CityLocation(name: 'कोलकाता (Kolkata)', state: 'West Bengal', latitude: 22.5726, longitude: 88.3639, icon: '🏛️'),
    CityLocation(name: 'बर्धमान (Bardhaman)', state: 'West Bengal', latitude: 23.2332, longitude: 87.8615, icon: '🌾'),
    CityLocation(name: 'सिलीगुड़ी (Siliguri)', state: 'West Bengal', latitude: 26.7271, longitude: 88.3953, icon: '🌾'),

    // --- Odisha ---
    CityLocation(name: 'भुवनेश्वर (Bhubaneswar)', state: 'Odisha', latitude: 20.2961, longitude: 85.8245, icon: '🏛️'),
    CityLocation(name: 'संबलपुर (Sambalpur)', state: 'Odisha', latitude: 21.4669, longitude: 83.9812, icon: '🌾'),

    // --- Chhattisgarh ---
    CityLocation(name: 'रायपुर (Raipur)', state: 'Chhattisgarh', latitude: 21.2514, longitude: 81.6296, icon: '🏛️'),
    CityLocation(name: 'बिलासपुर (Bilaspur)', state: 'Chhattisgarh', latitude: 22.0797, longitude: 82.1391, icon: '🌾'),

    // --- Jharkhand ---
    CityLocation(name: 'रांची (Ranchi)', state: 'Jharkhand', latitude: 23.3441, longitude: 85.3096, icon: '🏛️'),
    CityLocation(name: 'धनबाद (Dhanbad)', state: 'Jharkhand', latitude: 23.7957, longitude: 86.4304, icon: '🌾'),

    // --- Uttarakhand ---
    CityLocation(name: 'देहरादून (Dehradun)', state: 'Uttarakhand', latitude: 30.3165, longitude: 78.0322, icon: '🏛️'),
    CityLocation(name: 'हरिद्वार (Haridwar)', state: 'Uttarakhand', latitude: 29.9457, longitude: 78.1642, icon: '🛕'),
    CityLocation(name: 'हल्द्वानी (Haldwani)', state: 'Uttarakhand', latitude: 29.2183, longitude: 79.5130, icon: '🌾'),

    // --- Himachal Pradesh ---
    CityLocation(name: 'शिमला (Shimla)', state: 'Himachal Pradesh', latitude: 31.1048, longitude: 77.1734, icon: '🏔️'),
    CityLocation(name: 'मंडी (Mandi)', state: 'Himachal Pradesh', latitude: 31.7086, longitude: 76.9313, icon: '🌾'),

    // --- Delhi / NCR ---
    CityLocation(name: 'दिल्ली (Delhi)', state: 'Delhi', latitude: 28.6139, longitude: 77.2090, icon: '🏛️'),

    // --- Assam ---
    CityLocation(name: 'गुवाहाटी (Guwahati)', state: 'Assam', latitude: 26.1445, longitude: 91.7362, icon: '🏛️'),
    CityLocation(name: 'डिब्रूगढ़ (Dibrugarh)', state: 'Assam', latitude: 27.4728, longitude: 94.9120, icon: '🌾'),

    // --- Kerala ---
    CityLocation(name: 'कोच्चि (Kochi)', state: 'Kerala', latitude: 9.9312, longitude: 76.2673, icon: '🏛️'),
    CityLocation(name: 'पालक्काड (Palakkad)', state: 'Kerala', latitude: 10.7867, longitude: 76.6548, icon: '🌾'),
  ];
}
