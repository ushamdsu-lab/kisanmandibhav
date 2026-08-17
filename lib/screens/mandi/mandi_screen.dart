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
import '../../services/tts_service.dart';
import '../../widgets/mandi/voice_bulletin_bar.dart';

class MandiScreen extends StatefulWidget {
  const MandiScreen({super.key});

  @override
  State<MandiScreen> createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  bool _showAllDistrictRates = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final provider = context.read<MandiProvider>();
        setState(() {
          _showAllDistrictRates = false;
        });
        if (_tabController.index == 0) {
          if (provider.selectedDistrict.isEmpty) {
            provider.resetToHomeDistrict();
          }
        } else if (_tabController.index == 1) {
          if (provider.selectedDistrict.isNotEmpty) {
            provider.viewAllMandis();
          }
        }
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
      bottomNavigationBar: const VoiceBulletinBar(),
      body: Consumer<MandiProvider>(
        builder: (context, provider, _) {
          final isDistrictMandiListView = _tabController.index == 0 &&
              provider.selectedDistrict.isNotEmpty &&
              provider.selectedMarket.isEmpty &&
              !_showAllDistrictRates &&
              provider.availableMarkets.isNotEmpty;

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

                if (isDistrictMandiListView) ...[
                  // 1. District Mandis Selection View (First screen when district is active)
                  ..._buildDistrictMandisSlivers(context, provider),
                ] else ...[
                  // 2. Mandi Crop Prices Board (When a mandi is clicked or viewing all rates)
                  if (provider.selectedMarket.isNotEmpty || _showAllDistrictRates)
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

                  // Total Count, Voice Bulletin Button & Active Filter Indicator
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                      child: Row(
                        children: [
                          Text(
                            'कुल ${provider.rates.length} भाव उपलब्ध',
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
                                label: const Text(
                                  'भाव सुनें',
                                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
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
                      child: Container(
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
                            Icon(Icons.inventory_2_outlined, size: 54, color: AppColors.mandiAccent.withValues(alpha: 0.8)),
                            const SizedBox(height: 12),
                            Text(
                              provider.selectedMarket.isNotEmpty
                                  ? '${provider.selectedMarket} में आज कोई नई आवक दर्ज नहीं हुई'
                                  : (provider.selectedDistrict.isNotEmpty
                                      ? '${provider.selectedDistrict} जिले में आज कोई आवक दर्ज नहीं हुई'
                                      : 'आज कोई मंडी भाव दर्ज नहीं हुआ'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'सरकारी पोर्टल (Agmarknet) पर आज की नीलामी/आवक दर्ज होते ही यहाँ ताज़ा भाव दिखने लगेंगे।',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mandiAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              icon: const Icon(Icons.storefront_rounded, size: 18),
                              label: const Text('सभी मंडियों के भाव देखें', style: TextStyle(fontWeight: FontWeight.w700)),
                              onPressed: () {
                                _searchController.clear();
                                provider.clearFilters();
                              },
                            ),
                          ],
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
                ],

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

  List<Widget> _buildDistrictMandisSlivers(BuildContext context, MandiProvider provider) {
    final distHindi = DistrictHelper.getHindiName(provider.selectedDistrict);
    final markets = provider.availableMarkets;

    return [
      // District Mandis Header Banner
      SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE65100).withValues(alpha: 0.12),
                AppColors.primary.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE65100).withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE65100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 $distHindi जिले की प्रमुख मंडियां (${markets.length})',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'फसलों के ताज़ा भाव देखने के लिए अपनी मंडी चुनें:',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // List of Mandis Cards
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final market = markets[index];
            final count = provider.getRatesCountForMarket(market);
            final sampleCrops = provider.getSampleCropsForMarket(market);

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    provider.selectMarket(market);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE65100).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Color(0xFFE65100), size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    market,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        count > 0 ? '$count फसलों के ताज़ा भाव उपलब्ध' : 'आज की नीलामी भाव',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: count > 0 ? Colors.green.shade700 : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B5E20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'भाव देखें',
                                    style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (sampleCrops.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: sampleCrops.map((crop) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  crop,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: markets.length,
        ),
      ),

      // View All District Crops Button
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            ),
            icon: const Icon(Icons.grid_view_rounded, size: 18, color: AppColors.primary),
            label: Text(
              '📊 $distHindi जिले के सभी भाव एक साथ देखें',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
            ),
            onPressed: () {
              setState(() {
                _showAllDistrictRates = true;
              });
            },
          ),
        ),
      ),
    ];
  }

  Widget _buildSelectedMandiHeader(BuildContext context, MandiProvider provider) {
    final distHindi = DistrictHelper.getHindiName(provider.selectedDistrict);
    final title = provider.selectedMarket.isNotEmpty
        ? provider.selectedMarket
        : '$distHindi (सभी मंडियां)';

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
              setState(() {
                _showAllDistrictRates = false;
              });
              provider.selectMarket('');
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 14, color: Color(0xFFE65100)),
                  SizedBox(width: 4),
                  Text(
                    'सभी मंडियां',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFE65100)),
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
    final markets = provider.availableMarkets;
    if (markets.isEmpty) return const SizedBox.shrink();

    final distName = provider.selectedDistrict.isNotEmpty
        ? DistrictHelper.getHindiName(provider.selectedDistrict)
        : DistrictHelper.getHindiStateName(provider.selectedState);

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
                '🏬 $distName की प्रमुख मंडियां (${markets.length})',
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
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('सभी देखें', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.red)),
                        SizedBox(width: 2),
                        Icon(Icons.close_rounded, size: 12, color: Colors.red),
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
                    label: const Text('सभी मंडियां', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
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
                final count = provider.getRatesCountForMarket(market);
                final displayName = market
                    .replaceAll('APMC', '')
                    .trim();

                return ChoiceChip(
                  avatar: isSelected
                      ? const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white)
                      : null,
                  label: Text(
                    count > 0 ? '$displayName ($count)' : displayName,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
