import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/locale_provider.dart';
import '../../providers/mandi_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/commodity_helper.dart';
import '../../utils/district_helper.dart';
import '../../data/mandi_directory.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/notification_center_sheet.dart';
import '../../widgets/common/language_toggle_button.dart';
import 'widgets/mandi_rate_card.dart';
import 'widgets/mandi_state_picker_modal.dart';
import 'widgets/mandi_district_picker_modal.dart';
import 'widgets/mandi_price_comparison_modal.dart';
import 'widgets/mandi_price_alert_modal.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../widgets/ads/inline_ad_card.dart';
import '../../services/ad_service.dart';
import '../../services/tts_service.dart';

class MandiScreen extends StatefulWidget {
  const MandiScreen({super.key});

  @override
  State<MandiScreen> createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  String _resolveActiveDistrict(WeatherProvider weatherProv, MandiProvider mandiProv) {
    if (weatherProv.detectedDistrict.isNotEmpty) {
      final std = MandiDirectory.getStandardDistrictName(mandiProv.selectedState, weatherProv.detectedDistrict);
      if (std.isNotEmpty) return std;
      return weatherProv.detectedDistrict;
    }
    if (weatherProv.cityName.isNotEmpty) {
      final cleanCity = weatherProv.cityName.contains('(')
          ? weatherProv.cityName.substring(weatherProv.cityName.indexOf('(') + 1).replaceAll(')', '').trim()
          : weatherProv.cityName.split(',').first.trim();
      final std = MandiDirectory.getStandardDistrictName(mandiProv.selectedState, cleanCity);
      if (std.isNotEmpty) return std;
    }
    if (mandiProv.userHomeDistrict.isNotEmpty) {
      return mandiProv.userHomeDistrict;
    }
    return MandiDirectory.getDefaultDistrict(mandiProv.selectedState);
  }

  @override
  void initState() {
    super.initState();
    // Default to Tab 1 ("ज़िला व मंडियां") so that the user's active location (e.g. Kota) is shown immediately
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = context.read<MandiProvider>();
        final weatherProv = context.read<WeatherProvider>();
        if (_tabController.index == 0) {
          // Tab 0: सभी मंडियां (All Mandis of the state)
          provider.viewAllMandis();
        } else if (_tabController.index == 1) {
          // Tab 1: जिले की मंडियां (District Mandis)
          final targetDist = _resolveActiveDistrict(weatherProv, provider);
          provider.selectDistrict(targetDist);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MandiProvider>();
      final weatherProv = context.read<WeatherProvider>();
      final activeDist = _resolveActiveDistrict(weatherProv, provider);

      // On startup, ensure active district (Kota) is selected for Tab 1
      if (_tabController.index == 1) {
        if (provider.selectedDistrict != activeDist) {
          provider.selectDistrict(activeDist);
        }
      } else if (provider.selectedDistrict.isNotEmpty && _tabController.index != 1) {
        _tabController.index = 1;
      }

      if (provider.rates.isEmpty && !provider.isLoading) {
        provider.fetchRates(
          state: provider.selectedState,
          district: provider.selectedDistrict.isNotEmpty ? provider.selectedDistrict : activeDist,
          market: provider.selectedMarket.isNotEmpty ? provider.selectedMarket : null,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final isHi = localeProv.isHindi;

    return Scaffold(
      body: Consumer<MandiProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.fetchRates(state: provider.selectedState),
            child: CustomScrollView(
              slivers: [
                // Top App Bar with Tabs
                SliverAppBar(
                  pinned: true,
                  floating: false,
                  elevation: 2,
                  title: Text(
                    isHi ? '🏪 मंडी भाव लाइव' : '🏪 Live Mandi Rates',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 19, color: Colors.white),
                  ),
                  centerTitle: false,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.mandiGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: const Color(0xFFE65100),
                        unselectedLabelColor: Colors.white.withValues(alpha: 0.95),
                        labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                        tabs: [
                          Tab(
                            height: 38,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.account_balance_rounded, size: 16),
                                const SizedBox(width: 6),
                                Text(localeProv.t('tab_all_mandis')),
                              ],
                            ),
                          ),
                          Tab(
                            height: 38,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on_rounded, size: 16),
                                const SizedBox(width: 6),
                                Text(localeProv.t('tab_district_mandis')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    const LanguageToggleButton(),
                    IconButton(
                      icon: const Icon(Icons.my_location_rounded, color: Colors.white),
                      tooltip: isHi ? 'GPS लोकेशन से मंडी सेट करें' : 'Set Mandi from GPS',
                      onPressed: () async {
                        final weatherProv = context.read<WeatherProvider>();
                        final res = await weatherProv.fetchUserLocation(mandiProvider: provider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res.isGps
                                  ? (isHi
                                      ? '📍 लोकेशन: ${res.cityName} (${DistrictHelper.getHindiName(res.district)} जिले की सभी मंडियों के भाव)'
                                      : '📍 Location: ${res.cityName} (${res.district} District Mandis)')
                                  : (res.errorMessage ?? (isHi ? 'लोकेशन प्राप्त नहीं हो सकी' : 'Location unavailable'))),
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
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                              onPressed: () => NotificationCenterSheet.show(context),
                              tooltip: isHi ? 'सूचनाएं व भाव अलर्ट' : 'Alerts & Notifications',
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
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      onPressed: () => provider.fetchRates(state: provider.selectedState),
                      tooltip: isHi ? 'ताज़ा करें' : 'Refresh',
                    ),
                  ],
                ),

                // Location Header Bar
                SliverToBoxAdapter(
                  child: _buildLocationBar(context, provider),
                ),

                // Selected Market Header (if a specific market is clicked from strip)
                if (provider.selectedMarket.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSelectedMandiHeader(context, provider),
                  ),

                // District Mandis Quick Switcher Strip
                if (provider.availableMarkets.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildMandiSelector(context, provider),
                  ),


                  // Offline Notice Bar (if viewing cached data)
                  if (provider.isOffline)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off_rounded, color: Colors.brown, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ऑफ़लाइन मोड: अंतिम रिकॉर्डेड भाव प्रदर्शित (${provider.lastSyncTime.isNotEmpty ? provider.lastSyncTime : "कैश्ड"})',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.brown),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Category Switcher
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            _buildCategoryButton(localeProv.t('all_rates'), Icons.grid_view_rounded, provider.selectedCategory == 'all', () => provider.selectCategory('all')),
                            _buildCategoryButton(localeProv.t('main_crops'), Icons.grain_rounded, provider.selectedCategory == 'crops', () => provider.selectCategory('crops')),
                            _buildCategoryButton(localeProv.t('veg_and_fruits'), Icons.eco_rounded, provider.selectedCategory == 'vegetables', () => provider.selectCategory('vegetables')),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Quick Available Crops Filter (Shows ONLY crops that ACTUALLY exist in this Mandi!)
                  if (provider.availableCropsInCurrentView.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(localeProv.t('all_filter'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                selected: provider.selectedCropFilter.isEmpty,
                                onSelected: (_) => provider.selectCropFilter(''),
                              ),
                            ),
                            ...provider.availableCropsInCurrentView.map((c) {
                              final isSelected = provider.selectedCropFilter.toLowerCase() == c['key']!.toLowerCase() ||
                                  CommodityHelper.getHindiName(provider.selectedCropFilter).toLowerCase() == c['name']!.toLowerCase();
                              final chipLabel = isHi ? c['name']! : c['english']!;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(chipLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  selected: isSelected,
                                  onSelected: (_) => provider.selectCropFilter(c['key']!),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (q) => provider.searchCommodity(q),
                        decoration: InputDecoration(
                          hintText: isHi
                              ? '🔍 फसल या मंडी का नाम खोजें (उदा: जीरा, सरसों, मेड़ता)...'
                              : '🔍 Search crop or mandi (e.g. Wheat, Mustard, Merta)...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    provider.searchCommodity('');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),

                  // Active Crop/Search Banner (Clear explanation & 1-tap view all without losing Mandi)
                  if (provider.selectedCropFilter.isNotEmpty || provider.searchQuery.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          String activeFilterName = '';
                          if (provider.selectedCropFilter.isNotEmpty) {
                            activeFilterName = isHi
                                ? CommodityHelper.getHindiName(provider.selectedCropFilter)
                                : (CommodityHelper.getEnglishName(provider.selectedCropFilter).isNotEmpty
                                    ? CommodityHelper.getEnglishName(provider.selectedCropFilter)
                                    : provider.selectedCropFilter);
                          } else if (provider.searchQuery.isNotEmpty) {
                            activeFilterName = '"${provider.searchQuery}"';
                          }

                          return Container(
                            margin: const EdgeInsets.fromLTRB(16, 2, 16, 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFA5D6A7), width: 1.2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.filter_alt_rounded, size: 16, color: Color(0xFF2E7D32)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: isHi ? 'दिखा रहे हैं: ' : 'Showing: ',
                                          style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
                                        ),
                                        TextSpan(
                                          text: activeFilterName,
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    _searchController.clear();
                                    provider.clearCropAndSearchFilter();
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E7D32),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.refresh_rounded, size: 13, color: Colors.white),
                                        const SizedBox(width: 4),
                                        Text(
                                          isHi ? 'सभी फसलें देखें' : 'View All Crops',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Total Count, Voice Bulletin Button & Active Filter Indicator
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                      child: Row(
                        children: [
                          Text(
                            isHi
                                ? 'कुल ${provider.rates.length} भाव उपलब्ध'
                                : 'Total ${provider.rates.length} rates available',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          if (provider.rates.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B5E20),
                                  foregroundColor: Colors.white,
                                  elevation: 1,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  minimumSize: const Size(0, 30),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.volume_up_rounded, size: 15, color: Colors.amberAccent),
                                label: Text(
                                  isHi ? 'भाव सुनें' : 'Listen Bulletin',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                                ),
                                onPressed: () {
                                  final loc = provider.selectedMarket.isNotEmpty
                                      ? provider.selectedMarket
                                      : (provider.selectedDistrict.isNotEmpty
                                          ? provider.selectedDistrict
                                          : provider.selectedState);
                                  TtsService().speakMandiBulletin(
                                    mandiOrDistrict: loc,
                                    rates: provider.rates,
                                  );
                                },
                              ),
                            ),
                          if (provider.selectedCropFilter.isNotEmpty || provider.searchQuery.isNotEmpty)
                            InkWell(
                              onTap: () {
                                _searchController.clear();
                                provider.clearCropAndSearchFilter();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.refresh_rounded, size: 14, color: Color(0xFF2E7D32)),
                                    const SizedBox(width: 3),
                                    Text(
                                      isHi ? 'सभी भाव देखें' : 'All Crops',
                                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF2E7D32), fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Rates List
                  if (provider.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: LoadingShimmer(itemCount: 6, height: 130),
                      ),
                    )
                  else if (provider.error.isNotEmpty && provider.rates.isEmpty)
                    SliverFillRemaining(
                      child: AppErrorWidget(
                        message: provider.error,
                        onRetry: () => provider.fetchRates(state: provider.selectedState),
                      ),
                    )
                  else if (provider.rates.isEmpty)
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          final isCropOrSearchEmpty = provider.selectedCropFilter.isNotEmpty || provider.searchQuery.isNotEmpty;
                          String emptyFilterName = '';
                          if (provider.selectedCropFilter.isNotEmpty) {
                            emptyFilterName = isHi
                                ? CommodityHelper.getHindiName(provider.selectedCropFilter)
                                : (CommodityHelper.getEnglishName(provider.selectedCropFilter).isNotEmpty
                                    ? CommodityHelper.getEnglishName(provider.selectedCropFilter)
                                    : provider.selectedCropFilter);
                          } else if (provider.searchQuery.isNotEmpty) {
                            emptyFilterName = '"${provider.searchQuery}"';
                          }

                          return Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isCropOrSearchEmpty ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                                  size: 54,
                                  color: isCropOrSearchEmpty ? Colors.orange.shade700 : AppColors.mandiAccent.withValues(alpha: 0.8),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  isCropOrSearchEmpty
                                      ? (isHi
                                          ? '${provider.selectedMarket.isNotEmpty ? provider.selectedMarket : (provider.selectedDistrict.isNotEmpty ? provider.selectedDistrict : "मंडी")} में आज $emptyFilterName का भाव दर्ज नहीं हुआ'
                                          : 'No rates for $emptyFilterName today in ${provider.selectedMarket.isNotEmpty ? provider.selectedMarket : provider.selectedDistrict}')
                                      : (provider.selectedMarket.isNotEmpty
                                          ? '${provider.selectedMarket} में आज कोई नई आवक दर्ज नहीं हुई'
                                          : (provider.selectedDistrict.isNotEmpty
                                              ? '${provider.selectedDistrict} जिले में आज कोई आवक दर्ज नहीं हुई'
                                              : '${DistrictHelper.getHindiStateName(provider.selectedState)} राज्य में आज कोई मंडी भाव दर्ज नहीं हुआ')),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isCropOrSearchEmpty
                                      ? (isHi
                                          ? 'आज इस मंडी में इस फसल की नीलामी/आवक दर्ज नहीं हुई है। इस मंडी की अन्य फसलों के भाव देखने के लिए नीचे बटन दबाएं:'
                                          : 'No trading recorded for this crop today. Tap below to see all other crop rates in this mandi:')
                                      : (isHi
                                          ? 'सरकारी पोर्टल (Agmarknet) पर आज की नीलामी/आवक दर्ज होते ही यहाँ ताज़ा भाव दिखने लगेंगे।'
                                          : 'Fresh arrivals will appear once updated on Agmarknet.'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 20),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    if (isCropOrSearchEmpty) ...[
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1B5E20),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                        ),
                                        icon: const Icon(Icons.grain_rounded, size: 18),
                                        label: Text(
                                          isHi ? '🌾 मंडी की अन्य सभी फसलें देखें' : '🌾 View All Other Crops In Mandi',
                                          style: const TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          provider.clearCropAndSearchFilter();
                                        },
                                      ),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.mandiAccent,
                                          side: const BorderSide(color: AppColors.mandiAccent, width: 1.2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                        ),
                                        icon: const Icon(Icons.storefront_rounded, size: 18),
                                        label: Text(
                                          isHi ? 'अन्य मंडियों में खोजें' : 'Search Across All Mandis',
                                          style: const TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                        onPressed: () {
                                          provider.viewAllMandis();
                                        },
                                      ),
                                    ] else ...[
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.mandiAccent,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                        ),
                                        icon: const Icon(Icons.storefront_rounded, size: 18),
                                        label: const Text('सभी प्रमुख मंडियों के भाव देखें', style: TextStyle(fontWeight: FontWeight.w800)),
                                        onPressed: () {
                                          _searchController.clear();
                                          provider.clearFilters();
                                          if (_tabController.index != 0) {
                                            _tabController.animateTo(0);
                                          }
                                        },
                                      ),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          side: const BorderSide(color: AppColors.primary, width: 1.2),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                        ),
                                        icon: const Icon(Icons.map_rounded, size: 18),
                                        label: const Text('दूसरा राज्य / ज़िला चुनें', style: TextStyle(fontWeight: FontWeight.w800)),
                                        onPressed: () {
                                          MandiStatePickerModal.show(context, provider);
                                        },
                                      ),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade700,
                                          side: BorderSide(color: Colors.grey.shade400, width: 1.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                        ),
                                        icon: const Icon(Icons.refresh_rounded, size: 18),
                                        label: const Text('ताज़ा करें', style: TextStyle(fontWeight: FontWeight.w700)),
                                        onPressed: () {
                                          provider.fetchRates(state: provider.selectedState);
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final rate = provider.rates[index];
                          final card = MandiRateCard(
                            rate: rate,
                            index: index,
                            isFavorite: provider.isFavorite(rate.commodity),
                            hasAlert: provider.hasActiveAlertFor(rate.commodity),
                            onToggleFavorite: () => provider.toggleFavorite(rate.commodity),
                            onSetAlert: () => MandiPriceAlertModal.show(context, rate, provider),
                            onComparePrices: () {
                              AdService.showInterstitialAd(
                                onDismissed: () => MandiPriceComparisonModal.show(context, rate, provider),
                                cooldownSeconds: 90,
                              );
                            },
                          );

                          // Show Google AdMob inline ad after every 5 items
                          if (index > 0 && index % 5 == 0) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InlineAdCard(enabled: AdService.enableMandiInlineCards),
                                card,
                              ],
                            );
                          }

                          return card;
                        },
                        childCount: provider.rates.length,
                      ),
                    ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: BannerAdWidget(enabled: AdService.enableMandiBanner, showAdBadge: true),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 90)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context, MandiProvider provider) {
    final localeProv = context.watch<LocaleProvider>();
    final isHi = localeProv.isHindi;
    final distName = provider.selectedDistrict.isNotEmpty
        ? (isHi ? DistrictHelper.getHindiName(provider.selectedDistrict) : provider.selectedDistrict)
        : (isHi ? 'सभी जिले' : 'All Districts');
    final stateName = isHi ? DistrictHelper.getHindiStateName(provider.selectedState) : provider.selectedState;
    final homeDistName = isHi ? DistrictHelper.getHindiName(provider.userHomeDistrict) : provider.userHomeDistrict;

    return Column(
      children: [
        if (provider.isBrowsingOtherLocation)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.shade700, width: 0.8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.brown, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isHi ? 'आप $stateName ($distName) देख रहे हैं' : 'Viewing $stateName ($distName)',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                ),
                InkWell(
                  onTap: () => provider.resetToHomeDistrict(),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE65100),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.my_location_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          isHi ? 'मेरी लोकेशन ($homeDistName)' : 'My Location ($homeDistName)',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              // State Picker
              Expanded(
                child: InkWell(
                  onTap: () => MandiStatePickerModal.show(context, provider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            stateName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // District Picker
              Expanded(
                child: InkWell(
                  onTap: () => MandiDistrictPickerModal.show(context, provider),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_city_rounded, size: 16, color: AppColors.mandiAccent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            distName,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildSelectedMandiHeader(BuildContext context, MandiProvider provider) {
    final localeProv = context.watch<LocaleProvider>();
    final isHi = localeProv.isHindi;
    final distName = isHi ? DistrictHelper.getHindiName(provider.selectedDistrict) : provider.selectedDistrict;
    final title = provider.selectedMarket.isNotEmpty
        ? provider.selectedMarket
        : '$distName (${isHi ? "सभी मंडियां" : "All Markets"})';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              provider.selectMarket('');
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded, size: 14, color: Color(0xFFE65100)),
                  const SizedBox(width: 4),
                  Text(
                    isHi ? 'सभी मंडियां' : 'All Mandis',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '🏬 $title',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandiSelector(BuildContext context, MandiProvider provider) {
    final localeProv = context.watch<LocaleProvider>();
    final isHi = localeProv.isHindi;
    final markets = provider.availableMarkets;
    if (markets.isEmpty) return const SizedBox.shrink();

    final distName = provider.selectedDistrict.isNotEmpty
        ? (isHi ? DistrictHelper.getHindiName(provider.selectedDistrict) : provider.selectedDistrict)
        : (isHi ? DistrictHelper.getHindiStateName(provider.selectedState) : provider.selectedState);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 16, color: Color(0xFFE65100)),
              const SizedBox(width: 6),
              Text(
                isHi ? '🏬 $distName की प्रमुख मंडियां (${markets.length})' : '🏬 $distName Markets (${markets.length})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
              const Spacer(),
              if (provider.selectedMarket.isNotEmpty)
                GestureDetector(
                  onTap: () => provider.selectMarket(''),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade300, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isHi ? 'सभी देखें' : 'View All', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.red)),
                        const SizedBox(width: 2),
                        const Icon(Icons.close_rounded, size: 12, color: Colors.red),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: markets.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  final isAllSelected = provider.selectedMarket.isEmpty;
                  return ChoiceChip(
                    label: Text(isHi ? 'सभी मंडियां' : 'All Mandis', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                    selected: isAllSelected,
                    selectedColor: const Color(0xFFE65100),
                    labelStyle: TextStyle(
                      color: isAllSelected ? Colors.white : null,
                      fontWeight: isAllSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                    onSelected: (_) => provider.selectMarket(''),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  );
                }
                final market = markets[idx - 1];
                final isSelected = provider.selectedMarket == market;
                final isNearest = provider.userHomeMarket.isNotEmpty &&
                    (provider.userHomeMarket.toLowerCase() == market.toLowerCase() ||
                        market.toLowerCase().contains(provider.userHomeMarket.toLowerCase()));
                final count = provider.getRatesCountForMarket(market);
                final displayName = market
                    .replaceAll('APMC', '')
                    .trim();

                final labelText = isNearest
                    ? (count > 0 ? '📍 $displayName (${isHi ? "नजदीकी" : "Nearest"}: $count)' : '📍 $displayName (${isHi ? "नजदीकी" : "Nearest"})')
                    : (count > 0 ? '$displayName ($count)' : displayName);

                return ChoiceChip(
                  avatar: isSelected
                      ? const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white)
                      : (isNearest ? const Icon(Icons.my_location_rounded, size: 13, color: Color(0xFFE65100)) : null),
                  label: Text(
                    labelText,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected || isNearest ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFE65100),
                  onSelected: (_) => provider.selectMarket(market),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
