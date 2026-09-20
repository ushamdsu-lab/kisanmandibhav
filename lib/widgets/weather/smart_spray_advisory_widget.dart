import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/weather_provider.dart';
import '../../models/spray_advisory.dart';

class SmartSprayAdvisoryWidget extends StatelessWidget {
  const SmartSprayAdvisoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProv, _) {
        final advisory = SprayAdvisory.fromWeather(weatherProv.weatherData);

        Color cardBorderColor;
        Color badgeBgColor;
        Color badgeTextColor;
        IconData statusIcon;

        switch (advisory.level) {
          case SpraySafetyLevel.optimal:
            cardBorderColor = Colors.green.shade400;
            badgeBgColor = Colors.green.shade50;
            badgeTextColor = Colors.green.shade800;
            statusIcon = Icons.check_circle_rounded;
            break;
          case SpraySafetyLevel.moderate:
            cardBorderColor = Colors.amber.shade400;
            badgeBgColor = Colors.amber.shade50;
            badgeTextColor = Colors.amber.shade900;
            statusIcon = Icons.warning_amber_rounded;
            break;
          case SpraySafetyLevel.danger:
            cardBorderColor = Colors.red.shade400;
            badgeBgColor = Colors.red.shade50;
            badgeTextColor = Colors.red.shade900;
            statusIcon = Icons.cancel_rounded;
            break;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: cardBorderColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, color: badgeTextColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🌧️ स्मार्ट स्प्रे वेदर एडवाइजरी',
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          Text(
                            'दवा छिड़काव सुरक्षा सूचकांक',
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cardBorderColor),
                    ),
                    child: Text(
                      '${advisory.safetyScore}% स्कोर',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title & Desc
              Text(
                advisory.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: badgeTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                advisory.description,
                style: const TextStyle(fontSize: 12, height: 1.35),
              ),
              const SizedBox(height: 12),

              // 4 Metrics Grid
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricItem(Icons.air_rounded, 'हवा', advisory.windStatus),
                    Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                    _buildMetricItem(Icons.umbrella_rounded, 'वर्षा', advisory.rainStatus),
                    Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                    _buildMetricItem(Icons.thermostat_rounded, 'तापमान', advisory.tempStatus),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Best Window
              Row(
                children: [
                  const Icon(Icons.access_time_filled_rounded, size: 15, color: Colors.blue),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'सर्वोत्तम समय: ${advisory.bestTimeWindow}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
        ),
      ],
    );
  }
}
