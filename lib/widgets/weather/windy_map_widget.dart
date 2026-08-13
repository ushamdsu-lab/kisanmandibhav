import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../common/glass_card.dart';

import '../../utils/web_iframe.dart';

class WindyMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const WindyMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<WindyMapWidget> createState() => _WindyMapWidgetState();
}

class _WindyMapWidgetState extends State<WindyMapWidget> {
  String _selectedOverlay = 'rain'; // 'rain', 'wind', 'temp', 'clouds'
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _registerIframe();
  }

  @override
  void didUpdateWidget(covariant WindyMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _registerIframe();
    }
  }

  void _registerIframe() {
    _viewId = 'windy-iframe-${widget.latitude}-${widget.longitude}-$_selectedOverlay-${DateTime.now().millisecondsSinceEpoch}';
    final embedUrl = _buildEmbedUrl(_selectedOverlay);

    if (kIsWeb) {
      registerWindyIframe(_viewId, embedUrl);
    }
  }

  String _buildEmbedUrl(String overlay) {
    final lat = widget.latitude.toStringAsFixed(4);
    final lon = widget.longitude.toStringAsFixed(4);
    return 'https://embed.windy.com/embed2.html?'
        'lat=$lat&lon=$lon&detailLat=$lat&detailLon=$lon'
        '&width=650&height=400&zoom=7&level=surface'
        '&overlay=$overlay&product=ecmwf'
        '&menu=&message=true&marker=true&calendar=now'
        '&metricWind=km%2Fh&metricTemp=%C2%B0C&radarRange=-1';
  }

  void _changeOverlay(String overlay) {
    setState(() {
      _selectedOverlay = overlay;
      _registerIframe();
    });
  }

  void _openInAppFullScreen(BuildContext context) {
    final cleanName = widget.locationName.contains('(')
        ? widget.locationName.split('(').first.trim()
        : widget.locationName;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Windy In-App Fullscreen Map',
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🗺️ $cleanName लाइव राडार नक्शा',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Windy Interactive Radar • 100% In-App View',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 26, color: Colors.amberAccent),
                onPressed: () => Navigator.pop(context),
                tooltip: 'बंद करें ✕',
              ),
            ],
          ),
          body: StatefulBuilder(
            builder: (context, setFullState) {
              final fullViewId = 'windy-full-iframe-${widget.latitude}-${widget.longitude}-$_selectedOverlay-${DateTime.now().millisecondsSinceEpoch}';
              final embedUrl = _buildEmbedUrl(_selectedOverlay);

              if (kIsWeb) {
                registerWindyIframe(fullViewId, embedUrl);
              }

              return Column(
                children: [
                  Container(
                    color: Colors.grey.shade900,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFullLayerChip('rain', 'बारिश व राडार', Icons.water_drop_rounded, Colors.blue, setFullState),
                          const SizedBox(width: 8),
                          _buildFullLayerChip('wind', 'हवा का बहाव', Icons.air_rounded, Colors.teal, setFullState),
                          const SizedBox(width: 8),
                          _buildFullLayerChip('temp', 'तापमान मैप', Icons.thermostat_rounded, Colors.orange, setFullState),
                          const SizedBox(width: 8),
                          _buildFullLayerChip('clouds', 'बादल सैटेलाइट', Icons.cloud_rounded, Colors.purple, setFullState),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: kIsWeb
                        ? HtmlElementView(
                            key: ValueKey(fullViewId),
                            viewType: fullViewId,
                          )
                        : Container(
                            color: Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.satellite_alt_rounded, size: 64, color: Colors.amberAccent),
                                  const SizedBox(height: 12),
                                  Text(
                                    '📍 $cleanName लाइव राडार नक्शा',
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    '100% ऐप के अंदर लाइव सैटेलाइट व्यू',
                                    style: TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFullLayerChip(String value, String label, IconData icon, Color color, StateSetter setFullState) {
    final isSelected = _selectedOverlay == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOverlay = value;
          _registerIframe();
        });
        setFullState(() {});
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white30,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : icon,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanName = widget.locationName.contains('(')
        ? widget.locationName.split('(').first.trim()
        : widget.locationName;

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mausamAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map_rounded, color: AppColors.mausamAccent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🗺️ लाइव राडार व सैटेलाइट मैप',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Windy ECMWF ग्लोबल मौसम मॉडल • $cleanName',
                        style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => _openInAppFullScreen(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.mausamAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fullscreen_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 3),
                      Text(
                        'ऐप में फुल स्क्रीन ⛶',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Layer Switcher Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildLayerChip('rain', 'बारिश व राडार', Icons.water_drop_rounded, Colors.blue),
                const SizedBox(width: 6),
                _buildLayerChip('wind', 'हवा का बहाव', Icons.air_rounded, Colors.teal),
                const SizedBox(width: 6),
                _buildLayerChip('temp', 'तापमान मैप', Icons.thermostat_rounded, Colors.orange),
                const SizedBox(width: 6),
                _buildLayerChip('clouds', 'बादल सैटेलाइट', Icons.cloud_rounded, Colors.purple),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic Interactive Embedded Map (Web / Mobile Container)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 320,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mausamAccent.withValues(alpha: 0.2)),
              ),
              child: kIsWeb
                  ? HtmlElementView(
                      key: ValueKey(_viewId),
                      viewType: _viewId,
                    )
                  : Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.satellite_alt_rounded, size: 48, color: AppColors.mausamAccent),
                              const SizedBox(height: 8),
                              Text(
                                '📍 $cleanName लाइव राडार नक्शा',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'लाइव विंड और बारिश सैटेलाइट मैप देखें',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () => _openInAppFullScreen(context),
                                icon: const Icon(Icons.fullscreen_rounded, size: 16),
                                label: const Text('ऐप में फुल स्क्रीन देखें ⛶'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mausamAccent,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
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

  Widget _buildLayerChip(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedOverlay == value;
    return InkWell(
      onTap: () => _changeOverlay(value),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Theme.of(context).cardTheme.color ?? Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : icon,
              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
