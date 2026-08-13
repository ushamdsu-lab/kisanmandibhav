class Helpline {
  final String id;
  final String name;
  final String nameEn;
  final String number;
  final String icon;
  final String description;
  final String timing;
  final bool tollFree;
  final String category;

  Helpline({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.number,
    required this.icon,
    required this.description,
    required this.timing,
    required this.tollFree,
    required this.category,
  });

  factory Helpline.fromJson(Map<String, dynamic> json) => Helpline(
    id: json['id'],
    name: json['name'],
    nameEn: json['nameEn'],
    number: json['number'],
    icon: json['icon'],
    description: json['description'],
    timing: json['timing'],
    tollFree: json['tollFree'] ?? true,
    category: json['category'],
  );
}
