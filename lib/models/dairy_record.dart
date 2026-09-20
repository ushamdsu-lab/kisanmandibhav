import 'dart:convert';

class DairyRecord {
  final String id;
  final DateTime date;
  final double morningLiters;
  final double eveningLiters;
  final double fat; // उदा: 6.5
  final double ratePerLiter; // उदा: ₹55/L
  final String notes;

  DairyRecord({
    required this.id,
    required this.date,
    required this.morningLiters,
    required this.eveningLiters,
    this.fat = 0.0,
    this.ratePerLiter = 0.0,
    this.notes = '',
  });

  double get totalLiters => morningLiters + eveningLiters;
  double get totalIncome => totalLiters * ratePerLiter;

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'morningLiters': morningLiters,
        'eveningLiters': eveningLiters,
        'fat': fat,
        'ratePerLiter': ratePerLiter,
        'notes': notes,
      };

  factory DairyRecord.fromJson(Map<String, dynamic> json) => DairyRecord(
        id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: json['date'] != null
            ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
            : DateTime.now(),
        morningLiters: (json['morningLiters'] as num?)?.toDouble() ?? 0.0,
        eveningLiters: (json['eveningLiters'] as num?)?.toDouble() ?? 0.0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
        ratePerLiter: (json['ratePerLiter'] as num?)?.toDouble() ?? 0.0,
        notes: json['notes'] as String? ?? '',
      );

  static String encodeList(List<DairyRecord> entries) =>
      json.encode(entries.map((e) => e.toJson()).toList());

  static List<DairyRecord> decodeList(String raw) {
    if (raw.trim().isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list
          .map((item) => DairyRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

class AnimalVaccinationAlert {
  final String diseaseName;
  final String vaccineName;
  final String recommendedMonth;
  final String targetAnimals;
  final String precaution;

  const AnimalVaccinationAlert({
    required this.diseaseName,
    required this.vaccineName,
    required this.recommendedMonth,
    required this.targetAnimals,
    required this.precaution,
  });

  static const List<AnimalVaccinationAlert> standardCalendar = [
    AnimalVaccinationAlert(
      diseaseName: 'खुरपका-मुंहपका (FMD)',
      vaccineName: 'FMD Polyvalent Vaccine',
      recommendedMonth: 'फरवरी - मार्च और सितंबर - अक्टूबर',
      targetAnimals: 'गाय, भैंस, भेड़, बकरी',
      precaution: 'साल में दो बार टीका लगवाना अनिवार्य है। बुखार आने पर डॉक्टर से सलाह लें।',
    ),
    AnimalVaccinationAlert(
      diseaseName: 'गलघोंटू (HS - Hemorrhagic Septicemia)',
      vaccineName: 'HS Alum Precipitated Vaccine',
      recommendedMonth: 'मई - जून (मानसून से ठीक पहले)',
      targetAnimals: 'गाय, भैंस',
      precaution: 'वर्षा ऋतु शुरू होने से पहले अवश्य टीका लगवाएं, वर्षा में संक्रमण तेजी से फैलता है।',
    ),
    AnimalVaccinationAlert(
      diseaseName: 'ब्लैक क्वार्टर / लंगड़ा बुखार (BQ)',
      vaccineName: 'BQ Vaccine',
      recommendedMonth: 'मई - जून',
      targetAnimals: 'विशेषकर 6 माह से 3 वर्ष के बछड़े-बछिया',
      precaution: 'तेज बुखार और जांघों पर सूजन के लक्षण दिखते ही तुरंत पशु चिकित्सक से संपर्क करें।',
    ),
    AnimalVaccinationAlert(
      diseaseName: 'लंपी स्किन रोग (Lumpy Skin Disease)',
      vaccineName: 'Goat Pox Vaccine',
      recommendedMonth: 'अप्रैल - मई',
      targetAnimals: 'विशेषकर गोवंश',
      precaution: 'मच्छर-मक्खियों से बचाव करें और गौशाला में नीम के पत्तों का धुआं करें।',
    ),
  ];
}
