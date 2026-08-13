class CropStep {
  final int step;
  final String title;
  final String detail;

  CropStep({required this.step, required this.title, required this.detail});

  factory CropStep.fromJson(Map<String, dynamic> json) => CropStep(
    step: json['step'],
    title: json['title'],
    detail: json['detail'],
  );
}

class PestInfo {
  final String name;
  final String symptom;
  final String remedy;

  PestInfo({required this.name, required this.symptom, required this.remedy});

  factory PestInfo.fromJson(Map<String, dynamic> json) => PestInfo(
    name: json['name'],
    symptom: json['symptom'],
    remedy: json['remedy'],
  );
}

class Crop {
  final String id;
  final String name;
  final String nameEn;
  final String icon;
  final String season;
  final String sowingMonth;
  final String harvestMonth;
  final String duration;
  final String soilType;
  final String waterNeed;
  final String temperature;
  final String description;
  final List<CropStep> steps;
  final List<PestInfo> pests;

  Crop({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.season,
    required this.sowingMonth,
    required this.harvestMonth,
    required this.duration,
    required this.soilType,
    required this.waterNeed,
    required this.temperature,
    required this.description,
    required this.steps,
    required this.pests,
  });

  factory Crop.fromJson(Map<String, dynamic> json) => Crop(
    id: json['id'],
    name: json['name'],
    nameEn: json['nameEn'],
    icon: json['icon'],
    season: json['season'],
    sowingMonth: json['sowingMonth'],
    harvestMonth: json['harvestMonth'],
    duration: json['duration'],
    soilType: json['soilType'],
    waterNeed: json['waterNeed'],
    temperature: json['temperature'],
    description: json['description'],
    steps: (json['steps'] as List).map((e) => CropStep.fromJson(e)).toList(),
    pests: (json['pests'] as List).map((e) => PestInfo.fromJson(e)).toList(),
  );
}
