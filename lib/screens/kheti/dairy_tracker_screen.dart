import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/dairy_record.dart';
import '../../models/livestock_animal.dart';
import '../../models/dairy_expense.dart';
import '../../models/desi_animal_remedy.dart';
import '../../models/animal_ration_guide.dart';
import '../../providers/farm_khata_provider.dart';

class DairyTrackerScreen extends StatefulWidget {
  const DairyTrackerScreen({super.key});

  @override
  State<DairyTrackerScreen> createState() => _DairyTrackerScreenState();
}

class _DairyTrackerScreenState extends State<DairyTrackerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Gestation Calculator state
  AnimalType _calcAnimalType = AnimalType.cow;
  DateTime _calcInseminationDate = DateTime.now().subtract(const Duration(days: 60));

  // Ration Calculator state
  bool _rationIsBuffalo = false;
  double _rationDailyMilk = 10.0;
  bool _rationIsPregnant = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🐄 पशुपालन व डेयरी डायरी',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_in_talk_rounded),
            tooltip: 'पशु संजीवनी 1962 टोल-फ्री',
            onPressed: () => _callHelpline('1962'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.water_drop_rounded), text: 'दूध व खर्च'),
            Tab(icon: Icon(Icons.pets_rounded), text: 'मेरे पशु (Herd)'),
            Tab(icon: Icon(Icons.event_available_rounded), text: 'प्रसव कैलकुलेटर'),
            Tab(icon: Icon(Icons.restaurant_rounded), text: 'पशु आहार (Ration)'),
            Tab(icon: Icon(Icons.medical_services_rounded), text: 'देशी उपचार व टीके'),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0277BD), Color(0xFF01579B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 1) {
            _showAddAnimalSheet(context);
          } else if (_tabController.index == 0) {
            _showAddMilkSheet(context);
          } else {
            _showAddMilkSheet(context);
          }
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          _tabController.index == 1 ? 'पशु जोड़ें' : 'दूध एंट्री दर्ज करें',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0277BD),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMilkAndExpenseTab(context),
          _buildLivestockHerdTab(context),
          _buildCalvingCalculatorTab(context),
          _buildRationCalculatorTab(context),
          _buildRemediesAndVaccinationTab(context),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: MILK & EXPENSE (दूध व खर्च)
  // ==========================================
  Widget _buildMilkAndExpenseTab(BuildContext context) {
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Consumer<FarmKhataProvider>(
      builder: (context, provider, _) {
        final records = provider.dairyRecords;
        final expenses = provider.dairyExpenses;

        return CustomScrollView(
          slivers: [
            // Top Dairy KPI Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0277BD), Color(0xFF0288D1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0277BD).withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('🥛 कुल डेयरी उत्पादन व शुद्ध मुनाफा', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                          Text('100% ऑफ़लाइन', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                '${provider.dairyTotalLiters.toStringAsFixed(1)} L',
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              const Text('कुल दूध', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Container(width: 1, height: 36, color: Colors.white24),
                          Column(
                            children: [
                              Text(
                                currencyFmt.format(provider.dairyTotalIncome),
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              const Text('दूध आय', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                          Container(width: 1, height: 36, color: Colors.white24),
                          Column(
                            children: [
                              Text(
                                currencyFmt.format(provider.netDairyProfit),
                                style: const TextStyle(color: Colors.amberAccent, fontSize: 22, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              const Text('शुद्ध डेयरी बचत', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'औसत फैट: ${provider.dairyAverageFat > 0 ? '${provider.dairyAverageFat.toStringAsFixed(1)}%' : '--'} • चारा/खर्च: ${currencyFmt.format(provider.totalDairyExpense)}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddMilkSheet(context),
                        icon: const Icon(Icons.water_drop, size: 16, color: Color(0xFF0277BD)),
                        label: const Text('दूध एंट्री लिखें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddDairyExpenseSheet(context),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.orange),
                        label: const Text('चारा/दवा खर्च', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Header Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'दूध सप्लाई रिकॉर्ड (${records.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    Text(
                      'दैनिक हिसाब',
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),

            // Milk Records List
            if (records.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.water_drop_outlined, size: 50, color: Colors.grey.withValues(alpha: 0.35)),
                        const SizedBox(height: 8),
                        const Text('कोई दूध एंट्री दर्ज नहीं है', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        const Text('रोजाना सुबह और शाम का दूध हिसाब यहाँ लिखें', style: TextStyle(color: Colors.grey, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = records[index];
                    final dateStr = DateFormat('dd MMM yyyy').format(item.date);

                    return InkWell(
                      onTap: () => _showAddMilkSheet(context, existing: item),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('🥛', style: TextStyle(fontSize: 20)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'सुबह: ${item.morningLiters}L • शाम: ${item.eveningLiters}L'
                                    '${item.fat > 0 ? ' • Fat: ${item.fat}%' : ''}',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                                  ),
                                  if (item.notes.isNotEmpty)
                                    Text(item.notes, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item.totalLiters.toStringAsFixed(1)} L',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0277BD)),
                                ),
                                if (item.ratePerLiter > 0)
                                  Text(
                                    currencyFmt.format(item.totalIncome),
                                    style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () => _showAddMilkSheet(context, existing: item),
                                      child: Icon(Icons.edit_outlined, size: 16, color: Colors.blue.shade700),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _confirmDeleteDairy(context, provider, item),
                                      child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: records.length,
                ),
              ),

            // Dairy Expenses List
            if (expenses.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('पशु चारा व मेडिकल खर्च (${expenses.length})', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                      Text('कुल: ${currencyFmt.format(provider.totalDairyExpense)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final exp = expenses[index];
                    final dateStr = DateFormat('dd MMM').format(exp.date);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10)),
                            child: const Text('🌾', style: TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${exp.category} • $dateStr', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                              ],
                            ),
                          ),
                          Text('-${currencyFmt.format(exp.amount)}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w900, fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                            onPressed: () => provider.deleteDairyExpense(exp.id),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: expenses.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 2: LIVESTOCK HERD (मेरे पशु)
  // ==========================================
  Widget _buildLivestockHerdTab(BuildContext context) {
    return Consumer<FarmKhataProvider>(
      builder: (context, provider, _) {
        final animals = provider.animals;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Herd Summary Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00695C), Color(0xFF00897B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('🐄 पशुधन गणना व क्षमता', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('डेयरी प्रबंधन', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('${provider.totalCattleCount}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                          const Text('कुल पशु', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      Container(width: 1, height: 32, color: Colors.white24),
                      Column(
                        children: [
                          Text('${provider.milkingCattleCount}', style: const TextStyle(color: Colors.greenAccent, fontSize: 24, fontWeight: FontWeight.w900)),
                          const Text('दुधारू (Milking)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      Container(width: 1, height: 32, color: Colors.white24),
                      Column(
                        children: [
                          Text('${provider.pregnantCattleCount}', style: const TextStyle(color: Colors.amberAccent, fontSize: 24, fontWeight: FontWeight.w900)),
                          const Text('गाभिन (Pregnant)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      Container(width: 1, height: 32, color: Colors.white24),
                      Column(
                        children: [
                          Text('${provider.totalEstimatedDailyMilk.toStringAsFixed(0)} L', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                          const Text('दैनिक क्षमता', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('मेरे पशु सूची (${animals.length})', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ElevatedButton.icon(
                  onPressed: () => _showAddAnimalSheet(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('नया पशु जोड़ें'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00695C),
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (animals.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Text('🐄', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      const Text('कोई पशु रजिस्टर में नहीं है', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      const Text('अपनी गाय, भैंस, बकरी का विवरण यहाँ जोड़ें', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ...animals.map((animal) {
                final isCow = animal.animalType == AnimalType.cow;
                final isBuffalo = animal.animalType == AnimalType.buffalo;
                final emoji = isCow ? '🐄' : (isBuffalo ? '🐃' : '🐐');

                String statusLabel = 'दुधारू (दूध दे रही)';
                Color statusColor = Colors.green;
                if (animal.status == AnimalStatus.pregnant) {
                  statusLabel = 'गाभिन (Pregnant)';
                  statusColor = Colors.amber.shade800;
                } else if (animal.status == AnimalStatus.dry) {
                  statusLabel = 'सूखी / खाली (Dry)';
                  statusColor = Colors.grey;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(emoji, style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        animal.tagOrName,
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${animal.breed.isNotEmpty ? animal.breed : 'देशी'} • ब्यात: ${animal.lactationNumber}'
                                  '${animal.dailyMilkLiters > 0 ? ' • दैनिक दूध: ${animal.dailyMilkLiters}L' : ''}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (animal.inseminationDate != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.event_available, size: 16, color: Colors.amber),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'संभावित ब्याने की तारीख: ${animal.expectedCalvingDate != null ? DateFormat('dd MMM yyyy').format(animal.expectedCalvingDate!) : '--'}'
                                  '${animal.daysUntilCalving != null ? ' (${animal.daysUntilCalving} दिन शेष)' : ''}',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown.shade800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (animal.notes.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(animal.notes, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => provider.deleteLivestockAnimal(animal.id),
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                          label: const Text('हटाएं', style: TextStyle(color: Colors.red, fontSize: 11)),
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 3: CALVING DATE CALCULATOR (प्रसव कैलकुलेटर)
  // ==========================================
  Widget _buildCalvingCalculatorTab(BuildContext context) {
    int gestation = _calcAnimalType == AnimalType.cow ? 283 : (_calcAnimalType == AnimalType.buffalo ? 310 : 150);
    final expectedDelivery = _calcInseminationDate.add(Duration(days: gestation));
    final pregnancyCheck = _calcInseminationDate.add(const Duration(days: 60));
    final dryOff = expectedDelivery.subtract(const Duration(days: 60));
    final daysRemaining = expectedDelivery.difference(DateTime.now()).inDays;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE65100), Color(0xFFF57C00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('⏳ गर्भाधान व ब्याने की सटीक तारीख', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('कृत्रिम गर्भाधान (A.I.) की तारीख चुनें और प्रसव, गर्भ जांच व दूध सुखाने की तारीख जानें', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Animal Type Selector
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('🐄 गाय (283 दिन)')),
                selected: _calcAnimalType == AnimalType.cow,
                onSelected: (_) => setState(() => _calcAnimalType = AnimalType.cow),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('🐃 भैंस (310 दिन)')),
                selected: _calcAnimalType == AnimalType.buffalo,
                onSelected: (_) => setState(() => _calcAnimalType = AnimalType.buffalo),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('🐐 बकरी (150 दिन)')),
                selected: _calcAnimalType == AnimalType.goat,
                onSelected: (_) => setState(() => _calcAnimalType = AnimalType.goat),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date Picker Button
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('कृत्रिम गर्भाधान (A.I.) / सीमन तारीख:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_calcInseminationDate),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _calcInseminationDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 350)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _calcInseminationDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_month, size: 16),
                label: const Text('बदलें'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Result Milestones
        _buildMilestoneCard(
          icon: Icons.baby_changing_station,
          color: Colors.deepOrange,
          title: 'संभावित प्रसव / ब्याने की तारीख (Calving Date)',
          dateStr: DateFormat('dd MMMM yyyy').format(expectedDelivery),
          subtitle: daysRemaining > 0 ? 'लगभग $daysRemaining दिन बाकी हैं' : 'प्रसव समय पूर्ण हो चुका है',
          isHighlight: true,
        ),
        const SizedBox(height: 10),
        _buildMilestoneCard(
          icon: Icons.health_and_safety,
          color: Colors.blue,
          title: 'गर्भ जांच (Pregnancy Diagnosis) तारीख',
          dateStr: DateFormat('dd MMMM yyyy').format(pregnancyCheck),
          subtitle: 'A.I. के 60 से 90 दिन बाद पशु चिकित्सक से जांच अवश्य कराएं',
        ),
        const SizedBox(height: 10),
        _buildMilestoneCard(
          icon: Icons.water_drop_outlined,
          color: Colors.purple,
          title: 'दूध सुखाने की तारीख (Dry Off Period)',
          dateStr: DateFormat('dd MMMM yyyy').format(dryOff),
          subtitle: 'ब्याने से 60 दिन पूर्व दूध निकालना बंद करें ताकि अगला ब्यात अच्छा रहे',
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMilestoneCard({
    required IconData icon,
    required Color color,
    required String title,
    required String dateStr,
    required String subtitle,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? color.withValues(alpha: 0.1) : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: isHighlight ? 0.6 : 0.2), width: isHighlight ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isHighlight ? color : Colors.grey.shade700)),
                const SizedBox(height: 2),
                Text(dateStr, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: RATION CALCULATOR (पशु आहार कैलकुलेटर)
  // ==========================================
  Widget _buildRationCalculatorTab(BuildContext context) {
    final ration = AnimalRationCalculation.calculate(
      isBuffalo: _rationIsBuffalo,
      dailyMilkLiters: _rationDailyMilk,
      isPregnant: _rationIsPregnant,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🌾 वैज्ञानिक पशु आहार व राशन संतुलन', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('दूध व फैट बढ़ाने और पशु को स्वस्थ रखने के लिए संतुलित दैनिक खुराक (ICAR मानक)', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Controls
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('🐄 देशी/संकर गाय')),
                selected: !_rationIsBuffalo,
                onSelected: (_) => setState(() => _rationIsBuffalo = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('🐃 मुर्रा/देशी भैंस')),
                selected: _rationIsBuffalo,
                onSelected: (_) => setState(() => _rationIsBuffalo = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('दैनिक दूध उत्पादन (Liters/day):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('${_rationDailyMilk.toStringAsFixed(1)} लीटर', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green)),
                ],
              ),
              Slider(
                value: _rationDailyMilk,
                min: 0,
                max: 30,
                divisions: 30,
                label: '${_rationDailyMilk.toStringAsFixed(1)}L',
                onChanged: (val) => setState(() => _rationDailyMilk = val),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('क्या पशु अंतिम 2 माह का गाभिन है?', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                subtitle: const Text('गाभिन पशु को +1.25kg अतिरिक्त दाना चाहिए', style: TextStyle(fontSize: 11)),
                value: _rationIsPregnant,
                onChanged: (val) => setState(() => _rationIsPregnant = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('📋 प्रतिदिन आवश्यक संतुलित खुराक (24 घंटे हेतु):', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 8),

        _buildRationItem('🌾 सूखा चारा (भूसा / कड़बी)', '${ration.dryFodderKg} kg', 'पेट भरने व जुगाली हेतु आवश्यक'),
        _buildRationItem('🌿 हरा चारा (बरसीम / मक्का / नेपियर)', '${ration.greenFodderKg} kg', 'विटामिन-A व पाचन शक्ति हेतु'),
        _buildRationItem('🥣 संतुलित दाना / खली (Feed)', '${ration.concentrateKg} kg', 'दूध उत्पादन व फैट बढ़ाने हेतु'),
        _buildRationItem('🧂 मिनरल मिक्चर (खनिज लवण)', '${ration.mineralMixtureGrams.toInt()} ग्राम', 'हड्डियां मजबूत व समय पर गाभिन हेतु'),
        _buildRationItem('🧂 साधारण नमक (Common Salt)', '${ration.saltGrams.toInt()} ग्राम', 'पाचन व पानी पीने की इच्छा हेतु'),
        _buildRationItem('💧 पीने का स्वच्छ पानी', '${ration.dailyWaterLiters.toInt()} लीटर', 'दूध में 85-87% पानी होता है'),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRationItem(String title, String value, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10)),
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.green.shade900)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 5: REMEDIES & VACCINES (देशी उपचार व टीके)
  // ==========================================
  Widget _buildRemediesAndVaccinationTab(BuildContext context) {
    const remedies = DesiAnimalRemedy.standardRemedies;
    const vaccines = AnimalVaccinationAlert.standardCalendar;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Helpline
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('पशु संजीवनी राष्ट्रीय हेल्पलाइन', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF795548))),
                    const SizedBox(height: 2),
                    const Text('किसी भी आपात स्थिति में टोल-फ्री नंबर 1962 पर कॉल करें', style: TextStyle(fontSize: 11.5, color: Colors.black87)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _callHelpline('1962'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0277BD),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                child: const Text('कॉल 1962', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('🌿 पशुओं के प्रसिद्ध देशी घरेलू नुस्खे (Emergency Ayurvedic Remedies):', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 8),

        ...remedies.map((rem) => _buildRemedyCard(rem)),

        const SizedBox(height: 18),
        const Text('📋 राष्ट्रीय पशु टीकाकरण कैलेंडर (ICAR दिशानिर्देश):', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
        const SizedBox(height: 8),

        ...vaccines.map((v) => _buildVaccineCard(v)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRemedyCard(DesiAnimalRemedy rem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: ExpansionTile(
        title: Text(rem.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
        subtitle: Text('लक्षण: ${rem.symptoms}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
          child: const Text('🌿', style: TextStyle(fontSize: 18)),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          const Divider(),
          _buildInfoRow('सामग्री (Ingredients):', rem.ingredients.join('\n• ')),
          const SizedBox(height: 6),
          _buildInfoRow('बनाने की विधि:', rem.preparation),
          const SizedBox(height: 6),
          _buildInfoRow('खुराक व सेवन तरीका:', rem.dosage),
          const SizedBox(height: 6),
          _buildInfoRow('सावधानी:', rem.precaution),
        ],
      ),
    );
  }

  Widget _buildVaccineCard(AnimalVaccinationAlert v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(v.diseaseName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                child: Text(v.vaccineName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('📅 अनुशंसित समय: ${v.recommendedMonth}', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text('🎯 लक्षित पशु: ${v.targetAnimals}', style: TextStyle(color: Colors.grey.shade700, fontSize: 11.5)),
          const SizedBox(height: 4),
          Text('💡 सावधानी: ${v.precaution}', style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF00695C))),
        const SizedBox(width: 6),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 11.5))),
      ],
    );
  }

  // ==========================================
  // SHEET: ADD LIVESTOCK ANIMAL
  // ==========================================
  void _showAddAnimalSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final milkCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    AnimalType type = AnimalType.cow;
    AnimalStatus status = AnimalStatus.milking;
    DateTime? aiDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🐄 नया पशु रजिस्टर करें', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('🐄 गाय')),
                            selected: type == AnimalType.cow,
                            onSelected: (_) => setModalState(() => type = AnimalType.cow),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('🐃 भैंस')),
                            selected: type == AnimalType.buffalo,
                            onSelected: (_) => setModalState(() => type = AnimalType.buffalo),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('🐐 बकरी')),
                            selected: type == AnimalType.goat,
                            onSelected: (_) => setModalState(() => type = AnimalType.goat),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'पशु का नाम या टैग नंबर *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: breedCtrl,
                      decoration: const InputDecoration(labelText: 'नस्ल (उदा: साहीवाल, गिर, मुर्रा)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: milkCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'दैनिक दूध (Liters)', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<AnimalStatus>(
                            initialValue: status,
                            decoration: const InputDecoration(labelText: 'स्थिति (Status)', border: OutlineInputBorder()),
                            items: const [
                              DropdownMenuItem(value: AnimalStatus.milking, child: Text('दूध दे रही')),
                              DropdownMenuItem(value: AnimalStatus.pregnant, child: Text('गाभिन')),
                              DropdownMenuItem(value: AnimalStatus.dry, child: Text('सूखी / खाली')),
                            ],
                            onChanged: (v) => setModalState(() => status = v ?? AnimalStatus.milking),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(aiDate == null ? 'A.I. / सीमन की तारीख जोड़ें (वैकल्पिक)' : 'A.I. तारीख: ${DateFormat('dd/MM/yyyy').format(aiDate!)}'),
                      trailing: const Icon(Icons.calendar_month),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 30)),
                          firstDate: DateTime.now().subtract(const Duration(days: 350)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setModalState(() => aiDate = picked);
                      },
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(labelText: 'टिप्पणी / विवरण (वैकल्पिक)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0277BD), foregroundColor: Colors.white),
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया नाम या टैग लिखें')));
                            return;
                          }
                          final animal = LivestockAnimal(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            tagOrName: name,
                            animalType: type,
                            breed: breedCtrl.text.trim(),
                            dailyMilkLiters: double.tryParse(milkCtrl.text.trim()) ?? 0.0,
                            status: status,
                            inseminationDate: aiDate,
                            notes: notesCtrl.text.trim(),
                          );
                          context.read<FarmKhataProvider>().addLivestockAnimal(animal);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पशु सुरक्षित किया गया')));
                        },
                        child: const Text('सुरक्षित करें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // SHEET: ADD MILK ENTRY
  // ==========================================
  void _showAddMilkSheet(BuildContext context, {DairyRecord? existing}) {
    final morningCtrl = TextEditingController(text: existing != null ? existing.morningLiters.toString() : '');
    final eveningCtrl = TextEditingController(text: existing != null ? existing.eveningLiters.toString() : '');
    final fatCtrl = TextEditingController(text: existing != null && existing.fat > 0 ? existing.fat.toString() : '6.5');
    final rateCtrl = TextEditingController(text: existing != null && existing.ratePerLiter > 0 ? existing.ratePerLiter.toString() : '55');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      existing != null ? '✏️ दूध रिकॉर्ड एडिट करें' : '🥛 आज का दूध हिसाब दर्ज करें',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: morningCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'सुबह का दूध (Liters) *', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: eveningCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'शाम का दूध (Liters) *', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'दूध फैट % (उदा: 6.5)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: rateCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'भाव प्रति लीटर (₹/L)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'टिप्पणी (उदा: डेयरी सेंटर सप्लाई, घरेलू उपयोग)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0277BD), foregroundColor: Colors.white),
                    onPressed: () {
                      final m = double.tryParse(morningCtrl.text.trim()) ?? 0.0;
                      final e = double.tryParse(eveningCtrl.text.trim()) ?? 0.0;
                      if (m <= 0 && e <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया दूध की सही मात्रा लिखें')));
                        return;
                      }

                      final record = DairyRecord(
                        id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                        date: existing?.date ?? DateTime.now(),
                        morningLiters: m,
                        eveningLiters: e,
                        fat: double.tryParse(fatCtrl.text.trim()) ?? 0.0,
                        ratePerLiter: double.tryParse(rateCtrl.text.trim()) ?? 0.0,
                        notes: notesCtrl.text.trim(),
                      );

                      context.read<FarmKhataProvider>().addDairyRecord(record);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दूध रिकॉर्ड सुरक्षित हुआ')));
                    },
                    child: const Text('सुरक्षित करें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // SHEET: ADD DAIRY EXPENSE
  // ==========================================
  void _showAddDairyExpenseSheet(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'सरसों खल / दाना');
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String category = 'दाना/खल/चोकर';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🌾 चारा व पशु खर्च दर्ज करें', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'खर्च श्रेणी *', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'चारा/भूसा', child: Text('चारा/भूसा खरीद')),
                        DropdownMenuItem(value: 'दाना/खल/चोकर', child: Text('दाना/खल/चोकर (Feed)')),
                        DropdownMenuItem(value: 'डॉक्टर/दवाई', child: Text('डॉक्टर फीस व दवाई')),
                        DropdownMenuItem(value: 'A.I./सीमन', child: Text('A.I./सीमन स्ट्रॉ')),
                        DropdownMenuItem(value: 'अन्य', child: Text('अन्य डेयरी खर्च')),
                      ],
                      onChanged: (v) => setModalState(() => category = v ?? 'अन्य'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'विवरण (उदा: 50kg खल बोरी)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'रुपये (Amount) *', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(labelText: 'टिप्पणी (वैकल्पिक)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800, foregroundColor: Colors.white),
                        onPressed: () {
                          final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                          if (amt <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सही राशि दर्ज करें')));
                            return;
                          }

                          final exp = DairyExpense(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleCtrl.text.trim().isEmpty ? category : titleCtrl.text.trim(),
                            category: category,
                            amount: amt,
                            date: DateTime.now(),
                            notes: notesCtrl.text.trim(),
                          );

                          context.read<FarmKhataProvider>().addDairyExpense(exp);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('डेयरी खर्च सुरक्षित हुआ')));
                        },
                        child: const Text('सुरक्षित करें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteDairy(BuildContext context, FarmKhataProvider provider, DairyRecord item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('दूध रिकॉर्ड हटाएं?'),
        content: Text('क्या आप ${DateFormat('dd MMM').format(item.date)} का ${item.totalLiters}L का रिकॉर्ड हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('रद्द करें')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('हटाएं'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      provider.deleteDairyRecord(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दूध रिकॉर्ड हटा दिया गया')));
      }
    }
  }

  void _callHelpline(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }
}
