import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/kheti_provider.dart';
import '../../models/crop.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import '../../services/ad_service.dart';

class CropDetailScreen extends StatelessWidget {
  final String cropId;

  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    return Consumer<KhetiProvider>(
      builder: (context, provider, _) {
        final crop = provider.getCropById(cropId);

        if (crop == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('फसल विवरण')),
            body: const AppErrorWidget(message: 'फसल नहीं मिली'),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // --- App Bar ---
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                iconTheme: const IconThemeData(color: Colors.white),
                actionsIconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '${crop.name} (${crop.nameEn})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 6,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.khetiGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getCropIcon(crop.icon),
                        size: 80,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Info Cards ---
              SliverToBoxAdapter(
                child: _buildInfoSection(context, crop).animate()
                    .fadeIn(duration: 400.ms),
              ),

              // --- Steps ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    '📋 उगाने की विधि',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildStepCard(context, crop.steps[index], index, crop.steps.length),
                  childCount: crop.steps.length,
                ),
              ),

              // --- Pests ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    '🐛 रोग एवं कीट',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPestCard(context, crop.pests[index], index),
                  childCount: crop.pests.length,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: BannerAdWidget(enabled: AdService.enableKhetiBanner, showAdBadge: true),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, Crop crop) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(crop.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(context, '🌱 ${crop.sowingMonth}', 'बुवाई'),
              _infoChip(context, '🌾 ${crop.harvestMonth}', 'कटाई'),
              _infoChip(context, '⏱️ ${crop.duration}', 'अवधि'),
              _infoChip(context, '🌡️ ${crop.temperature}', 'तापमान'),
              _infoChip(context, '💧 ${crop.waterNeed}', 'पानी'),
              _infoChip(context, '🏔️ ${crop.soilType}', 'मिट्टी'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.khetiAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.khetiAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, CropStep step, int index, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.khetiGradient),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.step}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
              if (index < total - 1)
                Container(width: 2, height: 50, color: AppColors.khetiAccent.withValues(alpha: 0.2)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(step.detail, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildPestCard(BuildContext context, PestInfo pest, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppColors.error.withValues(alpha: 0.04),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bug_report_rounded, color: AppColors.error, size: 20),
        ),
        title: Text(pest.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labeledText(context, '🔍 लक्षण:', pest.symptom),
                const SizedBox(height: 8),
                _labeledText(context, '💊 उपचार:', pest.remedy),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 300.ms);
  }

  Widget _labeledText(BuildContext context, String label, String text) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: text),
        ],
      ),
    );
  }

  IconData _getCropIcon(String iconName) {
    switch (iconName) {
      case 'grain': return Icons.grain_rounded;
      case 'rice_bowl': return Icons.rice_bowl_rounded;
      case 'grass': return Icons.grass_rounded;
      case 'local_florist': return Icons.local_florist_rounded;
      case 'egg': return Icons.egg_rounded;
      case 'spa': return Icons.spa_rounded;
      default: return Icons.eco_rounded;
    }
  }
}
