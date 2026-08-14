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
    // --- Rajasthan (Jaipur Region) ---
    CityLocation(name: 'जयपुर (Jaipur)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Jaipur (Grain) APMC', latitude: 26.9124, longitude: 75.7873, icon: '🏰'),
    CityLocation(name: 'चौमू (Chomu)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Chomu APMC', latitude: 27.1687, longitude: 75.7208, icon: '🌾'),
    CityLocation(name: 'बस्सी (Bassi)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Bassi APMC', latitude: 26.8300, longitude: 76.0400, icon: '🌾'),
    CityLocation(name: 'चाकसू (Chaksu)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Chaksu APMC', latitude: 26.6000, longitude: 75.9500, icon: '🌾'),
    CityLocation(name: 'कोटपूतली (Kotputli)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Kotputli APMC', latitude: 27.7000, longitude: 76.2000, icon: '🌾'),
    CityLocation(name: 'सांभर लेक (Sambhar Lake)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Sambhar Lake APMC', latitude: 26.9100, longitude: 75.2000, icon: '🌾'),
    CityLocation(name: 'शाहपुरा (Shahpura)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Shahpura APMC', latitude: 27.3900, longitude: 75.9600, icon: '🌾'),
    CityLocation(name: 'दूदू (Dudu)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Dudu APMC', latitude: 26.6800, longitude: 75.2300, icon: '🌾'),
    CityLocation(name: 'जोबनेर (Jobner)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Jobner APMC', latitude: 26.9700, longitude: 75.3800, icon: '🌾'),
    CityLocation(name: 'बगरू (Bagru)', state: 'Rajasthan', district: 'Jaipur', mandi: 'Jaipur (Grain) APMC', latitude: 26.8100, longitude: 75.5400, icon: '🌾'),

    // --- Rajasthan (Jodhpur Region) ---
    CityLocation(name: 'मथानिया (Mathania)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Mathania APMC', latitude: 26.5312, longitude: 73.0232, icon: '🌶️'),
    CityLocation(name: 'जोधपुर (Jodhpur)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Jodhpur (Grain) APMC', latitude: 26.2389, longitude: 73.0243, icon: '🏰'),
    CityLocation(name: 'ओसियां (Osian)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Osian APMC', latitude: 26.7262, longitude: 72.9069, icon: '🛕'),
    CityLocation(name: 'बिलाड़ा (Bilara)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Bilara APMC', latitude: 26.1814, longitude: 73.7077, icon: '🌾'),
    CityLocation(name: 'फलोदी (Phalodi)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Phalodi APMC', latitude: 27.1311, longitude: 72.3664, icon: '🌾'),
    CityLocation(name: 'पीपाड़ शहर (Pipar City)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Pipar City APMC', latitude: 26.3900, longitude: 73.5400, icon: '🌾'),
    CityLocation(name: 'भोपालगढ़ (Bhopalgarh)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Bhopalgarh APMC', latitude: 26.6500, longitude: 73.4500, icon: '🌾'),
    CityLocation(name: 'बालेसर (Balesar)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Balesar APMC', latitude: 26.4000, longitude: 72.4500, icon: '🌾'),
    CityLocation(name: 'लूणी (Luni)', state: 'Rajasthan', district: 'Jodhpur', mandi: 'Luni APMC', latitude: 26.0400, longitude: 73.0800, icon: '🌾'),

    // --- Rajasthan (Other Major Districts) ---
    CityLocation(name: 'बीकानेर (Bikaner)', state: 'Rajasthan', district: 'Bikaner', mandi: 'Bikaner (Grain) APMC', latitude: 28.0229, longitude: 73.3119, icon: '🏰'),
    CityLocation(name: 'नोखा (Nokha)', state: 'Rajasthan', district: 'Bikaner', mandi: 'Nokha APMC', latitude: 27.6027, longitude: 73.4247, icon: '🌾'),
    CityLocation(name: 'श्रीडूंगरगढ़ (Sridungargarh)', state: 'Rajasthan', district: 'Bikaner', mandi: 'Sridungargarh APMC', latitude: 28.1060, longitude: 74.0040, icon: '🌾'),
    CityLocation(name: 'नागौर (Nagaur)', state: 'Rajasthan', district: 'Nagaur', mandi: 'Nagaur APMC', latitude: 27.2000, longitude: 73.7400, icon: '🌾'),
    CityLocation(name: 'मेड़ता सिटी (Merta City)', state: 'Rajasthan', district: 'Nagaur', mandi: 'Merta City APMC', latitude: 26.6500, longitude: 74.0300, icon: '🌾'),
    CityLocation(name: 'कोटा (Kota)', state: 'Rajasthan', district: 'Kota', mandi: 'Kota APMC', latitude: 25.2138, longitude: 75.8648, icon: '🌾'),
    CityLocation(name: 'रामगंज मंडी (Ramganjmandi)', state: 'Rajasthan', district: 'Kota', mandi: 'Ramganjmandi APMC', latitude: 24.6468, longitude: 75.9452, icon: '🌿'),
    CityLocation(name: 'सीकर (Sikar)', state: 'Rajasthan', district: 'Sikar', mandi: 'Sikar APMC', latitude: 27.6100, longitude: 75.1400, icon: '🌾'),
    CityLocation(name: 'नीमकाथाना (Neem Ka Thana)', state: 'Rajasthan', district: 'Sikar', mandi: 'Neem Ka Thana APMC', latitude: 27.7389, longitude: 75.7831, icon: '🌾'),
    CityLocation(name: 'अलवर (Alwar)', state: 'Rajasthan', district: 'Alwar', mandi: 'Alwar APMC', latitude: 27.5530, longitude: 76.6346, icon: '🌾'),
    CityLocation(name: 'खैरथल (Khairthal)', state: 'Rajasthan', district: 'Alwar', mandi: 'Khairthal APMC', latitude: 27.8000, longitude: 76.6300, icon: '🌾'),
    CityLocation(name: 'अजमेर (Ajmer)', state: 'Rajasthan', district: 'Ajmer', mandi: 'Ajmer APMC', latitude: 26.4499, longitude: 74.6399, icon: '🏰'),
    CityLocation(name: 'ब्यावर (Beawar)', state: 'Rajasthan', district: 'Ajmer', mandi: 'Beawar APMC', latitude: 26.1011, longitude: 74.3217, icon: '🌾'),
    CityLocation(name: 'श्रीगंगानगर (Ganganagar)', state: 'Rajasthan', district: 'Ganganagar', mandi: 'Sriganganagar (Grain) APMC', latitude: 29.9038, longitude: 73.8772, icon: '🌾'),
    CityLocation(name: 'सूरतगढ़ (Suratgarh)', state: 'Rajasthan', district: 'Ganganagar', mandi: 'Suratgarh APMC', latitude: 29.3204, longitude: 73.9014, icon: '🌾'),
    CityLocation(name: 'हनुमानगढ़ (Hanumangarh)', state: 'Rajasthan', district: 'Hanumangarh', mandi: 'Hanumangarh Town APMC', latitude: 29.5800, longitude: 74.3200, icon: '🌾'),
    CityLocation(name: 'उदयपुर (Udaipur)', state: 'Rajasthan', district: 'Udaipur', mandi: 'Udaipur (Grain) APMC', latitude: 24.5854, longitude: 73.7125, icon: '🏰'),
    CityLocation(name: 'पाली (Pali)', state: 'Rajasthan', district: 'Pali', mandi: 'Pali APMC', latitude: 25.7711, longitude: 73.3234, icon: '🌾'),
    CityLocation(name: 'सुमेरपुर (Sumerpur)', state: 'Rajasthan', district: 'Pali', mandi: 'Sumerpur APMC', latitude: 25.1524, longitude: 73.0827, icon: '🌾'),
    CityLocation(name: 'बाड़मेर (Barmer)', state: 'Rajasthan', district: 'Barmer', mandi: 'Barmer APMC', latitude: 25.7521, longitude: 71.3967, icon: '🌾'),
    CityLocation(name: 'बालोतरा (Balotra)', state: 'Rajasthan', district: 'Barmer', mandi: 'Balotra APMC', latitude: 25.8344, longitude: 72.2417, icon: '🌾'),
    CityLocation(name: 'भरतपुर (Bharatpur)', state: 'Rajasthan', district: 'Bharatpur', mandi: 'Bharatpur APMC', latitude: 27.2170, longitude: 77.4900, icon: '🌾'),
    CityLocation(name: 'भीलवाड़ा (Bhilwara)', state: 'Rajasthan', district: 'Bhilwara', mandi: 'Bhilwara APMC', latitude: 25.3407, longitude: 74.6313, icon: '🌾'),
    CityLocation(name: 'चित्तौड़गढ़ (Chittorgarh)', state: 'Rajasthan', district: 'Chittorgarh', mandi: 'Chittorgarh APMC', latitude: 24.8887, longitude: 74.6269, icon: '🏰'),
    CityLocation(name: 'झालावाड़ (Jhalawar)', state: 'Rajasthan', district: 'Jhalawar', mandi: 'Jhalawar APMC', latitude: 24.5973, longitude: 76.1610, icon: '🍊'),
    CityLocation(name: 'भवानी मंडी (Bhawani Mandi)', state: 'Rajasthan', district: 'Jhalawar', mandi: 'Bhawani Mandi APMC', latitude: 24.4172, longitude: 75.8336, icon: '🌾'),
    CityLocation(name: 'भरतपुर (Bharatpur)', state: 'Rajasthan', district: 'Bharatpur', mandi: 'Bharatpur APMC', latitude: 27.2170, longitude: 77.4900, icon: '🌾'),
    CityLocation(name: 'बाड़मेर (Barmer)', state: 'Rajasthan', district: 'Barmer', mandi: 'Barmer APMC', latitude: 25.7521, longitude: 71.3967, icon: '🌾'),
    CityLocation(name: 'बालोतरा (Balotra)', state: 'Rajasthan', district: 'Barmer', mandi: 'Balotra APMC', latitude: 25.8344, longitude: 72.2417, icon: '🌾'),
    CityLocation(name: 'अजमेर (Ajmer)', state: 'Rajasthan', district: 'Ajmer', mandi: 'Ajmer APMC', latitude: 26.4499, longitude: 74.6399, icon: '🏰'),
    CityLocation(name: 'ब्यावर (Beawar)', state: 'Rajasthan', district: 'Ajmer', mandi: 'Beawar APMC', latitude: 26.1011, longitude: 74.3217, icon: '🌾'),
    CityLocation(name: 'भीलवाड़ा (Bhilwara)', state: 'Rajasthan', district: 'Bhilwara', mandi: 'Bhilwara APMC', latitude: 25.3407, longitude: 74.6313, icon: '🌾'),
    CityLocation(name: 'चित्तौड़गढ़ (Chittorgarh)', state: 'Rajasthan', district: 'Chittorgarh', mandi: 'Chittorgarh APMC', latitude: 24.8887, longitude: 74.6269, icon: '🏰'),
    CityLocation(name: 'झालावाड़ (Jhalawar)', state: 'Rajasthan', district: 'Jhalawar', mandi: 'Jhalawar APMC', latitude: 24.5973, longitude: 76.1610, icon: '🍊'),
    CityLocation(name: 'भवानी मंडी (Bhawani Mandi)', state: 'Rajasthan', district: 'Jhalawar', mandi: 'Bhawani Mandi APMC', latitude: 24.4172, longitude: 75.8336, icon: '🌾'),

    // --- Madhya Pradesh ---
    CityLocation(name: 'इंदौर (Indore)', state: 'Madhya Pradesh', district: 'Indore', mandi: 'Indore (Grain) APMC', latitude: 22.7196, longitude: 75.8577, icon: '🌾'),
    CityLocation(name: 'भोपाल (Bhopal)', state: 'Madhya Pradesh', district: 'Bhopal', mandi: 'Bhopal (Karond) APMC', latitude: 23.2599, longitude: 77.4126, icon: '🏛️'),
    CityLocation(name: 'जबलपुर (Jabalpur)', state: 'Madhya Pradesh', district: 'Jabalpur', mandi: 'Jabalpur APMC', latitude: 23.1815, longitude: 79.9864, icon: '🌾'),
    CityLocation(name: 'ग्वालियर (Gwalior)', state: 'Madhya Pradesh', district: 'Gwalior', mandi: 'Gwalior (Lashkar) APMC', latitude: 26.2183, longitude: 78.1828, icon: '🏰'),
    CityLocation(name: 'उज्जैन (Ujjain)', state: 'Madhya Pradesh', district: 'Ujjain', mandi: 'Ujjain APMC', latitude: 23.1765, longitude: 75.7885, icon: '🛕'),
    CityLocation(name: 'नीमच (Neemuch)', state: 'Madhya Pradesh', district: 'Neemuch', mandi: 'Neemuch APMC', latitude: 24.4700, longitude: 74.8700, icon: '🌾'),
    CityLocation(name: 'मंदसौर (Mandsaur)', state: 'Madhya Pradesh', district: 'Mandsaur', mandi: 'Mandsaur APMC', latitude: 24.0700, longitude: 75.0700, icon: '🌾'),
    CityLocation(name: 'रतलाम (Ratlam)', state: 'Madhya Pradesh', district: 'Ratlam', mandi: 'Ratlam APMC', latitude: 23.3315, longitude: 75.0367, icon: '🌾'),

    // --- Gujarat ---
    CityLocation(name: 'अहमदाबाद (Ahmedabad)', state: 'Gujarat', district: 'Ahmedabad', mandi: 'Ahmedabad (Jamalpur) APMC', latitude: 23.0225, longitude: 72.5714, icon: '🏛️'),
    CityLocation(name: 'राजकोट (Rajkot)', state: 'Gujarat', district: 'Rajkot', mandi: 'Rajkot APMC', latitude: 22.3039, longitude: 70.8022, icon: '🌾'),
    CityLocation(name: 'सूरत (Surat)', state: 'Gujarat', district: 'Surat', mandi: 'Surat APMC', latitude: 21.1702, longitude: 72.8311, icon: '🏛️'),
    CityLocation(name: 'उंझा (Unjha)', state: 'Gujarat', district: 'Mehsana', mandi: 'Unjha APMC', latitude: 23.8000, longitude: 72.4000, icon: '🌿'),
    CityLocation(name: 'मेहसाणा (Mehsana)', state: 'Gujarat', district: 'Mehsana', mandi: 'Mehsana APMC', latitude: 23.6000, longitude: 72.4000, icon: '🌾'),
    CityLocation(name: 'जामनगर (Jamnagar)', state: 'Gujarat', district: 'Jamnagar', mandi: 'Jamnagar APMC', latitude: 22.4707, longitude: 70.0577, icon: '🌾'),

    // --- Punjab ---
    CityLocation(name: 'अमृतसर (Amritsar)', state: 'Punjab', district: 'Amritsar', mandi: 'Amritsar APMC', latitude: 31.6340, longitude: 74.8723, icon: '🛕'),
    CityLocation(name: 'लुधियाना (Ludhiana)', state: 'Punjab', district: 'Ludhiana', mandi: 'Ludhiana (Grain) APMC', latitude: 30.9010, longitude: 75.8573, icon: '🌾'),
    CityLocation(name: 'खन्ना (Khanna)', state: 'Punjab', district: 'Ludhiana', mandi: 'Khanna APMC', latitude: 30.7000, longitude: 76.2200, icon: '🌾'),
    CityLocation(name: 'जालंधर (Jalandhar)', state: 'Punjab', district: 'Jalandhar', mandi: 'Jalandhar APMC', latitude: 31.3260, longitude: 75.5762, icon: '🌾'),
    CityLocation(name: 'पटियाला (Patiala)', state: 'Punjab', district: 'Patiala', mandi: 'Patiala APMC', latitude: 30.3398, longitude: 76.3869, icon: '🏰'),
    CityLocation(name: 'बठिंडा (Bathinda)', state: 'Punjab', district: 'Bathinda', mandi: 'Bathinda APMC', latitude: 30.2110, longitude: 74.9455, icon: '🌾'),

    // --- Haryana ---
    CityLocation(name: 'हिसार (Hisar)', state: 'Haryana', district: 'Hisar', mandi: 'Hisar APMC', latitude: 29.1492, longitude: 75.7217, icon: '🌾'),
    CityLocation(name: 'करनाल (Karnal)', state: 'Haryana', district: 'Karnal', mandi: 'Karnal APMC', latitude: 29.6857, longitude: 76.9905, icon: '🌾'),
    CityLocation(name: 'सिरसा (Sirsa)', state: 'Haryana', district: 'Sirsa', mandi: 'Sirsa APMC', latitude: 29.5349, longitude: 75.0300, icon: '🌾'),
    CityLocation(name: 'रोहतक (Rohtak)', state: 'Haryana', district: 'Rohtak', mandi: 'Rohtak APMC', latitude: 28.8955, longitude: 76.6066, icon: '🌾'),
    CityLocation(name: 'सोनीपत (Sonipat)', state: 'Haryana', district: 'Sonipat', mandi: 'Sonipat APMC', latitude: 28.9931, longitude: 77.0151, icon: '🌾'),
    CityLocation(name: 'पानीपत (Panipat)', state: 'Haryana', district: 'Panipat', mandi: 'Panipat APMC', latitude: 29.3909, longitude: 76.9635, icon: '🌾'),

    // --- Uttar Pradesh ---
    CityLocation(name: 'लखनऊ (Lucknow)', state: 'Uttar Pradesh', district: 'Lucknow', mandi: 'Lucknow APMC', latitude: 26.8467, longitude: 80.9462, icon: '🏛️'),
    CityLocation(name: 'आगरा (Agra)', state: 'Uttar Pradesh', district: 'Agra', mandi: 'Agra APMC', latitude: 27.1767, longitude: 78.0081, icon: '🏰'),
    CityLocation(name: 'कानपुर (Kanpur)', state: 'Uttar Pradesh', district: 'Kanpur', mandi: 'Kanpur (Grain) APMC', latitude: 26.4499, longitude: 80.3319, icon: '🌾'),
    CityLocation(name: 'वाराणसी (Varanasi)', state: 'Uttar Pradesh', district: 'Varanasi', mandi: 'Varanasi APMC', latitude: 25.3176, longitude: 82.9739, icon: '🛕'),
    CityLocation(name: 'मथुरा (Mathura)', state: 'Uttar Pradesh', district: 'Mathura', mandi: 'Mathura APMC', latitude: 27.4924, longitude: 77.6737, icon: '🛕'),
    CityLocation(name: 'मेरठ (Meerut)', state: 'Uttar Pradesh', district: 'Meerut', mandi: 'Meerut APMC', latitude: 28.9845, longitude: 77.7064, icon: '🌾'),
    CityLocation(name: 'बरेली (Bareilly)', state: 'Uttar Pradesh', district: 'Bareilly', mandi: 'Bareilly APMC', latitude: 28.3670, longitude: 79.4304, icon: '🌾'),
    CityLocation(name: 'गोरखपुर (Gorakhpur)', state: 'Uttar Pradesh', district: 'Gorakhpur', mandi: 'Gorakhpur APMC', latitude: 26.7606, longitude: 83.3732, icon: '🌾'),

    // --- Maharashtra ---
    CityLocation(name: 'मुंबई (Mumbai)', state: 'Maharashtra', district: 'Mumbai', mandi: 'Vashi APMC', latitude: 19.0760, longitude: 72.8777, icon: '🏛️'),
    CityLocation(name: 'पुणे (Pune)', state: 'Maharashtra', district: 'Pune', mandi: 'Pune (Market Yard) APMC', latitude: 18.5204, longitude: 73.8567, icon: '🏛️'),
    CityLocation(name: 'नासिक (Nashik)', state: 'Maharashtra', district: 'Nashik', mandi: 'Nashik APMC', latitude: 20.0063, longitude: 73.7935, icon: '🌾'),
    CityLocation(name: 'नागपुर (Nagpur)', state: 'Maharashtra', district: 'Nagpur', mandi: 'Nagpur APMC', latitude: 21.1458, longitude: 79.0882, icon: '🏛️'),
    CityLocation(name: 'सोलापुर (Solapur)', state: 'Maharashtra', district: 'Solapur', mandi: 'Solapur APMC', latitude: 17.6599, longitude: 75.9064, icon: '🌾'),
    CityLocation(name: 'कोल्हापुर (Kolhapur)', state: 'Maharashtra', district: 'Kolhapur', mandi: 'Kolhapur APMC', latitude: 16.7050, longitude: 74.2433, icon: '🌾'),
    CityLocation(name: 'लातूर (Latur)', state: 'Maharashtra', district: 'Latur', mandi: 'Latur APMC', latitude: 18.4088, longitude: 76.5604, icon: '🌾'),

    // --- Karnataka ---
    CityLocation(name: 'बेंगलुरु (Bengaluru)', state: 'Karnataka', district: 'Bengaluru', mandi: 'Bengaluru (Yeshwanthpur) APMC', latitude: 12.9716, longitude: 77.5946, icon: '🏛️'),
    CityLocation(name: 'हुबली (Hubli)', state: 'Karnataka', district: 'Hubli-Dharwad', mandi: 'Hubli APMC', latitude: 15.3647, longitude: 75.1240, icon: '🌾'),
    CityLocation(name: 'मैसूरू (Mysuru)', state: 'Karnataka', district: 'Mysuru', mandi: 'Mysuru APMC', latitude: 12.2958, longitude: 76.6394, icon: '🏰'),
    CityLocation(name: 'गुलबर्गा (Gulbarga)', state: 'Karnataka', district: 'Gulbarga', mandi: 'Gulbarga APMC', latitude: 17.3297, longitude: 76.8343, icon: '🌾'),
    CityLocation(name: 'बेलगाम (Belgaum)', state: 'Karnataka', district: 'Belgaum', mandi: 'Belgaum APMC', latitude: 15.8497, longitude: 74.4977, icon: '🌾'),
    CityLocation(name: 'दावणगेरे (Davangere)', state: 'Karnataka', district: 'Davangere', mandi: 'Davangere APMC', latitude: 14.4644, longitude: 75.9218, icon: '🌾'),

    // --- Tamil Nadu ---
    CityLocation(name: 'चेन्नई (Chennai)', state: 'Tamil Nadu', district: 'Chennai', mandi: 'Chennai (Koyambedu) APMC', latitude: 13.0827, longitude: 80.2707, icon: '🏛️'),
    CityLocation(name: 'कोयंबटूर (Coimbatore)', state: 'Tamil Nadu', district: 'Coimbatore', mandi: 'Coimbatore APMC', latitude: 11.0168, longitude: 76.9558, icon: '🌾'),
    CityLocation(name: 'मदुरई (Madurai)', state: 'Tamil Nadu', district: 'Madurai', mandi: 'Madurai APMC', latitude: 9.9252, longitude: 78.1198, icon: '🛕'),
    CityLocation(name: 'सेलम (Salem)', state: 'Tamil Nadu', district: 'Salem', mandi: 'Salem APMC', latitude: 11.6643, longitude: 78.1460, icon: '🌾'),
    CityLocation(name: 'तंजावूर (Thanjavur)', state: 'Tamil Nadu', district: 'Thanjavur', mandi: 'Thanjavur APMC', latitude: 10.7870, longitude: 79.1378, icon: '🛕'),

    // --- Andhra Pradesh ---
    CityLocation(name: 'गुंटूर (Guntur)', state: 'Andhra Pradesh', district: 'Guntur', mandi: 'Guntur APMC', latitude: 16.3067, longitude: 80.4365, icon: '🌾'),
    CityLocation(name: 'विजयवाड़ा (Vijayawada)', state: 'Andhra Pradesh', district: 'Krishna', mandi: 'Vijayawada APMC', latitude: 16.5062, longitude: 80.6480, icon: '🌾'),
    CityLocation(name: 'कुर्नूल (Kurnool)', state: 'Andhra Pradesh', district: 'Kurnool', mandi: 'Kurnool APMC', latitude: 15.8281, longitude: 78.0373, icon: '🌾'),
    CityLocation(name: 'विशाखापट्टनम (Visakhapatnam)', state: 'Andhra Pradesh', district: 'Visakhapatnam', mandi: 'Visakhapatnam APMC', latitude: 17.6868, longitude: 83.2185, icon: '🏛️'),
    CityLocation(name: 'तिरुपति (Tirupati)', state: 'Andhra Pradesh', district: 'Chittoor', mandi: 'Tirupati APMC', latitude: 13.6288, longitude: 79.4192, icon: '🛕'),

    // --- Telangana ---
    CityLocation(name: 'हैदराबाद (Hyderabad)', state: 'Telangana', district: 'Hyderabad', mandi: 'Hyderabad (Bowenpally) APMC', latitude: 17.3850, longitude: 78.4867, icon: '🏛️'),
    CityLocation(name: 'वारंगल (Warangal)', state: 'Telangana', district: 'Warangal', mandi: 'Warangal APMC', latitude: 17.9784, longitude: 79.5941, icon: '🌾'),
    CityLocation(name: 'करीमनगर (Karimnagar)', state: 'Telangana', district: 'Karimnagar', mandi: 'Karimnagar APMC', latitude: 18.4386, longitude: 79.1288, icon: '🌾'),
    CityLocation(name: 'निज़ामाबाद (Nizamabad)', state: 'Telangana', district: 'Nizamabad', mandi: 'Nizamabad APMC', latitude: 18.6725, longitude: 78.0940, icon: '🌾'),

    // --- Bihar ---
    CityLocation(name: 'पटना (Patna)', state: 'Bihar', district: 'Patna', mandi: 'Patna APMC', latitude: 25.6093, longitude: 85.1376, icon: '🏛️'),
    CityLocation(name: 'मुज़फ़्फ़रपुर (Muzaffarpur)', state: 'Bihar', district: 'Muzaffarpur', mandi: 'Muzaffarpur APMC', latitude: 26.1209, longitude: 85.3647, icon: '🌾'),
    CityLocation(name: 'गया (Gaya)', state: 'Bihar', district: 'Gaya', mandi: 'Gaya APMC', latitude: 24.7955, longitude: 84.9994, icon: '🛕'),
    CityLocation(name: 'भागलपुर (Bhagalpur)', state: 'Bihar', district: 'Bhagalpur', mandi: 'Bhagalpur APMC', latitude: 25.2425, longitude: 86.9842, icon: '🌾'),

    // --- West Bengal ---
    CityLocation(name: 'कोलकाता (Kolkata)', state: 'West Bengal', district: 'Kolkata', mandi: 'Kolkata (Koley Market) APMC', latitude: 22.5726, longitude: 88.3639, icon: '🏛️'),
    CityLocation(name: 'बर्धमान (Bardhaman)', state: 'West Bengal', district: 'Bardhaman', mandi: 'Bardhaman APMC', latitude: 23.2332, longitude: 87.8615, icon: '🌾'),
    CityLocation(name: 'सिलीगुड़ी (Siliguri)', state: 'West Bengal', district: 'Siliguri', mandi: 'Siliguri APMC', latitude: 26.7271, longitude: 88.3953, icon: '🌾'),

    // --- Odisha ---
    CityLocation(name: 'भुवनेश्वर (Bhubaneswar)', state: 'Odisha', district: 'Bhubaneswar', mandi: 'Bhubaneswar APMC', latitude: 20.2961, longitude: 85.8245, icon: '🏛️'),
    CityLocation(name: 'संबलपुर (Sambalpur)', state: 'Odisha', district: 'Sambalpur', mandi: 'Sambalpur APMC', latitude: 21.4669, longitude: 83.9812, icon: '🌾'),

    // --- Chhattisgarh ---
    CityLocation(name: 'रायपुर (Raipur)', state: 'Chhattisgarh', district: 'Raipur', mandi: 'Raipur APMC', latitude: 21.2514, longitude: 81.6296, icon: '🏛️'),
    CityLocation(name: 'बिलासपुर (Bilaspur)', state: 'Chhattisgarh', district: 'Bilaspur', mandi: 'Bilaspur APMC', latitude: 22.0797, longitude: 82.1391, icon: '🌾'),

    // --- Jharkhand ---
    CityLocation(name: 'रांची (Ranchi)', state: 'Jharkhand', district: 'Ranchi', mandi: 'Ranchi APMC', latitude: 23.3441, longitude: 85.3096, icon: '🏛️'),
    CityLocation(name: 'धनबाद (Dhanbad)', state: 'Jharkhand', district: 'Dhanbad', mandi: 'Dhanbad APMC', latitude: 23.7957, longitude: 86.4304, icon: '🌾'),

    // --- Uttarakhand ---
    CityLocation(name: 'देहरादून (Dehradun)', state: 'Uttarakhand', district: 'Dehradun', mandi: 'Dehradun APMC', latitude: 30.3165, longitude: 78.0322, icon: '🏛️'),
    CityLocation(name: 'हरिद्वार (Haridwar)', state: 'Uttarakhand', district: 'Haridwar', mandi: 'Haridwar APMC', latitude: 29.9457, longitude: 78.1642, icon: '🛕'),
    CityLocation(name: 'हल्द्वानी (Haldwani)', state: 'Uttarakhand', district: 'Udham Singh Nagar', mandi: 'Haldwani APMC', latitude: 29.2183, longitude: 79.5130, icon: '🌾'),

    // --- Himachal Pradesh ---
    CityLocation(name: 'शिमला (Shimla)', state: 'Himachal Pradesh', district: 'Shimla', mandi: 'Shimla APMC', latitude: 31.1048, longitude: 77.1734, icon: '🏔️'),
    CityLocation(name: 'मंडी (Mandi)', state: 'Himachal Pradesh', district: 'Mandi', mandi: 'Mandi APMC', latitude: 31.7086, longitude: 76.9313, icon: '🌾'),

    // --- Delhi / NCR ---
    CityLocation(name: 'दिल्ली (Delhi)', state: 'Delhi', district: 'Delhi', mandi: 'Azadpur APMC', latitude: 28.6139, longitude: 77.2090, icon: '🏛️'),

    // --- Assam ---
    CityLocation(name: 'गुवाहाटी (Guwahati)', state: 'Assam', district: 'Guwahati', mandi: 'Guwahati (Fancy Bazaar) APMC', latitude: 26.1445, longitude: 91.7362, icon: '🏛️'),
    CityLocation(name: 'डिब्रूगढ़ (Dibrugarh)', state: 'Assam', district: 'Dibrugarh', mandi: 'Dibrugarh APMC', latitude: 27.4728, longitude: 94.9120, icon: '🌾'),

    // --- Kerala ---
    CityLocation(name: 'कोच्चि (Kochi)', state: 'Kerala', district: 'Ernakulam', mandi: 'Kochi APMC', latitude: 9.9312, longitude: 76.2673, icon: '🏛️'),
    CityLocation(name: 'पालक्काड (Palakkad)', state: 'Kerala', district: 'Palakkad', mandi: 'Palakkad APMC', latitude: 10.7867, longitude: 76.6548, icon: '🌾'),
  ];

  /// Returns all locations for a specific district
  static List<CityLocation> getCitiesForDistrict(String district, {String state = 'Rajasthan'}) {
    final distLower = district.toLowerCase().trim();
    if (distLower.isEmpty) return [];

    final matching = popularCities.where((c) {
      final cDist = c.district.toLowerCase();
      final cName = c.name.toLowerCase();
      return cDist == distLower || cDist.contains(distLower) || distLower.contains(cDist) ||
             cName.contains(distLower) || distLower.contains(cName.split(' ').first.toLowerCase());
    }).toList();

    return matching;
  }

  /// Returns dynamic quick chips for the current district context:
  /// First the tehsils/places of the current district, followed by major divisional cities of the state
  static List<CityLocation> getQuickChipsForLocation({required String currentDistrict, required String currentState}) {
    final List<CityLocation> result = [];
    final Set<String> addedNames = {};

    final stateName = currentState.isNotEmpty ? currentState : 'Rajasthan';

    // 1. First add places/tehsils of currently selected district
    if (currentDistrict.isNotEmpty) {
      final localPlaces = getCitiesForDistrict(currentDistrict, state: stateName);
      for (final c in localPlaces) {
        if (!addedNames.contains(c.name)) {
          result.add(c);
          addedNames.add(c.name);
        }
      }
    }

    // 2. Then add major divisional hubs of the current state
    final stateCities = popularCities.where((c) => c.state.toLowerCase().contains(stateName.toLowerCase())).toList();
    for (final c in stateCities) {
      if (!addedNames.contains(c.name)) {
        result.add(c);
        addedNames.add(c.name);
      }
    }

    // 3. Fallback to all popular cities if needed
    for (final c in popularCities) {
      if (!addedNames.contains(c.name)) {
        result.add(c);
        addedNames.add(c.name);
      }
    }

    return result;
  }
}
