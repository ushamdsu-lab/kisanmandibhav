import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../config/theme.dart';
import '../../services/ad_service.dart';

/// Card-styled Ad Container for in-feed lists (Mandi / Yojana feeds)
class InlineAdCard extends StatefulWidget {
  final EdgeInsetsGeometry margin;
  final bool enabled;

  const InlineAdCard({
    super.key,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.enabled = true,
  });

  @override
  State<InlineAdCard> createState() => _InlineAdCardState();
}

class _InlineAdCardState extends State<InlineAdCard> {
  NativeAd? _nativeAd;
  BannerAd? _bannerAd;
  bool _isNativeAdLoaded = false;
  bool _isBannerAdLoaded = false;
  bool _hasFailed = false;

  @override
  void initState() {
    super.initState();
    _loadInlineAd();
  }

  void _loadInlineAd() {
    if (!widget.enabled || !AdService.enableAllAds || !AdService.isSupportedPlatform) {
      setState(() => _hasFailed = true);
      return;
    }

    final nativeId = AdService.nativeAdUnitId;
    if (nativeId.isNotEmpty && !nativeId.contains('XXXXX')) {
      _nativeAd = NativeAd(
        adUnitId: nativeId,
        request: const AdRequest(),
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,
          mainBackgroundColor: Colors.transparent,
          cornerRadius: 12.0,
        ),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() {
                _isNativeAdLoaded = true;
                _hasFailed = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('[InlineAdCard] Native ad failed (${error.code}): ${error.message}. Falling back to banner.');
            ad.dispose();
            _nativeAd = null;
            if (mounted) {
              _loadBannerAd();
            }
          },
        ),
      );
      _nativeAd?.load();
    } else {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.largeBanner, // 320x100
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = true;
              _hasFailed = false;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[InlineAdCard] Banner ad fallback failed (${error.code}): ${error.message}');
          ad.dispose();
          _bannerAd = null;
          if (mounted) {
            setState(() {
              _isBannerAdLoaded = false;
              _hasFailed = true;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.isSupportedPlatform || _hasFailed) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Native Ad (Native Template)
    if (_isNativeAdLoaded && _nativeAd != null) {
      return Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        height: 120,
        child: AdWidget(ad: _nativeAd!),
      );
    }

    // 2. Banner Ad Fallback
    if (!_isBannerAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'प्रायोजित / Ad',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.info_outline,
                size: 14,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        ],
      ),
    );
  }
}
