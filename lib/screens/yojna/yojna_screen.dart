import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/app_images.dart';
import '../../models/scheme.dart';
import '../../models/helpline.dart';
import '../../providers/yojna_provider.dart';
import '../../widgets/common/loading_shimmer.dart';
import '../../widgets/common/error_widget.dart';

class YojnaScreen extends StatefulWidget {
  const YojnaScreen({super.key});

  @override
  State<YojnaScreen> createState() => _YojnaScreenState();
}

class _YojnaScreenState extends State<YojnaScreen> {
  final _searchController = TextEditingController();

  static const List<Map<String, String>> _stateOptions = [
    {'name': 'all', 'label': 'सभी राज्य (All India)'},
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<YojnaProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<YojnaProvider>(
        builder: (context, provider, _) {
          return CustomScrollView(
            slivers: [
              // --- App Bar ---
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    '📋 सरकारी योजनाएं',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.yojnaGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 10,
                          bottom: 0,
                          child: SizedBox(
                            height: 100,
                            child: AppImages.mahilaKisan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.verified_user_rounded),
                    onPressed: () => _showEligibilityCheckerModal(context),
                    tooltip: 'पात्रता जांचें',
                  ),
                ],
              ),

              // --- Eligibility Checker Banner with Mahila Kisan Artwork ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  child: InkWell(
                    onTap: () => _showEligibilityCheckerModal(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amberAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '100% नि:शुल्क सरकारी सहायता',
                                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'अपनी पात्रता जांचें (Eligibility Calculator)',
                                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'पीएम-किसान, कृषि बीमा, तारबंदी व सोलर पंप पात्रता',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 75,
                            width: 70,
                            child: AppImages.mahilaKisan,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // --- 1. Government Type Switcher (केंद्र vs राज्य vs सभी) ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        _buildGovtTab(
                          context: context,
                          label: '🏛️ केंद्र सरकार',
                          count: provider.centralCount,
                          isSelected: provider.selectedGovtType == 'central',
                          onTap: () => provider.selectGovtType('central'),
                          activeColor: AppColors.yojnaAccent,
                        ),
                        _buildGovtTab(
                          context: context,
                          label: '🏰 राज्य सरकार',
                          count: provider.stateCount,
                          isSelected: provider.selectedGovtType == 'state',
                          onTap: () => provider.selectGovtType('state'),
                          activeColor: AppColors.primary,
                        ),
                        _buildGovtTab(
                          context: context,
                          label: '🌐 सभी योजनाएं',
                          count: provider.totalCount,
                          isSelected: provider.selectedGovtType == 'all',
                          onTap: () => provider.selectGovtType('all'),
                          activeColor: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 2. State Selector Chips (Horizontal Scroll) ---
              if (provider.selectedGovtType == 'state' || provider.selectedGovtType == 'all')
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 16, 4),
                        child: Text(
                          '📍 राज्य अनुसार फ़िल्टर करें (Filter by State):',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: _stateOptions.map((st) {
                            final isSelected = provider.selectedStateFilter == st['name'];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: ChoiceChip(
                                label: Text(st['label']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                selected: isSelected,
                                onSelected: (_) => provider.selectStateFilter(st['name']!),
                                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                                checkmarkColor: AppColors.primary,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

              // --- 3. Search Bar ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (q) => provider.searchSchemes(q),
                    decoration: InputDecoration(
                      hintText: provider.selectedGovtType == 'central'
                          ? '🔍 केंद्र की योजना खोजें (उदा: PM-Kisan, KCC, कुसुम)...'
                          : '🔍 योजना खोजें (उदा: तारबंदी, किसान मित्र, भावांतर, सब्सिडी)...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                provider.searchSchemes('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // --- 4. Helpline Strip ---
              if (provider.helplines.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildHelplineStrip(context, provider.helplines),
                ),

              // --- Results Count & Filter Clear ---
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                  child: Row(
                    children: [
                      Text(
                        'कुल ${provider.schemes.length} योजनाएं उपलब्ध',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      if (provider.searchQuery.isNotEmpty || provider.selectedGovtType != 'all' || provider.selectedStateFilter != 'all')
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            provider.clearFilters();
                          },
                          child: const Text(
                            'फ़िल्टर हटाएं ✕',
                            style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // --- Schemes List ---
              if (provider.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: LoadingShimmer(itemCount: 4, height: 140),
                  ),
                )
              else if (provider.error.isNotEmpty)
                SliverFillRemaining(
                  child: AppErrorWidget(
                    message: provider.error,
                    onRetry: () => provider.loadData(),
                  ),
                )
              else if (provider.schemes.isEmpty)
                const SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.account_balance_outlined,
                    title: 'कोई योजना नहीं मिली',
                    subtitle: 'कृपया दूसरा राज्य या ' 'सभी राज्य' ' चुनें',
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final scheme = provider.schemes[index];
                      return _buildSchemeCard(context, scheme, provider, index);
                    },
                    childCount: provider.schemes.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGovtTab({
    required BuildContext context,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                '($count योजनाएं)',
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.white.withValues(alpha: 0.9) : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemeCard(BuildContext context, Scheme scheme, YojnaProvider provider, int index) {
    final isBookmarked = provider.isBookmarked(scheme.id);
    final isCentral = scheme.governmentType == 'central';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => context.push('/yojna/detail/${scheme.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Badges + Bookmark
              Row(
                children: [
                  // Government Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCentral
                          ? AppColors.yojnaAccent.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCentral
                            ? AppColors.yojnaAccent.withValues(alpha: 0.4)
                            : AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      scheme.badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isCentral ? AppColors.yojnaAccent : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      scheme.category,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isBookmarked ? AppColors.secondary : AppColors.textSecondary,
                    ),
                    onPressed: () => provider.toggleBookmark(scheme.id),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Scheme Title & Subtitle
              Text(
                scheme.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                scheme.nameEn,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 8),

              // Short Description
              Text(
                scheme.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Benefits Preview
              if (scheme.benefits.isNotEmpty)
                Column(
                  children: scheme.benefits.take(2).map((benefit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              benefit,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const Divider(height: 16),

              // Bottom Row: How to Apply & View More Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'आवेदन: ${scheme.howToApply}',
                      style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Row(
                    children: [
                      Text(
                        'पूरी जानकारी',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: ((index * 30).clamp(0, 300)).ms, duration: 250.ms);
  }

  Widget _buildHelplineStrip(BuildContext context, List<Helpline> helplines) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 18),
              SizedBox(width: 6),
              Text(
                '📞 किसान हेल्पलाइन (टोल-फ्री तुरंत कॉल करें):',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: helplines.take(2).map((h) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => launchUrl(Uri.parse('tel:${h.number.replaceAll('-', '')}')),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            h.name,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            h.number,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showEligibilityCheckerModal(BuildContext context) {
    bool hasLand = true;
    bool paysTax = false;
    bool isGovtEmp = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isPmKisanEligible = hasLand && !paysTax && !isGovtEmp;
            final isPmfbyEligible = hasLand;
            final isKusumEligible = hasLand;
            final isKccEligible = hasLand;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 40),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Center(
                              child: Container(
                                width: 48,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'बंद करें ✕',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 24),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🏛️ सरकारी योजना पात्रता कैलकुलेटर',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '3 आसान सवालों के जवाब दें और अपनी पात्र सरकारी योजनाएं तुरंत जानें',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 20),

                    // Q1: Land Ownership
                    const Text('1. क्या आपके नाम से स्वयं की कृषि भूमि (खेती की ज़मीन) है?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('हाँ, ज़मीन है'),
                            selected: hasLand,
                            onSelected: (_) => setModalState(() => hasLand = true),
                            selectedColor: AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('नहीं / भूमिहीन'),
                            selected: !hasLand,
                            onSelected: (_) => setModalState(() => hasLand = false),
                            selectedColor: Colors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Q2: Income Tax
                    const Text('2. क्या आप या आपके परिवार का कोई सदस्य इनकम टैक्स (आयकर) भरता है?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('नहीं, टैक्स नहीं भरते'),
                            selected: !paysTax,
                            onSelected: (_) => setModalState(() => paysTax = false),
                            selectedColor: AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('हाँ, टैक्स भरते हैं'),
                            selected: paysTax,
                            onSelected: (_) => setModalState(() => paysTax = true),
                            selectedColor: Colors.red.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Q3: Govt Job / Pensioner
                    const Text('3. क्या परिवार में कोई सरकारी नौकरी में है या ₹10,000+ से अधिक पेंशनर हैं?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('नहीं, कोई नहीं है'),
                            selected: !isGovtEmp,
                            onSelected: (_) => setModalState(() => isGovtEmp = false),
                            selectedColor: AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('हाँ, सरकारी नौकरी में हैं'),
                            selected: isGovtEmp,
                            onSelected: (_) => setModalState(() => isGovtEmp = true),
                            selectedColor: Colors.red.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- ELIGIBILITY RESULTS CARD ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 8),
                              Text('📊 आपकी योजना पात्रता रिपोर्ट (Eligibility Results):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _eligibilityItem(
                            context: context,
                            title: 'पीएम-किसान सम्मान निधि (PM-Kisan)',
                            amount: '₹6,000 / वर्ष (3 किस्तें)',
                            isEligible: isPmKisanEligible,
                            reason: isPmKisanEligible ? 'आप ₹2,000 की 3 किस्तों के लिए पूर्णतः पात्र हैं।' : 'अपात्र (आयकर / सरकारी नौकरी / ज़मीन न होना नियम)',
                          ),
                          _eligibilityItem(
                            context: context,
                            title: 'पीएम फसल बीमा योजना (PMFBY)',
                            amount: '1.5% - 2% न्यूनतम प्रीमियम',
                            isEligible: isPmfbyEligible,
                            reason: isPmfbyEligible ? 'आपकी फसल का 80% से 90% तक बीमा सुरक्षा कवर पात्र है।' : 'भूमिहीन (बटाईनामा / पट्टा अनुबंध आवश्यक)',
                          ),
                          _eligibilityItem(
                            context: context,
                            title: 'पीएम कुसुम सोलर पंप योजना (PM-KUSUM)',
                            amount: '60% से 90% सरकारी सब्सिडी',
                            isEligible: isKusumEligible,
                            reason: isKusumEligible ? 'खेत में सोलर पंप लगाने हेतु भारी सरकारी अनुदान पात्र।' : 'ज़मीन दस्तावेज़ आवश्यक',
                          ),
                          _eligibilityItem(
                            context: context,
                            title: 'किसान क्रेडिट कार्ड (KCC Loan)',
                            amount: '₹3 लाख तक 4% ब्याज दर',
                            isEligible: isKccEligible,
                            reason: isKccEligible ? 'कम ब्याज दर पर फसल ऋण हेतु पात्र।' : 'बैंक दस्तावेज़ आवश्यक',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _eligibilityItem({required BuildContext context, required String title, required String amount, required bool isEligible, required String reason}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isEligible ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isEligible ? Icons.check_circle_rounded : Icons.info_rounded,
              color: isEligible ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(amount, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isEligible ? Colors.green : Colors.orange)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(reason, style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
