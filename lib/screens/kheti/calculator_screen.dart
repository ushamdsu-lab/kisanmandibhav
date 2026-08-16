import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/kheti_provider.dart';
import '../../models/fertilizer.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../services/ad_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String? _selectedCropId;
  double _area = 1.0;
  String _unit = 'acre'; // Default to acre for practical farmer use (acre, bigha, hectare)
  final _areaController = TextEditingController(text: '1.0');

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 खाद कैलकुलेटर', style: TextStyle(fontWeight: FontWeight.w800)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.khetiGradient),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: BannerAdWidget(enabled: AdService.enableCalculatorBanner, showAdBadge: true),
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
                            avatar: CircleAvatar(backgroundColor: Colors.green, child: Text('U', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                            label: Text('यूरिया (45kg): ₹266.50', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.white,
                          ),
                          Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.orange, child: Text('D', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                            label: Text('DAP (50kg): ₹1,350', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.white,
                          ),
                          Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.blue, child: Text('N', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                            label: Text('NPK (50kg): ₹1,470', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            backgroundColor: Colors.white,
                          ),
                          Chip(
                            avatar: CircleAvatar(backgroundColor: Colors.purple, child: Text('M', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
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
                              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'iFMS dbtfert.nic.in',
                            style: TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 20),

                // --- Crop Selector ---
                const Text('1. अपनी फसल चुनें:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCropId,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.eco_rounded, color: AppColors.khetiAccent),
                    hintText: 'फसल का चयन करें (जैसे गेहूं, धान, सरसों)',
                  ),
                  items: crops.map((c) => DropdownMenuItem(
                    value: c.id,
                    child: Text('${c.name} (${c.nameEn})', style: const TextStyle(fontWeight: FontWeight.w600)),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedCropId = v),
                ),

                const SizedBox(height: 20),

                // --- Area Input ---
                const Text('2. खेत का क्षेत्रफल दर्ज करें:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _areaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: 'जैसे 1.0',
                          prefixIcon: Icon(Icons.square_foot_rounded, color: AppColors.khetiAccent),
                        ),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null && parsed >= 0) {
                            setState(() => _area = parsed);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _unit,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'acre', child: Text('एकड़ (Acre)', style: TextStyle(fontWeight: FontWeight.w600))),
                          DropdownMenuItem(value: 'bigha', child: Text('बीघा (Bigha)', style: TextStyle(fontWeight: FontWeight.w600))),
                          DropdownMenuItem(value: 'hectare', child: Text('हेक्टेयर (Ha)', style: TextStyle(fontWeight: FontWeight.w600))),
                        ],
                        onChanged: (v) => setState(() => _unit = v ?? 'acre'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // --- Results ---
                if (_selectedCropId != null && fertilizers.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📊 अनुशंसित खाद मात्रा (${_area.toStringAsFixed(1)} ${_getUnitLabel()})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'ICAR मानक खुराक',
                          style: TextStyle(fontSize: 10.5, color: AppColors.primaryDark, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
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
                      child: Text('इस फसल के लिए खाद डेटा उपलब्ध नहीं है', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.calculate_outlined, size: 48, color: AppColors.khetiAccent),
                        SizedBox(height: 10),
                        Text(
                          'ऊपर से फसल और खेत का क्षेत्रफल चुनें',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'आपको यूरिया, DAP, पोटाश व जिंक की सटीक वैज्ञानिक मात्रा व बैग संख्या मिल जाएगी।',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
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
    // 💡 Rigorous Scientific Unit Conversion:
    // 1 Hectare = 2.47105 Acres
    // If unit is 'hectare', use f.dosagePerHectare
    // If unit is 'bigha', use f.dosagePerBigha
    // If unit is 'acre', accurately calculate from Hectare / 2.47105
    final isTon = f.dosagePerHectare.contains('टन') || f.dosagePerBigha.contains('टन');
    
    double minBase = 0.0;
    double maxBase = 0.0;
    String displayUnit = isTon ? 'टन' : 'किलो';

    if (_unit == 'bigha') {
      final matches = RegExp(r'(\d+\.?\d*)').allMatches(f.dosagePerBigha).map((m) => double.tryParse(m.group(1)!) ?? 0.0).toList();
      if (matches.isNotEmpty) {
        minBase = matches.first;
        maxBase = matches.length > 1 ? matches[1] : matches.first;
      }
    } else if (_unit == 'acre') {
      // Convert Hectare rate to Acre rate by dividing by 2.47105
      final matches = RegExp(r'(\d+\.?\d*)').allMatches(f.dosagePerHectare).map((m) => double.tryParse(m.group(1)!) ?? 0.0).toList();
      if (matches.isNotEmpty) {
        minBase = matches.first / 2.47105;
        maxBase = matches.length > 1 ? (matches[1] / 2.47105) : minBase;
      }
    } else {
      // Hectare
      final matches = RegExp(r'(\d+\.?\d*)').allMatches(f.dosagePerHectare).map((m) => double.tryParse(m.group(1)!) ?? 0.0).toList();
      if (matches.isNotEmpty) {
        minBase = matches.first;
        maxBase = matches.length > 1 ? matches[1] : matches.first;
      }
    }

    final minTotal = minBase * _area;
    final maxTotal = maxBase * _area;

    String calculatedAmountStr;
    if ((maxTotal - minTotal).abs() < 0.1 || minTotal == maxTotal) {
      calculatedAmountStr = '${minTotal.toStringAsFixed(1)} $displayUnit';
    } else {
      calculatedAmountStr = '${minTotal.toStringAsFixed(1)} - ${maxTotal.toStringAsFixed(1)} $displayUnit';
    }

    // Bag estimations (यूरिया = 45kg/बोरी, DAP/NPK/MOP/SSP = 50kg/बोरी)
    String? bagEstimation;
    if (!isTon && minTotal > 0) {
      double bagWeight = 50.0;
      if (f.id == 'urea') {
        bagWeight = 45.0;
      }
      final avgKg = (minTotal + maxTotal) / 2.0;
      final bags = avgKg / bagWeight;
      if (bags >= 0.5) {
        bagEstimation = 'लगभग ${bags.toStringAsFixed(1)} बोरी (${bagWeight.toInt()}kg)';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(f.nameEn, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                // Calculated amount badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        calculatedAmountStr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    if (bagEstimation != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        bagEstimation,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            _detailRow('🧪 पोषक तत्व:', f.nutrient),
            _detailRow('📝 उपयोग समय:', f.usage),
            _detailRow('📏 प्रयोग विधि:', f.method),
            _detailRow('⚠️ सावधानी:', f.precaution),
            _detailRow('💰 सरकारी MRP:', f.price),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 300.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, height: 1.4),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            TextSpan(text: value, style: const TextStyle(color: AppColors.textSecondary)),
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
      default: return 'एकड़';
    }
  }
}
