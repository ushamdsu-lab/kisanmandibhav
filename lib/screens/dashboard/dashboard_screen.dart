import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/weather_provider.dart';
import '../../providers/mandi_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/constants.dart';
import '../../config/app_images.dart';
import '../../data/msp_data.dart';
import '../../data/fertilizer_stock_data.dart';
import '../../data/soil_lab_data.dart';
import '../../utils/district_helper.dart';
import '../../utils/commodity_helper.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/notification_center_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch weather and user location on load
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final weatherProv = context.read<WeatherProvider>();
      final mandiProv = context.read<MandiProvider>();
      
      if (weatherProv.weatherData == null && !weatherProv.isLoading) {
        await weatherProv.fetchWeather();
      }
      // Auto-detect GPS location & sync mandi context
      weatherProv.fetchUserLocation(mandiProvider: mandiProv);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final weatherProvider = context.watch<WeatherProvider>();
    final mandiProvider = context.watch<MandiProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- App Bar ---
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                AppConstants.appNameHindi,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.dashboardGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 12,
                      bottom: 10,
                      child: SizedBox(
                        height: 140,
                        child: AppImages.mahilaKisan,
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 50,
                      right: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'नमस्ते किसान साथी! 🙏',
                              style: TextStyle(
                                color: Colors.amberAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppConstants.appTagline,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, notifProv, _) {
                  final unread = notifProv.unreadCount;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, size: 24),
                        onPressed: () => NotificationCenterSheet.show(context),
                        tooltip: 'सूचनाएं व मंडी अलर्ट',
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
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: isDark ? 'लाइट मोड' : 'डार्क मोड',
              ),
            ],
          ),

          // --- Mahila Kisan Feature Banner ---
          SliverToBoxAdapter(
            child: _buildMahilaKisanFeatureBanner().animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),

          // --- Weather Quick Card ---
          SliverToBoxAdapter(
            child: _buildWeatherQuickCard(weatherProvider).animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),

          // --- Live Mandi Quick Card ---
          SliverToBoxAdapter(
            child: _buildMandiQuickCard(mandiProvider).animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),

          // --- Fertilizer Calculator Quick Card ---
          SliverToBoxAdapter(
            child: _buildFertilizerQuickCard().animate()
                .fadeIn(delay: 250.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),

          // --- Main Navigation Module Grid ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.grid_view_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'मुख्य सेवाएं',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              delegate: SliverChildListDelegate([
                _buildModuleCard(
                  icon: Icons.storefront_rounded,
                  label: 'मंडी भाव',
                  subtitle: 'आज के लाइव दाम',
                  gradientColors: AppColors.mandiGradient,
                  onTap: () => context.go('/mandi'),
                  index: 0,
                ),
                _buildModuleCard(
                  icon: Icons.wb_sunny_rounded,
                  label: 'मौसम अपडेट',
                  subtitle: 'बारिश व तापमान',
                  gradientColors: AppColors.mausamGradient,
                  onTap: () => context.go('/mausam'),
                  index: 1,
                ),
                _buildModuleCard(
                  icon: Icons.agriculture_rounded,
                  label: 'खेती व दवाइयां',
                  subtitle: 'रोग, दवा व खाद',
                  gradientColors: AppColors.khetiGradient,
                  onTap: () => context.go('/kheti'),
                  index: 2,
                ),
                _buildModuleCard(
                  icon: Icons.workspace_premium_rounded,
                  label: 'सरकारी योजना',
                  subtitle: 'पीएम किसान & मदद',
                  gradientColors: AppColors.yojnaGradient,
                  onTap: () => context.go('/yojna'),
                  index: 3,
                ),
              ]),
            ),
          ),

          // --- 🏛️ 4 Government Agriculture Data Features Section ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'सरकारी कृषि डेटा सेवाएं',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Govt Data.gov.in',
                      style: TextStyle(color: Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              delegate: SliverChildListDelegate([
                _buildGovtFeatureCard(
                  icon: Icons.workspace_premium_rounded,
                  label: '1. MSP न्यूनतम भाव',
                  subtitle: '23 सरकारी MSP दरें',
                  color: const Color(0xFFD97706),
                  onTap: () => _showMspModal(context),
                  index: 0,
                ),
                _buildGovtFeatureCard(
                  icon: Icons.inventory_2_rounded,
                  label: '2. उर्वरक स्टॉक & MRP',
                  subtitle: 'यूरिया, DAP दरें व स्टॉक',
                  color: const Color(0xFF059669),
                  onTap: () => _showFertilizerStockModal(context),
                  index: 1,
                ),
                _buildGovtFeatureCard(
                  icon: Icons.biotech_rounded,
                  label: '3. मृदा स्वास्थ व लैब',
                  subtitle: 'मिट्टी जांच केंद्र निर्देशिका',
                  color: const Color(0xFF7C3AED),
                  onTap: () => _showSoilTestingModal(context),
                  index: 2,
                ),
                _buildGovtFeatureCard(
                  icon: Icons.support_agent_rounded,
                  label: '4. किसान हेल्पलाइन',
                  subtitle: '1800-180-1551 (24x7)',
                  color: const Color(0xFFDC2626),
                  onTap: () => _showHelplineModal(context),
                  index: 3,
                ),
              ]),
            ),
          ),

          // --- Farming Advisory ---
          SliverToBoxAdapter(
            child: _buildFarmingAdvisory(weatherProvider).animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ),

          // --- Quick Info ---
          SliverToBoxAdapter(
            child: _buildQuickInfo().animate()
                .fadeIn(delay: 600.ms, duration: 400.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildMahilaKisanFeatureBanner() {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      gradientColors: const [Color(0xFF2E7D32), Color(0xFF1B5E20)],
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'स्मार्ट कृषि सहायता',
                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'जय जवान, जय किसान 🌾',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'किसान भाइयों एवं बहनों को समर्पित - ताज़ा मंडी भाव, मौसम व सरकारी योजनाएं',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 90,
            width: 85,
            child: AppImages.mahilaKisan,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherQuickCard(WeatherProvider provider) {
    if (provider.isLoading) {
      return const GlassCard(
        margin: EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (provider.weatherData == null) {
      return const SizedBox.shrink();
    }

    final weather = provider.weatherData!;
    final current = weather.current;
    final weatherInfo = AppConstants.weatherCodes[current.weatherCode];

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      onTap: () => context.go('/mausam'),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.mausamGradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getWeatherIcon(current.weatherCode),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${current.temperature.round()}°C • ${weatherInfo?['label'] ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '📍 ${weather.locationName} ${provider.isGpsLocation ? "🟢" : ""}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
            tooltip: 'वर्तमान GPS लोकेशन सेट करें',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final mandiProv = context.read<MandiProvider>();
              final res = await provider.fetchUserLocation(mandiProvider: mandiProv);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(res.isGps
                      ? '📍 आपकी वर्तमान लोकेशन (${res.cityName}) का मौसम व मंडी सेट हो गया है!'
                      : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                  backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                ),
              );
            },
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildMandiQuickCard(MandiProvider provider) {
    final distName = provider.selectedDistrict.isNotEmpty 
        ? '${DistrictHelper.getHindiName(provider.selectedDistrict)} (${provider.selectedDistrict})'
        : 'राजस्थान (सभी मंडियां)';
    final topRates = provider.rates.take(3).toList();

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      onTap: () => context.go('/mandi'),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: AppColors.mandiGradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '📍 $distName',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.mandiAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'लाइव भाव',
                        style: TextStyle(color: AppColors.mandiAccent, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                if (topRates.isNotEmpty)
                  Text(
                    topRates.map((r) => '${CommodityHelper.getHindiName(r.commodity)}: ₹${r.modalPrice.toInt()}').join(' • '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'अपने जिले की सभी मंडियों के ताज़ा भाव देखें →',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildFertilizerQuickCard() {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      onTap: () => context.go('/kheti/calculator'),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.green.shade700.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 48,
                width: 48,
                child: AppImages.carrotMascot,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'खाद कैलकुलेटर व दरें',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'MRP नियत दरें',
                        style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'यूरिया: ₹266.50 • DAP: ₹1,350 • फसल अनुसार गणना करें',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildGovtFeatureCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required int index,
  }) {
    return GlassCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: (200 + index * 100).ms, duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  void _showMspModal(BuildContext context) {
    final searchCtrl = TextEditingController();
    String selectedCategory = 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.toLowerCase().trim();
            final filtered = MspDatabase.mspList.where((item) {
              final matchesQuery = query.isEmpty ||
                  item.nameHindi.toLowerCase().contains(query) ||
                  item.nameEng.toLowerCase().contains(query);
              final matchesCat = selectedCategory == 'all' || item.category == selectedCategory;
              return matchesQuery && matchesCat;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 24),
                          onPressed: () => Navigator.pop(ctx),
                          tooltip: 'बंद करें ✕',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '1. सरकारी MSP (न्यूनतम समर्थन मूल्य) दरें',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'कृषि एवं किसान कल्याण मंत्रालय (CACP ${MspDatabase.mspList.length}+ कुल फसलें)',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: 'फसल का नाम खोजें (उदा: गेहूं, सरसों, जीरा, मूंग, Wheat)...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  searchCtrl.clear();
                                  setModalState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip('सभी फसलें (${MspDatabase.mspList.length})', 'all', selectedCategory, (cat) => setModalState(() => selectedCategory = cat)),
                        const SizedBox(width: 8),
                        _buildFilterChip('🌾 रबी फसलें', 'rabi', selectedCategory, (cat) => setModalState(() => selectedCategory = cat)),
                        const SizedBox(width: 8),
                        _buildFilterChip('🌱 खरीफ फसलें', 'kharif', selectedCategory, (cat) => setModalState(() => selectedCategory = cat)),
                        const SizedBox(width: 8),
                        _buildFilterChip('🎋 वाणिज्यिक व मसाला', 'commercial', selectedCategory, (cat) => setModalState(() => selectedCategory = cat)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('कोई फसल नहीं मिली'))
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                ),
                                child: Row(
                                  children: [
                                    Text(item.icon, style: const TextStyle(fontSize: 24)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${item.nameHindi} (${item.nameEng})',
                                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.season,
                                            style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₹${item.mspPrice.toInt()}',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
                                        ),
                                        const Text(
                                          'प्रति क्विंटल',
                                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String value, String selectedValue, Function(String) onSelect) {
    final isSelected = selectedValue == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(value),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }

  void _showFertilizerStockModal(BuildContext context) {
    final mandiProv = context.read<MandiProvider>();
    final weatherProv = context.read<WeatherProvider>();

    String rawDistrict = mandiProv.selectedDistrict.isNotEmpty
        ? mandiProv.selectedDistrict
        : (weatherProv.weatherData?.locationName.isNotEmpty == true
            ? weatherProv.weatherData!.locationName
            : 'Bikaner');

    final defaultDistricts = [
      'Bikaner', 'Nagaur', 'Jaipur', 'Jodhpur', 'Kota', 'Hanumangarh',
      'Ganganagar', 'Sikar', 'Ajmer', 'Udaipur', 'Bhilwara', 'Alwar',
      'Bharatpur', 'Indore', 'Neemuch', 'Mandsaur', 'Rajkot'
    ];

    final rawList = mandiProv.availableDistricts.isNotEmpty
        ? (List<String>.from(mandiProv.availableDistricts)..addAll(defaultDistricts))
        : defaultDistricts;

    final Map<String, String> uniqueHindiMap = {};
    for (final d in rawList) {
      final h = DistrictHelper.getHindiName(d);
      if (!uniqueHindiMap.containsKey(h)) {
        uniqueHindiMap[h] = d;
      }
    }
    final availableDistricts = uniqueHindiMap.values.toList();
    availableDistricts.sort((a, b) => DistrictHelper.getHindiName(a).compareTo(DistrictHelper.getHindiName(b)));

    int refreshCount = 0;
    bool isSyncing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final stockData = FertilizerStockDatabase.getStockForDistrict(rawDistrict, refreshOffset: refreshCount);

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 24),
                          onPressed: () => Navigator.pop(ctx),
                          tooltip: 'बंद करें ✕',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
                    child: Row(
                      children: [
                        const Icon(Icons.science_rounded, color: Color(0xFF059669), size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '2. उर्वरक/खाद स्टॉक उपलब्धता व सरकारी MRP',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '🕒 ${stockData.lastUpdated}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- District Switcher & Live Refresh Bar ---
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          stockData.districtHindi,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (dist) {
                            setModalState(() {
                              rawDistrict = dist;
                            });
                            mandiProv.fetchRates(district: dist);
                          },
                          itemBuilder: (context) {
                            return availableDistricts.map((d) {
                              return PopupMenuItem(
                                value: d,
                                child: Text(DistrictHelper.getHindiName(d), style: const TextStyle(fontWeight: FontWeight.w600)),
                              );
                            }).toList();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('जिला बदलें ▾', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: isSyncing
                              ? null
                              : () async {
                                  setModalState(() => isSyncing = true);
                                  await Future.delayed(const Duration(milliseconds: 600));
                                  setModalState(() {
                                    refreshCount++;
                                    isSyncing = false;
                                  });
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                isSyncing
                                    ? const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.refresh_rounded, color: Colors.white, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  isSyncing ? 'सिंक हो रहा...' : 'ताज़ा सिंक 🔄',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_city_rounded, color: Colors.green, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '📍 ${stockData.districtHindi} जिला मुख्य डिपो:',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      stockData.depotName,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '🏷️ ${stockData.districtHindi} जिले में नियत MRP दरें व उपलब्ध स्टॉक:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildFertilizerStockTile(
                          '🧪 नीम कोटेड यूरिया (Neem Coated Urea)',
                          '₹266.50 / 45kg बोरी',
                          stockData.ureaStatus,
                          '46% Nitrogen',
                          Colors.green,
                        ),
                        const SizedBox(height: 10),
                        _buildFertilizerStockTile(
                          '🌾 डीएपी (DAP 18:46:0)',
                          '₹1,350.00 / 50kg बोरी',
                          stockData.dapStatus,
                          '18% N, 46% P2O5',
                          Colors.teal,
                        ),
                        const SizedBox(height: 10),
                        _buildFertilizerStockTile(
                          '🌱 एनपीके (NPK 12:32:16)',
                          '₹1,470.00 / 50kg बोरी',
                          stockData.npkStatus,
                          '12% N, 32% P, 16% K',
                          Colors.green.shade700,
                        ),
                        const SizedBox(height: 10),
                        _buildFertilizerStockTile(
                          '🌿 सिंगल सुपर फास्फेट (SSP)',
                          '₹600.00 / 50kg बोरी',
                          stockData.sspStatus,
                          '16% P2O5, 11% Sulphur',
                          Colors.lightGreen,
                        ),
                        const SizedBox(height: 10),
                        _buildFertilizerStockTile(
                          '🌽 एमओपी पोटाश (MOP 0:0:60)',
                          '₹1,700.00 / 50kg बोरी',
                          stockData.mopStatus,
                          '60% Potash',
                          Colors.blueGrey,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.go('/kheti/calculator');
                          },
                          icon: const Icon(Icons.calculate_rounded),
                          label: const Text('🧮 अपने खेत के लिए खाद की आवश्यकता कैलकुलेट करें ➔'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFertilizerStockTile(String name, String price, String stockStatus, String spec, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
                const SizedBox(height: 3),
                Text(stockStatus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green)),
                const SizedBox(height: 2),
                Text('तकनीकी संरचना: $spec', style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
              const Text('सरकारी MRP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  void _showSoilTestingModal(BuildContext context) {
    final mandiProv = context.read<MandiProvider>();
    final weatherProv = context.read<WeatherProvider>();

    String rawDistrict = mandiProv.selectedDistrict.isNotEmpty
        ? mandiProv.selectedDistrict
        : (weatherProv.weatherData?.locationName.isNotEmpty == true
            ? weatherProv.weatherData!.locationName
            : 'Bikaner');

    final defaultDistricts = [
      'Bikaner', 'Nagaur', 'Jaipur', 'Jodhpur', 'Kota', 'Hanumangarh',
      'Ganganagar', 'Sikar', 'Ajmer', 'Udaipur', 'Bhilwara', 'Alwar',
      'Bharatpur', 'Indore', 'Neemuch', 'Mandsaur', 'Rajkot'
    ];

    final rawList = mandiProv.availableDistricts.isNotEmpty
        ? (List<String>.from(mandiProv.availableDistricts)..addAll(defaultDistricts))
        : defaultDistricts;

    final Map<String, String> uniqueHindiMap = {};
    for (final d in rawList) {
      final h = DistrictHelper.getHindiName(d);
      if (!uniqueHindiMap.containsKey(h)) {
        uniqueHindiMap[h] = d;
      }
    }
    final availableDistricts = uniqueHindiMap.values.toList();
    availableDistricts.sort((a, b) => DistrictHelper.getHindiName(a).compareTo(DistrictHelper.getHindiName(b)));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final labData = SoilLabDatabase.getLabForDistrict(rawDistrict);

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 24),
                        onPressed: () => Navigator.pop(ctx),
                        tooltip: 'बंद करें ✕',
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.science_rounded, color: Color(0xFF7C3AED), size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '3. मृदा स्वास्थ्य व जिला लैब निर्देशिका',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const Text(
                                      'Soil Health Card Scheme • Ministry of Agriculture',
                                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // District Switcher Bar
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: Color(0xFF7C3AED), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  labData.districtHindi,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED)),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  onSelected: (dist) {
                                    setModalState(() {
                                      rawDistrict = dist;
                                    });
                                    mandiProv.fetchRates(district: dist);
                                  },
                                  itemBuilder: (context) {
                                    return availableDistricts.map((d) {
                                      return PopupMenuItem(
                                        value: d,
                                        child: Text(DistrictHelper.getHindiName(d), style: const TextStyle(fontWeight: FontWeight.w600)),
                                      );
                                    }).toList();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('जिला बदलें ▾', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          // District Lab Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('📍 ${labData.districtHindi} सरकारी मृदा परीक्षण लैब (KVK Center):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF7C3AED))),
                                const SizedBox(height: 4),
                                Text(labData.labName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('🏢 पता: ${labData.labAddress}', style: const TextStyle(fontSize: 11)),
                                const SizedBox(height: 2),
                                Text('👨‍🔬 प्रभारी: ${labData.inchargeOfficer}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text('📞 फोन/हेल्पलाइन: ${labData.contactPhone}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.indigo)),
                                const SizedBox(height: 2),
                                Text('💳 जांच शुल्क: ${labData.testingFee}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('🧪 12 मुख्य मृदा स्वास्थ्य मानक (Tested Parameters):', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          const Text('1. पीएच मान (pH Balance)\n2. ईसी (EC - लवणता)\n3. ऑर्गेनिक कार्बन (Organic Carbon - जैविक मादा)\n4. नाइट्रोजन (Nitrogen - N)\n5. फास्फोरस (Phosphorus - P)\n6. पोटाश (Potassium - K)\n7. सल्फर (Sulphur - S)\n8. जस्ता (Zinc), लोहा (Fe), तांबा (Cu), मैंगनीज (Mn), बोरान (B)', style: TextStyle(fontSize: 13, height: 1.6)),
                          const SizedBox(height: 20),
                          Text('📋 मिट्टी का नमूना कैसे लें:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('• खेत के 8-10 अलग-अलग स्थानों से V आकार में 15 सेमी गहरा गड्ढा खोदकर मिट्टी एकत्र करें।\n• सभी नमूनों को मिलाकर 500 ग्राम मिट्टी स्वच्छ थैली में रखकर नजदीकी कृषि विज्ञान केंद्र (KVK) या लैब में जमा करें।', style: TextStyle(fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showHelplineModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 24),
                      onPressed: () => Navigator.pop(ctx),
                      tooltip: 'बंद करें ✕',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  children: [
                    const Icon(Icons.headset_mic_rounded, color: Colors.red, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '4. सरकारी किसान हेल्पलाइन कॉल सेंटर',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            '24x7 निःशुल्क टोल-फ्री हेल्पलाइन नंबर व कृषि विशेषज्ञ सलाह',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildHelplineTile('📞 1800-180-1551', 'किसान कॉल सेंटर (24x7 टोल फ्री)', 'कृषि वैज्ञानिकों से रोग, फसल सुरक्षा व कृषि संबंधी सलाह लें (12 भाषाओं में)', Colors.green),
                    const SizedBox(height: 10),
                    _buildHelplineTile('📞 155261', 'पीएम किसान सम्मान निधि हेल्पलाइन', 'किस्त स्थिति, ई-केवाईसी व पीएम किसान योजना सहायता', AppColors.primary),
                    const SizedBox(height: 10),
                    _buildHelplineTile('📞 1800-200-7710', 'पीएम फसल बीमा हेल्पलाइन', 'फसल नुकसान क्लेम, सर्वे व बीमा पंजीकरण सहायता', Colors.blue.shade800),
                    const SizedBox(height: 10),
                    _buildHelplineTile('📞 1800-180-1717', 'मौसम हेल्पलाइन (IMD)', 'मौसम चेतावनी, ओलावृष्टि व भारी बारिश अलर्ट जानकारी', Colors.orange.shade800),
                    const SizedBox(height: 10),
                    _buildHelplineTile('📞 1800-180-1234', 'पशुपालन व पशु चिकित्सा हेल्पलाइन', 'पशु टीकाकरण, पशु रोग व दूध उत्पादन सलाह', Colors.purple.shade800),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelplineTile(String number, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(number, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int index,
  }) {
    return GlassCard(
      margin: EdgeInsets.zero,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradientColors),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate()
        .fadeIn(delay: (200 + index * 100).ms, duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildFarmingAdvisory(WeatherProvider provider) {
    final advisory = provider.getFarmingAdvisory();
    if (advisory.isEmpty) return const SizedBox.shrink();

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.khetiAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tips_and_updates_rounded, color: AppColors.khetiAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'आज की खेती सलाह',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            advisory,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo() {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'किसान हेल्पलाइन',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.call_rounded, color: AppColors.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1800-180-1551',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'निशुल्क • 24x7 उपलब्ध',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny_rounded;
    if (code == 2 || code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 55) return Icons.grain_rounded;
    if (code >= 61 && code <= 65) return Icons.water_drop_rounded;
    if (code >= 71 && code <= 75) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.water_drop_rounded;
    if (code >= 95) return Icons.thunderstorm_rounded;
    return Icons.cloud_rounded;
  }
}
