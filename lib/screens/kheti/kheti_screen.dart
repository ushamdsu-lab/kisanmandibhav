import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../config/app_images.dart';
import '../../providers/kheti_provider.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';

class KhetiScreen extends StatefulWidget {
  const KhetiScreen({super.key});

  @override
  State<KhetiScreen> createState() => _KhetiScreenState();
}

class _KhetiScreenState extends State<KhetiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KhetiProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<KhetiProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              // --- App Bar ---
              SliverAppBar(
                expandedHeight: 130,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('🌱 खेती सलाह व कीट सुरक्षा'),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.khetiGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 12,
                          bottom: 0,
                          child: SizedBox(
                            height: 110,
                            width: 100,
                            child: AppImages.carrotMascot,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.calculate_rounded),
                    onPressed: () => context.go('/kheti/calculator'),
                    tooltip: 'खाद कैलकुलेटर',
                  ),
                ],
              ),

              // --- Season Filter ---
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    children: [
                      _buildSeasonChip(provider, 'all', 'सभी फसलें', Icons.grid_view_rounded),
                      _buildSeasonChip(provider, 'kharif', 'खरीफ', Icons.water_drop_rounded),
                      _buildSeasonChip(provider, 'rabi', 'रबी', Icons.ac_unit_rounded),
                      _buildSeasonChip(provider, 'zaid', 'जायद', Icons.wb_sunny_rounded),
                    ],
                  ),
                ),
              ),

              if (provider.isLoading)
                const SliverToBoxAdapter(
                  child: LoadingShimmer(itemCount: 4, height: 120),
                )
              else if (provider.error.isNotEmpty)
                SliverFillRemaining(
                  child: AppErrorWidget(
                    message: provider.error,
                    onRetry: () => provider.loadData(),
                  ),
                )
              else ...[
                // --- Crop Grid ---
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final crop = provider.crops[index];
                        return _buildCropCard(crop, index);
                      },
                      childCount: provider.crops.length,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSeasonChip(KhetiProvider provider, String season, String label, IconData icon) {
    final isSelected = provider.selectedSeason == season;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.khetiAccent),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => provider.setSeasonFilter(season),
        selectedColor: AppColors.khetiAccent,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : null,
          fontSize: 13,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildCropCard(dynamic crop, int index) {
    final seasonColor = crop.season == 'kharif'
        ? AppColors.mausamAccent
        : crop.season == 'rabi'
            ? AppColors.primary
            : AppColors.secondary;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go('/kheti/crop/${crop.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Crop icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: AppColors.khetiGradient),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.khetiAccent.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(_getCropIcon(crop.icon), color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              // Crop name
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  crop.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  crop.nameEn,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 6),
              // Season badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: seasonColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    crop.season == 'kharif' ? 'खरीफ फसल' : (crop.season == 'rabi' ? 'रबी फसल' : 'जायद फसल'),
                    style: TextStyle(color: seasonColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 80).ms, duration: 350.ms).scale(
      begin: const Offset(0.92, 0.92),
      end: const Offset(1, 1),
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
