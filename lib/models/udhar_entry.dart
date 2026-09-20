import 'dart:convert';

enum UdharType {
  lena, // मुझे पार्टी/व्यापारी से लेना है (Receivable)
  dena, // मुझे दुकानदार/मजदूर को देना है (Payable)
}

class UdharEntry {
  final String id;
  final String partyName;
  final String phone;
  final UdharType type;
  final double amount;
  final DateTime date;
  final DateTime? dueDate;
  final bool isSettled;
  final String notes;
  final String category; // जैसे: खाद-बीज दुकान, मजदूर, व्यापारी, KCC/ब्याज, अन्य

  UdharEntry({
    required this.id,
    required this.partyName,
    this.phone = '',
    required this.type,
    required this.amount,
    required this.date,
    this.dueDate,
    this.isSettled = false,
    this.notes = '',
    this.category = 'खाद-बीज दुकान',
  });

  UdharEntry copyWith({
    String? id,
    String? partyName,
    String? phone,
    UdharType? type,
    double? amount,
    DateTime? date,
    DateTime? dueDate,
    bool? isSettled,
    String? notes,
    String? category,
  }) {
    return UdharEntry(
      id: id ?? this.id,
      partyName: partyName ?? this.partyName,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      isSettled: isSettled ?? this.isSettled,
      notes: notes ?? this.notes,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'partyName': partyName,
        'phone': phone,
        'type': type == UdharType.lena ? 'lena' : 'dena',
        'amount': amount,
        'date': date.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'isSettled': isSettled,
        'notes': notes,
        'category': category,
      };

  factory UdharEntry.fromJson(Map<String, dynamic> json) => UdharEntry(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        partyName: json['partyName'] as String? ?? 'अज्ञात',
        phone: json['phone'] as String? ?? '',
        type: (json['type'] as String? ?? 'dena') == 'lena' ? UdharType.lena : UdharType.dena,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate'] as String) : null,
        isSettled: json['isSettled'] as bool? ?? false,
        notes: json['notes'] as String? ?? '',
        category: json['category'] as String? ?? 'खाद-बीज दुकान',
      );

  static String encodeList(List<UdharEntry> entries) =>
      json.encode(entries.map((e) => e.toJson()).toList());

  static List<UdharEntry> decodeList(String raw) {
    if (raw.trim().isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list
          .map((item) => UdharEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
