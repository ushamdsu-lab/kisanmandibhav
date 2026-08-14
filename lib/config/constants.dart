class AppConstants {
  // App Info
  static const String appName = 'KisanMandiBhav';
  static const String appNameHindi = 'किसान मंडी भाव';
  static const String appTagline = 'ताज़ा मंडी भाव व कृषि मौसम अपडेट';
  static const String appVersion = '1.0.5';

  // Network & Timeout
  static const Duration networkTimeout = Duration(seconds: 10);

  // API URLs
  static const String mandiResourceId = '9ef84268-d588-465a-a308-a864a43d0070';
  static const String mandiBaseUrl = 'https://api.data.gov.in/resource/$mandiResourceId';
  static const String weatherBaseUrl = 'https://api.open-meteo.com/v1/forecast';

  // Default Location (Delhi / Jaipur as reference)
  static const double defaultLatitude = 28.6139;
  static const double defaultLongitude = 77.2090;
  static const String defaultCity = 'दिल्ली';
  static const String defaultState = 'Delhi';

  // API Keys (Configurable via Storage or Environment)
  static String mandiApiKey = '579b464db66ec23bdd000001592db4fa842b480f7171a34c0956c64d';

  // Open-Meteo params
  static const String weatherParams =
      'temperature_2m,relative_humidity_2m,apparent_temperature,'
      'precipitation,rain,weather_code,wind_speed_10m,'
      'wind_direction_10m';
  static const String weatherDailyParams =
      'weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_sum,rain_sum,precipitation_probability_max,'
      'wind_speed_10m_max';

  // Seasons
  static const Map<String, String> seasons = {
    'kharif': 'खरीफ (जून-अक्टूबर)',
    'rabi': 'रबी (नवंबर-मार्च)',
    'zaid': 'जायद (मार्च-जून)',
  };

  // Area conversions
  static const double hectareToAcre = 2.47105;
  static const double acreToHectare = 0.404686;
  static const double hectareToBigha = 4.0; // Standard 1 Hectare approx 4 Pucca Bigha / 6.25-8 Kaccha Bigha
  static const double bighaToHectare = 0.25;

  // Weather codes to Hindi descriptions
  static const Map<int, Map<String, String>> weatherCodes = {
    0: {'label': 'साफ आसमान', 'icon': 'wb_sunny'},
    1: {'label': 'लगभग साफ', 'icon': 'wb_sunny'},
    2: {'label': 'आंशिक बादल', 'icon': 'cloud'},
    3: {'label': 'बादल छाए', 'icon': 'cloud'},
    45: {'label': 'कोहरा', 'icon': 'foggy'},
    48: {'label': 'घना कोहरा', 'icon': 'foggy'},
    51: {'label': 'हल्की बूंदाबांदी', 'icon': 'grain'},
    53: {'label': 'बूंदाबांदी', 'icon': 'grain'},
    55: {'label': 'तेज बूंदाबांदी', 'icon': 'grain'},
    61: {'label': 'हल्की बारिश', 'icon': 'water_drop'},
    63: {'label': 'बारिश', 'icon': 'water_drop'},
    65: {'label': 'भारी बारिश', 'icon': 'thunderstorm'},
    71: {'label': 'हल्की बर्फबारी', 'icon': 'ac_unit'},
    73: {'label': 'बर्फबारी', 'icon': 'ac_unit'},
    75: {'label': 'भारी बर्फबारी', 'icon': 'ac_unit'},
    80: {'label': 'हल्की बौछार', 'icon': 'water_drop'},
    81: {'label': 'बौछार', 'icon': 'water_drop'},
    82: {'label': 'भारी बौछार', 'icon': 'thunderstorm'},
    95: {'label': 'गरज के साथ बारिश', 'icon': 'thunderstorm'},
    96: {'label': 'ओलावृष्टि', 'icon': 'thunderstorm'},
    99: {'label': 'भारी ओलावृष्टि', 'icon': 'thunderstorm'},
  };

  // Indian States list
  static const List<String> indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar',
    'Chhattisgarh', 'Goa', 'Gujarat', 'Haryana',
    'Himachal Pradesh', 'Jharkhand', 'Karnataka', 'Kerala',
    'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
    'Mizoram', 'Nagaland', 'Odisha', 'Punjab',
    'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
    'Delhi', 'Jammu and Kashmir', 'Ladakh',
  ];
}
