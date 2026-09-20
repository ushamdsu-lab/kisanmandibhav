import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/mandi_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../utils/district_helper.dart';
import '../../../utils/commodity_helper.dart';
import '../../../data/mandi_directory.dart';

class DashboardMandiSpotlight extends StatelessWidget {
  final MandiProvider provider;
  final WeatherProvider? weatherProvider;

  const DashboardMandiSpotlight({
    super.key,
    required this.provider,
    this.weatherProvider,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Determine active district prioritizing the user's active weather location
    String activeDistrict = '';

    if (weatherProvider != null) {
      if (weatherProvider!.detectedDistrict.isNotEmpty) {
        activeDistrict = MandiDirectory.getStandardDistrictName(
          provider.selectedState,
          weatherProvider!.detectedDistrict,
        );
      }
      if (activeDistrict.isEmpty && weatherProvider!.cityName.isNotEmpty) {
        final cleanCity = weatherProvider!.cityName.contains('(')
            ? weatherProvider!.cityName.substring(weatherProvider!.cityName.indexOf('(') + 1).replaceAll(')', '').trim()
            : weatherProvider!.cityName.split(',').first.trim();
        activeDistrict = MandiDirectory.getStandardDistrictName(provider.selectedState, cleanCity);
        if (activeDistrict.isEmpty) {
          activeDistrict = MandiDirectory.getStandardDistrictName(provider.selectedState, weatherProvider!.cityName.split('(').first.trim());
        }
      }
    }

    if (activeDistrict.isEmpty && provider.selectedDistrict.isNotEmpty) {
      activeDistrict = provider.selectedDistrict;
    }

    if (activeDistrict.isEmpty && provider.userHomeDistrict.isNotEmpty) {
      activeDistrict = provider.userHomeDistrict;
    }

    if (activeDistrict.isEmpty) {
      activeDistrict = MandiDirectory.getDefaultDistrict(provider.selectedState);
    }

    final dist = activeDistrict;
    final distHindi = DistrictHelper.getHindiName(dist);
    final districtRates = provider.getRatesForDistrict(dist);
    final topRates = districtRates.isNotEmpty
        ? districtRates.take(3).toList()
        : provider.rates.take(3).toList();
    final districtMarkets = provider.getMarketsForDistrict(dist);

    final titleText = provider.selectedMarket.isNotEmpty && provider.selectedDistrict == dist
        ? '📍 ${provider.selectedMarket}'
        : '📍 $distHindi ($dist) मंडी';

    return InkWell(
      onTap: () {
        provider.selectDistrict(dist);
        context.go('/mandi');
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE65100), Color(0xFFF57C00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE65100).withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              titleText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.shade700,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ताज़ा भाव', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'आज के मॉडल भाव व आवक',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Row(
                  children: [
                    Text('देखें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                  ],
                ),
              ],
            ),
            if (topRates.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: topRates.map((r) {
                    final hindi = CommodityHelper.getHindiName(r.commodity);
                    final eng = CommodityHelper.getEnglishName(r.commodity);
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            hindi,
                            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            eng.isNotEmpty ? eng : r.commodity,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 9, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${r.modalPrice.toInt()}',
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 13.5, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            if (districtMarkets.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.store_mall_directory_rounded, size: 13, color: Colors.amberAccent),
                        const SizedBox(width: 4),
                        Text(
                          '$distHindi जिले की अन्य मंडियां:',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          ...districtMarkets.map((m) {
                            final isCur = provider.selectedMarket == m;
                            final shortName = m.replaceAll('APMC', '').trim();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () {
                                  provider.selectDistrict(dist);
                                  provider.selectMarket(m);
                                  context.go('/mandi');
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isCur ? Colors.white : Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    shortName,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isCur ? const Color(0xFFE65100) : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
