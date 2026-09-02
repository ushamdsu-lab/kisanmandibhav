import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/app_images.dart';
import '../../providers/mandi_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/notification_center_sheet.dart';
import '../../utils/district_helper.dart';
import 'widgets/dashboard_live_ticker.dart';
import 'widgets/dashboard_weather_card.dart';
import 'widgets/dashboard_mandi_spotlight.dart';
import 'widgets/govt_data_modals.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final weatherProv = context.read<WeatherProvider>();
      final mandiProv = context.read<MandiProvider>();

      if (weatherProv.weatherData == null && !weatherProv.isLoading) {
        if (StorageService.hasSavedLocation()) {
          // Location is ALREADY saved! Directly fetch weather, never prompt GPS again.
          weatherProv.fetchWeather();
        } else {
          // First launch only: auto-detect once and save permanently
          weatherProv.fetchUserLocation(mandiProvider: mandiProv);
        }
      }
      if (mandiProv.rates.isEmpty && !mandiProv.isLoading) {
        mandiProv.fetchRates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AppImages.appLogo(size: 34, borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'किसान मंडी भाव',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                ),
                Text(
                  'ताज़ा मंडी भाव व कृषि मौसम',
                  style: TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: Colors.white),
            tooltip: 'GPS लोकेशन रिफ्रेश करें',
            onPressed: () async {
              final weatherProv = context.read<WeatherProvider>();
              final mandiProv = context.read<MandiProvider>();
              final res = await weatherProv.fetchUserLocation(mandiProvider: mandiProv);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.isGps
                        ? '📍 लोकेशन: ${res.cityName} (${DistrictHelper.getHindiName(res.district)} जिले की सभी मंडियों के भाव)'
                        : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                    backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                  ),
                );
              }
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, notifProv, _) {
              final unread = notifProv.unreadCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () => NotificationCenterSheet.show(context),
                    tooltip: 'सूचनाएं व अलर्ट',
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Consumer2<WeatherProvider, MandiProvider>(
        builder: (context, weatherProv, mandiProv, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                weatherProv.fetchWeather(),
                mandiProv.fetchRates(),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Ticker
                  DashboardLiveTicker(mandiProvider: mandiProv),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. Weather Hero Card
                        DashboardWeatherCard(provider: weatherProv),

                        const SizedBox(height: 14),

                        // 3. Mandi Spotlight Card
                        DashboardMandiSpotlight(provider: mandiProv),

                        const SizedBox(height: 20),

                        // 4. Government Services & Tools Grid
                        Text(
                          '🏛️ सरकारी सुविधाएं व कृषि सेवाएं',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 12),

                        GridView.count(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.84,
                          children: [
                            _buildGridTile(
                              context,
                              'सरकारी MSP',
                              '🏛️',
                              Colors.blue.shade700,
                              () => GovtDataModals.showMspModal(context),
                            ),
                            _buildGridTile(
                              context,
                              'उर्वरक स्टॉक',
                              '🌱',
                              Colors.teal.shade700,
                              () => GovtDataModals.showFertilizerStockModal(context),
                            ),
                            _buildGridTile(
                              context,
                              'खाद कैलकुलेटर',
                              '🧪',
                              Colors.purple.shade700,
                              () => context.go('/kheti/calculator'),
                            ),
                            _buildGridTile(
                              context,
                              'हेल्पलाइन 24x7',
                              '📞',
                              Colors.green.shade700,
                              () => GovtDataModals.showHelplineModal(context),
                            ),
                            _buildGridTile(
                              context,
                              'मिट्टी जांच केंद्र',
                              '🔬',
                              Colors.deepOrange.shade700,
                              () => GovtDataModals.showSoilTestingModal(context),
                            ),
                            _buildGridTile(
                              context,
                              'किसान योजनाएं',
                              '📜',
                              Colors.indigo.shade700,
                              () => context.go('/schemes'),
                            ),
                            _buildGridTile(
                              context,
                              'फसल कैलेंडर',
                              '📅',
                              Colors.brown.shade700,
                              () => context.go('/kheti'),
                            ),
                            _buildGridTile(
                              context,
                              'मौसम रडार',
                              '🛰️',
                              Colors.cyan.shade800,
                              () => context.go('/mausam'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 5. Today's Farming Action Advisory
                        _buildActionAdvisory(context, weatherProv),

                        const SizedBox(height: 20),

                        // 6. Popular Crop Mandi Rates Preview
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🌾 प्रमुख फसल मंडी भाव',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/mandi'),
                              child: const Text('सभी देखें →', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        ...mandiProv.rates.take(4).map((r) => _buildMiniRateRow(context, r)),

                        const SizedBox(height: 90),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, String title, String emoji, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionAdvisory(BuildContext context, WeatherProvider weatherProv) {
    final spray = weatherProv.getSprayWindowStatus();
    final irrigation = weatherProv.getIrrigationStatus();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.psychology_alt_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'कृषि वैज्ञानिक दैनिक सलाह',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('छिड़काव (Spray):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(spray['status'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: spray['color'] as Color?)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('सिंचाई (Irrigation):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(irrigation['status'] ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: irrigation['color'] as Color?)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRateRow(BuildContext context, dynamic r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r.commodity.toString(),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              Text('${r.market} (${r.district})', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Text(
            '₹${r.modalPrice.toInt()}/Qtl',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1B5E20)),
          ),
        ],
      ),
    );
  }
}
