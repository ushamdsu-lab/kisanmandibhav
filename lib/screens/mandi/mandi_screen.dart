import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../models/mandi_rate.dart';
import '../../providers/mandi_provider.dart';
import '../../providers/weather_provider.dart';
import '../../utils/commodity_helper.dart';
import '../../utils/district_helper.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/notification_center_sheet.dart';

class MandiScreen extends StatefulWidget {
  const MandiScreen({super.key});

  @override
  State<MandiScreen> createState() => _MandiScreenState();
}

class _MandiScreenState extends State<MandiScreen> {
  final _searchController = TextEditingController();

  static const List<Map<String, String>> _primaryStates = [
    {'name': 'Rajasthan', 'label': 'राजस्थान'},
    {'name': 'Madhya Pradesh', 'label': 'मध्य प्रदेश'},
    {'name': 'Gujarat', 'label': 'गुजरात'},
    {'name': 'Punjab', 'label': 'पंजाब'},
    {'name': 'Haryana', 'label': 'हरियाणा'},
    {'name': 'Uttar Pradesh', 'label': 'उत्तर प्रदेश'},
    {'name': 'Maharashtra', 'label': 'महाराष्ट्र'},
    {'name': 'Karnataka', 'label': 'कर्नाटक'},
    {'name': 'Tamil Nadu', 'label': 'तमिलनाडु'},
    {'name': 'Andhra Pradesh', 'label': 'आंध्र प्रदेश'},
    {'name': 'Telangana', 'label': 'तेलंगाना'},
    {'name': 'Bihar', 'label': 'बिहार'},
    {'name': 'West Bengal', 'label': 'पश्चिम बंगाल'},
    {'name': 'Odisha', 'label': 'ओडिशा'},
    {'name': 'Chhattisgarh', 'label': 'छत्तीसगढ़'},
    {'name': 'Jharkhand', 'label': 'झारखंड'},
    {'name': 'Uttarakhand', 'label': 'उत्तराखंड'},
    {'name': 'Himachal Pradesh', 'label': 'हिमाचल प्रदेश'},
    {'name': 'Assam', 'label': 'असम'},
    {'name': 'Kerala', 'label': 'केरल'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MandiProvider>();
      if (provider.rates.isEmpty && !provider.isLoading) {
        provider.fetchRates(state: provider.selectedState.isEmpty ? provider.selectedState : provider.selectedState);
      }
    });
  }

  void _triggerRateNotificationIfLoaded(MandiProvider provider) {
    if (provider.rates.isNotEmpty && !provider.isLoading) {
      final notifProv = context.read<NotificationProvider>();
      notifProv.onMandiRatesUpdated(
        state: provider.selectedState,
        district: provider.selectedDistrict,
        mandi: provider.selectedMarket.isNotEmpty ? provider.selectedMarket : provider.selectedState,
        rates: provider.rates,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- State Picker Modal ---
  void _showStatePicker(BuildContext context, MandiProvider provider) {
    final searchCtrl = TextEditingController();

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
            final query = searchCtrl.text.trim().toLowerCase();
            final filteredStates = query.isEmpty
                ? _primaryStates
                : _primaryStates.where((s) {
                    final label = s['label']!.toLowerCase();
                    final name = s['name']!.toLowerCase();
                    return label.contains(query) || name.contains(query);
                  }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📍 राज्य चुनें (Select State)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: 'राज्य का नाम खोजें (उदा: राजस्थान, पंजाब, UP)...',
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
                  const Divider(height: 1),
                  Expanded(
                    child: filteredStates.isEmpty
                        ? const Center(child: Text('कोई राज्य नहीं मिला'))
                        : ListView.builder(
                            itemCount: filteredStates.length,
                            itemBuilder: (context, index) {
                              final st = filteredStates[index];
                              final isSelected = provider.selectedState.toLowerCase() == st['name']!.toLowerCase();

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.map_rounded,
                                    color: isSelected ? AppColors.primary : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  st['label']!,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : null,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(st['name']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                    : null,
                                onTap: () {
                                  provider.selectState(st['name']!);
                                  Navigator.pop(ctx);
                                },
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

  // --- District Picker Modal ---
  void _showDistrictPicker(BuildContext context, MandiProvider provider) {
    final districts = provider.availableDistricts;
    final searchCtrl = TextEditingController();

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
            final query = searchCtrl.text.toLowerCase();
            final filteredDistricts = query.isEmpty
                ? districts
                : districts.where((d) =>
                    d.toLowerCase().contains(query) ||
                    DistrictHelper.getHindiName(d).toLowerCase().contains(query)
                  ).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '🗺️ जिला चुनें (${districts.length} जिले)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  // --- GPS Location Mandi Tile ---
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.my_location_rounded, color: Colors.green),
                    ),
                    title: const Text('📍 मेरी वर्तमान GPS लोकेशन की मंडी', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.green)),
                    subtitle: const Text('लाइव GPS स्थान के अनुसार मंडी डेटा सेट करें', style: TextStyle(fontSize: 12)),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final weatherProv = context.read<WeatherProvider>();
                      final res = await weatherProv.fetchUserLocation(mandiProvider: provider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res.isGps
                                ? '📍 आपकी मंडी लोकेशन: ${res.cityName} (${res.mandi}) सेट हो गई!'
                                : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                            backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                          ),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: 'जिले का नाम खोजें (उदा: बीकानेर, नागौर, बीकानेर, Bikaner, Kota)...',
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
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: provider.selectedDistrict.isEmpty
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.map_rounded,
                        color: provider.selectedDistrict.isEmpty ? AppColors.primary : Colors.grey,
                      ),
                    ),
                    title: const Text('सभी जिले (All Districts)', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: provider.selectedDistrict.isEmpty
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : null,
                    onTap: () {
                      provider.selectDistrict('');
                      Navigator.pop(ctx);
                    },
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filteredDistricts.isEmpty
                        ? const Center(child: Text('कोई जिला नहीं मिला'))
                        : ListView.builder(
                            itemCount: filteredDistricts.length,
                            itemBuilder: (context, index) {
                              final dist = filteredDistricts[index];
                              final distHindi = DistrictHelper.getHindiName(dist);
                              final isSelected = provider.selectedDistrict.toLowerCase() == dist.toLowerCase();

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_city_rounded,
                                    color: isSelected ? AppColors.primary : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  distHindi,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primary : null,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: distHindi != dist ? Text(dist, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                    : null,
                                onTap: () {
                                  provider.selectDistrict(dist);
                                  Navigator.pop(ctx);
                                },
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

  // --- Mandi Picker Modal ---
  void _showMandiPicker(BuildContext context, MandiProvider provider) {
    final markets = provider.availableMarkets;
    final searchCtrl = TextEditingController();

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
            final query = searchCtrl.text.toLowerCase();
            final filteredMarkets = query.isEmpty
                ? markets
                : markets.where((m) => m.toLowerCase().contains(query)).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📍 मंडी चुनें (${markets.length} मंडियां)',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: InputDecoration(
                        hintText: 'मंडी का नाम खोजें (उदा: Nokha, Merta, Jaipur)...',
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
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: provider.selectedMarket.isEmpty
                            ? AppColors.mandiAccent.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.store_rounded,
                        color: provider.selectedMarket.isEmpty ? AppColors.mandiAccent : Colors.grey,
                      ),
                    ),
                    title: const Text('सभी मंडियां (All Mandis)', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: provider.selectedMarket.isEmpty
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.mandiAccent)
                        : null,
                    onTap: () {
                      provider.selectMarket('');
                      Navigator.pop(ctx);
                    },
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filteredMarkets.isEmpty
                        ? const Center(child: Text('कोई मंडी नहीं मिली'))
                        : ListView.builder(
                            itemCount: filteredMarkets.length,
                            itemBuilder: (context, index) {
                              final market = filteredMarkets[index];
                              final isSelected = provider.selectedMarket == market;

                              return ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.mandiAccent.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    color: isSelected ? AppColors.mandiAccent : Colors.grey,
                                  ),
                                ),
                                title: Text(
                                  DistrictHelper.getHindiMarketName(market, provider.selectedDistrict),
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.mandiAccent : null,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(market, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: AppColors.mandiAccent)
                                    : null,
                                onTap: () {
                                  provider.selectMarket(market);
                                  Navigator.pop(ctx);
                                },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MandiProvider>(
        builder: (context, provider, _) {

          return RefreshIndicator(
            onRefresh: () => provider.fetchRates(state: provider.selectedState),
            child: CustomScrollView(
              slivers: [
                // --- App Bar ---
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      '🏪 मंडी भाव लाइव',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.mandiGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.my_location_rounded),
                      tooltip: 'लाइव GPS मंडी स्थान सेट करें',
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
                              icon: const Icon(Icons.notifications_outlined, size: 24),
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
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () async {
                        await provider.fetchRates(state: provider.selectedState);
                        if (context.mounted) {
                          _triggerRateNotificationIfLoaded(provider);
                        }
                      },
                      tooltip: 'ताज़ा करें',
                    ),
                  ],
                ),

                // --- 1. 📍 Local District / Mandi Context Hero Card ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.mandiAccent.withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            provider.selectedDistrict.isNotEmpty
                                                ? '📍 जिला: ${DistrictHelper.getHindiName(provider.selectedDistrict)} (${provider.selectedDistrict})'
                                                : '📍 राज्य: ${_primaryStates.firstWhere((s) => s['name']!.toLowerCase() == provider.selectedState.toLowerCase(), orElse: () => {'label': provider.selectedState})['label']!}',
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (provider.isViewingHomeDistrict) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text('आपका जिला', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      provider.selectedDistrict.isNotEmpty
                                          ? 'आपके जिले की मंडियों (${provider.availableMarkets.length} मंडियां) के आज के ताज़ा भाव'
                                          : 'पूरे राज्य की सभी मंडियों के भाव दिखाए जा रहे हैं',
                                      style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (provider.selectedDistrict.isNotEmpty) ...[
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.explore_rounded, size: 15),
                                    label: const Text('🔍 अन्य मंडियों के भाव देखें', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      side: const BorderSide(color: AppColors.primary),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => provider.viewAllMandis(),
                                  ),
                                ),
                              ] else if (provider.userHomeDistrict.isNotEmpty) ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.home_rounded, size: 15, color: Colors.white),
                                    label: Text(
                                      '📍 वापस अपने जिले (${DistrictHelper.getHindiName(provider.userHomeDistrict)}) के भाव देखें',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => provider.resetToHomeDistrict(),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.tune_rounded, size: 15),
                                label: const Text('जिला बदलें', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _showDistrictPicker(context, provider),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- 2. Location / State / District / Mandi Filter Bar ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 3 Unified Selector Boxes: State, District, Mandi
                        Row(
                          children: [
                            // 1. State Selector Box
                            Expanded(
                              child: InkWell(
                                onTap: () => _showStatePicker(context, provider),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: provider.selectedState.isNotEmpty
                                        ? AppColors.mandiAccent.withValues(alpha: 0.12)
                                        : Theme.of(context).cardTheme.color,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: provider.selectedState.isNotEmpty
                                          ? AppColors.mandiAccent
                                          : Colors.grey.withValues(alpha: 0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.map_rounded,
                                        size: 18,
                                        color: AppColors.mandiAccent,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '1️⃣ राज्य (State)',
                                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              _primaryStates.firstWhere(
                                                (s) => s['name']!.toLowerCase() == provider.selectedState.toLowerCase(),
                                                orElse: () => {'label': provider.selectedState},
                                              )['label']!,
                                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 2. District Selector Box
                            Expanded(
                              child: InkWell(
                                onTap: () => _showDistrictPicker(context, provider),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: provider.selectedDistrict.isNotEmpty
                                        ? AppColors.primary.withValues(alpha: 0.12)
                                        : Theme.of(context).cardTheme.color,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: provider.selectedDistrict.isNotEmpty
                                          ? AppColors.primary
                                          : Colors.grey.withValues(alpha: 0.3),
                                      width: provider.selectedDistrict.isNotEmpty ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_city_rounded,
                                        size: 18,
                                        color: provider.selectedDistrict.isNotEmpty ? AppColors.primary : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '2️⃣ जिला (District)',
                                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              provider.selectedDistrict.isEmpty
                                                  ? 'सभी जिले'
                                                  : DistrictHelper.getHindiName(provider.selectedDistrict),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: provider.selectedDistrict.isNotEmpty ? AppColors.primary : null,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 3. Mandi Selector Box
                            Expanded(
                              child: InkWell(
                                onTap: () => _showMandiPicker(context, provider),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: provider.selectedMarket.isNotEmpty
                                        ? AppColors.mandiAccent.withValues(alpha: 0.12)
                                        : Theme.of(context).cardTheme.color,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: provider.selectedMarket.isNotEmpty
                                          ? AppColors.mandiAccent
                                          : Colors.grey.withValues(alpha: 0.3),
                                      width: provider.selectedMarket.isNotEmpty ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.storefront_rounded,
                                        size: 18,
                                        color: provider.selectedMarket.isNotEmpty ? AppColors.mandiAccent : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              '3️⃣ मंडी (Mandi)',
                                              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              provider.selectedMarket.isEmpty
                                                  ? 'सभी मंडियां'
                                                  : DistrictHelper.getHindiMarketName(provider.selectedMarket, provider.selectedDistrict),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: provider.selectedMarket.isNotEmpty ? AppColors.mandiAccent : null,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Colors.grey),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Quick Mandi Filter Chips for currently selected District
                        if (provider.selectedDistrict.isNotEmpty && provider.availableMarkets.length > 1) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 34,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: const Text('सभी मंडियां', style: TextStyle(fontSize: 11)),
                                    selected: provider.selectedMarket.isEmpty,
                                    onSelected: (_) => provider.selectMarket(''),
                                    selectedColor: AppColors.mandiAccent.withValues(alpha: 0.2),
                                  ),
                                ),
                                ...provider.availableMarkets.map((mandi) {
                                  final isSel = provider.selectedMarket == mandi;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(
                                        DistrictHelper.getHindiMarketName(mandi, provider.selectedDistrict),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      selected: isSel,
                                      onSelected: (_) => provider.selectMarket(mandi),
                                      selectedColor: AppColors.mandiAccent.withValues(alpha: 0.2),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Quick Clean State Text Chips (No emojis)
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _primaryStates.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 6),
                            itemBuilder: (context, index) {
                              final st = _primaryStates[index];
                              final isSelected = provider.selectedState.toLowerCase() == st['name']!.toLowerCase();
                              return InkWell(
                                onTap: () => provider.selectState(st['name']!),
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? const LinearGradient(colors: AppColors.mandiGradient)
                                        : null,
                                    color: isSelected ? null : Theme.of(context).cardTheme.color,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.mandiAccent
                                          : Colors.grey.withValues(alpha: 0.25),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      st['label']!,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 12,
                                        color: isSelected ? Colors.white : null,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- 3. CATEGORY SWITCHER (अनाज/फसलें vs सब्जियां/फल vs सभी) ---
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
                          _buildCategoryTab(
                            context: context,
                            label: '🌾 अनाज व दलहन',
                            count: provider.totalCropsCount,
                            isSelected: provider.selectedCategory == 'crops',
                            onTap: () => provider.selectCategory('crops'),
                            activeColor: AppColors.primary,
                          ),
                          _buildCategoryTab(
                            context: context,
                            label: '🥦 सब्जियां व फल',
                            count: provider.totalVegetablesCount,
                            isSelected: provider.selectedCategory == 'vegetables',
                            onTap: () => provider.selectCategory('vegetables'),
                            activeColor: AppColors.mandiAccent,
                          ),
                          _buildCategoryTab(
                            context: context,
                            label: '🌐 सभी',
                            count: null,
                            isSelected: provider.selectedCategory == 'all',
                            onTap: () => provider.selectCategory('all'),
                            activeColor: AppColors.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // --- 4. Popular Crops Quick Filter Strip (Dynamic by Category) ---
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 16, 4),
                        child: Text(
                          provider.selectedCategory == 'vegetables'
                              ? '🥦 प्रमुख सब्जियां व फल (Tap to Filter):'
                              : '⚡ मुख्य फसलें (Tap to Filter):',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: FilterChip(
                                label: const Text('सभी'),
                                selected: provider.selectedCropFilter.isEmpty,
                                onSelected: (_) => provider.selectCropFilter(''),
                                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                checkmarkColor: AppColors.primary,
                              ),
                            ),
                            ...(provider.selectedCategory == 'vegetables'
                                    ? CommodityHelper.popularVegetables
                                    : CommodityHelper.popularCrops)
                                .map((crop) {
                              final isSelected = provider.selectedCropFilter == crop['key'];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: FilterChip(
                                  avatar: Text(crop['icon']!, style: const TextStyle(fontSize: 14)),
                                  label: Text(crop['name']!, style: const TextStyle(fontSize: 12)),
                                  selected: isSelected,
                                  onSelected: (_) => provider.selectCropFilter(crop['key']!),
                                  selectedColor: AppColors.mandiAccent.withValues(alpha: 0.2),
                                  checkmarkColor: AppColors.mandiAccent,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // --- 5. Search Bar ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (q) => provider.searchCommodity(q),
                      decoration: InputDecoration(
                        hintText: provider.selectedCategory == 'vegetables'
                            ? '🔍 सब्जी या फल खोजें (उदा: टमाटर, मिर्च, भिंडी, बैंगन)...'
                            : '🔍 फसल खोजें (उदा: मूंग, तिल, मोठ, मूंगफली, ग्वार, सरसों)...',
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

                // --- Active Results Count & Active Filter Clear ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                    child: Row(
                      children: [
                        Text(
                          'कुल ${provider.rates.length} भाव उपलब्ध',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        if (provider.selectedMarket.isNotEmpty || provider.selectedDistrict.isNotEmpty || provider.selectedCropFilter.isNotEmpty || provider.searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              provider.clearFilters();
                            },
                            child: const Text(
                              'फ़िल्टर हटाएं ✕',
                              style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // --- Mandi Rate Cards ---
                if (provider.isLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: LoadingShimmer(itemCount: 6, height: 120),
                    ),
                  )
                else if (provider.error.isNotEmpty)
                  SliverFillRemaining(
                    child: AppErrorWidget(
                      message: provider.error,
                      onRetry: () => provider.fetchRates(state: provider.selectedState),
                    ),
                  )
                else if (provider.rates.isEmpty)
                  SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: provider.selectedCategory == 'vegetables'
                          ? Icons.eco_outlined
                          : Icons.store_outlined,
                      title: 'कोई भाव उपलब्ध नहीं है',
                      subtitle: provider.selectedCategory == 'vegetables'
                          ? 'इस मंडी में आज सब्जी/फल का भाव नहीं मिला'
                          : 'कृपया दूसरा जिला, मंडी या फसल चुनें',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final rate = provider.rates[index];
                        return _buildMandiPriceCard(context, rate, provider, index);
                      },
                      childCount: provider.rates.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab({
    required BuildContext context,
    required String label,
    required int? count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              if (count != null && count > 0)
                Text(
                  '($count भाव)',
                  style: TextStyle(
                    fontSize: 9,
                    color: isSelected ? Colors.white.withValues(alpha: 0.9) : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMandiPriceCard(BuildContext context, MandiRate rate, MandiProvider provider, int index) {
    final isFav = provider.isFavorite(rate.commodity);
    final hindiName = CommodityHelper.getHindiName(rate.commodity);
    final englishName = CommodityHelper.getEnglishName(rate.commodity);
    final isVeg = CommodityHelper.isVegetableOrFruit(rate.commodity);
    final isUp = rate.trendDirection == 'up';
    final isDown = rate.trendDirection == 'down';
    final trendColor = isUp ? Colors.green : (isDown ? Colors.red : Colors.blue);

    final card = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: () => _showPriceTrendModal(context, rate),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Hindi Commodity Name (Bold) + English Name + Favorite
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isVeg ? AppColors.mandiGradient : AppColors.khetiGradient,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isVeg ? Icons.eco_rounded : Icons.grain_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prominent Hindi Name
                        Text(
                          hindiName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: isVeg ? AppColors.mandiAccent : AppColors.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // English subtitle
                        Text(
                          englishName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (rate.variety.isNotEmpty && rate.variety != 'Other')
                          Text(
                            'किस्म: ${rate.variety}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFav ? AppColors.secondary : AppColors.textSecondary,
                    ),
                    onPressed: () => provider.toggleFavorite(rate.commodity),
                    iconSize: 24,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Mandi & District Badge + Price Trend Chip
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 14,
                            color: isVeg ? AppColors.mandiAccent : AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${DistrictHelper.getHindiMarketName(rate.market, rate.district)} (${DistrictHelper.getHindiName(rate.district)})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trendColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isUp ? '📈 तेजी' : (isDown ? '📉 मंदी' : '⏸️ स्थिर'),
                          style: TextStyle(color: trendColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.analytics_rounded, size: 14, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

            // Prices Section (Smart Handling for Single Auction vs Range)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: (rate.minPrice == rate.maxPrice)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'स्थिर/एकसमान भाव (Flat Rate)',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'आज एक ही दर पर पूरा व्यापार हुआ',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '₹${rate.modalPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _priceColumn(context, 'न्यूनतम भाव', '₹${rate.minPrice.toInt()}', AppColors.priceDown),
                          Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
                          _priceColumn(context, 'मॉडल भाव', '₹${rate.modalPrice.toInt()}', AppColors.mausamAccent),
                          Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.2)),
                          _priceColumn(context, 'अधिकतम भाव', '₹${rate.maxPrice.toInt()}', AppColors.priceUp),
                        ],
                      ),
              ),
              const SizedBox(height: 8),

              // Arrival Date & Unit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📅 आगमन तिथि: ${rate.arrivalDate}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                  const Text(
                    'दर: प्रति क्विंटल (₹/Qtl)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return card.animate().fadeIn(delay: Duration(milliseconds: (index * 30).clamp(0, 300)), duration: const Duration(milliseconds: 250));
  }

  Widget _priceColumn(BuildContext context, String label, String price, Color color) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              price,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showPriceTrendModal(BuildContext context, MandiRate rate) {
    final provider = context.read<MandiProvider>();
    final hindiName = CommodityHelper.getHindiName(rate.commodity);
    final englishName = CommodityHelper.getEnglishName(rate.commodity);
    final history = rate.getHistory7Days();
    final isUp = rate.trendDirection == 'up';
    final isDown = rate.trendDirection == 'down';
    final trendColor = isUp ? const Color(0xFF10B981) : (isDown ? const Color(0xFFEF4444) : const Color(0xFF3B82F6));
    final absChg = rate.priceChange.abs().round();
    final comparisonRates = provider.getRatesForCommodity(rate);
    final highestRate = comparisonRates.isNotEmpty ? comparisonRates.first : rate;
    final lowestRate = comparisonRates.isNotEmpty ? comparisonRates.last : rate;

    bool showAllMandis = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final displayedMandis = showAllMandis
                ? comparisonRates
                : comparisonRates.take(4).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Drag Handle & Close Button Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                    child: Row(
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
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
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'बंद करें ✕',
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- 1. Header Banner Card ---
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  trendColor.withValues(alpha: 0.15),
                                  AppColors.primary.withValues(alpha: 0.08),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: trendColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: trendColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isUp ? Icons.trending_up_rounded : (isDown ? Icons.trending_down_rounded : Icons.trending_flat_rounded),
                                    color: trendColor,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            hindiName,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 20,
                                                ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '($englishName)',
                                            style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_rounded, size: 13, color: AppColors.primary),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${DistrictHelper.getHindiMarketName(rate.market, rate.district)}, ${DistrictHelper.getHindiName(rate.district)} • ${rate.arrivalDate}',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Trend Pill Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: trendColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: trendColor.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isUp ? '📈 +₹$absChg' : (isDown ? '📉 -₹$absChg' : '⏸️ स्थिर'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          // --- 2. Price Tiles (Min, Modal, Max) ---
                          Row(
                            children: [
                              _buildModernPriceTile(
                                context: context,
                                label: 'न्यूनतम भाव',
                                price: '₹${rate.minPrice.toInt()}',
                                color: AppColors.priceDown,
                                bgColor: AppColors.priceDown.withValues(alpha: 0.1),
                                icon: Icons.south_west_rounded,
                              ),
                              const SizedBox(width: 10),
                              _buildModernPriceTile(
                                context: context,
                                label: 'मॉडल (औसत) भाव',
                                price: '₹${rate.modalPrice.toInt()}',
                                color: AppColors.primary,
                                bgColor: AppColors.primary.withValues(alpha: 0.12),
                                icon: Icons.star_rounded,
                                isFeatured: true,
                              ),
                              const SizedBox(width: 10),
                              _buildModernPriceTile(
                                context: context,
                                label: 'अधिकतम भाव',
                                price: '₹${rate.maxPrice.toInt()}',
                                color: AppColors.priceUp,
                                bgColor: AppColors.priceUp.withValues(alpha: 0.1),
                                icon: Icons.north_east_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- Crop Medicine & Advisory Shortcut Banner ---
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              final cropId = CommodityHelper.getCropIdForCommodity(rate.commodity);
                              if (cropId != null) {
                                context.push('/kheti/crop/$cropId');
                              } else {
                                context.go('/kheti');
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.khetiGradient.first.withValues(alpha: 0.15),
                                    AppColors.khetiGradient.last.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.medication_liquid_rounded, color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '🌿 ${CommodityHelper.getHindiName(rate.commodity)} के रोग, दवाइयां व खाद सलाह देखें ➔',
                                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'कीट लक्षण, कीटनाशक दवाइयां व उर्वरक कैलकुलेटर',
                                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // --- 3. 7-Day Visual Price Chart ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '📊 7-दिवसीय भाव इतिहास ग्राफ',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const Text(
                                '₹ / क्विंटल',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                            ),
                            child: SizedBox(
                              height: 130,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: history.map((pt) {
                                  final maxHistPrice = history.map((h) => h.price).reduce(max);
                                  final minHistPrice = history.map((h) => h.price).reduce(min);
                                  final range = (maxHistPrice - minHistPrice).abs();
                                  final double flexRatio = range == 0 ? 0.6 : ((pt.price - minHistPrice) / range).clamp(0.25, 1.0);
                                  final isToday = pt.dateStr == 'आज';

                                  return Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        // Price tag above bar
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isToday ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '₹${pt.price.toInt()}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: isToday ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Bar
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          height: (70 * flexRatio).clamp(24.0, 70.0),
                                          width: isToday ? 22 : 16,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isToday
                                                  ? [AppColors.primary, AppColors.secondary]
                                                  : [AppColors.primary.withValues(alpha: 0.35), AppColors.primary.withValues(alpha: 0.2)],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius: BorderRadius.circular(6),
                                            boxShadow: isToday
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.primary.withValues(alpha: 0.4),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Date label
                                        Text(
                                          pt.dateStr,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                                            color: isToday ? AppColors.primary : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // --- 4. Direct Price Change Status Box ---
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: trendColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: trendColor.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isUp ? Icons.check_circle_rounded : (isDown ? Icons.arrow_downward_rounded : Icons.info_rounded),
                                  color: trendColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    rate.marketAdvisory,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: trendColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),

                          // --- 5. CROSS-MANDI PRICE COMPARISON SECTION ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '🏢 राज्य की अन्य मंडियों में $hindiName के भाव',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${comparisonRates.length} मंडियां',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Highlights Banner Card (Highest vs Lowest Mandi Rate)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.06),
                                  AppColors.secondary.withValues(alpha: 0.06),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Text('🏆', style: TextStyle(fontSize: 14)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('सर्वश्रेष्ठ भाव', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                            Text(
                                              '₹${highestRate.modalPrice.toInt()}/Qtl',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.green),
                                            ),
                                            Text(
                                              '${DistrictHelper.getHindiMarketName(highestRate.market, highestRate.district)} (${DistrictHelper.getHindiName(highestRate.district)})',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 38, color: Colors.grey.withValues(alpha: 0.2)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Text('📉', style: TextStyle(fontSize: 14)),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text('न्यूनतम भाव', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                                            Text(
                                              '₹${lowestRate.modalPrice.toInt()}/Qtl',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.blue),
                                            ),
                                            Text(
                                              '${DistrictHelper.getHindiMarketName(lowestRate.market, lowestRate.district)} (${DistrictHelper.getHindiName(lowestRate.district)})',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Clean Uncluttered List of Mandis
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedMandis.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = displayedMandis[index];
                              final isCurrent = item.market == rate.market && item.district == rate.district;
                              final diff = item.modalPrice - rate.modalPrice;
                              final isHighest = item.modalPrice == highestRate.modalPrice && item.modalPrice > rate.modalPrice;

                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  provider.syncLocationContext(
                                    state: item.state,
                                    district: item.district,
                                    market: item.market,
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isCurrent
                                        ? AppColors.primary.withValues(alpha: 0.08)
                                        : Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isCurrent
                                          ? AppColors.primary
                                          : (isHighest ? Colors.green.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.15)),
                                      width: isCurrent ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isCurrent
                                              ? AppColors.primary.withValues(alpha: 0.15)
                                              : Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.storefront_rounded,
                                          size: 18,
                                          color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    DistrictHelper.getHindiMarketName(item.market, item.district),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w700,
                                                      color: isCurrent ? AppColors.primary : null,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isCurrent) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Text(
                                                      '📍 वर्तमान',
                                                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                                if (isHighest && !isCurrent) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: const Text(
                                                      '🏆 टॉप भाव',
                                                      style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'जिला: ${item.district} • रेंज: ₹${item.minPrice.toInt()} - ₹${item.maxPrice.toInt()}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '₹${item.modalPrice.toInt()}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              color: isCurrent ? AppColors.primary : (diff > 0 ? Colors.green : (diff < 0 ? Colors.red : null)),
                                            ),
                                          ),
                                          if (!isCurrent && diff != 0)
                                            Text(
                                              diff > 0 ? '+₹${diff.toInt()}' : '-₹${diff.abs().toInt()}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: diff > 0 ? Colors.green : Colors.red,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          if (comparisonRates.length > 4) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    showAllMandis = !showAllMandis;
                                  });
                                },
                                icon: Icon(showAllMandis ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded),
                                label: Text(
                                  showAllMandis
                                      ? 'कम मंडियां देखें'
                                      : 'और ${comparisonRates.length - 4} मंडियां देखें 🔽',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildModernPriceTile({
    required BuildContext context,
    required String label,
    required String price,
    required Color color,
    required Color bgColor,
    required IconData icon,
    bool isFeatured = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFeatured ? color.withValues(alpha: 0.5) : color.withValues(alpha: 0.2),
            width: isFeatured ? 1.5 : 1.0,
          ),
          boxShadow: isFeatured
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodySmall?.color),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
