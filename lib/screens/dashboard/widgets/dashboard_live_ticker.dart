import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/mandi_provider.dart';
import '../../../models/mandi_rate.dart';
import '../../../utils/commodity_helper.dart';

class DashboardLiveTicker extends StatelessWidget {
  final MandiProvider mandiProvider;

  const DashboardLiveTicker({super.key, required this.mandiProvider});

  @override
  Widget build(BuildContext context) {
    final List<MandiRate> topCrops = mandiProvider.rates.take(8).toList();

    return Container(
      width: double.infinity,
      color: Colors.black.withValues(alpha: 0.05),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.white, size: 8),
                  SizedBox(width: 4),
                  Text('ताज़ा भाव', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            if (topCrops.isEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Text(
                  'मंडियों के लाइव भाव लोड हो रहे हैं...',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              )
            else
              ...topCrops.map((r) {
              final hindi = CommodityHelper.getHindiName(r.commodity);
              final isUp = r.trendDirection == 'up';
              final isDown = r.trendDirection == 'down';
              final trendColor = isUp ? Colors.green.shade700 : (isDown ? Colors.red.shade700 : Colors.blue.shade700);

              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: InkWell(
                  onTap: () => context.go('/mandi'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$hindi: ',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                      Text(
                        '₹${r.modalPrice.toInt()}',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: trendColor),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isUp ? '📈' : (isDown ? '📉' : '⏸️'),
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 10),
                      Container(width: 1, height: 12, color: Colors.grey.withValues(alpha: 0.3)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
