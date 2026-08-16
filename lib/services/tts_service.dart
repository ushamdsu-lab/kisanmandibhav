import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/mandi_rate.dart';
import '../models/weather_data.dart';
import '../utils/commodity_helper.dart';
import '../config/constants.dart';

enum TtsAudioState { stopped, playing, paused }

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  static FlutterTts? _flutterTts;
  static AudioPlayer? _audioPlayer;
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
      _audioPlayer = AudioPlayer();
      _audioPlayer!.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          stateNotifier.value = TtsAudioState.stopped;
          currentTitleNotifier.value = '';
          currentSpeechNotifier.value = '';
        } else if (state == PlayerState.playing) {
          stateNotifier.value = TtsAudioState.playing;
        } else if (state == PlayerState.paused) {
          stateNotifier.value = TtsAudioState.paused;
        }
      });

      _flutterTts = FlutterTts();
      await _flutterTts!.setLanguage("hi-IN");
      await _flutterTts!.setSpeechRate(kIsWeb ? 0.9 : 0.44);
      await _flutterTts!.setPitch(1.08);
      await _flutterTts!.setVolume(1.0);

      // Pick Google Hindi Female voice on Android
      try {
        final dynamic voices = await _flutterTts!.getVoices;
        if (voices is List) {
          Map<dynamic, dynamic>? selectedVoice;
          for (final voice in voices) {
            if (voice is Map) {
              final name = (voice['name'] ?? '').toString().toLowerCase();
              final locale = (voice['locale'] ?? '').toString().toLowerCase();
              if (locale.contains('hi') || locale.contains('hin')) {
                if (name.contains('hia') ||
                    name.contains('hie') ||
                    name.contains('female') ||
                    name.contains('woman')) {
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
      } catch (_) {}

      _flutterTts!.setStartHandler(() => stateNotifier.value = TtsAudioState.playing);
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
      _flutterTts!.setPauseHandler(() => stateNotifier.value = TtsAudioState.paused);
      _flutterTts!.setContinueHandler(() => stateNotifier.value = TtsAudioState.playing);
      _flutterTts!.setErrorHandler((_) => stateNotifier.value = TtsAudioState.stopped);

      _isInitialized = true;
    } catch (e) {
      debugPrint('[TtsService] Init error: $e');
    }
  }

  /// 🌤️ Read complete Weather Forecast Bulletin in sweet Hindi
  Future<void> speakWeatherReport({
    required String city,
    required WeatherData weather,
  }) async {
    await init();
    await stop();

    final cleanCity = city.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    final temp = weather.current.temperature.round();
    final feels = weather.current.apparentTemperature.round();
    final weatherInfo = AppConstants.weatherCodes[weather.current.weatherCode];
    final condition = weatherInfo?['label'] ?? 'सामान्य मौसम';
    final rain = weather.daily.isNotEmpty ? weather.daily.first.precipitationProbability : 0;
    final wind = weather.current.windSpeed.round();
    final humidity = weather.current.humidity;

    final sb = StringBuffer();
    sb.write("नमस्कार किसान भाइयों! आज $cleanCity में मौसम $condition रहेगा। ");
    sb.write("वर्तमान तापमान $temp डिग्री सेल्सियस है, जो $feels डिग्री जैसा महसूस हो रहा है। ");
    if (rain >= 50) {
      sb.write("आज $rain प्रतिशत बारिश होने की संभावना है। ");
      sb.write("किसान सलाह: आज तेज़ बारिश की संभावना है, फसलों में कीटनाशक छिड़काव व सिंचाई से बचें। ");
    } else if (rain > 20) {
      sb.write("आज $rain प्रतिशत हल्की बारिश होने की संभावना है। ");
    } else {
      sb.write("बारिश की संभावना $rain प्रतिशत है। ");
    }
    sb.write("हवा की गति $wind किलोमीटर प्रति घंटा और नमी $humidity प्रतिशत रहेगी। ");
    if (rain < 30 && wind < 20) {
      sb.write("किसान सलाह: आज मौसम अनुकूल है, आप फसलों में सिंचाई व कीटनाशक छिड़काव का कार्य कर सकते हैं। ");
    }
    sb.write("धन्यवाद और आपका दिन मंगलमय हो!");

    final fullText = sb.toString();
    currentTitleNotifier.value = "$cleanCity - आज का मौसम ($temp°C)";
    currentSpeechNotifier.value = fullText;
    stateNotifier.value = TtsAudioState.playing;

    try {
      await _flutterTts!.speak(fullText);
    } catch (e) {
      debugPrint('[TtsService] Weather speak error: $e');
      stateNotifier.value = TtsAudioState.stopped;
    }
  }

  /// 🌾 Read complete Mandi Rates Bulletin in sweet Hindi
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

    sb.write("प्रति क्विंटल दर्ज हुआ है। धन्यवाद और आपका दिन शुभ हो!");
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

  /// 🌾 Read single crop rate in Hindi
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

  Future<void> pause() async {
    try {
      await _flutterTts?.pause();
      await _audioPlayer?.pause();
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
      await _audioPlayer?.stop();
    } catch (_) {}
    stateNotifier.value = TtsAudioState.stopped;
    currentTitleNotifier.value = '';
    currentSpeechNotifier.value = '';
  }
}
