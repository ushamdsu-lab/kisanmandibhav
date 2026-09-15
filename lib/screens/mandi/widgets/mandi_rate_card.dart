import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/mandi_rate.dart';
import '../../../providers/locale_provider.dart';
import '../../../utils/commodity_helper.dart';
import '../../../utils/district_helper.dart';
import '../../../utils/whatsapp_share_helper.dart';
import '../../../data/msp_data.dart';
import '../../../widgets/mandi/sparkline_chart_widget.dart';
import '../../../services/tts_service.dart';

class MandiRateCard extends StatelessWidget {
  final MandiRate rate;
  final int index;
  final bool isFavorite;
  final bool hasAlert;
  final VoidCallback onToggleFavorite;
  final VoidCallback onSetAlert;
  final VoidCallback onComparePrices;

  const MandiRateCard({
    super.key,
    required this.rate,
    required this.index,
    required this.isFavorite,
    required this.hasAlert,
    required this.onToggleFavorite,
    required this.onSetAlert,
    required this.onComparePrices,
  });

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final isHi = localeProv.isHindi;
    final hindiName = CommodityHelper.getHindiName(rate.commodity);
    final englishName = CommodityHelper.getEnglishName(rate.commodity);
    final primaryName = isHi ? hindiName : (englishName.isNotEmpty ? englishName : rate.commodity);
    final secondaryName = isHi ? (englishName.isNotEmpty ? englishName : rate.commodity) : hindiName;
    final districtName = isHi ? DistrictHelper.getHindiName(rate.district) : rate.district;
    final mspItem = MspDatabase.getMspForCrop(rate.commodity);

    final cardWidget = Card(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isFavorite
              ? Colors.amber.shade600.withValues(alpha: 0.6)
              : Colors.grey.withValues(alpha: 0.15),
          width: isFavorite ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: onComparePrices,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Crop Name, Live Badge, and Favorite Star
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                primaryName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: const Color(0xFF1B5E20),
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Live APMC vs Reference badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: rate.isLive
                                    ? Colors.green.shade50
                                    : Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: rate.isLive ? Colors.green.shade600 : Colors.amber.shade700,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                rate.isLive ? (isHi ? '🟢 Agmarknet लाइव' : '🟢 APMC Live') : (isHi ? '🟡 संदर्भ दर' : '🟡 Ref Rate'),
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: rate.isLive ? Colors.green.shade800 : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        // Secondary Crop Name underneath
                        Text(
                          secondaryName,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(Icons.storefront_rounded, size: 12.5, color: Color(0xFFE65100)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${rate.market} • $districtName',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFE65100),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Favorite Toggle Button (Min 48x48 tap target)
                  IconButton(
                    iconSize: 26,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    icon: Icon(
                      isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFavorite ? Colors.amber.shade600 : Colors.grey.shade400,
                    ),
                    onPressed: onToggleFavorite,
                    tooltip: isFavorite ? (isHi ? 'पसंदीदा से हटाएं' : 'Remove Favorite') : (isHi ? 'पसंदीदा बनाएं' : 'Add Favorite'),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. Price Grid & Highlights
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Modal Price (Main)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHi ? 'मॉडल भाव (औसत)' : 'Modal Price (Avg)',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${rate.modalPrice.toInt()}',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            Text(
                              isHi ? ' /क्विंटल' : ' /Qtl',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Min & Max Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isHi ? 'न्यूनतम' : 'Min'}: ₹${rate.minPrice.toInt()}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.blueGrey),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isHi ? 'अधिकतम' : 'Max'}: ₹${rate.maxPrice.toInt()}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.green.shade800),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 3. Metadata & MSP comparison row
              Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${isHi ? 'आवक' : 'Arrival'}: ${rate.arrivalQuantityFormatted} (${rate.arrivalStatus})',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  if (mspItem != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'MSP: ₹${mspItem.mspPrice.toInt()}',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // 4. Action Row (Compare Mandis, Price Alert, WhatsApp Share)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 320,
                  child: Row(
                    children: [
                      // Price Trend badge & 7-Day Sparkline
                      SparklineChartWidget(
                        state: rate.state,
                        commodity: rate.commodity,
                        modalPrice: rate.modalPrice,
                        minPrice: rate.minPrice,
                        maxPrice: rate.maxPrice,
                        compact: true,
                      ),
                      const Spacer(),
                      // Compare prices button
                      TextButton.icon(
                        onPressed: onComparePrices,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: const Size(36, 32),
                        ),
                        icon: const Icon(Icons.compare_arrows_rounded, size: 15, color: AppColors.primary),
                        label: Text(isHi ? 'तुलना' : 'Compare', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                      // Price Alert button
                      IconButton(
                        iconSize: 19,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        tooltip: isHi ? 'भाव अलर्ट सेट करें' : 'Set Price Alert',
                        icon: Icon(
                          hasAlert ? Icons.notifications_active_rounded : Icons.notification_add_outlined,
                          color: hasAlert ? Colors.amber.shade800 : Colors.grey.shade600,
                        ),
                        onPressed: onSetAlert,
                      ),
                      // Voice Speak Rate Button
                      IconButton(
                        iconSize: 19,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        tooltip: isHi ? 'भाव बोलकर सुनें (Audio)' : 'Listen Audio Bulletin',
                        icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF1B5E20)),
                        onPressed: () {
                          TtsService().speakCropRate(rate);
                        },
                      ),
                      // WhatsApp Share
                      IconButton(
                        iconSize: 19,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        tooltip: isHi ? 'व्हाट्सएप पर पर्ची भेजें' : 'Share on WhatsApp',
                        icon: const Icon(Icons.share_rounded, color: Color(0xFF25D366)),
                        onPressed: () {
                          WhatsAppShareHelper.shareRateSlip(rate: rate);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (index < 8) {
      return cardWidget
          .animate()
          .fadeIn(delay: Duration(milliseconds: (index * 35).clamp(0, 280)), duration: 200.ms)
          .slideY(begin: 0.04, end: 0);
    }
    return cardWidget;
  }
}
