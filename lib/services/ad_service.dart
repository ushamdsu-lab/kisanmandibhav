import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/custom_ad.dart';

/// Centralized Service for managing Google Mobile Ads (AdMob) & Custom Sponsored Ads
class AdService {
  AdService._();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  /// SET TO `false` IN PRODUCTION WHEN USING YOUR REAL ADMOB AD UNIT IDS
  static bool isTestMode = false;

  /// Online URL to update manual sponsor ads without rebuilding app
  static String remoteSponsorUrl =
      'https://raw.githubusercontent.com/ushamdsu-lab/kisanmandibhav/main/assets/data/sponsor_ad.json';

  // ==========================================
  // 🔘 ADS ON / OFF MASTER & SCREEN SWITCHES
  // (Yahan se aap kisi bhi ad ko ON ya OFF kar sakte hain)
  // ==========================================
  /// Poore App mein sabhi Ads ko ek sath ON/OFF karne ka Master Switch
  static bool enableAllAds = true;

  /// Manual / Direct Sponsor Ads Toggle (Disabled - Google Ads only)
  static bool enableCustomSponsorAds = false;

  /// Specific Screens ke liye ON/OFF Switches:
  static bool enableMandiBanner = true;
  static bool enableMandiInlineCards = true;
  static bool enableMausamBanner = true;
  static bool enableMausamInlineCards = true;
  static bool enableYojnaBanner = true;
  static bool enableYojnaInlineCards = true;
  static bool enableKhetiBanner = true;
  static bool enableCalculatorBanner = true;
  static bool enableInterstitialAds = false; // Full screen ads disabled for smooth farmer experience

  // ==========================================
  // 📢 DIRECT / MANUAL SPONSORED ADS LIST
  // (Empty - Google Ads preferred)
  // ==========================================
  static List<CustomAd> customAds = [];

  // ==========================================
  // PRODUCTION AD UNIT IDS
  // (Paste your real AdMob Ad Unit IDs here)
  // ==========================================
  static const String _prodAndroidBannerId = 'ca-app-pub-7650949194753110/5674116546';
  static const String _prodAndroidInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodAndroidRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodAndroidNativeId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  static const String _prodIosBannerId = 'ca-app-pub-7650949194753110/5674116546';
  static const String _prodIosInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodIosRewardedId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';
  static const String _prodIosNativeId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY';

  // ==========================================
  // GOOGLE OFFICIAL TEST AD UNIT IDS
  // ==========================================
  static const String _testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testAndroidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testAndroidNativeId = 'ca-app-pub-3940256099942544/2247696110';

  static const String _testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testIosRewardedId = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testIosNativeId = 'ca-app-pub-3940256099942544/3986624511';

  // ==========================================
  // AD UNIT ID GETTERS
  // ==========================================
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (isTestMode) {
      return Platform.isIOS ? _testIosBannerId : _testAndroidBannerId;
    }
    return Platform.isIOS ? _prodIosBannerId : _prodAndroidBannerId;
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (isTestMode) {
      return Platform.isAndroid ? _testAndroidInterstitialId : _testIosInterstitialId;
    }
    return Platform.isAndroid ? _prodAndroidInterstitialId : _prodIosInterstitialId;
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (isTestMode) {
      return Platform.isAndroid ? _testAndroidRewardedId : _testIosRewardedId;
    }
    return Platform.isAndroid ? _prodAndroidRewardedId : _prodIosRewardedId;
  }

  static String get nativeAdUnitId {
    if (kIsWeb) return '';
    if (isTestMode) {
      return Platform.isAndroid ? _testAndroidNativeId : _testIosNativeId;
    }
    return Platform.isAndroid ? _prodAndroidNativeId : _prodIosNativeId;
  }

  // ==========================================
  // INITIALIZATION & UMP CONSENT (GDPR / 2026 POLICY COMPLIANT)
  // ==========================================
  static Future<void> init() async {
    if (kIsWeb) {
      debugPrint('[AdService] Google Mobile Ads is not supported on Web.');
      return;
    }

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // 1. Google UMP Consent Management (Required for EEA / UK / Global Compliance)
        await _requestUserConsent();

        // 2. Initialize MobileAds SDK
        await MobileAds.instance.initialize();
        
        // 3. Register test devices and set family-friendly content rating (2026 AdMob Policy)
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: [
              '7cf83247-f5b2-4386-b1cf-b95d171ee5c2',
            ],
            // Blocks adult, gambling and inappropriate ads for farmer safety
            maxAdContentRating: MaxAdContentRating.pg,
          ),
        );

        _isInitialized = true;
        debugPrint('[AdService] MobileAds initialized with UMP consent and Test Device registered.');
        
        // Preload first interstitial ad
        loadInterstitialAd();
      }

      // Fetch remote sponsor ad in background (non-blocking)
      fetchRemoteSponsorAds();
    } catch (e) {
      debugPrint('[AdService] Initialization error: $e');
    }
  }

  /// Request User Messaging Platform (UMP) consent (Compliant with Google AdMob 2026 Policy)
  static Future<void> _requestUserConsent() async {
    try {
      final params = ConsentRequestParameters();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          ConsentForm.loadAndShowConsentFormIfRequired(
            (FormError? formError) {
              if (formError != null) {
                debugPrint('[AdService] UMP Consent Form error: ${formError.message}');
              } else {
                debugPrint('[AdService] UMP Consent status checked / updated.');
              }
            },
          );
        },
        (FormError error) {
          debugPrint('[AdService] UMP Consent info update failed: ${error.message}');
        },
      );
    } catch (e) {
      debugPrint('[AdService] UMP consent check skipped: $e');
    }
  }

  /// Fetch remote sponsor ads dynamically without rebuilding app (Disabled)
  static Future<void> fetchRemoteSponsorAds() async {
    // Custom sponsor ads disabled as user prefers official Google Ads
    return;
  }

  // ==========================================
  // INTERSTITIAL AD MANAGEMENT & COOLDOWN
  // ==========================================
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialLoading = false;
  static DateTime? _lastInterstitialShownTime;

  /// Minimum gap between two full-screen interstitial ads (default: 60 seconds)
  static const int defaultCooldownSeconds = 60;

  static void loadInterstitialAd() {
    if (kIsWeb || !isSupportedPlatform || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          debugPrint('[AdService] Interstitial Ad loaded successfully.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('[AdService] Interstitial Ad failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Show interstitial ad safely with cooldown check
  static void showInterstitialAd({
    VoidCallback? onDismissed,
    int cooldownSeconds = defaultCooldownSeconds,
  }) {
    if (kIsWeb || !isSupportedPlatform || !enableAllAds || !enableInterstitialAds) {
      onDismissed?.call();
      return;
    }

    // In test mode, bypass cooldown so developer can test instantly
    if (!isTestMode && _lastInterstitialShownTime != null) {
      final difference = DateTime.now().difference(_lastInterstitialShownTime!).inSeconds;
      if (difference < cooldownSeconds) {
        debugPrint('[AdService] Interstitial skipped due to cooldown (${difference}s / ${cooldownSeconds}s).');
        onDismissed?.call();
        return;
      }
    }

    if (_interstitialAd == null) {
      debugPrint('[AdService] Interstitial ad was still loading or not ready yet. Preloading now.');
      loadInterstitialAd();
      onDismissed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _lastInterstitialShownTime = DateTime.now();
        loadInterstitialAd(); // Preload next
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Failed to show interstitial: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDismissed?.call();
      },
    );

    _interstitialAd!.show();
  }

  // ==========================================
  // HELPER PROPERTIES
  // ==========================================
  static bool get isSupportedPlatform {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
