import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/mandi_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/commodity_helper.dart';
import '../../utils/district_helper.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/notification_center_sheet.dart';
import 'widgets/mandi_rate_card.dart';
import 'widgets/mandi_state_picker_modal.dart';
import 'widgets/mandi_district_picker_modal.dart';
import 'widgets/mandi_price_comparison_modal.dart';
import 'widgets/mandi_price_alert_modal.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../widgets/ads/inline_ad_card.dart';
import '../../widgets/ads/custom_sponsor_card.dart';
import '../../services/ad_service.dart';

class MandiScreen extends StatefulWidget {
  const MandiScreen({super.key});

  @override
  State<MandiScreen> createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = context.read<MandiProvider>();
        if (_tabController.index == 0) {
          if (provider.selectedDistrict.isEmpty) {
            provider.resetToHomeDistrict();
          }
        } else if (_tabController.index == 1) {
          if (provider.selectedDistrict.isNotEmpty) {
            provider.viewAllMandis();
          }
        }
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MandiProvider>();
      final weatherProv = context.read<WeatherProvider>();

      if (provider.userHomeDistrict.isEmpty || !weatherProv.isGpsLocation) {
        await weatherProv.fetchUserLocation(mandiProvider: provider);
      } else if (provider.rates.isEmpty && !provider.isLoading) {
        provider.fetchRates(
          state: provider.selectedState,
          district: provider.selectedDistrict,
          market: provider.selectedMarket,
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
                  title: const Text(
                    '🏪 मंडी भाव लाइव',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white),
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
                        tabs: const [
                          Tab(
                            height: 38,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_rounded, size: 16),
                                SizedBox(width: 4),
                                Text('मेरा ज़िला'),
                              ],
                            ),
                          ),
                          Tab(
                            height: 38,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.account_balance_rounded, size: 16),
                                SizedBox(width: 4),
                                Text('पूरा राज्य'),
                              ],
                            ),
                          ),
                          Tab(
                            height: 38,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.public_rounded, size: 16),
                                SizedBox(width: 4),
                                Text('देश भर की'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.my_location_rounded, color: Colors.white),
                      tooltip: 'GPS लोकेशन से मंडी सेट करें',
                      onPressed: () async {
                        final weatherProv = context.read<WeatherProvider>();
                        final res = await weatherProv.fetchUserLocation(mandiProvider: provider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res.isGps
                                  ? '📍 मंडी लोकेशन: ${res.cityName} (${res.mandi}) सेट हो गई!'
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
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                              onPressed: () => NotificationCenterSheet.show(context),
                              tooltip: 'सूचनाएं व भाव अलर्ट',
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
                      tooltip: 'ताज़ा करें',
                    ),
                  ],
                ),

                // Location Header Bar
                SliverToBoxAdapter(
                  child: _buildLocationBar(context, provider),
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
                          _buildCategoryButton('सभी भाव', Icons.grid_view_rounded, provider.selectedCategory == 'all', () => provider.selectCategory('all')),
                          _buildCategoryButton('अनाज व दलहन', Icons.grain_rounded, provider.selectedCategory == 'crops', () => provider.selectCategory('crops')),
                          _buildCategoryButton('सब्जी व फल', Icons.eco_rounded, provider.selectedCategory == 'vegetables', () => provider.selectCategory('vegetables')),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Popular Crops Filter
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
                            label: const Text('सभी', style: TextStyle(fontWeight: FontWeight.bold)),
                            selected: provider.selectedCropFilter.isEmpty,
                            onSelected: (_) => provider.selectCropFilter(''),
                          ),
                        ),
                        ...(provider.selectedCategory == 'vegetables'
                                ? CommodityHelper.popularVegetables
                                : CommodityHelper.popularCrops)
                            .map((c) {
                          final isSelected = provider.selectedCropFilter == c['key'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(c['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
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
                        hintText: '🔍 फसल या मंडी का नाम खोजें (उदा: जीरा, सरसों, मेड़ता)...',
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

                // Total Count & Active Filter Indicator
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'कुल ${provider.rates.length} भाव उपलब्ध',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                        ),
                        if (provider.selectedMarket.isNotEmpty || provider.selectedDistrict.isNotEmpty || provider.selectedCropFilter.isNotEmpty || provider.searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              provider.clearFilters();
                            },
                            child: const Text(
                              'फ़िल्टर हटाएं ✕',
                              style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold),
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
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text('कोई मंडी भाव नहीं मिला', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                provider.clearFilters();
                              },
                              child: const Text('सभी फ़िल्टर साफ़ करें'),
                            ),
                          ],
                        ),
                      ),
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

                        // Show custom sponsor ad or Google AdMob inline ad after every 5 items
                        if (index > 0 && index % 5 == 0) {
                          final showCustom = AdService.enableCustomSponsorAds && AdService.customAds.isNotEmpty;
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showCustom)
                                CustomSponsorCard(ad: AdService.customAds.first)
                              else
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
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationBar(BuildContext context, MandiProvider provider) {
    final distHindi = provider.selectedDistrict.isNotEmpty ? DistrictHelper.getHindiName(provider.selectedDistrict) : 'सभी जिले';
    final stateHindi = DistrictHelper.getHindiStateName(provider.selectedState);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
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
                        stateHindi,
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
                        distHindi,
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
