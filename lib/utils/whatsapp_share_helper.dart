import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/mandi_rate.dart';
import '../utils/commodity_helper.dart';
import '../utils/district_helper.dart';

class WhatsAppShareHelper {
  /// Generate formatted WhatsApp text for the entire active Mandi
  static String generateMandiParchiText({
    required String state,
    required String district,
    required String market,
    required List<MandiRate> rates,
    String? weatherInfo,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.day} ${_getHindiMonth(now.month)} ${now.year}';
    final hindiMarket = market.isNotEmpty 
        ? DistrictHelper.getHindiMarketName(market, district)
        : (district.isNotEmpty ? '${DistrictHelper.getHindiName(district)} मंडी' : '$state मंडी');

    final buffer = StringBuffer();
    buffer.writeln('🌾 *किसान मंडी भाव - आज की ताज़ा भाव पर्ची* 🌾');
    buffer.writeln('📍 *मंडी:* $hindiMarket ($state)');
    buffer.writeln('📅 *दिनांक:* $dateStr');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');

    final displayRates = rates.take(12).toList();
    if (displayRates.isEmpty) {
      buffer.writeln('आज के भाव अपडेट हो रहे हैं...');
    } else {
      for (final r in displayRates) {
        final hindiName = CommodityHelper.getHindiName(r.commodity);
        final price = r.modalPrice.toInt();
        final trendIcon = r.trendDirection == 'up' ? '🟢' : (r.trendDirection == 'down' ? '🔴' : '⚪');
        final chg = r.priceChange.round();
        final chgText = chg > 0 ? ' (+$chg)' : (chg < 0 ? ' ($chg)' : '');
        
        buffer.writeln('• *$hindiName:* ₹$price/क्विंटल $trendIcon$chgText');
      }
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    if (weatherInfo != null && weatherInfo.isNotEmpty) {
      buffer.writeln('🌦️ *मौसम:* $weatherInfo');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    }
    buffer.writeln('📲 *अपने जिले का ताज़ा भाव जानने के लिए "किसान मित्र" ऐप डाउनलोड करें।*');
    buffer.writeln('जय जवान, जय किसान! 🚜🌾');

    return buffer.toString();
  }

  /// Generate formatted WhatsApp text for a single commodity rate
  static String generateSingleCropParchiText({
    required MandiRate rate,
    List<MandiRate>? topOtherMandis,
  }) {
    final hindiName = CommodityHelper.getHindiName(rate.commodity);
    final englishName = CommodityHelper.getEnglishName(rate.commodity);
    final hindiMarket = DistrictHelper.getHindiMarketName(rate.market, rate.district);
    final now = DateTime.now();
    final dateStr = '${now.day} ${_getHindiMonth(now.month)} ${now.year}';
    final trendIcon = rate.trendDirection == 'up' ? '🟢' : (rate.trendDirection == 'down' ? '🔴' : '⚪');
    final chg = rate.priceChange.round();
    final chgText = chg > 0 ? ' (+$chg तेज़ी)' : (chg < 0 ? ' ($chg मंदी)' : ' (समान)');

    final buffer = StringBuffer();
    buffer.writeln('🌾 *फसल भाव अपडेट - $hindiName ($englishName)* 🌾');
    buffer.writeln('📍 *मंडी:* $hindiMarket (${DistrictHelper.getHindiName(rate.district)})');
    buffer.writeln('📅 *दिनांक:* $dateStr');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('💰 *आज का मॉडल भाव:* ₹${rate.modalPrice.toInt()} / क्विंटल $trendIcon$chgText');
    buffer.writeln('📊 *न्यूनतम भाव:* ₹${rate.minPrice.toInt()} / क्विंटल');
    buffer.writeln('📈 *उच्चतम भाव:* ₹${rate.maxPrice.toInt()} / क्विंटल');
    buffer.writeln('🌾 *किस्म/क्वालिटी:* ${rate.variety}');
    buffer.writeln('📦 *मंडी आवक:* ${rate.arrivalQuantityFormatted} (${rate.arrivalStatus})');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━');

    if (topOtherMandis != null && topOtherMandis.isNotEmpty) {
      buffer.writeln('🏢 *राज्य की अन्य मंडियों में भाव:*');
      for (final other in topOtherMandis.take(4)) {
        if (other.market != rate.market) {
          final mName = DistrictHelper.getHindiMarketName(other.market, other.district);
          buffer.writeln('  • $mName: ₹${other.modalPrice.toInt()}/Qtl');
        }
      }
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━');
    }

    buffer.writeln('📲 *रोज़ाना मंडी भाव और मौसम के लिए "किसान मित्र" ऐप इस्तेमाल करें।*');
    return buffer.toString();
  }

  /// Launch WhatsApp with text message
  static Future<bool> shareToWhatsApp(String message) async {
    final encoded = Uri.encodeComponent(message);
    final whatsappUri = Uri.parse('whatsapp://send?text=$encoded');
    final webWhatsappUri = Uri.parse('https://api.whatsapp.com/send?text=$encoded');

    try {
      if (await canLaunchUrl(whatsappUri)) {
        return await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webWhatsappUri)) {
        return await launchUrl(webWhatsappUri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback: Copy to clipboard
        await Clipboard.setData(ClipboardData(text: message));
        return false;
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: message));
      return false;
    }
  }

  /// Convenience method to share a single rate slip
  static Future<bool> shareRateSlip({required MandiRate rate, List<MandiRate>? topOtherMandis}) async {
    final text = generateSingleCropParchiText(rate: rate, topOtherMandis: topOtherMandis);
    return await shareToWhatsApp(text);
  }

  static String _getHindiMonth(int month) {
    const months = [
      '', 'जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
      'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'
    ];
    return (month >= 1 && month <= 12) ? months[month] : '';
  }
}
