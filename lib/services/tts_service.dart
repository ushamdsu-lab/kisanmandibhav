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

  List<String> _pendingSegments = [];
  int _currentSegmentIndex = 0;
  bool _isUsingAudioPlayer = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _audioPlayer = AudioPlayer();
      _audioPlayer!.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed) {
          _playNextSegment();
        } else if (state == PlayerState.stopped) {
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
      await _flutterTts!.setSpeechRate(kIsWeb ? 0.85 : 0.42);
      await _flutterTts!.setPitch(0.92);
      await _flutterTts!.setVolume(1.0);

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

  /// 🌾 Read LIVE Mandi Rates currently shown on screen with exact prices
  Future<void> speakMandiBulletin({
    required String mandiOrDistrict,
    required List<MandiRate> rates,
  }) async {
    if (rates.isEmpty) return;
    await init();
    await stop();

    final title = "$mandiOrDistrict - लाइव भाव बुलेटिन";
    final sb = StringBuffer();
    sb.write("नमस्कार किसान भाइयों! आज $mandiOrDistrict में फसलों के ताज़ा भाव इस प्रकार हैं: ");

    // Read top 10 crops currently on the screen with their exact live modal prices
    final topRates = rates.take(10).toList();
    for (int i = 0; i < topRates.length; i++) {
      final r = topRates[i];
      final crop = CommodityHelper.getHindiName(r.commodity);
      final price = r.modalPrice.toInt();
      if (i == topRates.length - 1 && topRates.length > 1) {
        sb.write("और $crop $price रुपये, ");
      } else {
        sb.write("$crop $price रुपये, ");
      }
    }

    sb.write("प्रति क्विंटल दर्ज हुआ है। धन्यवाद और आपका दिन शुभ हो!");
    final fullText = sb.toString();

    await _speakDynamicText(fullText, title);
  }

  /// 🌾 Read single crop rate in Hindi with exact modal, min and max prices
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

    final title = "$cropHindi - ₹$modal/क्विंटल";
    await _speakDynamicText(text, title);
  }

  /// 🌤️ Read complete Weather Forecast Bulletin with live data
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
      sb.write("आज बारिश की संभावना $rain प्रतिशत है। ");
    }
    sb.write("हवा की गति $wind किलोमीटर प्रति घंटा और नमी $humidity प्रतिशत रहेगी। ");
    if (rain < 30 && wind < 20) {
      sb.write("किसान सलाह: आज मौसम अनुकूल है, आप फसलों में सिंचाई व छिड़काव का कार्य कर सकते हैं। ");
    }
    sb.write("धन्यवाद और आपका दिन मंगलमय हो!");

    final fullText = sb.toString();
    final title = "$cleanCity - आज का मौसम ($temp°C)";
    await _speakDynamicText(fullText, title);
  }

  /// Speaks dynamic live text using streaming neural audio with instant fallback
  Future<void> _speakDynamicText(String fullText, String title) async {
    currentTitleNotifier.value = title;
    currentSpeechNotifier.value = fullText;
    stateNotifier.value = TtsAudioState.playing;

    final segments = _splitIntoSegments(fullText);
    _pendingSegments = segments;
    _currentSegmentIndex = 0;

    _playNextSegment();
  }

  void _playNextSegment() async {
    if (_currentSegmentIndex >= _pendingSegments.length) {
      stateNotifier.value = TtsAudioState.stopped;
      currentTitleNotifier.value = '';
      currentSpeechNotifier.value = '';
      return;
    }

    final segment = _pendingSegments[_currentSegmentIndex];
    _currentSegmentIndex++;

    // Try high-definition Google Neural voice stream
    try {
      _isUsingAudioPlayer = true;
      final encoded = Uri.encodeComponent(segment);
      final url = 'https://translate.google.com/translate_tts?ie=UTF-8&tl=hi&client=tw-ob&q=$encoded';
      await _audioPlayer!.play(UrlSource(url));
    } catch (_) {
      // Fallback to local TTS
      _isUsingAudioPlayer = false;
      try {
        await _flutterTts!.speak(segment);
      } catch (e) {
        stateNotifier.value = TtsAudioState.stopped;
      }
    }
  }

  List<String> _splitIntoSegments(String text) {
    final sentences = text.split(RegExp(r'[।\.\!\?]\s*'));
    final List<String> segments = [];
    String current = '';

    for (final s in sentences) {
      final trimmed = s.trim();
      if (trimmed.isEmpty) continue;
      if ('$current $trimmed'.length > 120) {
        if (current.isNotEmpty) segments.add(current.trim());
        current = trimmed;
      } else {
        current = current.isEmpty ? trimmed : '$current $trimmed';
      }
    }
    if (current.isNotEmpty) {
      segments.add(current.trim());
    }
    return segments.isNotEmpty ? segments : [text];
  }

  Future<void> pause() async {
    try {
      if (_isUsingAudioPlayer) {
        await _audioPlayer?.pause();
      } else {
        await _flutterTts?.pause();
      }
      stateNotifier.value = TtsAudioState.paused;
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      if (_isUsingAudioPlayer) {
        await _audioPlayer?.resume();
      } else {
        if (currentSpeechNotifier.value.isNotEmpty) {
          await _flutterTts?.speak(currentSpeechNotifier.value);
        }
      }
      stateNotifier.value = TtsAudioState.playing;
    } catch (_) {}
  }

  Future<void> stop() async {
    _pendingSegments.clear();
    _currentSegmentIndex = 0;
    try {
      await _audioPlayer?.stop();
      await _flutterTts?.stop();
    } catch (_) {}
    stateNotifier.value = TtsAudioState.stopped;
    currentTitleNotifier.value = '';
    currentSpeechNotifier.value = '';
  }
}
