import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/mandi_rate.dart';
import '../../../providers/mandi_provider.dart';
import '../../../utils/commodity_helper.dart';
import '../../../utils/district_helper.dart';
import '../../../widgets/mandi/sparkline_chart_widget.dart';

class MandiPriceComparisonModal extends StatefulWidget {
  final MandiRate targetRate;
  final MandiProvider provider;

  const MandiPriceComparisonModal({
    super.key,
    required this.targetRate,
    required this.provider,
  });

  static void show(BuildContext context, MandiRate rate, MandiProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MandiPriceComparisonModal(targetRate: rate, provider: provider),
    );
  }

  @override
  State<MandiPriceComparisonModal> createState() => _MandiPriceComparisonModalState();
}

class _MandiPriceComparisonModalState extends State<MandiPriceComparisonModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filterScope = 'all'; // 'all', 'district', 'state'

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final comparisonRates = widget.provider.getRatesForCommodity(widget.targetRate);
    final hindiName = CommodityHelper.getHindiName(widget.targetRate.commodity);
    final distName = widget.targetRate.district.isNotEmpty
        ? widget.targetRate.district
        : (widget.provider.selectedDistrict.isNotEmpty ? widget.provider.selectedDistrict : 'Jodhpur');
    final distHindi = DistrictHelper.getHindiName(distName);

    // Segment rates into District Mandis and State Mandis
    final districtRates = comparisonRates.where((r) =>
        r.district.toLowerCase() == distName.toLowerCase() ||
        r.district.toLowerCase().contains(distName.toLowerCase()) ||
        distName.toLowerCase().contains(r.district.toLowerCase())
    ).toList();

    final stateRates = comparisonRates.where((r) => !districtRates.contains(r)).toList();

    // Query filter
    final query = _searchCtrl.text.toLowerCase().trim();
    List<MandiRate> displayedDistrict = districtRates.where((r) {
      if (query.isEmpty) return true;
      final mMatch = r.market.toLowerCase().contains(query);
      final dMatch = r.district.toLowerCase().contains(query) ||
          DistrictHelper.getHindiName(r.district).toLowerCase().contains(query);
      return mMatch || dMatch;
    }).toList();

    List<MandiRate> displayedState = stateRates.where((r) {
      if (query.isEmpty) return true;
      final mMatch = r.market.toLowerCase().contains(query);
      final dMatch = r.district.toLowerCase().contains(query) ||
          DistrictHelper.getHindiName(r.district).toLowerCase().contains(query);
      return mMatch || dMatch;
    }).toList();

    double highestPrice = widget.targetRate.modalPrice;
    double lowestPrice = widget.targetRate.modalPrice;
    String highestMandi = widget.targetRate.market;

    if (comparisonRates.isNotEmpty) {
      highestPrice = comparisonRates.first.modalPrice;
      highestMandi = '${comparisonRates.first.market} (${comparisonRates.first.district})';
      lowestPrice = comparisonRates.last.modalPrice;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
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
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$hindiName भाव तुलना',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      Text(
                        'राज्य की सभी ${comparisonRates.length} मंडियों में आज के दाम',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Summary Stats Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('राज्य में उच्चतम भाव', style: TextStyle(fontSize: 10.5, color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('₹${highestPrice.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                      Text(highestMandi, style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary), maxLines: 1),
                    ],
                  ),
                  Container(width: 1, height: 36, color: Colors.green.withValues(alpha: 0.3)),
                  Column(
                    children: [
                      const Text('न्यूनतम दर्ज', style: TextStyle(fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('₹${lowestPrice.toInt()}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.blueGrey)),
                      Text('औसत भाव', style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 7-Day Rolling Price History Chart (FIFO Window)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SparklineChartWidget(
              state: widget.targetRate.state,
              commodity: widget.targetRate.commodity,
              modalPrice: widget.targetRate.modalPrice,
              minPrice: widget.targetRate.minPrice,
              maxPrice: widget.targetRate.maxPrice,
              compact: false,
            ),
          ),

          // Search Field & Scope Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'मंडी या जिला खोजें (उदा: मेड़ता, नोखा, जयपुर)...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() => _searchCtrl.clear()))
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Filter Scope Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildScopeChip('सभी मंडियां (${comparisonRates.length})', _filterScope == 'all', () => setState(() => _filterScope = 'all')),
                  const SizedBox(width: 6),
                  _buildScopeChip('$distHindi ज़िला (${districtRates.length})', _filterScope == 'district', () => setState(() => _filterScope = 'district')),
                  const SizedBox(width: 6),
                  _buildScopeChip('राज्य की अन्य मंडियां (${stateRates.length})', _filterScope == 'state', () => setState(() => _filterScope = 'state')),
                ],
              ),
            ),
          ),

          const Divider(height: 8),

          // Mandis List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              children: [
                // 1. District Section (if scope allows)
                if (_filterScope != 'state' && displayedDistrict.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '📍 $distHindi जिले की सभी मंडियां (${displayedDistrict.length})',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                  ...displayedDistrict.asMap().entries.map((entry) => _buildRateItem(context, entry.value, entry.key)),
                ],

                // 2. State Section (if scope allows)
                if (_filterScope != 'district' && displayedState.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_rounded, color: AppColors.mandiAccent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '🏛️ राज्य के अन्य जिलों की मंडियां (${displayedState.length})',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.mandiAccent),
                        ),
                      ],
                    ),
                  ),
                  ...displayedState.asMap().entries.map((entry) => _buildRateItem(context, entry.value, displayedDistrict.length + entry.key)),
                ],

                if (displayedDistrict.isEmpty && displayedState.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('कोई मंडी नहीं मिली')),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
      selected: isSelected,
      onSelected: (_) => onTap(),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildRateItem(BuildContext context, MandiRate r, int index) {
    final isCurrentTarget = r.market.toLowerCase() == widget.targetRate.market.toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentTarget
            ? AppColors.primary.withValues(alpha: 0.12)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrentTarget
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.2),
          width: isCurrentTarget ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: index == 0 ? Colors.amber.shade700 : Colors.grey.shade300,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: index == 0 ? Colors.white : Colors.black87,
              ),
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
                        r.market,
                        style: TextStyle(
                          fontWeight: isCurrentTarget ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 14,
                          color: isCurrentTarget ? AppColors.primary : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentTarget) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('आपकी मंडी', style: TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                Text('${DistrictHelper.getHindiName(r.district)} (${r.district}) • ${r.variety}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${r.modalPrice.toInt()}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
              ),
              Text(
                '₹${r.minPrice.toInt()} - ₹${r.maxPrice.toInt()}',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
