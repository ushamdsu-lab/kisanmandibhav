class Fertilizer {
  final String id;
  final String name;
  final String nameEn;
  final String nutrient;
  final String usage;
  final String dosagePerHectare;
  final String dosagePerBigha;
  final String method;
  final String precaution;
  final String price;
  final List<String> crops;

  Fertilizer({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nutrient,
    required this.usage,
    required this.dosagePerHectare,
    required this.dosagePerBigha,
    required this.method,
    required this.precaution,
    required this.price,
    required this.crops,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) => Fertilizer(
    id: json['id'],
    name: json['name'],
    nameEn: json['nameEn'],
    nutrient: json['nutrient'],
    usage: json['usage'],
    dosagePerHectare: json['dosagePerHectare'],
    dosagePerBigha: json['dosagePerBigha'],
    method: json['method'],
    precaution: json['precaution'],
    price: json['price'],
    crops: List<String>.from(json['crops']),
  );
}
