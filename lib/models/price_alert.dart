import 'dart:convert';

class PriceAlert {
  final String id;
  final String commodity;
  final String market;
  final String district;
  final double targetPrice;
  final String condition; // 'above' or 'below'
  final DateTime createdAt;
  bool isTriggered;

  PriceAlert({
    required this.id,
    required this.commodity,
    required this.market,
    required this.district,
    required this.targetPrice,
    this.condition = 'above',
    DateTime? createdAt,
    this.isTriggered = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'commodity': commodity,
        'market': market,
        'district': district,
        'targetPrice': targetPrice,
        'condition': condition,
        'createdAt': createdAt.toIso8601String(),
        'isTriggered': isTriggered,
      };

  factory PriceAlert.fromJson(Map<String, dynamic> json) => PriceAlert(
        id: json['id'] as String,
        commodity: json['commodity'] as String,
        market: json['market'] as String? ?? '',
        district: json['district'] as String? ?? '',
        targetPrice: (json['targetPrice'] as num).toDouble(),
        condition: json['condition'] as String? ?? 'above',
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        isTriggered: json['isTriggered'] as bool? ?? false,
      );

  static String encodeList(List<PriceAlert> alerts) =>
      json.encode(alerts.map((a) => a.toJson()).toList());

  static List<PriceAlert> decodeList(String jsonStr) {
    if (jsonStr.isEmpty) return [];
    try {
      final List<dynamic> decoded = json.decode(jsonStr);
      return decoded.map((item) => PriceAlert.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
