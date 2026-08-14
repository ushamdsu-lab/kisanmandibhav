import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../data/msp_data.dart';
import '../../../data/fertilizer_stock_data.dart';
import '../../../data/soil_lab_data.dart';

class GovtDataModals {
  GovtDataModals._();

  static void showMspModal(BuildContext context) {
    final searchCtrl = TextEditingController();
    String filterSeason = 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.toLowerCase().trim();
            final filtered = MspDatabase.mspList.where((item) {
              final matchQuery = query.isEmpty ||
                  item.nameHindi.toLowerCase().contains(query) ||
                  item.nameEng.toLowerCase().contains(query);
              final matchSeason = filterSeason == 'all' || item.category == filterSeason;
              return matchQuery && matchSeason;
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🏛️ सरकारी MSP न्यूनतम समर्थन मूल्य',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 17),
                            ),
                            const Text('CACP / कृषि एवं किसान कल्याण मंत्रालय (2024-25)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                        IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                  ),
                  // Filter Season Chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        _buildFilterChip('सभी फसलें', filterSeason == 'all', () => setModalState(() => filterSeason = 'all')),
                        const SizedBox(width: 6),
                        _buildFilterChip('रबी MSP', filterSeason == 'rabi', () => setModalState(() => filterSeason = 'rabi')),
                        const SizedBox(width: 6),
                        _buildFilterChip('खरीफ MSP', filterSeason == 'kharif', () => setModalState(() => filterSeason = 'kharif')),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (_) => setModalState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'फसल खोजें (उदा: गेहूं, सरसों, चना, धान, मूंग)...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber.shade100,
                              child: Text(item.icon, style: const TextStyle(fontSize: 20)),
                            ),
                            title: Row(
                              children: [
                                Text(item.nameHindi, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: item.isOfficialMsp ? Colors.green.shade50 : Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: item.isOfficialMsp ? Colors.green : Colors.blue),
                                  ),
                                  child: Text(
                                    item.isOfficialMsp ? 'Govt MSP' : 'बाजार आधार',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: item.isOfficialMsp ? Colors.green.shade800 : Colors.blue.shade800),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text('${item.nameEng} • ${item.season}', style: const TextStyle(fontSize: 11)),
                            trailing: Text(
                              '₹${item.mspPrice.toInt()}/Qtl',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static void showFertilizerStockModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🌱 उर्वरक उपलब्धता व सरकारी MRP',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        const Text('उर्वरक विभाग, रसायन एवं उर्वरक मंत्रालय (iFMS dbtfert.nic.in)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: FertilizerStockDatabase.fertilizers.length,
                  itemBuilder: (context, index) {
                    final f = FertilizerStockDatabase.fertilizers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(f.nameHindi, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                                Text(f.mrpPrice, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('पोषक तत्व: ${f.nutrient}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_rounded, color: Colors.green, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'स्टॉक स्थिति: ${f.nationalStockStatus}',
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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

  static void showSoilTestingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🧪 मृदा स्वास्थ्य व मिट्टी जांच केंद्र',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        const Text('Soil Health Card Portal (soilhealth.dac.gov.in)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: SoilLabDatabase.labs.length,
                  itemBuilder: (context, index) {
                    final lab = SoilLabDatabase.labs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.science_rounded, color: Colors.white),
                        ),
                        title: Text(lab.labName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        subtitle: Text('${lab.labAddress}\nफोन: ${lab.contactPhone}', style: const TextStyle(fontSize: 11)),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.call_rounded, color: Colors.green),
                          onPressed: () => launchUrl(Uri.parse('tel:${lab.contactPhone}')),
                        ),
                      ),
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

  static void showHelplineModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📞 24x7 किसान हेल्पलाइन',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        const Text('निःशुल्क सरकारी सहायता नंबर', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    _buildHelplineCard('किसान कॉल सेंटर (KCC)', '1800-180-1551', 'कृषि वैज्ञानिकों से सीधे बात करें (24 घंटे, सभी भाषाएं)', Icons.support_agent_rounded, Colors.green),
                    _buildHelplineCard('खाद कालाबाजारी व अधिक दाम शिकायत', '1800-11-5501', 'उर्वरक विभाग, रसायन मंत्रालय हेल्पलाइन', Icons.report_problem_rounded, Colors.orange),
                    _buildHelplineCard('प्रधानमंत्री फसल बीमा योजना (PMFBY)', '1800-180-2117', 'फसल खराबा, क्लेम व बीमा संबंधित सहायता', Icons.shield_rounded, Colors.blue),
                    _buildHelplineCard('PM किसान सम्मान निधि हेल्पलाइन', '155261', '₹6000 वार्षिक क़िस्त संबंधित पूछताछ', Icons.account_balance_wallet_rounded, Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }

  static Widget _buildHelplineCard(String title, String number, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: Text('$subtitle\nटोल-फ्री: $number', style: const TextStyle(fontSize: 11.5)),
        isThreeLine: true,
        trailing: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: const Icon(Icons.call_rounded, size: 16, color: Colors.white),
          label: const Text('कॉल', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => launchUrl(Uri.parse('tel:$number')),
        ),
      ),
    );
  }
}
