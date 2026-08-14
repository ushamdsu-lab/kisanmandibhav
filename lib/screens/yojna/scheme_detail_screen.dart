import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/theme.dart';
import '../../providers/yojna_provider.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/in_app_browser_sheet.dart';

class SchemeDetailScreen extends StatelessWidget {
  final String schemeId;

  const SchemeDetailScreen({super.key, required this.schemeId});

  @override
  Widget build(BuildContext context) {
    return Consumer<YojnaProvider>(
      builder: (context, provider, _) {
        final scheme = provider.getSchemeById(schemeId);

        if (scheme == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('योजना विवरण')),
            body: const AppErrorWidget(message: 'योजना नहीं मिली'),
          );
        }

        final isBookmarked = provider.isBookmarked(scheme.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                    onPressed: () => provider.toggleBookmark(scheme.id),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    scheme.name,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.yojnaGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getSchemeIcon(scheme.icon),
                        size: 70,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + English name
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.yojnaAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              scheme.category,
                              style: TextStyle(fontSize: 12, color: AppColors.yojnaAccent, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(scheme.nameEn, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        scheme.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                      ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                      const SizedBox(height: 24),

                      // Benefits
                      _buildSection(
                        context,
                        '✅ लाभ',
                        scheme.benefits,
                        Icons.check_circle_rounded,
                        AppColors.primary,
                      ),

                      const SizedBox(height: 20),

                      // Eligibility
                      _buildSection(
                        context,
                        '📝 पात्रता',
                        scheme.eligibility,
                        Icons.person_rounded,
                        AppColors.mausamAccent,
                      ),

                      const SizedBox(height: 20),

                      // Required documents
                      _buildSection(
                        context,
                        '📄 आवश्यक दस्तावेज',
                        scheme.documents,
                        Icons.description_rounded,
                        AppColors.secondary,
                      ),

                      const SizedBox(height: 24),

                      // How to apply
                      Card(
                        color: AppColors.khetiAccent.withValues(alpha: 0.06),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.how_to_reg_rounded, color: AppColors.khetiAccent),
                                  const SizedBox(width: 8),
                                  Text(
                                    'आवेदन कैसे करें',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(scheme.howToApply, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

                      const SizedBox(height: 16),

                      // In-App Website Portal button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => InAppBrowserSheet.show(
                            context,
                            url: scheme.website,
                            title: scheme.name,
                          ),
                          icon: const Icon(Icons.language_rounded),
                          label: const Text('आधिकारिक पोर्टल देखें (इन-ऐप)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.yojnaAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(BuildContext context, String title, List<String> items, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (200 + i * 60).ms, duration: 250.ms);
        }),
      ],
    );
  }

  IconData _getSchemeIcon(String iconName) {
    switch (iconName) {
      case 'account_balance_wallet': return Icons.account_balance_wallet_rounded;
      case 'shield': return Icons.shield_rounded;
      case 'credit_card': return Icons.credit_card_rounded;
      case 'science': return Icons.science_rounded;
      case 'water_drop': return Icons.water_drop_rounded;
      case 'store': return Icons.store_rounded;
      default: return Icons.article_rounded;
    }
  }
}
