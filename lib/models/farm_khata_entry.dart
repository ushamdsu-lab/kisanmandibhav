import 'dart:convert';

enum KhataEntryType {
  expense,
  income,
}

class FarmKhataEntry {
  final String id;
  final String cropName;
  final KhataEntryType type;
  final String category; // उदा: बीज, खाद, कीटनाशक, डीजल/जुताई, मजदूरी, मंडी बिक्री, अन्य
  final double amount;
  final double? quantity; // जैसे 10 क्विंटल, 5 बोरी
  final String? unit; // क्विंटल, बोरी, लीटर, एकड़
  final DateTime date;
  final String notes;

  FarmKhataEntry({
    required this.id,
    required this.cropName,
    required this.type,
    required this.category,
    required this.amount,
    this.quantity,
    this.unit,
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropName': cropName,
        'type': type == KhataEntryType.expense ? 'expense' : 'income',
        'category': category,
        'amount': amount,
        'quantity': quantity,
        'unit': unit,
        'date': date.toIso8601String(),
        'notes': notes,
      };

  factory FarmKhataEntry.fromJson(Map<String, dynamic> json) => FarmKhataEntry(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        cropName: json['cropName'] as String? ?? 'अन्य फसल',
        type: (json['type'] as String? ?? 'expense') == 'income'
            ? KhataEntryType.income
            : KhataEntryType.expense,
        category: json['category'] as String? ?? 'अन्य',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
        notes: json['notes'] as String? ?? '',
      );

  static String encodeList(List<FarmKhataEntry> entries) =>
      json.encode(entries.map((e) => e.toJson()).toList());

  static List<FarmKhataEntry> decodeList(String raw) {
    if (raw.trim().isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list
          .map((item) => FarmKhataEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
