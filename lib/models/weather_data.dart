class CurrentWeather {
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double windGusts;
  final double precipitation;
  final double rain;
  final int weatherCode;
  final int cloudCover;
  final double surfacePressure;
  final int usAqi;
  final double pm25;
  final double pm10;
  final DateTime time;

  CurrentWeather({
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.windGusts,
    required this.precipitation,
    required this.rain,
    required this.weatherCode,
    required this.cloudCover,
    required this.surfacePressure,
    this.usAqi = 0,
    this.pm25 = 0,
    this.pm10 = 0,
    required this.time,
  });

  String get aqiLabel {
    if (usAqi <= 0) return 'सामान्य (Normal)';
    if (usAqi <= 50) return '🟢 उत्तम (Good)';
    if (usAqi <= 100) return '🟡 संतोषजनक (Moderate)';
    if (usAqi <= 150) return '🟠 संवेदनशील (Unhealthy)';
    if (usAqi <= 200) return '🔴 खराब (Poor)';
    return '🟣 अति खतरनाक (Severe)';
  }

  factory CurrentWeather.fromJson(Map<String, dynamic> json, {int usAqi = 0, double pm25 = 0, double pm10 = 0}) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] ?? 0).toDouble(),
      apparentTemperature: (json['apparent_temperature'] ?? (json['temperature_2m'] ?? 0)).toDouble(),
      humidity: (json['relative_humidity_2m'] ?? 0).toInt(),
      windSpeed: (json['wind_speed_10m'] ?? 0).toDouble(),
      windDirection: (json['wind_direction_10m'] ?? 0).toInt(),
      windGusts: (json['wind_gusts_10m'] ?? (json['wind_speed_10m'] ?? 0)).toDouble(),
      precipitation: (json['precipitation'] ?? 0).toDouble(),
      rain: (json['rain'] ?? 0).toDouble(),
      weatherCode: (json['weather_code'] ?? 0).toInt(),
      cloudCover: (json['cloud_cover'] ?? 0).toInt(),
      surfacePressure: (json['surface_pressure'] ?? 0).toDouble(),
      usAqi: usAqi,
      pm25: pm25,
      pm10: pm10,
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;
  final double precipitationSum;
  final double rainSum;
  final int precipitationProbability;
  final double windSpeedMax;
  final double uvIndexMax;
  final String sunrise;
  final String sunset;

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.precipitationSum,
    required this.rainSum,
    required this.precipitationProbability,
    required this.windSpeedMax,
    this.uvIndexMax = 0,
    this.sunrise = '',
    this.sunset = '',
  });
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int humidity;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });
}

class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final List<HourlyForecast> hourly;
  final String locationName;
  final double latitude;
  final double longitude;
  final String weatherEngineInfo;

  WeatherData({
    required this.current,
    required this.daily,
    required this.hourly,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.weatherEngineInfo = '⚡ हाइब्रिड मॉडल (ECMWF + GFS + AQI)',
  });
}
