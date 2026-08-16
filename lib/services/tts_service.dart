import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/mandi_rate.dart';
import '../utils/commodity_helper.dart';

enum TtsAudioState { stopped, playing, paused }

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  static FlutterTts? _flutterTts;
  static bool _isInitialized = false;

  final ValueNotifier<TtsAudioState> stateNotifier =
      ValueNotifier<TtsAudioState>(TtsAudioState.stopped);
  final ValueNotifier<String> currentTitleNotifier = ValueNotifier<String>('');
  final ValueNotifier<String> currentSpeechNotifier = ValueNotifier<String>('');

  bool get isPlaying => stateNotifier.value == TtsAudioState.playing;
  bool get isPaused => stateNotifier.value == TtsAudioState.paused;
  bool get isStopped => stateNotifier.value == TtsAudioState.stopped;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // Configure Hindi Locale (India)
      await _flutterTts!.setLanguage("hi-IN");

      // Natural, pleasant radio-announcer pace and clear sweet female tone
      await _flutterTts!.setSpeechRate(kIsWeb ? 0.9 : 0.44);
      await _flutterTts!.setPitch(1.08);
      await _flutterTts!.setVolume(1.0);

      // Attempt to pick Google Hindi Female Voice on Android / iOS
      try {
        final dynamic voices = await _flutterTts!.getVoices;
        if (voices is List) {
          Map<dynamic, dynamic>? selectedVoice;

          // Priority 1: Google Hindi Female neural voice
          for (final voice in voices) {
            if (voice is Map) {
              final name = (voice['name'] ?? '').toString().toLowerCase();
              final locale = (voice['locale'] ?? '').toString().toLowerCase();
              if (locale.contains('hi') || locale.contains('hin')) {
                if (name.contains('hia') ||
                    name.contains('hie') ||
                    name.contains('female') ||
                    name.contains('woman') ||
                    name.contains('girl')) {
                  selectedVoice = voice;
                  break;
                }
              }
            }
          }

          // Priority 2: Any standard Hindi voice
          if (selectedVoice == null) {
            for (final voice in voices) {
              if (voice is Map) {
                final locale = (voice['locale'] ?? '').toString().toLowerCase();
                if (locale.contains('hi')) {
                  selectedVoice = voice;
                  break;
                }
              }
            }
          }

          if (selectedVoice != null) {
            final voiceName = selectedVoice['name']?.toString() ?? '';
            final voiceLocale = selectedVoice['locale']?.toString() ?? 'hi-IN';
            if (voiceName.isNotEmpty) {
              await _flutterTts!.setVoice({"name": voiceName, "locale": voiceLocale});
            }
          }
        }
      } catch (e) {
        debugPrint('[TtsService] Voice selection fallback: $e');
      }

      _flutterTts!.setStartHandler(() {
        stateNotifier.value = TtsAudioState.playing;
      });

      _flutterTts!.setCompletionHandler(() {
        stateNotifier.value = TtsAudioState.stopped;
        currentTitleNotifier.value = '';
        currentSpeechNotifier.value = '';
      });

      _flutterTts!.setCancelHandler(() {
        stateNotifier.value = TtsAudioState.stopped;
        currentTitleNotifier.value = '';
        currentSpeechNotifier.value = '';
      });

      _flutterTts!.setPauseHandler(() {
        stateNotifier.value = TtsAudioState.paused;
      });

      _flutterTts!.setContinueHandler(() {
        stateNotifier.value = TtsAudioState.playing;
      });

      _flutterTts!.setErrorHandler((msg) {
        debugPrint('[TtsService] Error: $msg');
        stateNotifier.value = TtsAudioState.stopped;
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('[TtsService] Init failed: $e');
    }
  }

  /// Read single crop rate clearly in Hindi
  Future<void> speakCropRate(MandiRate rate) async {
    await init();
    await stop();

    final cropHindi = CommodityHelper.getHindiName(rate.commodity);
    final marketName = rate.market.trim();
    final modal = rate.modalPrice.toInt();
    final min = rate.minPrice.toInt();
    final max = rate.maxPrice.toInt();

    final text =
        "$marketName में $cropHindi का मॉडल भाव $modal रुपये प्रति क्विंटल है। "
        "न्यूनतम भाव $min रुपये और अधिकतम भाव $max रुपये रहा।";

    currentTitleNotifier.value = "$cropHindi - ₹$modal/Qtl";
    currentSpeechNotifier.value = text;
    stateNotifier.value = TtsAudioState.playing;

    try {
      await _flutterTts!.speak(text);
    } catch (e) {
      debugPrint('[TtsService] Speak error: $e');
      stateNotifier.value = TtsAudioState.stopped;
    }
  }

  /// Read comprehensive Hindi Audio Bulletin for all crops in the Mandi
  Future<void> speakMandiBulletin({
    required String mandiOrDistrict,
    required List<MandiRate> rates,
  }) async {
    if (rates.isEmpty) return;
    await init();
    await stop();

    final title = "$mandiOrDistrict - दैनिक मंडी बुलेटिन";
    final sb = StringBuffer();
    sb.write("नमस्कार किसान भाइयों! आज $mandiOrDistrict के प्रमुख मंडी भाव इस प्रकार हैं: ");

    final topRates = rates.take(15).toList();
    for (int i = 0; i < topRates.length; i++) {
      final r = topRates[i];
      final crop = CommodityHelper.getHindiName(r.commodity);
      final price = r.modalPrice.toInt();
      sb.write("$crop, $price रुपये, ");
    }

    sb.write("प्रति क्विंटल दर्ज हुआ है। धन्यवाद!");
    final fullText = sb.toString();

    currentTitleNotifier.value = title;
    currentSpeechNotifier.value = fullText;
    stateNotifier.value = TtsAudioState.playing;

    try {
      await _flutterTts!.speak(fullText);
    } catch (e) {
      debugPrint('[TtsService] Bulletin speak error: $e');
      stateNotifier.value = TtsAudioState.stopped;
    }
  }

  Future<void> pause() async {
    try {
      await _flutterTts?.pause();
      stateNotifier.value = TtsAudioState.paused;
    } catch (_) {}
  }

  Future<void> resume() async {
    if (currentSpeechNotifier.value.isNotEmpty) {
      try {
        stateNotifier.value = TtsAudioState.playing;
        await _flutterTts?.speak(currentSpeechNotifier.value);
      } catch (_) {}
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts?.stop();
    } catch (_) {}
    stateNotifier.value = TtsAudioState.stopped;
    currentTitleNotifier.value = '';
    currentSpeechNotifier.value = '';
  }
}
