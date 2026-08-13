class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String mandi;
  final String district;
  final String state;
  final String type; // 'rate_update', 'price_surge', 'weather_warning', 'scheme_alert'
  final bool isRead;
  final double? changePercent;
  final String? commodityName;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.mandi,
    required this.district,
    required this.state,
    this.type = 'rate_update',
    this.isRead = false,
    this.changePercent,
    this.commodityName,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? mandi,
    String? district,
    String? state,
    String? type,
    bool? isRead,
    double? changePercent,
    String? commodityName,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      mandi: mandi ?? this.mandi,
      district: district ?? this.district,
      state: state ?? this.state,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      changePercent: changePercent ?? this.changePercent,
      commodityName: commodityName ?? this.commodityName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'mandi': mandi,
      'district': district,
      'state': state,
      'type': type,
      'isRead': isRead,
      'changePercent': changePercent,
      'commodityName': commodityName,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'मंडी भाव अपडेट',
      body: json['body'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      mandi: json['mandi'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      type: json['type'] as String? ?? 'rate_update',
      isRead: json['isRead'] as bool? ?? false,
      changePercent: (json['changePercent'] as num?)?.toDouble(),
      commodityName: json['commodityName'] as String?,
    );
  }
}
