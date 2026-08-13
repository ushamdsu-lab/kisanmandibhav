import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../models/mandi_rate.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _alertsEnabled = true;
  bool _isLoading = false;
  String _lastNotifiedKey = '';

  List<NotificationItem> get notifications => _notifications;
  bool get alertsEnabled => _alertsEnabled;
  bool get isLoading => _isLoading;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _alertsEnabled = await NotificationService.isAlertEnabled();
    final saved = await NotificationService.getNotifications();

    if (saved.isNotEmpty) {
      _notifications = saved;
    } else {
      // Provide helpful initial notifications
      _notifications = [
        NotificationItem(
          id: 'init_1',
          title: '🌾 स्वागत है! मंडी भाव अलर्ट सक्रिय है',
          body: 'आपकी चुनी हुई मंडी और लोकेशन के अनुसार नए भाव जारी होते ही आपको यहाँ ताज़ा नोटिफिकेशन मिलेगा।',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          mandi: 'Mandi APMC',
          district: '',
          state: 'All India',
          type: 'rate_update',
          isRead: false,
        ),
        NotificationItem(
          id: 'init_2',
          title: '⛅ कृषि मौसम व दवा छिड़काव सलाह',
          body: 'अगले 3 दिनों के मौसम पूर्वानुमान के अनुसार आज दवा छिड़काव के लिए मौसम अनुकूल है।',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          mandi: '',
          district: '',
          state: 'All India',
          type: 'weather_warning',
          isRead: false,
        ),
      ];
      await NotificationService.saveNotifications(_notifications);
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Trigger alert when Mandi Rates are updated for user's selected location
  Future<void> onMandiRatesUpdated({
    required String state,
    required String district,
    required String mandi,
    required List<MandiRate> rates,
  }) async {
    if (!_alertsEnabled || rates.isEmpty) return;

    final currentKey = '$state-$district-$mandi-${rates.length}';
    if (_lastNotifiedKey == currentKey) return; // Prevent duplicate rapid notifications
    _lastNotifiedKey = currentKey;

    final notif = NotificationService.generateRateUpdateNotification(
      state: state,
      district: district,
      mandi: mandi,
      rates: rates,
    );

    _notifications.insert(0, notif);
    await NotificationService.saveNotifications(_notifications);
    notifyListeners();
  }

  /// Add custom notification
  Future<void> addNotification(NotificationItem item) async {
    _notifications.insert(0, item);
    await NotificationService.saveNotifications(_notifications);
    notifyListeners();
  }

  /// Mark single notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await NotificationService.saveNotifications(_notifications);
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await NotificationService.saveNotifications(_notifications);
    notifyListeners();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    await NotificationService.saveNotifications(_notifications);
    notifyListeners();
  }

  /// Toggle alerts enabled
  Future<void> toggleAlerts(bool enabled) async {
    _alertsEnabled = enabled;
    await NotificationService.setAlertEnabled(enabled);
    notifyListeners();
  }
}
