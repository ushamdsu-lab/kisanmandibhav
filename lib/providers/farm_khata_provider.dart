import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/farm_khata_entry.dart';
import '../models/dairy_record.dart';
import '../models/udhar_entry.dart';
import '../models/livestock_animal.dart';
import '../models/dairy_expense.dart';
import '../services/storage_service.dart';

class FarmKhataProvider extends ChangeNotifier {
  List<FarmKhataEntry> _khataEntries = [];
  List<DairyRecord> _dairyRecords = [];
  List<UdharEntry> _udharEntries = [];
  List<LivestockAnimal> _animals = [];
  List<DairyExpense> _dairyExpenses = [];

  String _selectedCrop = 'all';
  String _selectedPeriod = 'all'; // 'all', 'this_month', 'last_30_days'
  String _searchQuery = '';
  bool _isLoading = false;

  List<FarmKhataEntry> get allEntries => _khataEntries;
  List<DairyRecord> get dairyRecords => _dairyRecords;
  List<UdharEntry> get udharEntries => _udharEntries;
  List<LivestockAnimal> get animals => _animals;
  List<DairyExpense> get dairyExpenses => _dairyExpenses;

  String get selectedCrop => _selectedCrop;
  String get selectedPeriod => _selectedPeriod;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  // List of distinct crop names registered by user + standard defaults
  List<String> get availableCrops {
    final crops = <String>{'सोयाबीन', 'गेहूं', 'चना', 'सरसों', 'लहसुन', 'कपास'};
    for (final e in _khataEntries) {
      if (e.cropName.trim().isNotEmpty) {
        crops.add(e.cropName.trim());
      }
    }
    return crops.toList();
  }

  // Filtered entries by crop, period, and search query
  List<FarmKhataEntry> get filteredEntries {
    final now = DateTime.now();
    return _khataEntries.where((e) {
      if (_selectedCrop != 'all' && e.cropName.toLowerCase() != _selectedCrop.toLowerCase()) {
        return false;
      }
      if (_selectedPeriod == 'this_month') {
        if (e.date.month != now.month || e.date.year != now.year) return false;
      } else if (_selectedPeriod == 'last_30_days') {
        if (now.difference(e.date).inDays > 30) return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = e.cropName.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q) ||
            e.notes.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  // Category-wise expense breakdown (for analytics progress bars)
  Map<String, double> get categoryExpenses {
    final Map<String, double> map = {};
    for (final e in filteredEntries) {
      if (e.type == KhataEntryType.expense) {
        map[e.category] = (map[e.category] ?? 0.0) + e.amount;
      }
    }
    return map;
  }

  // Real-time KPI calculations
  double get totalIncome => filteredEntries
      .where((e) => e.type == KhataEntryType.income)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => filteredEntries
      .where((e) => e.type == KhataEntryType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get netProfit => totalIncome - totalExpense;
  bool get isProfitable => netProfit >= 0;

  // Crop-wise Profitability Breakdown
  Map<String, Map<String, double>> get cropProfitabilitySummary {
    final Map<String, Map<String, double>> summary = {};
    for (final e in _khataEntries) {
      final crop = e.cropName.trim().isEmpty ? 'अन्य' : e.cropName.trim();
      summary.putIfAbsent(crop, () => {'income': 0.0, 'expense': 0.0, 'profit': 0.0});
      if (e.type == KhataEntryType.income) {
        summary[crop]!['income'] = (summary[crop]!['income'] ?? 0.0) + e.amount;
      } else {
        summary[crop]!['expense'] = (summary[crop]!['expense'] ?? 0.0) + e.amount;
      }
    }
    for (final crop in summary.keys) {
      summary[crop]!['profit'] = (summary[crop]!['income'] ?? 0.0) - (summary[crop]!['expense'] ?? 0.0);
    }
    return summary;
  }

  // --- 🤝 Udhar Khata KPIs ---
  double get totalLena => _udharEntries
      .where((u) => !u.isSettled && u.type == UdharType.lena)
      .fold(0.0, (sum, u) => sum + u.amount);

  double get totalDena => _udharEntries
      .where((u) => !u.isSettled && u.type == UdharType.dena)
      .fold(0.0, (sum, u) => sum + u.amount);

  double get netUdharBalance => totalLena - totalDena;

  // --- 🐄 Livestock Herd KPIs ---
  int get totalCattleCount => _animals.length;
  int get milkingCattleCount => _animals.where((a) => a.status == AnimalStatus.milking).length;
  int get pregnantCattleCount => _animals.where((a) => a.status == AnimalStatus.pregnant).length;
  int get dryCattleCount => _animals.where((a) => a.status == AnimalStatus.dry).length;

  double get totalEstimatedDailyMilk =>
      _animals.fold(0.0, (sum, a) => sum + a.dailyMilkLiters);

  // --- 🥛 Dairy Milk KPIs ---
  double get dairyTotalLiters =>
      _dairyRecords.fold(0.0, (sum, r) => sum + r.totalLiters);

  double get dairyTotalIncome =>
      _dairyRecords.fold(0.0, (sum, r) => sum + r.totalIncome);

  double get totalDairyExpense =>
      _dairyExpenses.fold(0.0, (sum, e) => sum + e.amount);

  double get netDairyProfit => dairyTotalIncome - totalDairyExpense;

  double get dairyAverageFat {
    if (_dairyRecords.isEmpty) return 0.0;
    final validRecords = _dairyRecords.where((r) => r.fat > 0).toList();
    if (validRecords.isEmpty) return 0.0;
    final totalFat = validRecords.fold(0.0, (sum, r) => sum + r.fat);
    return totalFat / validRecords.length;
  }

  FarmKhataProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _khataEntries = StorageService.getFarmKhataEntries();
    _dairyRecords = StorageService.getDairyRecords();
    _udharEntries = StorageService.getUdharEntries();
    _animals = StorageService.getLivestockAnimals();
    _dairyExpenses = StorageService.getDairyExpenses();

    // If completely empty on first use, provide realistic starter entries
    if (_khataEntries.isEmpty) {
      _seedStarterEntriesIfEmpty();
    }
    if (_dairyRecords.isEmpty) {
      _seedStarterDairyIfEmpty();
    }
    if (_udharEntries.isEmpty) {
      _seedStarterUdharIfEmpty();
    }
    if (_animals.isEmpty) {
      _seedStarterAnimalsIfEmpty();
    }
    if (_dairyExpenses.isEmpty) {
      _seedStarterDairyExpensesIfEmpty();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _seedStarterEntriesIfEmpty() {
    final now = DateTime.now();
    _khataEntries = [
      FarmKhataEntry(
        id: 'seed_exp_1',
        cropName: 'सोयाबीन',
        type: KhataEntryType.expense,
        category: 'खाद व उर्वरक',
        amount: 2700,
        quantity: 2,
        unit: 'बोरी/कट्टा',
        date: now.subtract(const Duration(days: 8)),
        notes: '2 कट्टे DAP खाद',
      ),
      FarmKhataEntry(
        id: 'seed_exp_2',
        cropName: 'सोयाबीन',
        type: KhataEntryType.expense,
        category: 'डीजल व जुताई',
        amount: 3200,
        quantity: 35,
        unit: 'लीटर',
        date: now.subtract(const Duration(days: 6)),
        notes: 'खेत की जुताई व बुवाई',
      ),
      FarmKhataEntry(
        id: 'seed_inc_1',
        cropName: 'सोयाबीन',
        type: KhataEntryType.income,
        category: 'मंडी फसल बिक्री',
        amount: 34500,
        quantity: 7.5,
        unit: 'क्विंटल',
        date: now.subtract(const Duration(days: 1)),
        notes: 'कोटा मंडी में ₹4,600/क्विंटल भाव पर बिक्री',
      ),
    ];
    for (final e in _khataEntries) {
      StorageService.saveFarmKhataEntry(e);
    }
  }

  void _seedStarterDairyIfEmpty() {
    final now = DateTime.now();
    _dairyRecords = [
      DairyRecord(
        id: 'seed_dairy_1',
        date: now.subtract(const Duration(days: 1)),
        morningLiters: 7.5,
        eveningLiters: 6.0,
        fat: 6.5,
        ratePerLiter: 54,
        notes: 'मुर्रा भैंस दूध',
      ),
      DairyRecord(
        id: 'seed_dairy_2',
        date: now,
        morningLiters: 8.0,
        eveningLiters: 6.5,
        fat: 6.8,
        ratePerLiter: 55,
        notes: 'डेयरी कलेक्शन सेंटर सप्लाई',
      ),
    ];
    for (final r in _dairyRecords) {
      StorageService.saveDairyRecord(r);
    }
  }

  void _seedStarterUdharIfEmpty() {
    final now = DateTime.now();
    _udharEntries = [
      UdharEntry(
        id: 'seed_udhar_1',
        partyName: 'श्री राम खाद-बीज भंडार',
        phone: '9829012345',
        type: UdharType.dena,
        amount: 4200,
        date: now.subtract(const Duration(days: 15)),
        dueDate: now.add(const Duration(days: 20)),
        isSettled: false,
        category: 'खाद-बीज दुकान',
        notes: 'DAP व पोटाश खाद का बकाया',
      ),
      UdharEntry(
        id: 'seed_udhar_2',
        partyName: 'सुरेश आढ़ती (मंडी व्यापारी)',
        phone: '9414056789',
        type: UdharType.lena,
        amount: 12500,
        date: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 10)),
        isSettled: false,
        category: 'व्यापारी/आढ़ती',
        notes: 'लहसुन तुलाई का बाकी भुगतान',
      ),
    ];
    for (final u in _udharEntries) {
      StorageService.saveUdharEntry(u);
    }
  }

  void _seedStarterAnimalsIfEmpty() {
    final now = DateTime.now();
    _animals = [
      LivestockAnimal(
        id: 'seed_animal_1',
        tagOrName: 'गंगा (गाय)',
        animalType: AnimalType.cow,
        breed: 'साहीवाल',
        lactationNumber: 2,
        dailyMilkLiters: 11.5,
        status: AnimalStatus.milking,
        inseminationDate: now.subtract(const Duration(days: 90)),
        notes: 'शांत स्वभाव, सुबह 6L शाम 5.5L',
      ),
      LivestockAnimal(
        id: 'seed_animal_2',
        tagOrName: 'सुल्ताना (भैंस)',
        animalType: AnimalType.buffalo,
        breed: 'मुर्रा नस्ल',
        lactationNumber: 3,
        dailyMilkLiters: 14.0,
        status: AnimalStatus.milking,
        inseminationDate: now.subtract(const Duration(days: 140)),
        notes: 'फैट 7.2%, उत्तम दुधारू',
      ),
      LivestockAnimal(
        id: 'seed_animal_3',
        tagOrName: 'कल्याणी (गाभिन गाय)',
        animalType: AnimalType.cow,
        breed: 'गिर',
        lactationNumber: 1,
        dailyMilkLiters: 0.0,
        status: AnimalStatus.pregnant,
        inseminationDate: now.subtract(const Duration(days: 220)),
        notes: 'प्रसव संभावित लगभग 2 माह में',
      ),
    ];
    for (final a in _animals) {
      StorageService.saveLivestockAnimal(a);
    }
  }

  void _seedStarterDairyExpensesIfEmpty() {
    final now = DateTime.now();
    _dairyExpenses = [
      DairyExpense(
        id: 'seed_dexp_1',
        title: 'सरसों खल 1 बोरी (50kg)',
        category: 'दाना/खल/चोकर',
        amount: 1650,
        date: now.subtract(const Duration(days: 7)),
        notes: 'पशु आहार हेतु',
      ),
      DairyExpense(
        id: 'seed_dexp_2',
        title: 'गेहूं का सूखा भूसा (2 क्विंटल)',
        category: 'चारा/भूसा',
        amount: 1400,
        date: now.subtract(const Duration(days: 12)),
        notes: 'सर्दियों का चारा संग्रह',
      ),
    ];
    for (final e in _dairyExpenses) {
      StorageService.saveDairyExpense(e);
    }
  }

  void setSelectedCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  // --- Farm Khata Actions ---
  Future<void> addKhataEntry(FarmKhataEntry entry) async {
    await StorageService.saveFarmKhataEntry(entry);
    _khataEntries.removeWhere((e) => e.id == entry.id);
    _khataEntries.insert(0, entry);
    notifyListeners();
  }

  Future<void> deleteKhataEntry(String id) async {
    await StorageService.deleteFarmKhataEntry(id);
    _khataEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> clearCropKhata(String cropName) async {
    await StorageService.clearCropKhata(cropName);
    _khataEntries.removeWhere((e) => e.cropName.toLowerCase() == cropName.toLowerCase());
    notifyListeners();
  }

  // --- Udhar Actions ---
  Future<void> addUdharEntry(UdharEntry entry) async {
    await StorageService.saveUdharEntry(entry);
    _udharEntries.removeWhere((u) => u.id == entry.id);
    _udharEntries.insert(0, entry);
    notifyListeners();
  }

  Future<void> deleteUdharEntry(String id) async {
    await StorageService.deleteUdharEntry(id);
    _udharEntries.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  Future<void> toggleUdharSettled(String id) async {
    await StorageService.toggleUdharSettled(id);
    final index = _udharEntries.indexWhere((u) => u.id == id);
    if (index != -1) {
      final old = _udharEntries[index];
      _udharEntries[index] = old.copyWith(isSettled: !old.isSettled);
      notifyListeners();
    }
  }

  String generateUdharWhatsAppReminder(UdharEntry entry) {
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dStr = DateFormat('dd MMM yyyy').format(entry.date);
    final dueStr = entry.dueDate != null ? DateFormat('dd MMM yyyy').format(entry.dueDate!) : 'शीघ्र';

    final buffer = StringBuffer();
    buffer.writeln('🙏 *नमस्कार ${entry.partyName} जी,*');
    if (entry.type == UdharType.lena) {
      buffer.writeln('यह किसान मित्र बहीखाता से शेष भुगतान का सौम्य स्मरण पत्र है:');
      buffer.writeln('💰 *बकाया राशि (लेना):* ${currencyFmt.format(entry.amount)}');
      buffer.writeln('📅 लेन-देन तारीख: $dStr');
      buffer.writeln('⏳ भुगतान अंतिम तिथि: $dueStr');
      if (entry.notes.isNotEmpty) buffer.writeln('📝 विवरण: ${entry.notes}');
      buffer.writeln('\nकृपया समयानुसार भुगतान करने की कृपा करें। धन्यवाद!');
    } else {
      buffer.writeln('यह किसान मित्र बहीखाता हिसाब पर्ची है:');
      buffer.writeln('💰 *देय राशि:* ${currencyFmt.format(entry.amount)}');
      buffer.writeln('📅 तारीख: $dStr');
      if (entry.notes.isNotEmpty) buffer.writeln('📝 विवरण: ${entry.notes}');
      buffer.writeln('\nहिसाब दर्ज कर लिया गया है।');
    }
    buffer.writeln('\n🌾 _Kisan Mitra कृषि ऐप द्वारा_');
    return buffer.toString();
  }

  // --- Livestock Animal Actions ---
  Future<void> addLivestockAnimal(LivestockAnimal animal) async {
    await StorageService.saveLivestockAnimal(animal);
    _animals.removeWhere((a) => a.id == animal.id);
    _animals.insert(0, animal);
    notifyListeners();
  }

  Future<void> deleteLivestockAnimal(String id) async {
    await StorageService.deleteLivestockAnimal(id);
    _animals.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // --- Dairy Record Actions ---
  Future<void> addDairyRecord(DairyRecord record) async {
    await StorageService.saveDairyRecord(record);
    _dairyRecords.removeWhere((r) => r.id == record.id);
    _dairyRecords.insert(0, record);
    notifyListeners();
  }

  Future<void> deleteDairyRecord(String id) async {
    await StorageService.deleteDairyRecord(id);
    _dairyRecords.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  // --- Dairy Expense Actions ---
  Future<void> addDairyExpense(DairyExpense expense) async {
    await StorageService.saveDairyExpense(expense);
    _dairyExpenses.removeWhere((e) => e.id == expense.id);
    _dairyExpenses.insert(0, expense);
    notifyListeners();
  }

  Future<void> deleteDairyExpense(String id) async {
    await StorageService.deleteDairyExpense(id);
    _dairyExpenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // Generates clean WhatsApp formatted text receipt
  String generateWhatsAppReceiptText() {
    final currencyFmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final cropTitle = _selectedCrop == 'all' ? 'सभी फसलें' : _selectedCrop;
    final nowStr = DateFormat('dd MMM yyyy').format(DateTime.now());

    final buffer = StringBuffer();
    buffer.writeln('🌾 *किसान बहीखाता हिसाब पर्ची* 🌾');
    buffer.writeln('📅 तारीख: $nowStr');
    buffer.writeln('🌱 फसल: *$cropTitle*');
    buffer.writeln('--------------------------------');
    buffer.writeln('💰 *कुल आमदनी (बिक्री):* ${currencyFmt.format(totalIncome)}');
    buffer.writeln('📉 *कुल खेती खर्च:* ${currencyFmt.format(totalExpense)}');
    buffer.writeln(isProfitable
        ? '✅ *शुद्ध बचत/मुनाफा:* ${currencyFmt.format(netProfit)}'
        : '⚠️ *शुद्ध घाटा:* ${currencyFmt.format(netProfit.abs())}');
    buffer.writeln('--------------------------------');
    buffer.writeln('*हाल के खर्चे व आमदनी:*');

    final recent = filteredEntries.take(8).toList();
    if (recent.isEmpty) {
      buffer.writeln('कोई एंट्री नहीं मिली।');
    } else {
      for (final e in recent) {
        final icon = e.type == KhataEntryType.income ? '➕' : '➖';
        final dStr = DateFormat('dd/MM').format(e.date);
        buffer.writeln('$icon [$dStr] ${e.category} (${e.cropName}): ${currencyFmt.format(e.amount)}');
      }
    }

    buffer.writeln('\n📱 _Kisan Mitra ऐप द्वारा जनरेट किया गया_');
    return buffer.toString();
  }

  // --- 💾 Full Backup & Restore ---
  String exportBackupJson() => StorageService.exportAllKhataBackupJson();

  Future<bool> importBackupJson(String rawJson) async {
    final success = await StorageService.importKhataBackupJson(rawJson);
    if (success) {
      await loadData();
    }
    return success;
  }
}

