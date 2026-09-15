import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../data/crop_disease_database.dart';
import '../../providers/locale_provider.dart';
import '../../services/crop_doctor_service.dart';
import '../../services/tts_service.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/language_toggle_button.dart';

class CropDoctorScreen extends StatefulWidget {
  final String? initialCropId;

  const CropDoctorScreen({super.key, this.initialCropId});

  @override
  State<CropDoctorScreen> createState() => _CropDoctorScreenState();
}

class _CropDoctorScreenState extends State<CropDoctorScreen>
    with SingleTickerProviderStateMixin {
  int _selectedModeIndex = 0; // 0: Photo Scan, 1: Symptom Checklist, 2: All Diseases Directory
  String _selectedCropId = 'wheat';
  String _selectedCategory = 'all';
  String _directorySearchQuery = '';

  // Photo State
  XFile? _selectedImage;
  Uint8List? _imageBytes;

  // Symptom State
  final Set<String> _selectedSymptoms = {};

  // Diagnosis State
  CropDiagnosisResult? _diagnosisResult;
  bool _isAnalyzing = false;

  late AnimationController _scanAnimController;

  static const List<Map<String, String>> cropCategories = [
    {'id': 'all', 'name': 'सभी फसलें'},
    {'id': 'grains', 'name': '🌾 अनाज'},
    {'id': 'pulses', 'name': '🫘 दलहन/तिलहन'},
    {'id': 'vegetables', 'name': '🍅 सब्जियां'},
    {'id': 'spices', 'name': '🌿 मसाले'},
    {'id': 'fruits', 'name': '🍎 फल/बागवानी'},
    {'id': 'commercial', 'name': '⚪ नकदी फसलें'},
  ];

  static const List<Map<String, String>> supportedCrops = [
    // 🌾 अनाज व मोटा अनाज (Grains & Millets)
    {'id': 'wheat', 'name': 'गेहूं', 'category': 'grains', 'icon': '🌾'},
    {'id': 'paddy', 'name': 'धान/चावल', 'category': 'grains', 'icon': '🌾'},
    {'id': 'maize', 'name': 'मक्का', 'category': 'grains', 'icon': '🌽'},
    {'id': 'bajra', 'name': 'बाजरा', 'category': 'grains', 'icon': '🌾'},

    // 🫘 दलहन व तिलहन (Pulses & Oilseeds)
    {'id': 'mustard', 'name': 'सरसों/राई', 'category': 'pulses', 'icon': '🌱'},
    {'id': 'soybean', 'name': 'सोयाबीन', 'category': 'pulses', 'icon': '🫘'},
    {'id': 'gram', 'name': 'चना', 'category': 'pulses', 'icon': '🌱'},
    {'id': 'moong', 'name': 'मूंग', 'category': 'pulses', 'icon': '🫘'},
    {'id': 'urad', 'name': 'उड़द', 'category': 'pulses', 'icon': '🫘'},
    {'id': 'groundnut', 'name': 'मूंगफली', 'category': 'pulses', 'icon': '🥜'},
    {'id': 'castor', 'name': 'अरंडी', 'category': 'pulses', 'icon': '🫘'},
    {'id': 'sunflower', 'name': 'सूरजमुखी', 'category': 'pulses', 'icon': '🌻'},
    {'id': 'sesame', 'name': 'तिल', 'category': 'pulses', 'icon': '⚪'},

    // 🥬 सब्जियां (Vegetables)
    {'id': 'chaulai', 'name': 'चौलाई/चंवला/लोबिया', 'category': 'vegetables', 'icon': '🥬'},
    {'id': 'tomato', 'name': 'टमाटर', 'category': 'vegetables', 'icon': '🍅'},
    {'id': 'potato', 'name': 'आलू', 'category': 'vegetables', 'icon': '🥔'},
    {'id': 'onion', 'name': 'प्याज', 'category': 'vegetables', 'icon': '🧅'},
    {'id': 'garlic', 'name': 'लहसुन', 'category': 'vegetables', 'icon': '🧄'},
    {'id': 'chilli', 'name': 'मिर्च', 'category': 'vegetables', 'icon': '🌶️'},
    {'id': 'brinjal', 'name': 'बैंगन', 'category': 'vegetables', 'icon': '🍆'},
    {'id': 'okra', 'name': 'भिंडी', 'category': 'vegetables', 'icon': '🌿'},
    {'id': 'cauliflower', 'name': 'गोभी', 'category': 'vegetables', 'icon': '🥦'},
    {'id': 'pea', 'name': 'मटर', 'category': 'vegetables', 'icon': '🫛'},

    // 🌿 मसाले व औषधीय फसलें (Spices)
    {'id': 'jeera', 'name': 'जीरा', 'category': 'spices', 'icon': '🌿'},
    {'id': 'coriander', 'name': 'धनिया', 'category': 'spices', 'icon': '🌿'},
    {'id': 'fennel', 'name': 'सौंफ', 'category': 'spices', 'icon': '🌿'},
    {'id': 'fenugreek', 'name': 'मेथी', 'category': 'spices', 'icon': '🌿'},
    {'id': 'ginger', 'name': 'अदरक', 'category': 'spices', 'icon': '🫚'},
    {'id': 'turmeric', 'name': 'हल्दी', 'category': 'spices', 'icon': '🟡'},

    // ⚪ नकदी व वाणिज्यिक फसलें (Commercial Crops)
    {'id': 'cotton', 'name': 'कपास/नरमा', 'category': 'commercial', 'icon': '⚪'},
    {'id': 'sugarcane', 'name': 'गन्ना', 'category': 'commercial', 'icon': '🎋'},
    {'id': 'guar', 'name': 'ग्वार', 'category': 'commercial', 'icon': '🌱'},
    {'id': 'isabgol', 'name': 'इसबगोल', 'category': 'commercial', 'icon': '🌾'},

    // 🍎 फल व बागवानी (Fruits & Horticulture)
    {'id': 'pomegranate', 'name': 'अनार', 'category': 'fruits', 'icon': '🍎'},
    {'id': 'citrus', 'name': 'संतरा/नींबू', 'category': 'fruits', 'icon': '🍋'},
    {'id': 'mango', 'name': 'आम', 'category': 'fruits', 'icon': '🥭'},
    {'id': 'guava', 'name': 'अमरूद', 'category': 'fruits', 'icon': '🍈'},
    {'id': 'papaya', 'name': 'पपीता', 'category': 'fruits', 'icon': '🍈'},
    {'id': 'watermelon', 'name': 'तरबूज/खरबूजा', 'category': 'fruits', 'icon': '🍉'},
    {'id': 'banana', 'name': 'केला', 'category': 'fruits', 'icon': '🍌'},
    {'id': 'apple', 'name': 'सेब', 'category': 'fruits', 'icon': '🍎'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCropId != null && widget.initialCropId!.isNotEmpty) {
      _selectedCropId = widget.initialCropId!;
    }
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    super.dispose();
  }

  void _resetDiagnosis() {
    setState(() {
      _selectedImage = null;
      _imageBytes = null;
      _diagnosisResult = null;
      _selectedSymptoms.clear();
      _isAnalyzing = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final img = await picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (img != null) {
        final bytes = await img.readAsBytes();
        setState(() {
          _selectedImage = img;
          _imageBytes = bytes;
          _isAnalyzing = true;
          _diagnosisResult = null;
        });

        final result = await CropDoctorService.diagnoseImageBytes(
          imageBytes: bytes,
          cropId: _selectedCropId,
          imagePath: img.path,
        );

        if (mounted) {
          setState(() {
            _diagnosisResult = result;
            _isAnalyzing = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Image picking error: $e');
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ फोटो चुनने में समस्या आई। कृपया पुनः प्रयास करें।'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _diagnoseBySymptoms() async {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('कृपया कम से कम 1 लक्षण चुनें!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _diagnosisResult = null;
    });

    final result = await CropDoctorService.diagnoseSymptoms(
      cropId: _selectedCropId,
      selectedSymptoms: _selectedSymptoms.toList(),
    );

    if (mounted) {
      setState(() {
        _diagnosisResult = result;
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final isHi = localeProv.isHindi;

    final filteredCrops = _selectedCategory == 'all'
        ? supportedCrops
        : supportedCrops.where((c) => c['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isHi ? '📸 AI फसल डॉक्टर (रोग व दवा)' : '📸 AI Crop Doctor (Prescription)',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white),
        ),
        actions: [
          const LanguageToggleButton(),
          if (_diagnosisResult != null || _selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: isHi ? 'नई जांच करें' : 'New Scan',
              onPressed: _resetDiagnosis,
            ),
        ],
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Selector: 3 Modes
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeTab(0, Icons.camera_alt_rounded, isHi ? 'फोटो स्कैन' : 'Photo Scan'),
                  ),
                  Expanded(
                    child: _buildModeTab(1, Icons.checklist_rounded, isHi ? 'लक्षण जांच' : 'Symptom Check'),
                  ),
                  Expanded(
                    child: _buildModeTab(2, Icons.menu_book_rounded, isHi ? 'रोग डायरेक्टरी' : 'Disease Guide'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Step 1: Crop Category & Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1️⃣ फसल चुनें:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
                ),
                Text(
                  'कुल 41+ फसलें',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Category Chips
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: cropCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final cat = cropCategories[index];
                  final isCatSelected = _selectedCategory == cat['id'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat['id']!;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCatSelected ? const Color(0xFF1B5E20) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat['name']!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCatSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isCatSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Crop Choice Chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: filteredCrops.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final crop = filteredCrops[index];
                  final isSelected = _selectedCropId == crop['id'];

                  return ChoiceChip(
                    avatar: Text(crop['icon']!, style: const TextStyle(fontSize: 14)),
                    label: Text(crop['name']!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    selectedColor: const Color(0xFF1B5E20),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCropId = crop['id']!;
                          _diagnosisResult = null;
                          _selectedSymptoms.clear();
                        });
                      }
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Content Based on Selected Mode
            if (_selectedModeIndex == 0) ...[
              _buildPhotoScanSection(context),
            ] else if (_selectedModeIndex == 1) ...[
              _buildSymptomChecklistSection(context),
            ] else ...[
              _buildDiseaseDirectorySection(context),
            ],

            // Scanning Progress Loading Indicator
            if (_isAnalyzing) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF1B5E20)),
                    const SizedBox(height: 12),
                    Text(
                      _selectedModeIndex == 0
                          ? '🧠 AI पत्ती की फोटो का विश्लेषण कर रहा है...'
                          : '🔍 लक्षणों के आधार पर बीमारी खोजी जा रही है...',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            // Step 3: Diagnosis Result Report Card
            if (_diagnosisResult != null && !_isAnalyzing) ...[
              const SizedBox(height: 24),
              _buildDiagnosisReport(context, _diagnosisResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModeTab(int index, IconData icon, String label) {
    final isSel = _selectedModeIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedModeIndex = index;
          _resetDiagnosis();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFF1B5E20) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSel ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSel ? Colors.white : Colors.black87),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isSel ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoScanSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2️⃣ पत्ती/पौधे की फोटो लें:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        const SizedBox(height: 10),

        if (_imageBytes != null) ...[
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1B5E20), width: 2),
                  image: DecorationImage(
                    image: MemoryImage(_imageBytes!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (_isAnalyzing)
                AnimatedBuilder(
                  animation: _scanAnimController,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanAnimController.value * 210,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.8),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              Positioned(
                top: 10,
                right: 10,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('फोटो बदलें', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1B5E20).withValues(alpha: 0.05),
                  Colors.green.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.25), width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.document_scanner_rounded, size: 40, color: Color(0xFF1B5E20)),
                ),
                const SizedBox(height: 14),
                const Text(
                  'प्रभावित पत्ती की साफ़ फोटो लें',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'फोटो अपलोड होते ही AI बीमारी व सही दवाई की पहचान करेगा',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B5E20),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.camera_alt_rounded, size: 20),
                        label: const Text('कैमरा खोलें', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        onPressed: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1B5E20),
                          side: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.photo_library_rounded, size: 20),
                        label: const Text('गैलरी से चुनें', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        onPressed: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSymptomChecklistSection(BuildContext context) {
    final symptoms = CropDiseaseDatabase.getSymptomTagsForCrop(_selectedCropId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2️⃣ पौधे में दिख रहे लक्षण चुनें:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        const SizedBox(height: 4),
        const Text(
          'आप अपनी फसल में क्या खराबी देख रहे हैं? नीचे से टिक करें:',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: symptoms.map((sym) {
            final isSelected = _selectedSymptoms.contains(sym);
            return FilterChip(
              label: Text(sym, style: const TextStyle(fontSize: 12.5)),
              selected: isSelected,
              selectedColor: const Color(0xFF1B5E20),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
              checkmarkColor: Colors.white,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSymptoms.add(sym);
                  } else {
                    _selectedSymptoms.remove(sym);
                  }
                  _diagnosisResult = null;
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedSymptoms.isNotEmpty ? const Color(0xFF1B5E20) : Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: _selectedSymptoms.isNotEmpty ? 3 : 0,
            ),
            icon: const Icon(Icons.search_rounded, size: 22),
            label: Text(
              _selectedSymptoms.isNotEmpty
                  ? 'रोग पहचानें व इलाज देखें (${_selectedSymptoms.length} चुने)'
                  : 'कम से कम 1 लक्षण चुनें',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            onPressed: _selectedSymptoms.isNotEmpty ? _diagnoseBySymptoms : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseDirectorySection(BuildContext context) {
    final allDiseases = CropDiseaseDatabase.getDiseasesByCrop(_selectedCropId);
    final query = _directorySearchQuery.trim().toLowerCase();
    final displayedDiseases = query.isEmpty
        ? allDiseases
        : allDiseases.where((d) =>
            d.diseaseNameHindi.toLowerCase().contains(query) ||
            d.diseaseNameEnglish.toLowerCase().contains(query) ||
            d.chemicalMedicine.toLowerCase().contains(query) ||
            d.symptoms.any((s) => s.toLowerCase().contains(query))).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📖 फसल के सभी रोग व दवाई डायरेक्टरी:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 15),
            ),
            Text(
              '${allDiseases.length} रोग दर्ज',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Search in directory
        TextField(
          onChanged: (val) => setState(() => _directorySearchQuery = val),
          decoration: InputDecoration(
            hintText: 'रोग या दवाई का नाम खोजें...',
            prefixIcon: const Icon(Icons.search_rounded),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),

        if (displayedDiseases.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: const Text('कोई रोग नहीं मिला', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ] else ...[
          ...displayedDiseases.map((disease) => _buildDiseaseCard(context, disease)),
        ],
      ],
    );
  }

  Widget _buildDiseaseCard(BuildContext context, CropDisease d) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(d.icon, style: const TextStyle(fontSize: 20)),
        ),
        title: Text(
          d.diseaseNameHindi,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        subtitle: Text(
          '${d.diseaseNameEnglish} • ${d.severity}',
          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          // Symptoms
          const Text('🔍 मुख्य लक्षण:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange)),
          const SizedBox(height: 4),
          ...d.symptoms.map((s) => Text('• $s', style: const TextStyle(fontSize: 12))),
          const SizedBox(height: 10),

          // Chemical
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🧪 अनुमोदित दवाई व स्प्रे:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF1B5E20))),
                const SizedBox(height: 2),
                Text(d.chemicalMedicine, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 2),
                Text('💧 मात्रा: ${d.sprayDosage}', style: const TextStyle(fontSize: 11.5, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Organic
          Text('🍃 जैविक उपाय: ${d.organicRemedy}', style: const TextStyle(fontSize: 12, color: Colors.teal)),
          const SizedBox(height: 10),

          // Share Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF25D366),
                side: const BorderSide(color: Color(0xFF25D366)),
              ),
              icon: const Icon(Icons.share_rounded, size: 16),
              label: const Text('उपचार पर्ची शेयर करें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => CropDoctorService.sharePrescriptionSlip(d),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisReport(BuildContext context, CropDiagnosisResult result) {
    final d = result.disease;
    final alternatives = result.alternativeDiseases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF1B5E20), size: 22),
                const SizedBox(width: 6),
                Text(
                  'जांच रिपोर्ट (Diagnosis Result):',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
            TextButton.icon(
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('नई जांच', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: _resetDiagnosis,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Disease Main Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${d.cropHindi} (${d.cropName})',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'प्राथमिक निदान • ${result.confidence.toInt()}% मैच',
                      style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '🚨 ${d.diseaseNameHindi}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 19),
              ),
              const SizedBox(height: 2),
              Text(
                d.diseaseNameEnglish,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.biotech_rounded, color: Colors.amberAccent, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'कारक: ${d.pathogen}',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Symptoms Card
        GlassCard(
          padding: const EdgeInsets.all(14),
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.visibility_rounded, color: Colors.orange, size: 18),
                  SizedBox(width: 6),
                  Text('प्रमुख लक्षण (Symptoms)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              ...d.symptoms.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Expanded(child: Text(s, style: const TextStyle(fontSize: 12.5))),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Chemical Prescription & Dosage Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.4), width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.medication_liquid_rounded, color: Color(0xFF1B5E20), size: 20),
                  SizedBox(width: 6),
                  Text(
                    '🧪 रासायनिक दवाई व स्प्रे (Chemical Treatment)',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1B5E20)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                d.chemicalMedicine,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'मात्रा: ${d.sprayDosage}',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Organic / Desi Remedy Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.eco_rounded, color: Colors.teal, size: 18),
                  SizedBox(width: 6),
                  Text('🍃 जैविक व देसी उपचार (Organic Solution)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.teal)),
                ],
              ),
              const SizedBox(height: 6),
              Text(d.organicRemedy, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Action Buttons: WhatsApp Share & Audio Readout
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('पर्ची WhatsApp करें', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                onPressed: () => CropDoctorService.sharePrescriptionSlip(d),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              icon: const Icon(Icons.volume_up_rounded, size: 18, color: Colors.amberAccent),
              label: const Text('बोलकर सुनें', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              onPressed: () {
                final text = '${d.cropHindi} में ${d.diseaseNameHindi} के लक्षण हैं। इसके उपचार के लिए ${d.chemicalMedicine} का ${d.sprayDosage} के हिसाब से छिड़काव करें।';
                TtsService().speak(text);
              },
            ),
          ],
        ),

        // Alternative Diseases Section (If more diseases exist for this crop)
        if (alternatives.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: Colors.teal, size: 20),
              const SizedBox(width: 6),
              Text(
                '🌾 इसी फसल के अन्य संभावित रोग (${alternatives.length}):',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'यदि उपरोक्त लक्षण आपके खेत से मेल नहीं खाते, तो नीचे दिए अन्य रोग देखें:',
            style: TextStyle(fontSize: 11.5, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          ...alternatives.map((alt) => _buildDiseaseCard(context, alt)),
        ],
      ],
    );
  }
}
