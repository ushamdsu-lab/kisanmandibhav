import 'weather_data.dart';

enum SpraySafetyLevel {
  optimal, // 🟢 सर्वोत्तम समय
  moderate, // 🟡 सावधानी के साथ
  danger, // 🔴 स्प्रे न करें (हानिकारक)
}

class SprayAdvisory {
  final SpraySafetyLevel level;
  final int safetyScore; // 0 to 100
  final String title;
  final String description;
  final String windStatus;
  final String rainStatus;
  final String tempStatus;
  final String humidityStatus;
  final String bestTimeWindow;

  const SprayAdvisory({
    required this.level,
    required this.safetyScore,
    required this.title,
    required this.description,
    required this.windStatus,
    required this.rainStatus,
    required this.tempStatus,
    required this.humidityStatus,
    required this.bestTimeWindow,
  });

  /// Evaluates weather conditions to calculate smart spraying advisory
  factory SprayAdvisory.fromWeather(WeatherData? weather) {
    if (weather == null) {
      return const SprayAdvisory(
        level: SpraySafetyLevel.moderate,
        safetyScore: 50,
        title: 'मौसम डेटा लोड हो रहा है...',
        description: 'सटीक स्प्रे सलाह के लिए मौसम डेटा सिंक हो रहा है।',
        windStatus: '--',
        rainStatus: '--',
        tempStatus: '--',
        humidityStatus: '--',
        bestTimeWindow: 'सुबह 7:00 से 10:00 या शाम 4:00 से 6:30',
      );
    }

    final curr = weather.current;
    final wind = curr.windSpeed;
    final temp = curr.temperature;
    final humidity = curr.humidity;
    final rainProb = weather.daily.isNotEmpty ? weather.daily.first.precipitationProbability : 0;
    final isRainingNow = curr.precipitation > 0 || curr.rain > 0;

    int score = 100;
    final issues = <String>[];

    // 1. Rain check (Most critical)
    String rainTxt = 'बारिश की संभावना $rainProb%';
    if (isRainingNow) {
      score -= 60;
      rainTxt = 'वर्तमान में बारिश हो रही है';
      issues.add('बारिश से दवा धुल जाएगी');
    } else if (rainProb > 40) {
      score -= 40;
      issues.add('अगले कुछ घंटों में वर्षा की अधिक संभावना है');
    } else if (rainProb > 20) {
      score -= 15;
    }

    // 2. Wind speed check (Drift risk)
    String windTxt = '${wind.toStringAsFixed(1)} km/h';
    if (wind > 18) {
      score -= 35;
      windTxt += ' (अत्यधिक तेज हवा)';
      issues.add('तेज हवा से दवा उड़कर दूसरी जगह जाएगी व असर घटेगा');
    } else if (wind > 12) {
      score -= 20;
      windTxt += ' (मध्यम हवा)';
      issues.add('हवा की गति थोड़ी तेज है');
    } else {
      windTxt += ' (शांत / अनुकूल)';
    }

    // 3. Temperature check (Evaporation & foliage burn risk)
    String tempTxt = '${temp.toStringAsFixed(1)}°C';
    if (temp > 35) {
      score -= 25;
      tempTxt += ' (अत्यधिक गर्मी)';
      issues.add('तेज धूप व गर्मी में पत्तियों के झुलसने का खतरा है');
    } else if (temp < 10) {
      score -= 15;
      tempTxt += ' (अत्यधिक ठंड)';
    } else {
      tempTxt += ' (उपयुक्त)';
    }

    // 4. Humidity check
    String humTxt = '$humidity%';
    if (humidity < 30) {
      score -= 10;
      humTxt += ' (शुष्क हवा)';
    } else if (humidity > 90) {
      score -= 10;
      humTxt += ' (अत्यधिक नमी/ओस)';
    }

    score = score.clamp(0, 100);

    SpraySafetyLevel lvl;
    String title;
    String desc;

    if (score >= 75) {
      lvl = SpraySafetyLevel.optimal;
      title = '🟢 स्प्रे के लिए उत्तम मौसम (Safe to Spray)';
      desc = 'हवा शांत है और बारिश का कोई खतरा नहीं है। कीटनाशक, फफूंदनाशक या टॉनिक छिड़काव के लिए सर्वोत्तम समय है।';
    } else if (score >= 45) {
      lvl = SpraySafetyLevel.moderate;
      title = '🟡 सावधानी के साथ स्प्रे करें (Proceed with Caution)';
      desc = issues.isNotEmpty
          ? '${issues.join("। ")}। आवश्यक होने पर ही सुबह शांत समय स्प्रे करें।'
          : 'हवा व नमी का ध्यान रखते हुए ही छिड़काव करें।';
    } else {
      lvl = SpraySafetyLevel.danger;
      title = '🔴 आज स्प्रे स्थगित करें (Do Not Spray)';
      desc = issues.isNotEmpty
          ? '${issues.join("। ")}। आज छिड़काव करने से दवाई और पैसे दोनों व्यर्थ हो सकते हैं।'
          : 'मौसम प्रतिकूल है, छिड़काव टालें।';
    }

    return SprayAdvisory(
      level: lvl,
      safetyScore: score,
      title: title,
      description: desc,
      windStatus: windTxt,
      rainStatus: rainTxt,
      tempStatus: tempTxt,
      humidityStatus: humTxt,
      bestTimeWindow: temp > 30 ? 'शाम 4:30 से 6:45 बजे (धूप ढलने के बाद)' : 'सुबह 7:30 से 10:30 बजे (ओस सूखने के बाद)',
    );
  }
}
