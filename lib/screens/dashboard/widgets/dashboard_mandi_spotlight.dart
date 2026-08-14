import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/mandi_provider.dart';
import '../../../utils/district_helper.dart';
import '../../../utils/commodity_helper.dart';

class DashboardMandiSpotlight extends StatelessWidget {
  final MandiProvider provider;

  const DashboardMandiSpotlight({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final dist = provider.selectedDistrict.isNotEmpty
        ? provider.selectedDistrict
        : (provider.userHomeDistrict.isNotEmpty ? provider.userHomeDistrict : 'Jodhpur');
    final distHindi = DistrictHelper.getHindiName(dist);
    final topRates = provider.rates.take(3).toList();

    return InkWell(
      onTap: () => context.go('/mandi'),
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
                              '📍 $distHindi ($dist) मंडी',
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
                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            hindi,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${r.modalPrice.toInt()}',
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
