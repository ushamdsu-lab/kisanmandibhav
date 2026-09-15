import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/app_images.dart';
import '../../providers/mandi_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/notification_center_sheet.dart';
import '../../widgets/common/language_toggle_button.dart';
import '../../utils/district_helper.dart';
import '../../utils/commodity_helper.dart';
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

      if (!StorageService.hasSavedLocation()) {
        if (!weatherProv.isLoading) {
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
    final localeProv = context.watch<LocaleProvider>();

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
              children: [
                Text(
                  localeProv.t('app_title'),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                ),
                Text(
                  localeProv.t('app_subtitle'),
                  style: const TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          const LanguageToggleButton(),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: Colors.white),
            tooltip: localeProv.t('gps_refresh'),
            onPressed: () async {
              final weatherProv = context.read<WeatherProvider>();
              final mandiProv = context.read<MandiProvider>();
              final res = await weatherProv.fetchUserLocation(mandiProvider: mandiProv);
              if (context.mounted) {
                SnackBarAction? action;
                if (res.isLocationServiceDisabled) {
                  action = SnackBarAction(
                    label: 'GPS चालू करें',
                    textColor: Colors.amberAccent,
                    onPressed: () => Geolocator.openLocationSettings(),
                  );
                } else if (res.isPermissionDeniedForever) {
                  action = SnackBarAction(
                    label: 'सेटिंग्स खोलें',
                    textColor: Colors.amberAccent,
                    onPressed: () => Geolocator.openAppSettings(),
                  );
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res.isGps
                        ? '📍 सटीक GPS: ${res.cityName} (${DistrictHelper.getHindiName(res.district)} जिला)'
                        : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                    backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                    duration: const Duration(seconds: 4),
                    action: action,
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

                        const SizedBox(height: 14),

                        // 3B. AI Crop Doctor Hero Banner
                        InkWell(
                          onTap: () => context.push('/crop-doctor'),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 26),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            localeProv.t('ai_crop_doctor'),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.amberAccent,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(localeProv.t('free_and_offline'), style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        localeProv.t('doctor_banner_sub'),
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 4. Government Services & Tools Grid
                        Text(
                          localeProv.t('govt_services_title'),
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
                              localeProv.t('tool_doctor'),
                              '📸',
                              const Color(0xFF1B5E20),
                              () => context.push('/crop-doctor'),
                            ),
                            _buildGridTile(
                              context,
                              localeProv.t('tool_msp'),
                              '🏛️',
                              Colors.blue.shade700,
                              () => GovtDataModals.showMspModal(context),
                            ),
                            _buildGridTile(
                              context,
                              localeProv.t('tool_fertilizer'),
                              '🌱',
                              Colors.teal.shade700,
                              () => GovtDataModals.showFertilizerStockModal(context),
                            ),
                            _buildGridTile(
                              context,
                              localeProv.t('tool_calculator'),
                              '🧪',
                              Colors.purple.shade700,
                              () => context.go('/kheti/calculator'),
                            ),
                            _buildGridTile(
                              context,
                              localeProv.t('tool_helpline'),
                              '📞',
                              Colors.green.shade700,
                              () => GovtDataModals.showHelplineModal(context),
                            ),
                            _buildGridTile(
                              context,
                              localeProv.t('tool_soil'),
                              '🔬',
                              Colors.deepOrange.shade700,
                              () => GovtDataModals.showSoilTestingModal(context),
                            ),
                            _buildGridTile(
                              context,
                              localeProv.t('tool_schemes'),
                              '📜',
                              Colors.indigo.shade700,
                              () => context.go('/yojna'),
                            ),
                            _buildGridTile(
                              context,
                              localeProv.t('tool_calendar'),
                              '📅',
                              Colors.brown.shade700,
                              () => context.go('/kheti'),
                            ),
                            _buildGridTile(
                              context,
                              localeProv.t('tool_radar'),
                              '🛰️',
                              Colors.cyan.shade800,
                              () => context.go('/mausam'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // 5. Today's Farming Action Advisory
                        _buildActionAdvisory(context, weatherProv, localeProv),

                        const SizedBox(height: 20),

                        // 6. Popular Crop Mandi Rates Preview
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localeProv.t('top_rates_preview'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/mandi'),
                              child: Text(localeProv.t('view_all'), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        ...mandiProv.rates.take(4).map((r) => _buildMiniRateRow(context, r, localeProv)),

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

  Widget _buildActionAdvisory(BuildContext context, WeatherProvider weatherProv, LocaleProvider localeProv) {
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
            children: [
              const Icon(Icons.psychology_alt_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                localeProv.t('agri_advisory_title'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primaryDark),
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
                      Text(localeProv.t('spray_label'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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
                      Text(localeProv.t('irrigation_label'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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

  Widget _buildMiniRateRow(BuildContext context, dynamic r, LocaleProvider localeProv) {
    final rawCommodity = r.commodity.toString();
    final isHi = localeProv.isHindi;
    final hindiName = CommodityHelper.getHindiName(rawCommodity);
    final englishName = CommodityHelper.getEnglishName(rawCommodity);
    final primaryName = isHi ? hindiName : (englishName.isNotEmpty ? englishName : rawCommodity);
    final secondaryName = isHi ? (englishName.isNotEmpty ? englishName : rawCommodity) : hindiName;
    final distName = isHi ? DistrictHelper.getHindiName(r.district.toString()) : r.district.toString();

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryName,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1B5E20)),
                ),
                Text(
                  secondaryName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 1),
                Text(
                  '${r.market} • $distName',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            '₹${r.modalPrice.toInt()}${localeProv.t('per_quintal')}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: Color(0xFF1B5E20)),
          ),
        ],
      ),
    );
  }
}
