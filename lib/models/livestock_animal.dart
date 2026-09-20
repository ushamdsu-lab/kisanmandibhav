import 'dart:convert';

enum AnimalType {
  cow, // गाय
  buffalo, // भैंस
  goat, // बकरी
  other, // अन्य
}

enum AnimalStatus {
  milking, // दुधारू (दूध दे रही है)
  pregnant, // गाभिन
  dry, // सूखी / खाली
}

class LivestockAnimal {
  final String id;
  final String tagOrName; // उदा: गंगा, लक्ष्मी, 102
  final AnimalType animalType;
  final String breed; // उदा: साहीवाल, गिर, मुर्रा, जाफराबादी, सिरोही
  final int lactationNumber; // ब्यात (उदा: 1st, 2nd, 3rd)
  final double dailyMilkLiters; // प्रतिदिन औसतन दूध
  final AnimalStatus status;
  final DateTime? inseminationDate; // AI / गर्भाधान की तारीख
  final String notes;

  LivestockAnimal({
    required this.id,
    required this.tagOrName,
    required this.animalType,
    this.breed = '',
    this.lactationNumber = 1,
    this.dailyMilkLiters = 0.0,
    this.status = AnimalStatus.milking,
    this.inseminationDate,
    this.notes = '',
  });

  // Gestation length in days
  int get gestationDays {
    switch (animalType) {
      case AnimalType.cow:
        return 283;
      case AnimalType.buffalo:
        return 310;
      case AnimalType.goat:
        return 150;
      case AnimalType.other:
        return 280;
    }
  }

  // Expected Calving / Delivery Date
  DateTime? get expectedCalvingDate {
    if (inseminationDate == null) return null;
    return inseminationDate!.add(Duration(days: gestationDays));
  }

  // Days remaining for delivery
  int? get daysUntilCalving {
    final ed = expectedCalvingDate;
    if (ed == null) return null;
    return ed.difference(DateTime.now()).inDays;
  }

  // Pregnancy check recommended date (60-90 days after AI)
  DateTime? get pregnancyCheckDate {
    if (inseminationDate == null) return null;
    return inseminationDate!.add(const Duration(days: 60));
  }

  // Dry off date (Stop milking ~60 days before calving)
  DateTime? get dryOffDate {
    final ed = expectedCalvingDate;
    if (ed == null) return null;
    return ed.subtract(const Duration(days: 60));
  }

  LivestockAnimal copyWith({
    String? id,
    String? tagOrName,
    AnimalType? animalType,
    String? breed,
    int? lactationNumber,
    double? dailyMilkLiters,
    AnimalStatus? status,
    DateTime? inseminationDate,
    String? notes,
  }) {
    return LivestockAnimal(
      id: id ?? this.id,
      tagOrName: tagOrName ?? this.tagOrName,
      animalType: animalType ?? this.animalType,
      breed: breed ?? this.breed,
      lactationNumber: lactationNumber ?? this.lactationNumber,
      dailyMilkLiters: dailyMilkLiters ?? this.dailyMilkLiters,
      status: status ?? this.status,
      inseminationDate: inseminationDate ?? this.inseminationDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tagOrName': tagOrName,
        'animalType': animalType.name,
        'breed': breed,
        'lactationNumber': lactationNumber,
        'dailyMilkLiters': dailyMilkLiters,
        'status': status.name,
        'inseminationDate': inseminationDate?.toIso8601String(),
        'notes': notes,
      };

  factory LivestockAnimal.fromJson(Map<String, dynamic> json) {
    AnimalType parseType(String? val) {
      if (val == 'buffalo') return AnimalType.buffalo;
      if (val == 'goat') return AnimalType.goat;
      if (val == 'other') return AnimalType.other;
      return AnimalType.cow;
    }

    AnimalStatus parseStatus(String? val) {
      if (val == 'pregnant') return AnimalStatus.pregnant;
      if (val == 'dry') return AnimalStatus.dry;
      return AnimalStatus.milking;
    }

    return LivestockAnimal(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      tagOrName: json['tagOrName'] as String? ?? 'गौ माता',
      animalType: parseType(json['animalType'] as String?),
      breed: json['breed'] as String? ?? '',
      lactationNumber: (json['lactationNumber'] as num?)?.toInt() ?? 1,
      dailyMilkLiters: (json['dailyMilkLiters'] as num?)?.toDouble() ?? 0.0,
      status: parseStatus(json['status'] as String?),
      inseminationDate: json['inseminationDate'] != null
          ? DateTime.tryParse(json['inseminationDate'] as String)
          : null,
      notes: json['notes'] as String? ?? '',
    );
  }

  static String encodeList(List<LivestockAnimal> entries) =>
      json.encode(entries.map((e) => e.toJson()).toList());

  static List<LivestockAnimal> decodeList(String raw) {
    if (raw.trim().isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list
          .map((item) => LivestockAnimal.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
