/// Model for Manual / Direct Sponsored Ads (कस्टम प्रायोजित विज्ञापन)
class CustomAd {
  final String id;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String? assetImage;
  final String tag;
  final String actionType; // 'whatsapp', 'call', 'url'
  final String actionValue; // Phone number or URL
  final String actionButtonText;
  final bool isActive;

  const CustomAd({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.assetImage,
    this.tag = 'प्रायोजित / Sponsored',
    this.actionType = 'whatsapp',
    required this.actionValue,
    this.actionButtonText = 'संपर्क करें',
    this.isActive = true,
  });

  factory CustomAd.fromJson(Map<String, dynamic> json) {
    return CustomAd(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      assetImage: json['assetImage'] as String?,
      tag: json['tag'] as String? ?? 'प्रायोजित / Sponsored',
      actionType: json['actionType'] as String? ?? 'whatsapp',
      actionValue: json['actionValue'] as String? ?? '',
      actionButtonText: json['actionButtonText'] as String? ?? 'संपर्क करें',
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'assetImage': assetImage,
      'tag': tag,
      'actionType': actionType,
      'actionValue': actionValue,
      'actionButtonText': actionButtonText,
      'isActive': isActive,
    };
  }
}
