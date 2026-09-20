import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  String _currentLanguage = 'hi';

  LocaleProvider() {
    _loadLanguage();
  }

  String get currentLanguage => _currentLanguage;
  bool get isHindi => _currentLanguage == 'hi';
  bool get isEnglish => _currentLanguage == 'en';
  Locale get locale => Locale(_currentLanguage);

  void _loadLanguage() {
    _currentLanguage = StorageService.getSavedLanguage();
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    _currentLanguage = languageCode;
    await StorageService.saveLanguage(languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final nextLang = _currentLanguage == 'hi' ? 'en' : 'hi';
    await setLanguage(nextLang);
  }

  String t(String key) {
    if (_currentLanguage == 'en') {
      return _enTranslations[key] ?? _hiTranslations[key] ?? key;
    }
    return _hiTranslations[key] ?? key;
  }

  static const Map<String, String> _hiTranslations = {
    // Nav
    'nav_home': 'होम',
    'nav_mandi': 'मंडी',
    'nav_weather': 'मौसम',
    'nav_kheti': 'खेती',
    'nav_yojna': 'योजना',

    // App Header
    'app_title': 'किसान मंडी भाव',
    'app_subtitle': 'ताज़ा मंडी भाव व कृषि मौसम',
    'gps_refresh': 'GPS लोकेशन रिफ्रेश करें',
    'lang_switch': 'English',

    // Dashboard
    'farmer_smart_tools': '⚡ किसान स्मार्ट टूल्स',
    'tool_khata': 'कृषि बहीखाता',
    'tool_dairy': 'पशुपालन व डेयरी',
    'sub_khata': 'मुनाफा व खर्च डायरी',
    'sub_dairy': 'दूध व टीका रिकॉर्ड',
    'sub_doctor': 'पत्ती स्कैन व रोग',
    'sub_calculator': 'यूरिया व DAP मात्रा',
    'ai_crop_doctor': '📸 AI फसल डॉक्टर',
    'free_and_offline': 'फ्री व ऑफलाइन',
    'doctor_banner_sub': 'पौधे की फोटो लें → तुरंत बीमारी व दवाई का नाम जानें',
    'govt_services_title': '🏛️ सरकारी सुविधाएं व सहायता',
    'tool_doctor': 'फसल डॉक्टर',
    'tool_msp': 'सरकारी MSP',
    'tool_fertilizer': 'उर्वरक स्टॉक',
    'tool_calculator': 'खाद कैलकुलेटर',
    'tool_helpline': 'हेल्पलाइन 24x7',
    'tool_soil': 'मिट्टी जांच केंद्र',
    'tool_schemes': 'किसान योजनाएं',
    'tool_calendar': 'फसल कैलेंडर',
    'tool_radar': 'मौसम रडार',
    'agri_advisory_title': 'कृषि वैज्ञानिक दैनिक सलाह',
    'spray_label': 'छिड़काव (Spray):',
    'irrigation_label': 'सिंचाई (Irrigation):',
    'top_rates_preview': '🌾 प्रमुख फसल मंडी भाव',
    'view_all': 'सभी देखें →',
    'per_quintal': ' /क्विंटल',
    'listen_weather': 'मौसम सुनें',
    'clear_weather': 'साफ़ मौसम',
    'weather_humidity': '💧 नमी',
    'weather_wind': '💨 हवा',
    'weather_7day_forecast': '7 दिन पूर्वानुमान',
    'spotlight_tag': 'ताज़ा भाव',
    'spotlight_sub': 'आज के मॉडल भाव व आवक',
    'view_btn': 'देखें',

    // Mandi Screen
    'mandi_title': 'मंडी भाव लाइव',
    'tab_district_mandis': 'ज़िला व मंडियां',
    'tab_all_mandis': 'पूरे राज्य की मंडियां',
    'all_districts': 'सभी जिले',
    'back_to_my_location': 'मेरी लोकेशन पर लौटें',
    'you_are_viewing': 'आप देख रहे हैं',
    'select_state': 'राज्य चुनें',
    'select_district': 'ज़िला चुनें',
    'all_rates': 'सभी भाव',
    'main_crops': 'मुख्य फसलें',
    'veg_and_fruits': 'सब्जी व फल',
    'all_filter': 'सभी',
    'search_crop_mandi': '🔍 फसल या मंडी का नाम खोजें (उदा: जीरा, सरसों, मेड़ता)...',
    'min_price': 'न्यूनतम',
    'max_price': 'अधिकतम',
    'modal_price': 'मॉडल भाव',
    'arrival_date': 'आवक तारीख',
    'today_rates': 'ताज़ा भाव',
    'share_whatsapp': 'WhatsApp पर शेयर करें',
    'price_alert': 'भाव अलर्ट',
    'compare_btn': 'तुलना',
    'alert_btn': 'अलर्ट',
    'listen_bulletin': 'भाव सुनें',
    'clear_filters': 'फ़िल्टर हटाएं ✕',

    // Weather Screen
    'weather_title': 'कृषि मौसम अलर्ट',
    'current_temp': 'तापमान',
    'humidity': 'नमी',
    'wind_speed': 'हवा की गति',
    'rain_chance': 'बारिश की संभावना',
    'forecast_7_days': 'अगले 7 दिन का पूर्वानुमान',
    'farming_advice': 'किसान मौसम सलाह',
    'spray_condition': 'कीटनाशक छिड़काव अनुकूलता',
    'irrigation_guide': 'सिंचाई प्रबंधन सलाह',
    'select_city': 'जिला या शहर चुनें',
    'use_gps': 'वर्तमान GPS लोकेशन उपयोग करें',
    'change_city': 'बदलें ▼',

    // Kheti (Farming) Screen
    'kheti_title': 'खेती सलाह व कीट सुरक्षा',
    'search_crop_pest': '🔍 फसल या कीट खोजें (उदा: गेहूं, जीरा, तना छेदक)...',
    'season_all': 'सभी फसलें',
    'season_kharif': 'खरीफ फसलें',
    'season_rabi': 'रबी फसलें',
    'season_zaid': 'जायद फसलें',
    'no_crop_found': 'कोई फसल नहीं मिली',
    'major_pests': 'प्रमुख कीट व रोग:',
    'symptoms_label': 'लक्षण:',
    'remedy_label': 'उपचार व स्प्रे:',
    'view_fertilizer_plan': 'उर्वरक व खाद प्रबंधन देखें →',

    // Calculator Screen
    'calc_title': 'उर्वरक व खाद कैलकुलेटर',
    'calc_subtitle': 'खेत के आकार अनुसार NPK, यूरिया, DAP व MOP की सटीक मात्रा',
    'area_unit': 'क्षेत्रफल इकाई:',
    'enter_area': 'खेत का क्षेत्रफल दर्ज करें:',
    'bigha': 'बीघा (Bigha)',
    'acre': 'एकड़ (Acre)',
    'hectare': 'हेक्टेयर (Hectare)',
    'calculate_dose': 'खाद की मात्रा निकालें',
    'required_fertilizers': 'आवश्यक उर्वरक (Fertilizer Requirement):',
    'basal_dose': 'बुवाई के समय (Basal Dose):',
    'top_dressing': 'पहली व दूसरी सिंचाई पर (Top Dressing):',

    // Crop Doctor
    'doctor_title': 'AI फसल डॉक्टर (रोग व दवा)',
    'mode_photo': 'फोटो स्कैन',
    'mode_symptoms': 'लक्षण जांच',
    'mode_directory': 'रोग डायरेक्टरी',
    'select_crop': 'फसल चुनें:',
    'take_photo': 'पत्ती/पौधे की फोटो लें:',
    'camera_btn': 'कैमरा खोलें',
    'gallery_btn': 'गैलरी से चुनें',
    'select_symptoms': 'पौधे में दिख रहे लक्षण चुनें:',
    'diagnose_btn': 'रोग पहचानें व इलाज देखें',
    'diagnosis_result': 'जांच रिपोर्ट (Diagnosis Result)',
    'primary_diagnosis': 'प्राथमिक निदान',
    'chemical_treatment': 'रासायनिक दवाई व स्प्रे',
    'organic_solution': 'जैविक व देसी उपचार',
    'dosage': 'मात्रा:',
    'share_prescription': 'पर्ची WhatsApp करें',
    'speak_aloud': 'बोलकर सुनें',
    'alternative_diseases': 'इसी फसल के अन्य संभावित रोग व दवाई',
    'all_diseases_directory': 'फसल के सभी रोग व दवाई डायरेक्टरी',
    'search_disease_med': 'रोग या दवाई का नाम खोजें...',

    // Schemes
    'schemes_title': 'सरकारी कृषि योजनाएं',
    'for_you_tab': '🌟 आपके लिए',
    'central_schemes': 'केंद्र सरकार',
    'state_schemes': 'राज्य सरकार',
    'subsidy': 'सब्सिडी व लाभ',
    'eligibility': 'पात्रता',
    'how_to_apply': 'आवेदन कैसे करें',
    'check_eligibility': 'अपनी पात्रता जांचें',
  };

  static const Map<String, String> _enTranslations = {
    // Nav
    'nav_home': 'Home',
    'nav_mandi': 'Mandi',
    'nav_weather': 'Weather',
    'nav_kheti': 'Farming',
    'nav_yojna': 'Schemes',

    // App Header
    'app_title': 'Kisan Mandi Bhav',
    'app_subtitle': 'Live APMC Rates & Agri Weather',
    'gps_refresh': 'Refresh GPS Location',
    'lang_switch': 'हिंदी',

    // Dashboard
    'farmer_smart_tools': '⚡ Smart Farmer Tools',
    'tool_khata': 'Farm Khata',
    'tool_dairy': 'Dairy & Animal Care',
    'sub_khata': 'Profit & Expense Diary',
    'sub_dairy': 'Milk & Vaccine Records',
    'sub_doctor': 'Scan Leaf Disease',
    'sub_calculator': 'Urea & DAP Dosage',
    'ai_crop_doctor': '📸 AI Crop Doctor',
    'free_and_offline': 'Free & Offline',
    'doctor_banner_sub': 'Take crop leaf photo → Get disease & medicine instantly',
    'govt_services_title': '🏛️ Govt Services & Helplines',
    'tool_doctor': 'Crop Doctor',
    'tool_msp': 'Govt MSP',
    'tool_fertilizer': 'Fertilizer Stock',
    'tool_calculator': 'Fertilizer Calc',
    'tool_helpline': 'Helpline 24x7',
    'tool_soil': 'Soil Testing',
    'tool_schemes': 'Govt Schemes',
    'tool_calendar': 'Crop Calendar',
    'tool_radar': 'Weather Radar',
    'agri_advisory_title': 'Daily Agronomist Advisory',
    'spray_label': 'Spray Window:',
    'irrigation_label': 'Irrigation Window:',
    'top_rates_preview': '🌾 Top Mandi Crop Prices',
    'view_all': 'View All →',
    'per_quintal': ' /Qtl',
    'listen_weather': 'Listen Weather',
    'clear_weather': 'Clear Sky',
    'weather_humidity': '💧 Humidity',
    'weather_wind': '💨 Wind',
    'weather_7day_forecast': '7-Day Forecast',
    'spotlight_tag': 'Live Rates',
    'spotlight_sub': 'Today\'s Modal Prices & Arrivals',
    'view_btn': 'View',

    // Mandi Screen
    'mandi_title': 'Live Mandi Bhav',
    'tab_district_mandis': 'District & Mandis',
    'tab_all_mandis': 'All State Mandis',
    'all_districts': 'All Districts',
    'back_to_my_location': 'Back to My Location',
    'you_are_viewing': 'Viewing',
    'select_state': 'Select State',
    'select_district': 'Select District',
    'all_rates': 'All Rates',
    'main_crops': 'Main Crops',
    'veg_and_fruits': 'Fruits & Veg',
    'all_filter': 'All',
    'search_crop_mandi': '🔍 Search crop or mandi (e.g. Wheat, Mustard, Merta)...',
    'min_price': 'Min',
    'max_price': 'Max',
    'modal_price': 'Modal Price',
    'arrival_date': 'Arrival Date',
    'today_rates': 'Live Rates',
    'share_whatsapp': 'Share on WhatsApp',
    'price_alert': 'Price Alert',
    'compare_btn': 'Compare',
    'alert_btn': 'Alert',
    'listen_bulletin': 'Listen Bulletin',
    'clear_filters': 'Clear Filters ✕',

    // Weather Screen
    'weather_title': 'Agri Weather & Alerts',
    'current_temp': 'Temperature',
    'humidity': 'Humidity',
    'wind_speed': 'Wind Speed',
    'rain_chance': 'Rain Chance',
    'forecast_7_days': '7-Day Weather Forecast',
    'farming_advice': 'Farming Advisory',
    'spray_condition': 'Pesticide Spray Feasibility',
    'irrigation_guide': 'Irrigation Management Advisory',
    'select_city': 'Select District or City',
    'use_gps': 'Use Current GPS Location',
    'change_city': 'Change ▼',

    // Kheti (Farming) Screen
    'kheti_title': 'Crop Advisory & Pest Protection',
    'search_crop_pest': '🔍 Search crop or pest (e.g. Wheat, Jeera, Stem Borer)...',
    'season_all': 'All Crops',
    'season_kharif': 'Kharif Season',
    'season_rabi': 'Rabi Season',
    'season_zaid': 'Zaid Season',
    'no_crop_found': 'No crops found',
    'major_pests': 'Major Pests & Diseases:',
    'symptoms_label': 'Symptoms:',
    'remedy_label': 'Treatment & Chemical Spray:',
    'view_fertilizer_plan': 'View Fertilizer Management Plan →',

    // Calculator Screen
    'calc_title': 'Fertilizer Dosage Calculator',
    'calc_subtitle': 'Accurate NPK, Urea, DAP & MOP calculations for your field area',
    'area_unit': 'Area Unit:',
    'enter_area': 'Enter Field Area:',
    'bigha': 'Bigha',
    'acre': 'Acre',
    'hectare': 'Hectare',
    'calculate_dose': 'Calculate Fertilizer Requirement',
    'required_fertilizers': 'Fertilizer Requirement:',
    'basal_dose': 'At Sowing Time (Basal Dose):',
    'top_dressing': 'At 1st & 2nd Irrigation (Top Dressing):',

    // Crop Doctor
    'doctor_title': 'AI Crop Doctor (Diagnosis)',
    'mode_photo': 'Photo Scan',
    'mode_symptoms': 'Symptom Check',
    'mode_directory': 'Disease Guide',
    'select_crop': 'Select Crop:',
    'take_photo': 'Take photo of infected leaf:',
    'camera_btn': 'Open Camera',
    'gallery_btn': 'Choose from Gallery',
    'select_symptoms': 'Select symptoms visible on plant:',
    'diagnose_btn': 'Diagnose & View Medicine',
    'diagnosis_result': 'Diagnosis Result Report',
    'primary_diagnosis': 'Primary Diagnosis',
    'chemical_treatment': 'Approved Chemical Spray',
    'organic_solution': 'Organic & Bio Remedy',
    'dosage': 'Dosage:',
    'share_prescription': 'Share Prescription on WhatsApp',
    'speak_aloud': 'Audio Speech',
    'alternative_diseases': 'Other Potential Diseases for this Crop',
    'all_diseases_directory': 'Crop Disease & Medicine Directory',
    'search_disease_med': 'Search disease or medicine name...',

    // Schemes
    'schemes_title': 'Govt Agricultural Schemes',
    'for_you_tab': '🌟 For You',
    'central_schemes': 'Central Govt',
    'state_schemes': 'State Govt',
    'subsidy': 'Subsidy & Benefits',
    'eligibility': 'Eligibility',
    'how_to_apply': 'How to Apply',
    'check_eligibility': 'Check Eligibility',
  };
}

