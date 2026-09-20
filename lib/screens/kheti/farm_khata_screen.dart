import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/farm_khata_entry.dart';
import '../../models/udhar_entry.dart';
import '../../providers/farm_khata_provider.dart';

class FarmKhataScreen extends StatefulWidget {
  const FarmKhataScreen({super.key});

  @override
  State<FarmKhataScreen> createState() => _FarmKhataScreenState();
}

class _FarmKhataScreenState extends State<FarmKhataScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _showAnalytics = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '📒 कृषि बहीखाता (मुनाफा व उधारी)',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(_showAnalytics ? Icons.table_chart_rounded : Icons.pie_chart_outline_rounded),
            tooltip: _showAnalytics ? 'हिसाब सूची देखें' : 'खर्च का विश्लेषण देखें',
            onPressed: () {
              setState(() {
                _showAnalytics = !_showAnalytics;
              });
            },
          ),
          Consumer<FarmKhataProvider>(
            builder: (context, provider, _) {
              return IconButton(
                icon: const Icon(Icons.share_rounded),
                tooltip: 'WhatsApp पर हिसाब शेयर करें',
                onPressed: () => _shareWhatsApp(context, provider.generateWhatsAppReceiptText()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'बैकअप व रीस्टोर',
            onSelected: (val) {
              if (val == 'export') {
                _handleExportBackup(context);
              } else if (val == 'import') {
                _handleImportBackup(context);
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.green),
                    SizedBox(width: 8),
                    Text('💾 पूरा बैकअप लें (Export)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.cloud_download_outlined, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('📥 बैकअप रीस्टोर करें (Import)'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long_rounded), text: 'खर्च व आमदनी'),
            Tab(icon: Icon(Icons.handshake_rounded), text: 'उधारी व लेन-देन'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'फसल मुनाफा'),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 1) {
            _showUdharFormSheet(context);
          } else {
            _showEntryFormSheet(context);
          }
        },
        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
        label: Text(
          _tabController.index == 1 ? 'उधार दर्ज करें' : 'नया हिसाब जोड़ें',
          style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIncomeExpenseTab(context),
          _buildUdharTab(context),
          _buildCropProfitTab(context),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: INCOME & EXPENSE (खर्च व आमदनी)
  // ==========================================
  Widget _buildIncomeExpenseTab(BuildContext context) {
    return Consumer<FarmKhataProvider>(
      builder: (context, provider, _) {
        final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

        return CustomScrollView(
          slivers: [
            // Top Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: provider.isProfitable
                          ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
                          : [const Color(0xFFB71C1C), const Color(0xFFC62828)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: (provider.isProfitable ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C))
                            .withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            provider.isProfitable ? '✨ कुल शुद्ध बचत / मुनाफा' : '⚠️ कुल घाटा',
                            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              provider.selectedCrop == 'all' ? 'सभी फसलें' : provider.selectedCrop,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currencyFmt.format(provider.netProfit.abs()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            provider.isProfitable ? 'शुद्ध लाभ' : 'घाटा',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.arrow_downward_rounded, color: Colors.greenAccent, size: 14),
                                      SizedBox(width: 4),
                                      Text('कुल बिक्री (आय)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFmt.format(provider.totalIncome),
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(height: 30, width: 1, color: Colors.white24),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.arrow_upward_rounded, color: Colors.amberAccent, size: 14),
                                        SizedBox(width: 4),
                                        Text('कुल खेती खर्च', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFmt.format(provider.totalExpense),
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick 1-Tap Expense Presets Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt_rounded, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          'त्वरित जोड़ें (1-Tap Quick Expenses):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildQuickPresetChip('🚜 ट्रैक्टर जुताई ₹2,500', 'डीजल व जुताई', 2500, provider),
                          _buildQuickPresetChip('🌱 DAP खाद ₹1,350', 'खाद व उर्वरक', 1350, provider),
                          _buildQuickPresetChip('🌾 यूरिया खाद ₹267', 'खाद व उर्वरक', 267, provider),
                          _buildQuickPresetChip('🧪 कीटनाशक स्प्रे ₹850', 'कीटनाशक व दवाई', 850, provider),
                          _buildQuickPresetChip('👷 मजदूरी दिहाड़ी ₹500', 'मजदूरी व निंदाई', 500, provider),
                          _buildQuickPresetChip('🚛 मंडी भाड़ा ₹1,200', 'मंडी व भाड़ा', 1200, provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Crop Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    FilterChip(
                      label: const Text('सभी फसलें'),
                      selected: provider.selectedCrop == 'all',
                      onSelected: (_) => provider.setSelectedCrop('all'),
                      selectedColor: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                      checkmarkColor: const Color(0xFF1B5E20),
                    ),
                    const SizedBox(width: 8),
                    ...provider.availableCrops.map(
                      (crop) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(crop),
                          selected: provider.selectedCrop == crop,
                          onSelected: (_) => provider.setSelectedCrop(crop),
                          selectedColor: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                          checkmarkColor: const Color(0xFF1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Analytics Section (if toggled)
            if (_showAnalytics && provider.categoryExpenses.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 मद-वार खर्च विश्लेषण (Category Breakdown)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ...provider.categoryExpenses.entries.map((entry) {
                          final pct = provider.totalExpense > 0 ? (entry.value / provider.totalExpense) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text(
                                      '${currencyFmt.format(entry.value)} (${(pct * 100).toStringAsFixed(1)}%)',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: pct,
                                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

            // Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'लेन-देन सूची (${provider.filteredEntries.length})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    const Text('100% ऑफ़लाइन सुरक्षित', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            // Entries List
            if (provider.filteredEntries.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.menu_book_rounded, size: 64, color: Colors.grey.withValues(alpha: 0.35)),
                        const SizedBox(height: 12),
                        const Text('कोई हिसाब नहीं मिला', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('नया खर्च या मंडी बिक्री जोड़ने के लिए नीचे टैप करें', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showEntryFormSheet(context),
                          icon: const Icon(Icons.add),
                          label: const Text('हिसाब दर्ज करें'),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = provider.filteredEntries[index];
                    final isIncome = item.type == KhataEntryType.income;
                    final dateStr = DateFormat('dd MMM yyyy').format(item.date);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                              color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(item.category, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(item.cropName, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$dateStr${item.quantity != null ? ' • ${item.quantity} ${item.unit ?? ''}' : ''}',
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
                                '${isIncome ? '+' : '-'}${currencyFmt.format(item.amount)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => _showEntryFormSheet(context, existing: item),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(Icons.edit_outlined, size: 16, color: Colors.blue.shade700),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _confirmDelete(context, provider, item),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: provider.filteredEntries.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        );
      },
    );
  }

  Widget _buildQuickPresetChip(String label, String category, double amount, FarmKhataProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade50,
        side: BorderSide(color: Colors.green.shade200),
        onPressed: () {
          final entry = FarmKhataEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            cropName: provider.selectedCrop == 'all' ? 'सोयाबीन' : provider.selectedCrop,
            type: KhataEntryType.expense,
            category: category,
            amount: amount,
            date: DateTime.now(),
            notes: 'त्वरित एंट्री',
          );
          provider.addKhataEntry(entry);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('जोड़ा गया: $label'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 2: UDHAR & LEDGER (उधारी व देनदारी)
  // ==========================================
  Widget _buildUdharTab(BuildContext context) {
    return Consumer<FarmKhataProvider>(
      builder: (context, provider, _) {
        final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
        final udhars = provider.udharEntries;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top Udhar Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF37474F), Color(0xFF263238)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('🤝 किसान उधारी व बकाया डायरी', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      Text('लेन-देन खाता', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            currencyFmt.format(provider.totalLena),
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          const Text('कुल लेना (Receivable)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                      Container(width: 1, height: 36, color: Colors.white24),
                      Column(
                        children: [
                          Text(
                            currencyFmt.format(provider.totalDena),
                            style: const TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          const Text('कुल देना (Payable)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'पार्टी व दुकानदार हिसाब (${udhars.length})',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                TextButton.icon(
                  onPressed: () => _showUdharFormSheet(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('उधार जोड़ें', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (udhars.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.handshake_outlined, size: 60, color: Colors.grey.withValues(alpha: 0.35)),
                      const SizedBox(height: 12),
                      const Text('कोई उधारी या बकाया दर्ज नहीं है', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      const Text('दुकानदार, व्यापारी या मजदूर का हिसाब यहाँ रखें', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showUdharFormSheet(context),
                        icon: const Icon(Icons.add),
                        label: const Text('उधार खाता बनाएं'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...udhars.map((item) {
                final isLena = item.type == UdharType.lena;
                final dateStr = DateFormat('dd MMM yyyy').format(item.date);
                final dueStr = item.dueDate != null ? DateFormat('dd MMM').format(item.dueDate!) : null;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.isSettled
                          ? Colors.grey.withValues(alpha: 0.2)
                          : (isLena ? Colors.green.shade300 : Colors.red.shade300),
                      width: item.isSettled ? 1 : 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: item.isSettled
                                  ? Colors.grey.shade100
                                  : (isLena ? Colors.green.shade50 : Colors.red.shade50),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.isSettled ? Icons.check_circle_rounded : (isLena ? Icons.call_received_rounded : Icons.call_made_rounded),
                              color: item.isSettled ? Colors.grey : (isLena ? Colors.green.shade700 : Colors.red.shade700),
                              size: 18,
                            ),
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
                                        item.partyName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          decoration: item.isSettled ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: item.isSettled
                                            ? Colors.grey.shade200
                                            : (isLena ? Colors.green.shade100 : Colors.red.shade100),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.isSettled ? '✅ चुकता' : (isLena ? 'लेना है' : 'देना है'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: item.isSettled ? Colors.grey.shade700 : (isLena ? Colors.green.shade900 : Colors.red.shade900),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${item.category} • $dateStr${dueStr != null ? ' • अंतिम: $dueStr' : ''}',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                                ),
                                if (item.notes.isNotEmpty)
                                  Text(item.notes, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            currencyFmt.format(item.amount),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isLena ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                          Row(
                            children: [
                              // Toggle Settled Button
                              TextButton(
                                onPressed: () => provider.toggleUdharSettled(item.id),
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                child: Text(item.isSettled ? 'बकाया करें' : 'चुकता मार्क करें'),
                              ),
                              // WhatsApp Reminder
                              IconButton(
                                icon: const Icon(Icons.share_rounded, color: Colors.green, size: 20),
                                tooltip: 'WhatsApp पर पर्ची भेजें',
                                onPressed: () {
                                  final msg = provider.generateUdharWhatsAppReminder(item);
                                  _shareWhatsApp(context, msg, phone: item.phone);
                                },
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                onPressed: () => provider.deleteUdharEntry(item.id),
                              ),
                            ],
                          ),
                        ],
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
  // TAB 3: CROP-WISE PROFIT (फसल मुनाफा विश्लेषण)
  // ==========================================
  Widget _buildCropProfitTab(BuildContext context) {
    return Consumer<FarmKhataProvider>(
      builder: (context, provider, _) {
        final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
        final summary = provider.cropProfitabilitySummary;

        if (summary.isEmpty) {
          return const Center(
            child: Text('कोई फसल डेटा उपलब्ध नहीं है। खर्च व आमदनी जोड़ें।'),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🌾 फसल-वार शुद्ध मुनाफा रिपोर्ट', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('हर फसल पर हुआ कुल खर्च, मंडी बिक्री व शुद्ध बचत का पूरा हिसाब', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...summary.entries.map((entry) {
              final crop = entry.key;
              final income = entry.value['income'] ?? 0.0;
              final expense = entry.value['expense'] ?? 0.0;
              final profit = entry.value['profit'] ?? 0.0;
              final isProfitable = profit >= 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                        Text('🌱 $crop', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isProfitable ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isProfitable ? 'मुनाफा: +${currencyFmt.format(profit)}' : 'घाटा: -${currencyFmt.format(profit.abs())}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: isProfitable ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('कुल बिक्री (आमदनी)', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(currencyFmt.format(income), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('कुल खेती खर्च', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(currencyFmt.format(expense), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Profit Margin Progress Bar
                    if (income > 0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('मुनाफा मार्जिन', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Text('${((profit / income) * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (profit / income).clamp(0.0, 1.0),
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(isProfitable ? Colors.green : Colors.red),
                            ),
                          ),
                        ],
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
  // ADD UDHAR FORM SHEET
  // ==========================================
  void _showUdharFormSheet(BuildContext context) {
    final partyCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    UdharType type = UdharType.dena;
    String category = 'खाद-बीज दुकान';

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
                        const Text('🤝 नया उधारी / बकाया दर्ज करें', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Type Toggle (Lena vs Dena)
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('देना है (Payable)')),
                            selected: type == UdharType.dena,
                            selectedColor: Colors.red.shade100,
                            onSelected: (_) => setModalState(() => type = UdharType.dena),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('लेना है (Receivable)')),
                            selected: type == UdharType.lena,
                            selectedColor: Colors.green.shade100,
                            onSelected: (_) => setModalState(() => type = UdharType.lena),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: partyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'पार्टी / व्यक्ति / दुकान का नाम *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'मोबाइल नंबर (WhatsApp हेतु)',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'रुपये (Amount) *',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        const udharCats = ['खाद-बीज दुकान', 'मजदूर दिहाड़ी', 'व्यापारी/आढ़ती', 'ट्रैक्टर/डीजल पंप', 'KCC/ब्याज', 'अन्य'];
                        final safeCategory = udharCats.contains(category) ? category : udharCats.first;

                        return DropdownButtonFormField<String>(
                          initialValue: safeCategory,
                          decoration: const InputDecoration(
                            labelText: 'श्रेणी (Category)',
                            prefixIcon: Icon(Icons.category_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: udharCats
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setModalState(() => category = v ?? safeCategory),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'विवरण / टिप्पणी (वैकल्पिक)',
                        prefixIcon: Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final party = partyCtrl.text.trim();
                          final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                          if (party.isEmpty || amt <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('कृपया पार्टी का नाम और सही राशि दर्ज करें')),
                            );
                            return;
                          }

                          final entry = UdharEntry(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            partyName: party,
                            phone: phoneCtrl.text.trim(),
                            type: type,
                            amount: amt,
                            date: DateTime.now(),
                            dueDate: DateTime.now().add(const Duration(days: 30)),
                            category: category,
                            notes: notesCtrl.text.trim(),
                          );

                          context.read<FarmKhataProvider>().addUdharEntry(entry);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('उधार खाता सफलतापूर्वक सुरक्षित किया गया')),
                          );
                        },
                        child: const Text('सुरक्षित करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
  // ADD/EDIT INCOME-EXPENSE SHEET
  // ==========================================
  void _showEntryFormSheet(BuildContext context, {FarmKhataEntry? existing}) {
    final cropCtrl = TextEditingController(text: existing?.cropName ?? 'सोयाबीन');
    final amountCtrl = TextEditingController(text: existing != null ? existing.amount.toString() : '');
    final qtyCtrl = TextEditingController(text: existing?.quantity != null ? existing!.quantity.toString() : '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    KhataEntryType type = existing?.type ?? KhataEntryType.expense;
    String category = existing?.category ?? 'खाद व उर्वरक';
    String unit = existing?.unit ?? 'बोरी/कट्टा';

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
                        Text(
                          existing != null ? '✏️ हिसाब संपादित करें' : '➕ नया हिसाब जोड़ें',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('खेती खर्च (Expense)')),
                            selected: type == KhataEntryType.expense,
                            selectedColor: Colors.red.shade100,
                            onSelected: (_) {
                              setModalState(() {
                                type = KhataEntryType.expense;
                                category = 'खाद व उर्वरक';
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('फसल बिक्री (Income)')),
                            selected: type == KhataEntryType.income,
                            selectedColor: Colors.green.shade100,
                            onSelected: (_) {
                              setModalState(() {
                                type = KhataEntryType.income;
                                category = 'मंडी फसल बिक्री';
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cropCtrl,
                      decoration: const InputDecoration(
                        labelText: 'फसल का नाम (उदा: गेहूं, सोयाबीन, सरसों) *',
                        prefixIcon: Icon(Icons.grass_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        final categoryList = type == KhataEntryType.expense
                            ? const [
                                'खाद व उर्वरक',
                                'डीजल व जुताई',
                                'बीज खरीद',
                                'कीटनाशक व दवाई',
                                'मजदूरी व निंदाई',
                                'सिंचाई व बिजली बिल',
                                'मंडी व भाड़ा',
                                'अन्य खर्च',
                              ]
                            : const [
                                'मंडी फसल बिक्री',
                                'सरकारी खरीद (MSP)',
                                'चारा/भूसा बिक्री',
                                'अन्य आमदनी',
                              ];
                        final safeCategory = categoryList.contains(category) ? category : categoryList.first;

                        return DropdownButtonFormField<String>(
                          initialValue: safeCategory,
                          decoration: const InputDecoration(
                            labelText: 'खर्च/आमदनी श्रेणी *',
                            prefixIcon: Icon(Icons.category_outlined),
                            border: OutlineInputBorder(),
                          ),
                          items: categoryList
                              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                              .toList(),
                          onChanged: (v) => setModalState(() => category = v ?? safeCategory),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'कुल राशि (₹) *',
                        prefixIcon: Icon(Icons.currency_rupee),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: qtyCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'मात्रा (वैकल्पिक)',
                              prefixIcon: Icon(Icons.scale_rounded),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              const units = ['बोरी/कट्टा', 'क्विंटल', 'लीटर', 'किलो', 'एकड़/बीघा'];
                              final safeUnit = units.contains(unit) ? unit : units.first;

                              return DropdownButtonFormField<String>(
                                initialValue: safeUnit,
                                decoration: const InputDecoration(
                                  labelText: 'इकाई (Unit)',
                                  border: OutlineInputBorder(),
                                ),
                                items: units
                                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                    .toList(),
                                onChanged: (v) => setModalState(() => unit = v ?? safeUnit),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'टिप्पणी / विवरण (वैकल्पिक)',
                        prefixIcon: Icon(Icons.notes_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final crop = cropCtrl.text.trim();
                          final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                          final qty = double.tryParse(qtyCtrl.text.trim());

                          if (crop.isEmpty || amt <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('कृपया फसल का नाम और सही राशि दर्ज करें')),
                            );
                            return;
                          }

                          final entry = FarmKhataEntry(
                            id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            cropName: crop,
                            type: type,
                            category: category,
                            amount: amt,
                            quantity: qty,
                            unit: qty != null ? unit : null,
                            date: existing?.date ?? DateTime.now(),
                            notes: notesCtrl.text.trim(),
                          );

                          context.read<FarmKhataProvider>().addKhataEntry(entry);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(existing != null ? 'हिसाब अपडेट किया गया' : 'हिसाब सफलतापूर्वक सुरक्षित किया गया')),
                          );
                        },
                        child: const Text('सुरक्षित करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _confirmDelete(BuildContext context, FarmKhataProvider provider, FarmKhataEntry item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('हिसाब हटाएं?'),
        content: Text('क्या आप ${item.cropName} (${item.category}) का ₹${item.amount.toInt()} का हिसाब हटाना चाहते हैं?'),
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
      provider.deleteKhataEntry(item.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('हिसाब हटा दिया गया')),
        );
      }
    }
  }

  void _shareWhatsApp(BuildContext context, String text, {String phone = ''}) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uriStr = cleanPhone.isNotEmpty
        ? 'whatsapp://send?phone=91$cleanPhone&text=${Uri.encodeComponent(text)}'
        : 'whatsapp://send?text=${Uri.encodeComponent(text)}';
    final uri = Uri.parse(uriStr);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        final webUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp खोलने में असमर्थ। पर्ची कॉपी की गई।')),
        );
      }
    }
  }

  void _handleExportBackup(BuildContext context) {
    final provider = context.read<FarmKhataProvider>();
    final jsonStr = provider.exportBackupJson();
    final dateStr = DateFormat('dd-MM-yyyy').format(DateTime.now());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_upload_outlined, color: Colors.green),
            SizedBox(width: 8),
            Text('बहीखाता बैकअप तैयार है', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('कुल खर्च/आय एंट्रीज: ${provider.allEntries.length}'),
            Text('उधारी खाते: ${provider.udharEntries.length}'),
            Text('पशुधन रिकॉर्ड्स: ${provider.animals.length}'),
            Text('डेयरी दूध रिकॉर्ड्स: ${provider.dairyRecords.length}'),
            const SizedBox(height: 12),
            const Text(
              'इस बैकअप को WhatsApp पर अपने नंबर या सुरक्षित चैट में भेजकर सहेज लें:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('बंद करें')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              final backupMsg = '💾 *KISAN_MITRA_BACKUP_$dateStr*\n```$jsonStr```';
              _shareWhatsApp(context, backupMsg);
            },
            icon: const Icon(Icons.share, size: 16),
            label: const Text('WhatsApp पर बैकअप भेजें'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20), foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _handleImportBackup(BuildContext context) {
    final textCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_download_outlined, color: Colors.blue),
            SizedBox(width: 8),
            Text('बैकअप रीस्टोर करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'WhatsApp से कॉपी किया गया बैकअप कोड (JSON) यहाँ पेस्ट करें:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: textCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '{"backupVersion": "1.0", ...}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('रद्द करें')),
          ElevatedButton(
            onPressed: () async {
              String raw = textCtrl.text.trim();
              if (raw.contains('```')) {
                final parts = raw.split('```');
                if (parts.length >= 2) raw = parts[1].trim();
              }

              final success = await context.read<FarmKhataProvider>().importBackupJson(raw);
              if (ctx.mounted) Navigator.pop(ctx);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? '✅ बैकअप सफलतापूर्वक रीस्टोर हो गया!' : '❌ बैकअप कोड अमान्य है। पुनः प्रयास करें।'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white),
            child: const Text('रीस्टोर करें'),
          ),
        ],
      ),
    );
  }
}

