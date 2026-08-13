class Scheme {
  final String id;
  final String name;
  final String nameEn;
  final String governmentType; // 'central' or 'state'
  final String stateName; // 'All India', 'Rajasthan', 'Madhya Pradesh', 'Gujarat'
  final String badgeText;
  final String category;
  final String categoryEn;
  final String icon;
  final String description;
  final List<String> eligibility;
  final List<String> benefits;
  final String howToApply;
  final String website;
  final List<String> documents;

  Scheme({
    required this.id,
    required this.name,
    required this.nameEn,
    this.governmentType = 'central',
    this.stateName = 'All India',
    this.badgeText = '🏛️ केंद्र सरकार',
    required this.category,
    required this.categoryEn,
    required this.icon,
    required this.description,
    required this.eligibility,
    required this.benefits,
    required this.howToApply,
    required this.website,
    required this.documents,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) => Scheme(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    nameEn: json['nameEn'] ?? '',
    governmentType: json['governmentType'] ?? 'central',
    stateName: json['stateName'] ?? 'All India',
    badgeText: json['badgeText'] ?? '🏛️ केंद्र सरकार',
    category: json['category'] ?? '',
    categoryEn: json['categoryEn'] ?? '',
    icon: json['icon'] ?? 'account_balance_wallet',
    description: json['description'] ?? '',
    eligibility: List<String>.from(json['eligibility'] ?? []),
    benefits: List<String>.from(json['benefits'] ?? []),
    howToApply: json['howToApply'] ?? '',
    website: json['website'] ?? '',
    documents: List<String>.from(json['documents'] ?? []),
  );
}
