import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/crop_calendar_model.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  CropCalendarTemplate _selectedCrop = CropCalendarTemplate.defaultTemplates.first;
  DateTime _sowingDate = DateTime.now().subtract(const Duration(days: 22)); // Default to CRI stage
  final Set<String> _completedStages = <String>{};

  int get _daysSinceSowing => DateTime.now().difference(_sowingDate).inDays.clamp(0, _selectedCrop.totalDays + 20);

  @override
  Widget build(BuildContext context) {
    final days = _daysSinceSowing;
    final progress = (days / _selectedCrop.totalDays).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🗓️ वैज्ञानिक फसल कैलेंडर',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'WhatsApp पर कैलेंडर शेयर करें',
            onPressed: _shareCalendarOnWhatsApp,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Top Config Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B5E20).withValues(alpha: 0.3),
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
                    Text(
                      '${_selectedCrop.emoji} ${_selectedCrop.hindiName} फसल चक्र',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedCrop.season,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
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
                          const Text('फसल की वर्तमान आयु:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            'आज $days दिन की फसल',
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 20, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickSowingDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1B5E20),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.calendar_today, size: 14),
                      label: Text(
                        'बुवाई: ${DateFormat('dd MMM').format(_sowingDate)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('बुवाई (दिन 0)', style: TextStyle(color: Colors.white70, fontSize: 10)),
                    Text('कुल चक्र: ${_selectedCrop.totalDays} दिन', style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Crop Selector Horizontal Chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: CropCalendarTemplate.defaultTemplates.map((tpl) {
                final isSel = _selectedCrop.cropId == tpl.cropId;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${tpl.emoji} ${tpl.hindiName}'),
                    selected: isSel,
                    selectedColor: const Color(0xFF1B5E20).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFF1B5E20),
                    onSelected: (_) {
                      setState(() {
                        _selectedCrop = tpl;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // Timeline Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📋 दिन-वार कार्य योजना (${_selectedCrop.stages.length} मुख्य चरण):',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const Text('ICAR मानक', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),

          // Stages Timeline List
          ..._selectedCrop.stages.map((stage) {
            final isCurrent = stage.isCurrent(days);
            final isPast = stage.isPast(days);
            final isDone = _completedStages.contains(stage.id) || isPast;

            Color borderColor = Colors.grey.withValues(alpha: 0.2);
            Color headerBg = Colors.grey.shade50;
            if (isCurrent) {
              borderColor = Colors.amber.shade600;
              headerBg = Colors.amber.shade50;
            } else if (isDone) {
              borderColor = Colors.green.shade200;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stage Card Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: headerBg,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isDone ? Icons.check_circle_rounded : (isCurrent ? Icons.play_circle_fill : Icons.schedule_rounded),
                              color: isDone ? Colors.green : (isCurrent ? Colors.amber.shade900 : Colors.grey),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stage.stageName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.5,
                                    color: isCurrent ? Colors.amber.shade900 : null,
                                  ),
                                ),
                                Text(
                                  'दिन ${stage.startDay} से ${stage.endDay} • ${stage.startDay > days ? '${stage.startDay - days} दिन बाद' : (isCurrent ? '⚡ वर्तमान में सक्रिय' : 'चरण समाप्त')}',
                                  style: TextStyle(fontSize: 11, color: isCurrent ? Colors.brown : Colors.grey.shade600, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            _completedStages.contains(stage.id) ? Icons.task_alt_rounded : Icons.radio_button_unchecked_rounded,
                            color: _completedStages.contains(stage.id) ? Colors.green : Colors.grey,
                            size: 22,
                          ),
                          tooltip: 'काम पूर्ण मार्क करें',
                          onPressed: () {
                            setState(() {
                              if (_completedStages.contains(stage.id)) {
                                _completedStages.remove(stage.id);
                              } else {
                                _completedStages.add(stage.id);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Stage Content Details
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAdviceItem(Icons.water_drop_outlined, 'सिंचाई सलाह:', stage.irrigationAdvice, Colors.blue.shade700),
                        const SizedBox(height: 8),
                        _buildAdviceItem(Icons.grain_rounded, 'खाद व स्प्रे खुराक:', stage.fertilizerAdvice, Colors.green.shade800),
                        const SizedBox(height: 8),
                        _buildAdviceItem(Icons.bug_report_outlined, 'कीट व रोग चेतावनी:', stage.pestWarning, Colors.red.shade700),
                        const SizedBox(height: 8),
                        _buildAdviceItem(Icons.lightbulb_outline_rounded, 'विशेष टिप:', stage.criticalTips, Colors.orange.shade800),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAdviceItem(IconData icon, String label, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, height: 1.35, color: Colors.black87),
              children: [
                TextSpan(text: '$label ', style: TextStyle(fontWeight: FontWeight.w900, color: color)),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _pickSowingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sowingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 180)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _sowingDate = picked);
    }
  }

  void _shareCalendarOnWhatsApp() async {
    final days = _daysSinceSowing;
    final buffer = StringBuffer();
    buffer.writeln('🌾 *${_selectedCrop.hindiName} वैज्ञानिक फसल कैलेंडर* 🌾');
    buffer.writeln('📅 बुवाई तारीख: ${DateFormat('dd MMM yyyy').format(_sowingDate)}');
    buffer.writeln('🌱 आज फसल की आयु: *$days दिन* (कुल चक्र: ${_selectedCrop.totalDays} दिन)');
    buffer.writeln('--------------------------------');

    for (final st in _selectedCrop.stages) {
      final current = st.isCurrent(days) ? ' ⚡ [वर्तमान चरण]' : '';
      buffer.writeln('\n*दिन ${st.startDay}-${st.endDay}: ${st.stageName}*$current');
      buffer.writeln('💧 सिंचाई: ${st.irrigationAdvice}');
      buffer.writeln('🧪 खाद/स्प्रे: ${st.fertilizerAdvice}');
    }

    buffer.writeln('\n📱 _Kisan Mitra ऐप द्वारा जनरेट किया गया_');
    final text = buffer.toString();
    final uri = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        final webUri = Uri.parse('https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}');
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कैलेंडर विवरण कॉपी किया गया')));
      }
    }
  }
}
