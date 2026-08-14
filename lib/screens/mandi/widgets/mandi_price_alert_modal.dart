import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/mandi_rate.dart';
import '../../../providers/mandi_provider.dart';
import '../../../utils/commodity_helper.dart';

class MandiPriceAlertModal extends StatefulWidget {
  final MandiRate rate;
  final MandiProvider provider;

  const MandiPriceAlertModal({
    super.key,
    required this.rate,
    required this.provider,
  });

  static void show(BuildContext context, MandiRate rate, MandiProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MandiPriceAlertModal(rate: rate, provider: provider),
    );
  }

  @override
  State<MandiPriceAlertModal> createState() => _MandiPriceAlertModalState();
}

class _MandiPriceAlertModalState extends State<MandiPriceAlertModal> {
  late final TextEditingController _priceCtrl;
  String _condition = 'above';

  @override
  void initState() {
    super.initState();
    final existingAlert = widget.provider.getActiveAlertFor(widget.rate.commodity);
    final initialTarget = existingAlert?.targetPrice ?? (widget.rate.modalPrice * 1.05).roundToDouble();
    _priceCtrl = TextEditingController(text: initialTarget.toInt().toString());
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hindiName = CommodityHelper.getHindiName(widget.rate.commodity);
    final existingAlert = widget.provider.getActiveAlertFor(widget.rate.commodity);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🔔 $hindiName भाव अलर्ट',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'वर्तमान मॉडल भाव: ₹${widget.rate.modalPrice.toInt()}/क्विंटल (${widget.rate.market})',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Condition selector
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('भाव इससे ऊपर जाने पर (≥)'),
                  selected: _condition == 'above',
                  onSelected: (v) => setState(() => _condition = 'above'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('भाव नीचे आने पर (≤)'),
                  selected: _condition == 'below',
                  onSelected: (v) => setState(() => _condition = 'below'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Target Price Input
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'लक्षित भाव दर्ज करें (₹/क्विंटल)',
              prefixIcon: Icon(Icons.currency_rupee_rounded, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),

          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(existingAlert != null ? Icons.check_circle_rounded : Icons.add_alert_rounded),
              label: Text(existingAlert != null ? 'अलर्ट अपडेट करें' : 'नया अलर्ट चालू करें'),
              onPressed: () async {
                final target = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
                if (target > 0) {
                  await widget.provider.setPriceAlert(
                    commodity: widget.rate.commodity,
                    targetPrice: target,
                    market: widget.rate.market,
                    district: widget.rate.district,
                    condition: _condition,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('🔔 $hindiName के लिए ₹${target.toInt()} का भाव अलर्ट सेट हो गया!'),
                        backgroundColor: Colors.green.shade700,
                      ),
                    );
                  }
                }
              },
            ),
          ),
          if (existingAlert != null) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () async {
                  await widget.provider.removePriceAlert(existingAlert.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('अलर्ट हटा दिया गया है')),
                    );
                  }
                },
                child: const Text('यह अलर्ट हटाएं', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
