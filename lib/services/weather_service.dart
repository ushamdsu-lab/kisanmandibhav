import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';
import '../config/constants.dart';

class WeatherService {
  static Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    String locationName = '',
  }) async {
    // 1. Standard GFS / IMD Best-Match Forecast (Original Weather Engine)
    final stdUrl = Uri.parse(
      '${AppConstants.weatherBaseUrl}?'
      'latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,cloud_cover,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max,precipitation_sum,rain_sum,precipitation_probability_max,wind_speed_10m_max'
      '&hourly=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m'
      '&timezone=Asia/Kolkata'
      '&forecast_days=7',
    );

    // 2. ECMWF High-Resolution European Weather Model (New Engine)
    final ecmwfUrl = Uri.parse(
      '${AppConstants.weatherBaseUrl}?'
      'latitude=$latitude&longitude=$longitude'
      '&models=ecmwf_ifs025'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,cloud_cover,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,wind_speed_10m_max'
      '&timezone=Asia/Kolkata'
      '&forecast_days=7',
    );

    // 3. Air Quality & Environment API (AQI, PM2.5, PM10)
    final aqiUrl = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality?'
      'latitude=$latitude&longitude=$longitude'
      '&current=us_aqi,pm2_5,pm10'
      '&timezone=Asia/Kolkata',
    );

    try {
      final responses = await Future.wait([
        http.get(stdUrl).timeout(AppConstants.networkTimeout),
        http.get(ecmwfUrl).timeout(AppConstants.networkTimeout).catchError((_) => http.Response('{}', 404)),
        http.get(aqiUrl).timeout(AppConstants.networkTimeout).catchError((_) => http.Response('{}', 404)),
      ]);

      final stdRes = responses[0];
      final ecmRes = responses[1];
      final aqiRes = responses[2];

      if (stdRes.statusCode != 200) {
        throw Exception('मौसम डेटा प्राप्त नहीं हो सका (${stdRes.statusCode})');
      }

      final stdData = json.decode(stdRes.body);
      Map<String, dynamic> ecmData = {};
      if (ecmRes.statusCode == 200 && ecmRes.body.isNotEmpty) {
        try {
          ecmData = json.decode(ecmRes.body);
        } catch (_) {}
      }

      int usAqi = 0;
      double pm25 = 0.0;
      double pm10 = 0.0;

      if (aqiRes.statusCode == 200 && aqiRes.body.isNotEmpty) {
        try {
          final aqiJson = json.decode(aqiRes.body);
          final currentAqi = aqiJson['current'];
          if (currentAqi != null) {
            usAqi = (currentAqi['us_aqi'] ?? 0).toInt();
            pm25 = (currentAqi['pm2_5'] ?? 0).toDouble();
            pm10 = (currentAqi['pm10'] ?? 0).toDouble();
          }
        } catch (_) {}
      }

      // Blend Current Weather from stdData & ecmData
      final stdCurrent = stdData['current'] ?? {};
      final ecmCurrent = ecmData['current'] ?? {};

      final double temp1 = (stdCurrent['temperature_2m'] ?? 0).toDouble();
      final double temp2 = (ecmCurrent['temperature_2m'] ?? temp1).toDouble();
      final double blendTemp = ecmCurrent.isNotEmpty ? (temp1 + temp2) / 2.0 : temp1;

      final double app1 = (stdCurrent['apparent_temperature'] ?? temp1).toDouble();
      final double app2 = (ecmCurrent['apparent_temperature'] ?? app1).toDouble();
      final double blendAppTemp = ecmCurrent.isNotEmpty ? (app1 + app2) / 2.0 : app1;

      final double wind1 = (stdCurrent['wind_speed_10m'] ?? 0).toDouble();
      final double wind2 = (ecmCurrent['wind_speed_10m'] ?? wind1).toDouble();
      final double blendWind = ecmCurrent.isNotEmpty ? (wind1 + wind2) / 2.0 : wind1;

      final double gust1 = (stdCurrent['wind_gusts_10m'] ?? wind1).toDouble();
      final double gust2 = (ecmCurrent['wind_gusts_10m'] ?? gust1).toDouble();
      final double blendGusts = ecmCurrent.isNotEmpty ? (gust1 + gust2) / 2.0 : gust1;

      final double precip1 = (stdCurrent['precipitation'] ?? 0).toDouble();
      final double precip2 = (ecmCurrent['precipitation'] ?? 0).toDouble();
      final double maxPrecip = math.max(precip1, precip2);

      final int code1 = (stdCurrent['weather_code'] ?? 0).toInt();
      final int code2 = (ecmCurrent['weather_code'] ?? code1).toInt();
      final int blendCode = (code1 >= 50 && code1 <= 99) ? code1 : ((code2 >= 50 && code2 <= 99) ? code2 : code1);

      final current = CurrentWeather(
        temperature: blendTemp,
        apparentTemperature: blendAppTemp,
        humidity: (stdCurrent['relative_humidity_2m'] ?? 0).toInt(),
        windSpeed: blendWind,
        windDirection: (stdCurrent['wind_direction_10m'] ?? 0).toInt(),
        windGusts: blendGusts,
        precipitation: maxPrecip,
        rain: (stdCurrent['rain'] ?? 0).toDouble(),
        weatherCode: blendCode,
        cloudCover: (stdCurrent['cloud_cover'] ?? 0).toInt(),
        surfacePressure: (stdCurrent['surface_pressure'] ?? 0).toDouble(),
        usAqi: usAqi,
        pm25: pm25,
        pm10: pm10,
        time: DateTime.tryParse(stdCurrent['time'] ?? '') ?? DateTime.now(),
      );

      // Blend Daily Forecast
      final stdDaily = stdData['daily'] ?? {};
      final ecmDaily = ecmData['daily'] ?? {};

      final List stdTimes = stdDaily['time'] ?? [];
      final List<DailyForecast> daily = [];

      for (int i = 0; i < stdTimes.length; i++) {
        String sunriseStr = '';
        String sunsetStr = '';
        if (stdDaily['sunrise'] != null && (stdDaily['sunrise'] as List).length > i) {
          final rawSunrise = stdDaily['sunrise'][i].toString();
          if (rawSunrise.contains('T')) sunriseStr = rawSunrise.split('T').last;
        }
        if (stdDaily['sunset'] != null && (stdDaily['sunset'] as List).length > i) {
          final rawSunset = stdDaily['sunset'][i].toString();
          if (rawSunset.contains('T')) sunsetStr = rawSunset.split('T').last;
        }

        final double max1 = (stdDaily['temperature_2m_max']?[i] ?? 0).toDouble();
        final double max2 = (ecmDaily['temperature_2m_max'] != null && (ecmDaily['temperature_2m_max'] as List).length > i)
            ? (ecmDaily['temperature_2m_max'][i] ?? max1).toDouble()
            : max1;
        final double blendMax = (max1 + max2) / 2.0;

        final double min1 = (stdDaily['temperature_2m_min']?[i] ?? 0).toDouble();
        final double min2 = (ecmDaily['temperature_2m_min'] != null && (ecmDaily['temperature_2m_min'] as List).length > i)
            ? (ecmDaily['temperature_2m_min'][i] ?? min1).toDouble()
            : min1;
        final double blendMin = (min1 + min2) / 2.0;

        final int rawProb = (stdDaily['precipitation_probability_max']?[i] ?? 0).toInt();
        final double precipSum = (stdDaily['precipitation_sum']?[i] ?? 0).toDouble();
        
        int calculatedProb = rawProb;
        final currentRain = (stdCurrent['rain'] ?? 0).toDouble();
        final currentPrecip = (stdCurrent['precipitation'] ?? 0).toDouble();
        if (precipSum < 0.5 && currentRain == 0 && currentPrecip == 0) {
          final cloud = (stdCurrent['cloud_cover'] ?? 0).toInt();
          calculatedProb = (cloud * 0.35).round();
        }

        daily.add(DailyForecast(
          date: DateTime.tryParse(stdTimes[i].toString()) ?? DateTime.now().add(Duration(days: i)),
          weatherCode: stdDaily['weather_code']?[i] ?? 0,
          tempMax: blendMax,
          tempMin: blendMin,
          precipitationSum: (stdDaily['precipitation_sum']?[i] ?? 0).toDouble(),
          rainSum: (stdDaily['rain_sum']?[i] ?? 0).toDouble(),
          precipitationProbability: calculatedProb,
          windSpeedMax: (stdDaily['wind_speed_10m_max']?[i] ?? 0).toDouble(),
          uvIndexMax: (stdDaily['uv_index_max'] != null && (stdDaily['uv_index_max'] as List).length > i)
              ? (stdDaily['uv_index_max'][i] ?? 0).toDouble()
              : 0.0,
          sunrise: sunriseStr,
          sunset: sunsetStr,
        ));
      }

      // Parse Hourly Forecast
      final hourlyData = stdData['hourly'] ?? {};
      final List<HourlyForecast> hourly = [];
      final List hourlyTimes = hourlyData['time'] ?? [];
      for (int i = 0; i < hourlyTimes.length.clamp(0, 24); i++) {
        hourly.add(HourlyForecast(
          time: DateTime.tryParse(hourlyTimes[i].toString()) ?? DateTime.now().add(Duration(hours: i)),
          temperature: (hourlyData['temperature_2m']?[i] ?? 0).toDouble(),
          humidity: (hourlyData['relative_humidity_2m']?[i] ?? 0).toInt(),
          precipitation: (hourlyData['precipitation']?[i] ?? 0).toDouble(),
          weatherCode: (hourlyData['weather_code']?[i] ?? 0).toInt(),
          windSpeed: (hourlyData['wind_speed_10m']?[i] ?? 0).toDouble(),
        ));
      }

      return WeatherData(
        current: current,
        daily: daily,
        hourly: hourly,
        locationName: locationName.isEmpty ? AppConstants.defaultCity : locationName,
        latitude: latitude,
        longitude: longitude,
        weatherEngineInfo: ecmData.isNotEmpty
            ? '⚡ सैटेलाइट रडार (ECMWF + GFS)'
            : '⚡ सैटेलाइट रडार (ECMWF)',
      );
    } on TimeoutException {
      throw Exception('मौसम सर्वर से संपर्क समय समाप्त (Timeout)। कृपया इंटरनेट जांचें।');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('मौसम डेटा प्राप्त करने में समस्या: $e');
    }
  }
}
