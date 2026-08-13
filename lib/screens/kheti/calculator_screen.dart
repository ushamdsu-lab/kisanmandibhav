import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/kheti_provider.dart';
import '../../models/fertilizer.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String? _selectedCropId;
  double _area = 1.0;
  String _unit = 'hectare'; // hectare, bigha, acre

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 खाद कैलकुलेटर'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.khetiGradient),
          ),
        ),
      ),
      body: Consumer<KhetiProvider>(
        builder: (context, provider, _) {
          final crops = provider.allCrops;
          final fertilizers = _selectedCropId != null
              ? provider.getFertilizersForCrop(_selectedCropId!)
              : <Fertilizer>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Official Govt Rates Card ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '🏛️ भारत सरकार द्वारा तय नियंत्रित खाद MRP दरें',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: const [
                          Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.green, child: Text('U', style: TextStyle(color: Colors.white, fontSize: 10))),
                            label: Text('यूरिया (45kg): ₹266.50', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.white,
                          ),
                          Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.orange, child: Text('D', style: TextStyle(color: Colors.white, fontSize: 10))),
                            label: Text('DAP (50kg): ₹1,350', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.white,
                          ),
                          Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('N', style: TextStyle(color: Colors.white, fontSize: 10))),
                            label: Text('NPK (50kg): ₹1,470', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.white,
                          ),
                          Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.purple, child: Text('M', style: TextStyle(color: Colors.white, fontSize: 10))),
                            label: Text('MOP (50kg): ₹1,700', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Expanded(
                            child: Text(
                              '📞 शिकायत हेल्पलाइन: 1800-11-5501',
                              style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'iFMS dbtfert.nic.in',
                            style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // --- Crop Selector ---
                Text('फसल चुनें', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCropId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.eco_rounded, color: AppColors.khetiAccent),
                  ),
                  hint: const Text('फसल चुनें'),
                  items: crops.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.name} (${c.nameEn})'),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCropId = v),
                ),

                const SizedBox(height: 20),

                // --- Area Input ---
                Text('क्षेत्रफल दर्ज करें', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: '1.0',
                          prefixIcon: Icon(Icons.square_foot_rounded, color: AppColors.khetiAccent),
                        ),
                        onChanged: (v) => setState(() => _area = double.tryParse(v) ?? 1.0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        items: const [
                          DropdownMenuItem(value: 'hectare', child: Text('हेक्टेयर')),
                          DropdownMenuItem(value: 'bigha', child: Text('बीघा')),
                          DropdownMenuItem(value: 'acre', child: Text('एकड़')),
                        ],
                        onChanged: (v) => setState(() => _unit = v ?? 'hectare'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // --- Results ---
                if (_selectedCropId != null && fertilizers.isNotEmpty) ...[
                  Text(
                    '📊 अनुशंसित खाद मात्रा',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'क्षेत्रफल: ${_area.toStringAsFixed(1)} ${_getUnitLabel()}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),

                  ...fertilizers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final f = entry.value;
                    return _buildFertilizerResult(f, i);
                  }),
                ] else if (_selectedCropId != null && fertilizers.isEmpty) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('इस फसल के लिए खाद डेटा उपलब्ध नहीं है'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFertilizerResult(Fertilizer f, int index) {
    // Calculate dosage based on unit
    final dosageText = _unit == 'bigha' ? f.dosagePerBigha : f.dosagePerHectare;
    // Parse numeric value from dosage string for calculation
    final numericMatch = RegExp(r'(\d+\.?\d*)').firstMatch(dosageText);
    final baseAmount = numericMatch != null ? double.parse(numericMatch.group(1)!) : 0.0;
    final calculated = (baseAmount * _area).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.khetiGradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.science_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        f.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(f.nameEn, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                // Calculated amount
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$calculated किलो',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _detailRow('🧪 पोषक तत्व:', f.nutrient),
            _detailRow('📝 उपयोग:', f.usage),
            _detailRow('📏 विधि:', f.method),
            _detailRow('⚠️ सावधानी:', f.precaution),
            _detailRow('💰 कीमत:', f.price),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms, duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String _getUnitLabel() {
    switch (_unit) {
      case 'hectare': return 'हेक्टेयर';
      case 'bigha': return 'बीघा';
      case 'acre': return 'एकड़';
      default: return 'हेक्टेयर';
    }
  }
}
