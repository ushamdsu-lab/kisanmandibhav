import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/constants.dart';
import '../../../providers/weather_provider.dart';
import '../../../services/tts_service.dart';

class DashboardWeatherCard extends StatelessWidget {
  final WeatherProvider provider;

  const DashboardWeatherCard({super.key, required this.provider});

  IconData _getWeatherIcon(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny_rounded;
    if (code == 2 || code == 3) return Icons.cloud_rounded;
    if (code >= 45 && code <= 48) return Icons.foggy;
    if (code >= 51 && code <= 65) return Icons.water_drop_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.grain_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.wb_sunny_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.weatherData == null) {
      return Container(
        height: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final weather = provider.weatherData;
    final temp = weather?.current.temperature.round() ?? 27;
    final weatherCode = weather?.current.weatherCode ?? 1;
    final weatherInfo = AppConstants.weatherCodes[weatherCode];
    final locationName = weather?.locationName ?? 'जयपुर, राजस्थान';
    final humidity = weather?.current.humidity ?? 68;
    final windSpeed = weather?.current.windSpeed ?? 12;

    return InkWell(
      onTap: () => context.go('/mausam'),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2), Color(0xFF0097A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: Colors.amberAccent, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              locationName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () {
                              if (weather != null) {
                                TtsService().speakWeatherReport(
                                  city: locationName,
                                  weather: weather,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.volume_up_rounded, color: Color(0xFF0D47A1), size: 13),
                                  SizedBox(width: 3),
                                  Text(
                                    'मौसम सुनें',
                                    style: TextStyle(
                                      color: Color(0xFF0D47A1),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$temp°',
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            weatherInfo?['label'] ?? 'साफ़ मौसम',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getWeatherIcon(weatherCode),
                    color: Colors.amberAccent,
                    size: 38,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniStat('💧 नमी', '$humidity%'),
                  Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.2)),
                  _miniStat('💨 हवा', '${windSpeed.round()} km/h'),
                  Container(width: 1, height: 16, color: Colors.white.withValues(alpha: 0.2)),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('7 दिन पूर्वानुमान', style: TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.w800)),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.amberAccent, size: 10),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String val) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
      ],
    );
  }
}
