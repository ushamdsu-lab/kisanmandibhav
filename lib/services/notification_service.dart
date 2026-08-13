import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';
import '../models/mandi_rate.dart';
import '../utils/district_helper.dart';
import '../utils/commodity_helper.dart';

class NotificationService {
  static const String _notificationsKey = 'kisan_mandi_notifications_v1';
  static const String _alertPrefKey = 'kisan_mandi_alert_preferences';

  /// Fetch saved notifications
  static Future<List<NotificationItem>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_notificationsKey);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> list = json.decode(raw);
        return list.map((item) => NotificationItem.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
    return [];
  }

  /// Save notifications list
  static Future<void> saveNotifications(List<NotificationItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep latest 50 notifications to preserve memory
      final toSave = items.take(50).map((i) => i.toJson()).toList();
      await prefs.setString(_notificationsKey, json.encode(toSave));
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  /// Generate intelligent notification from updated Mandi Rates for user's location
  static NotificationItem generateRateUpdateNotification({
    required String state,
    required String district,
    required String mandi,
    required List<MandiRate> rates,
  }) {
    final mandiName = DistrictHelper.getHindiMarketName(mandi, district);
    final topGainers = rates.where((r) => r.modalPrice > 0).toList()
      ..sort((a, b) => b.modalPrice.compareTo(a.modalPrice));

    final sampleCrops = topGainers.take(3).map((r) {
      final price = r.modalPrice.toInt();
      final hindiName = CommodityHelper.getHindiName(r.commodity);
      return '$hindiName: ₹$price';
    }).join(' • ');

    final String body = sampleCrops.isNotEmpty
        ? 'आज के ताजा भाव: $sampleCrops प्रति क्विंटल। भाव देखने के लिए टैप करें।'
        : '$mandiName में आज के नए कृषि उपज भाव जारी कर दिए गए हैं।';

    return NotificationItem(
      id: 'rate_${DateTime.now().millisecondsSinceEpoch}',
      title: '🌾 $mandiName के नए भाव अपडेट!',
      body: body,
      timestamp: DateTime.now(),
      mandi: mandi,
      district: district,
      state: state,
      type: 'rate_update',
      isRead: false,
    );
  }

  /// Check and save alert preference
  static Future<bool> isAlertEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_alertPrefKey) ?? true;
    } catch (_) {
      return true;
    }
  }

  /// Set alert preference
  static Future<void> setAlertEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_alertPrefKey, enabled);
    } catch (_) {}
  }
}
