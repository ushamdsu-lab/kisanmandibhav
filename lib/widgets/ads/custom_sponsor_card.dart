import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/custom_ad.dart';

/// Reusable Card Widget for displaying Manual / Direct Sponsored Ads
class CustomSponsorCard extends StatelessWidget {
  final CustomAd ad;
  final EdgeInsetsGeometry margin;

  const CustomSponsorCard({
    super.key,
    required this.ad,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  Future<void> _handleAction(BuildContext context) async {
    try {
      Uri uri;
      if (ad.actionType == 'call') {
        uri = Uri.parse('tel:${ad.actionValue.replaceAll(RegExp(r'[^0-9+]'), '')}');
      } else if (ad.actionType == 'whatsapp') {
        final cleanNumber = ad.actionValue.replaceAll(RegExp(r'[^0-9]'), '');
        uri = Uri.parse('https://wa.me/$cleanNumber?text=${Uri.encodeComponent("नमस्ते, मैंने किसान मंडी भाव ऐप पर आपका विज्ञापन देखा।")}');
      } else {
        uri = Uri.parse(ad.actionValue.startsWith('http') ? ad.actionValue : 'https://${ad.actionValue}');
      }

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('लिंक ओपन नहीं हो सका')),
          );
        }
      }
    } catch (e) {
      debugPrint('[CustomSponsorCard] Action error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ad.isActive) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _handleAction(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tag + Sponsored Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ad.tag,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _getActionIcon(ad.actionType),
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Optional Banner Image
                if (ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ad.imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  )
                else if (ad.assetImage != null && ad.assetImage!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      ad.assetImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),

                if ((ad.imageUrl != null && ad.imageUrl!.isNotEmpty) ||
                    (ad.assetImage != null && ad.assetImage!.isNotEmpty))
                  const SizedBox(height: 10),

                // Title & Subtitle
                Text(
                  ad.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ad.subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleAction(context),
                    icon: Icon(_getActionIcon(ad.actionType), size: 16),
                    label: Text(
                      ad.actionButtonText,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getActionColor(ad.actionType),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getActionIcon(String type) {
    switch (type) {
      case 'call':
        return Icons.phone_rounded;
      case 'whatsapp':
        return Icons.chat_rounded;
      default:
        return Icons.launch_rounded;
    }
  }

  Color _getActionColor(String type) {
    switch (type) {
      case 'call':
        return const Color(0xFF1976D2);
      case 'whatsapp':
        return const Color(0xFF25D366);
      default:
        return AppColors.primary;
    }
  }
}
