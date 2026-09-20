import 'dart:convert';

class DairyExpense {
  final String id;
  final String title;
  final String category; // उदा: चारा/भूसा, दाना/खल/चोकर, डॉक्टर/दवाई, A.I./सीमन, अन्य
  final double amount;
  final DateTime date;
  final String notes;

  DairyExpense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory DairyExpense.fromJson(Map<String, dynamic> json) => DairyExpense(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] as String? ?? 'डेयरी खर्च',
        category: json['category'] as String? ?? 'चारा/भूसा',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
        notes: json['notes'] as String? ?? '',
      );

  static String encodeList(List<DairyExpense> entries) =>
      json.encode(entries.map((e) => e.toJson()).toList());

  static List<DairyExpense> decodeList(String raw) {
    if (raw.trim().isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list
          .map((item) => DairyExpense.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
