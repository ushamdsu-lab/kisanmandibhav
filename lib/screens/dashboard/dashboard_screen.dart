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
import '../../data/mandi_directory.dart';
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
      } else {
        // Sync mandi provider location with weather location
        final currentCity = weatherProv.cityName;
        final cleanCity = currentCity.contains('(')
            ? currentCity.substring(currentCity.indexOf('(') + 1).replaceAll(')', '').trim()
            : currentCity.split(',').first.trim();
        final stdDist = MandiDirectory.getStandardDistrictName(
          mandiProv.selectedState,
          weatherProv.detectedDistrict.isNotEmpty ? weatherProv.detectedDistrict : cleanCity,
        );
        if (stdDist.isNotEmpty && mandiProv.userHomeDistrict != stdDist) {
          mandiProv.syncLocationContext(
            state: weatherProv.detectedState.isNotEmpty ? weatherProv.detectedState : mandiProv.selectedState,
            district: stdDist,
          );
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localeProv.t('app_title'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    localeProv.t('app_subtitle'),
                    style: const TextStyle(fontSize: 10.5, color: Colors.white70, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
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
                        DashboardMandiSpotlight(
                          provider: mandiProv,
                          weatherProvider: weatherProv,
                        ),

                        const SizedBox(height: 16),

                        // 4A. ⚡ किसान स्मार्ट टूल्स (Farmer Smart Tools Section)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              localeProv.t('farmer_smart_tools'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.green.shade200),
                              ),
                              child: Text(
                                localeProv.t('free_and_offline'),
                                style: TextStyle(color: Colors.green.shade800, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 4-Card Modern Grid for Smart Tools
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.6,
                          children: [
                            // Card 1: कृषि बहीखाता (Farm Khata)
                            _buildSleekSmartToolCard(
                              context: context,
                              title: localeProv.t('tool_khata'),
                              subtitle: localeProv.t('sub_khata'),
                              badgeText: 'मुनाफा डायरी',
                              icon: Icons.auto_stories_rounded,
                              gradientColors: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                              badgeColor: const Color(0xFFFEF3C7),
                              badgeTextColor: const Color(0xFF92400E),
                              onTap: () => context.push('/farm-khata'),
                            ),
                            // Card 2: पशुपालन व डेयरी (Dairy & Cattle)
                            _buildSleekSmartToolCard(
                              context: context,
                              title: localeProv.t('tool_dairy'),
                              subtitle: localeProv.t('sub_dairy'),
                              badgeText: 'दूध व टीका',
                              icon: Icons.water_drop_rounded,
                              gradientColors: const [Color(0xFF0288D1), Color(0xFF01579B)],
                              badgeColor: const Color(0xFFE0F2FE),
                              badgeTextColor: const Color(0xFF0369A1),
                              onTap: () => context.push('/dairy-tracker'),
                            ),
                            // Card 3: AI फसल डॉक्टर (Crop Doctor)
                            _buildSleekSmartToolCard(
                              context: context,
                              title: 'AI फसल डॉक्टर',
                              subtitle: localeProv.t('sub_doctor'),
                              badgeText: 'रोग स्कैनर',
                              icon: Icons.document_scanner_rounded,
                              gradientColors: const [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                              badgeColor: const Color(0xFFDCFCE7),
                              badgeTextColor: const Color(0xFF166534),
                              onTap: () => context.push('/crop-doctor'),
                            ),
                            // Card 4: खाद कैलकुलेटर (Fertilizer Calculator)
                            _buildSleekSmartToolCard(
                              context: context,
                              title: localeProv.t('tool_calculator'),
                              subtitle: localeProv.t('sub_calculator'),
                              badgeText: 'सटीक मात्रा',
                              icon: Icons.calculate_rounded,
                              gradientColors: const [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                              badgeColor: const Color(0xFFF3E8FF),
                              badgeTextColor: const Color(0xFF6B21A8),
                              onTap: () => context.go('/kheti/calculator'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // 4B. 🏛️ सरकारी सुविधाएं व सहायता (Govt Services & Hub)
                        Text(
                          localeProv.t('govt_services_title'),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(height: 12),

                        // Modern Sleek 5-Item Row/Grid with Vector Badges
                        GridView.count(
                          crossAxisCount: 5,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.76,
                          children: [
                            _buildGovtServiceTile(
                              context: context,
                              title: localeProv.t('tool_schemes'),
                              icon: Icons.assignment_turned_in_rounded,
                              iconColor: const Color(0xFF3949AB),
                              bgTintColor: const Color(0xFFE8EAF6),
                              onTap: () => context.go('/yojna'),
                            ),
                            _buildGovtServiceTile(
                              context: context,
                              title: localeProv.t('tool_msp'),
                              icon: Icons.account_balance_rounded,
                              iconColor: const Color(0xFF1E88E5),
                              bgTintColor: const Color(0xFFE3F2FD),
                              onTap: () => GovtDataModals.showMspModal(context),
                            ),
                            _buildGovtServiceTile(
                              context: context,
                              title: localeProv.t('tool_fertilizer'),
                              icon: Icons.eco_rounded,
                              iconColor: const Color(0xFF00897B),
                              bgTintColor: const Color(0xFFE0F2F1),
                              onTap: () => GovtDataModals.showFertilizerStockModal(context),
                            ),
                            _buildGovtServiceTile(
                              context: context,
                              title: localeProv.t('tool_soil'),
                              icon: Icons.biotech_rounded,
                              iconColor: const Color(0xFFF4511E),
                              bgTintColor: const Color(0xFFFBE9E7),
                              onTap: () => GovtDataModals.showSoilTestingModal(context),
                            ),
                            _buildGovtServiceTile(
                              context: context,
                              title: localeProv.t('tool_helpline'),
                              icon: Icons.support_agent_rounded,
                              iconColor: const Color(0xFF2E7D32),
                              bgTintColor: const Color(0xFFE8F5E9),
                              onTap: () => GovtDataModals.showHelplineModal(context),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

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

  Widget _buildSleekSmartToolCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required List<Color> gradientColors,
    required Color badgeColor,
    required Color badgeTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: gradientColors.first.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovtServiceTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgTintColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.14)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgTintColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  secondaryName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '${r.market} • $distName',
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFFE65100), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${r.modalPrice.toInt()}${localeProv.t('per_quintal')}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5, color: Color(0xFF1B5E20)),
          ),
        ],
      ),
    );
  }
}
