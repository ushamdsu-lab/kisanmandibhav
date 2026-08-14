import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/mandi_provider.dart';
import '../../../providers/weather_provider.dart';
import '../../../utils/district_helper.dart';

class MandiDistrictPickerModal extends StatelessWidget {
  final MandiProvider provider;

  const MandiDistrictPickerModal({super.key, required this.provider});

  static void show(BuildContext context, MandiProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MandiDistrictPickerModal(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final districts = provider.availableDistricts;
    final searchCtrl = TextEditingController();

    return StatefulBuilder(
      builder: (context, setModalState) {
        final query = searchCtrl.text.toLowerCase();
        final filteredDistricts = query.isEmpty
            ? districts
            : districts.where((d) =>
                d.toLowerCase().contains(query) ||
                DistrictHelper.getHindiName(d).toLowerCase().contains(query)
              ).toList();

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
                      '🗺️ जिला चुनें (${districts.length} जिले)',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // GPS Tile
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.my_location_rounded, color: Colors.green),
                ),
                title: const Text('📍 मेरी वर्तमान GPS लोकेशन की मंडी', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.green)),
                subtitle: const Text('ऑटोमेटिक जिला व मंडी भाव सेट करें', style: TextStyle(fontSize: 11)),
                onTap: () async {
                  Navigator.pop(context);
                  final weatherProv = context.read<WeatherProvider>();
                  final res = await weatherProv.fetchUserLocation(mandiProvider: provider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res.isGps
                            ? '📍 आपकी मंडी लोकेशन: ${res.cityName} (${res.mandi}) सेट हो गई!'
                            : (res.errorMessage ?? 'लोकेशन प्राप्त नहीं हो सकी')),
                        backgroundColor: res.isGps ? Colors.green.shade700 : Colors.orange.shade800,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (_) => setModalState(() {}),
                  decoration: InputDecoration(
                    hintText: 'जिले का नाम खोजें (उदा: जोधपुर, बीकानेर, नागौर, कोटा)...',
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
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: provider.selectedDistrict.isEmpty
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.map_rounded,
                    color: provider.selectedDistrict.isEmpty ? AppColors.primary : Colors.grey,
                  ),
                ),
                title: const Text('सभी जिले (पूरा राज्य)', style: TextStyle(fontWeight: FontWeight.w700)),
                trailing: provider.selectedDistrict.isEmpty
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                    : null,
                onTap: () {
                  provider.selectDistrict('');
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: filteredDistricts.isEmpty
                    ? const Center(child: Text('कोई जिला नहीं मिला', style: TextStyle(fontWeight: FontWeight.w600)))
                    : ListView.builder(
                        itemCount: filteredDistricts.length,
                        itemBuilder: (context, index) {
                          final dist = filteredDistricts[index];
                          final distHindi = DistrictHelper.getHindiName(dist);
                          final isSelected = provider.selectedDistrict.toLowerCase() == dist.toLowerCase();

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
                                Icons.location_city_rounded,
                                color: isSelected ? AppColors.primary : Colors.grey,
                              ),
                            ),
                            title: Text(
                              distHindi,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected ? AppColors.primary : null,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: distHindi != dist ? Text(dist, style: const TextStyle(fontSize: 11, color: Colors.grey)) : null,
                            trailing: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                                : null,
                            onTap: () {
                              provider.selectDistrict(dist);
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
