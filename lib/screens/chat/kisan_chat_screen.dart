import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_images.dart';
import '../../models/mandi_rate.dart';
import '../../data/crop_disease_database.dart';
import '../../utils/commodity_helper.dart';
import '../../providers/mandi_provider.dart';
import '../../services/kisan_chat_service.dart';

class KisanChatScreen extends StatefulWidget {
  final String? initialQuery;

  const KisanChatScreen({super.key, this.initialQuery});

  @override
  State<KisanChatScreen> createState() => _KisanChatScreenState();
}

class _KisanChatScreenState extends State<KisanChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  final List<String> _quickPrompts = [
    '🌾 नीमच में लहसुन का भाव',
    '🌾 इंदौर में सोयाबीन भाव',
    '🩺 गेहूं में पीला रतुआ दवा',
    '🩺 टमाटर में झुलसा रोग',
    '🩺 सरसों में माहू (चेपा) स्प्रे',
    '🩺 चने में इल्ली की रोकथाम',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      ChatMessage(
        id: 'welcome',
        text: 'राम राम किसान भाई! 🙏 मैं आपका किसान मित्र AI हूँ।\n\n'
            'आप मुझसे अपनी फसल से जुड़ा कोई भी सवाल पूछ सकते हैं:\n\n'
            '1️⃣ मंडी भाव: मंडी और फसल का नाम लिखें\n'
            '👉 उदा: "नीमच में लहसुन भाव" या "इंदौर सोयाबीन"\n\n'
            '2️⃣ रोग व दवा: फसल और बीमारी का नाम लिखें\n'
            '👉 उदा: "गेहूं में पीला रतुआ दवा" या "टमाटर में झुलसा"\n\n'
            'नीचे दिए गए सुझावों पर भी क्लिक कर सकते हैं!',
        isUser: false,
        timestamp: DateTime.now(),
        type: ChatMessageType.suggestions,
        quickActions: _quickPrompts,
      ),
    );

    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSend(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _textController.clear();

    // 1. Add User message
    setState(() {
      _messages.add(
        ChatMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          text: query,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    // 2. Get MandiProvider pool
    final mandiProv = context.read<MandiProvider>();
    final rates = mandiProv.rates;

    // Simulate natural AI thinking delay
    await Future.delayed(const Duration(milliseconds: 400));

    // 3. Process AI Response
    final botResponse = await KisanChatService.processMessage(query, liveRates: rates);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add(botResponse);
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: AppImages.appLogo(size: 28, borderRadius: BorderRadius.circular(6)),
            ),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '💬 किसान मित्र AI चैट',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
                ),
                Text(
                  'मंडी भाव व फसल रोग विशेषज्ञ',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'नई बातचीत',
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessage(
                    id: 'welcome_reset',
                    text: 'राम राम! नई बातचीत शुरू हो गई है। अपनी फसल, रोग या मंडी का नाम लिखें।',
                    isUser: false,
                    timestamp: DateTime.now(),
                    type: ChatMessageType.suggestions,
                    quickActions: _quickPrompts,
                  ),
                );
              });
            },
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
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Horizontal Quick Chips
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: _quickPrompts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final prompt = _quickPrompts[i];
                return ActionChip(
                  label: Text(
                    prompt,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.green.shade200),
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  onPressed: () => _handleSend(prompt),
                );
              },
            ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _textController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _handleSend,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'फसल+रोग या मंडी+फसल लिखें...',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.psychology_alt_rounded, color: Color(0xFF1B5E20), size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _handleSend(_textController.text),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(width: 8),
            Text(
              'किसान मित्र सोच रहा है...',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    // Assistant Message
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14, right: 24),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(
            color: msg.type == ChatMessageType.cropDisease
                ? Colors.red.shade200
                : (msg.type == ChatMessageType.mandiRate ? Colors.green.shade200 : Colors.grey.shade300),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      msg.type == ChatMessageType.cropDisease
                          ? Icons.local_hospital_rounded
                          : (msg.type == ChatMessageType.mandiRate ? Icons.storefront_rounded : Icons.smart_toy_rounded),
                      size: 16,
                      color: msg.type == ChatMessageType.cropDisease
                          ? Colors.red.shade700
                          : const Color(0xFF1B5E20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      msg.type == ChatMessageType.cropDisease
                          ? 'CIBRC प्रमाणित समाधान'
                          : (msg.type == ChatMessageType.mandiRate ? 'लाइव मंडी भाव' : 'किसान मित्र AI'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: msg.type == ChatMessageType.cropDisease
                            ? Colors.red.shade800
                            : const Color(0xFF1B5E20),
                      ),
                    ),
                  ],
                ),
                // Action Buttons: TTS & WhatsApp
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded, size: 20, color: Color(0xFF1B5E20)),
                      tooltip: 'बोलकर सुनें',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => KisanChatService.speakMessage(msg),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF25D366)),
                      tooltip: 'WhatsApp पर शेयर करें',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => KisanChatService.shareToWhatsApp(msg),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 14),

            // Message text (Zero raw asterisks)
            if (msg.alternativeRates != null && msg.alternativeRates!.isNotEmpty) ...[
              _buildFormattedText(msg.text.split('\n\n').first),
              _buildRatesList(msg.alternativeRates!),
            ] else if (msg.mandiRate != null) ...[
              _buildSingleMandiCard(msg.mandiRate!),
            ] else if (msg.disease != null) ...[
              _buildPrescriptionCard(msg.disease!),
            ] else ...[
              _buildFormattedText(msg.text),
            ],

            // Quick Actions if attached
            if (msg.quickActions != null && msg.quickActions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: msg.quickActions!.map((action) {
                  return InkWell(
                    onTap: () => _handleSend(action),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        '👉 $action',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    final clean = text.replaceAll('*', '');
    return Text(
      clean,
      style: const TextStyle(fontSize: 13.5, height: 1.5, color: Colors.black87),
    );
  }

  Widget _buildRatesList(List<MandiRate> rates) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: rates.length,
        separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (context, i) {
          final r = rates[i];
          final cropName = CommodityHelper.getHindiName(r.commodity);
          return InkWell(
            onTap: () => _handleSend('${r.market} में $cropName भाव'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${r.market} APMC',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black87),
                        ),
                        Text(
                          '${r.state} • $cropName',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA5D6A7)),
                    ),
                    child: Text(
                      '₹${r.modalPrice.toInt()} / क्विंटल',
                      style: const TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.w900,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleMandiCard(MandiRate rate) {
    final cropName = CommodityHelper.getHindiName(rate.commodity);
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${rate.market} मंडी (${rate.state})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rate.arrivalStatus,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹${rate.modalPrice.toInt()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ क्विंटल ($cropName मॉडल भाव)',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'न्यूनतम: ₹${rate.minPrice.toInt()}',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 10),
              Text(
                'अधिकतम: ₹${rate.maxPrice.toInt()}',
                style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(CropDisease disease) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.healing_rounded, size: 18, color: Color(0xFFDC2626)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${disease.diseaseNameHindi} (${disease.diseaseNameEnglish})',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF991B1B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💊 रासायनिक दवा (CIBRC प्रमाणित):',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: Color(0xFF1B5E20)),
                ),
                const SizedBox(height: 2),
                Text(
                  disease.chemicalMedicine,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  '💧 खुराक: ${disease.sprayDosage}',
                  style: TextStyle(fontSize: 11.5, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
          if (disease.organicRemedy.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '🍃 जैविक उपाय: ${disease.organicRemedy}',
              style: TextStyle(fontSize: 11.5, color: Colors.green.shade900),
            ),
          ],
          if (disease.precautions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '⚠️ सावधानी: ${disease.precautions}',
              style: TextStyle(fontSize: 11, color: Colors.orange.shade900),
            ),
          ],
        ],
      ),
    );
  }
}
