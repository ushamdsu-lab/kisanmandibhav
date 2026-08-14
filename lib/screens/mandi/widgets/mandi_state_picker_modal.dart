import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../providers/mandi_provider.dart';

class MandiStatePickerModal extends StatelessWidget {
  final MandiProvider provider;

  static const List<Map<String, String>> primaryStates = [
    {'name': 'Rajasthan', 'label': 'राजस्थान'},
    {'name': 'Madhya Pradesh', 'label': 'मध्य प्रदेश'},
    {'name': 'Gujarat', 'label': 'गुजरात'},
    {'name': 'Punjab', 'label': 'पंजाब'},
    {'name': 'Haryana', 'label': 'हरियाणा'},
    {'name': 'Uttar Pradesh', 'label': 'उत्तर प्रदेश'},
    {'name': 'Maharashtra', 'label': 'महाराष्ट्र'},
    {'name': 'Karnataka', 'label': 'कर्नाटक'},
    {'name': 'Tamil Nadu', 'label': 'तमिलनाडु'},
    {'name': 'Andhra Pradesh', 'label': 'आंध्र प्रदेश'},
    {'name': 'Telangana', 'label': 'तेलंगाना'},
    {'name': 'Bihar', 'label': 'बिहार'},
    {'name': 'West Bengal', 'label': 'पश्चिम बंगाल'},
    {'name': 'Odisha', 'label': 'ओडिशा'},
    {'name': 'Chhattisgarh', 'label': 'छत्तीसगढ़'},
    {'name': 'Jharkhand', 'label': 'झारखंड'},
    {'name': 'Uttarakhand', 'label': 'उत्तराखंड'},
    {'name': 'Himachal Pradesh', 'label': 'हिमाचल प्रदेश'},
    {'name': 'Assam', 'label': 'असम'},
    {'name': 'Kerala', 'label': 'केरल'},
  ];

  const MandiStatePickerModal({super.key, required this.provider});

  static void show(BuildContext context, MandiProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MandiStatePickerModal(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();

    return StatefulBuilder(
      builder: (context, setModalState) {
        final query = searchCtrl.text.trim().toLowerCase();
        final filteredStates = query.isEmpty
            ? primaryStates
            : primaryStates.where((s) {
                final label = s['label']!.toLowerCase();
                final name = s['name']!.toLowerCase();
                return label.contains(query) || name.contains(query);
              }).toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📍 राज्य चुनें (Select State)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: 'राज्य का नाम खोजें (उदा: राजस्थान, UP, पंजाब)...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              searchCtrl.clear();
                              setModalState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: filteredStates.isEmpty
                    ? const Center(child: Text('कोई राज्य नहीं मिला', style: TextStyle(fontWeight: FontWeight.w600)))
                    : ListView.builder(
                        itemCount: filteredStates.length,
                        itemBuilder: (context, index) {
                          final st = filteredStates[index];
                          final isSelected = provider.selectedState.toLowerCase() == st['name']!.toLowerCase();

                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.map_rounded,
                                color: isSelected ? AppColors.primary : Colors.grey,
                              ),
                            ),
                            title: Text(
                              st['label']!,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : null,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(st['name']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                : null,
                            onTap: () {
                              provider.selectState(st['name']!);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
