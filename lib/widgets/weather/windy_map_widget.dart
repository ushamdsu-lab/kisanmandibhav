import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
  String _selectedOverlay = 'rain';
  int _zoomLevel = 8;
  String _selectedModel = 'ecmwf';
  late String _viewId;
  WebViewController? _webViewController;
  bool _isLoadingMobile = true;

  static const List<Map<String, dynamic>> _overlays = [
    {'id': 'rain', 'label': 'बारिश व रडार', 'icon': Icons.water_drop_rounded, 'color': Colors.blue},
    {'id': 'thunder', 'label': 'आंधी-तूफान', 'icon': Icons.bolt_rounded, 'color': Colors.amber},
    {'id': 'wind', 'label': 'हवा का बहाव', 'icon': Icons.air_rounded, 'color': Colors.teal},
    {'id': 'gust', 'label': 'तेज झोंके', 'icon': Icons.waves_rounded, 'color': Colors.cyan},
    {'id': 'clouds', 'label': 'बादल सैटेलाइट', 'icon': Icons.cloud_rounded, 'color': Colors.purple},
    {'id': 'temp', 'label': 'तापमान मैप', 'icon': Icons.thermostat_rounded, 'color': Colors.orange},
    {'id': 'fog', 'label': 'कोहरा / धुंध', 'icon': Icons.foggy, 'color': Colors.blueGrey},
    {'id': 'rh', 'label': 'हवा में नमी', 'icon': Icons.opacity_rounded, 'color': Colors.lightBlue},
  ];

  static const List<Map<String, String>> _models = [
    {'id': 'ecmwf', 'label': 'ECMWF (यूरोपियन #1)'},
    {'id': 'gfs', 'label': 'GFS (अमेरिकी)'},
    {'id': 'icon', 'label': 'ICON (जर्मन)'},
  ];

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  @override
  void didUpdateWidget(covariant WindyMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      _initMap();
    }
  }

  void _initMap() {
    _viewId = 'windy-iframe-${widget.latitude}-${widget.longitude}-$_selectedOverlay-$_zoomLevel-$_selectedModel-${DateTime.now().millisecondsSinceEpoch}';
    final embedUrl = _buildEmbedUrl();

    if (kIsWeb) {
      registerWindyIframe(_viewId, embedUrl);
    } else {
      _initMobileWebView(embedUrl);
    }
  }

  void _initMobileWebView(String embedUrl) {
    _isLoadingMobile = true;
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1E293B))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _isLoadingMobile = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(embedUrl));
  }

  String _buildEmbedUrl({
    String? overlay,
    int? zoom,
    String? model,
  }) {
    final activeOverlay = overlay ?? _selectedOverlay;
    final activeZoom = zoom ?? _zoomLevel;
    final activeModel = model ?? _selectedModel;
    final lat = widget.latitude.toStringAsFixed(4);
    final lon = widget.longitude.toStringAsFixed(4);
    return 'https://embed.windy.com/embed2.html?'
        'lat=$lat&lon=$lon&detailLat=$lat&detailLon=$lon'
        '&width=650&height=400&zoom=$activeZoom&level=surface'
        '&overlay=$activeOverlay&product=$activeModel'
        '&menu=&message=true&marker=true&calendar=now'
        '&metricWind=km%2Fh&metricTemp=%C2%B0C&radarRange=-1';
  }

  void _changeOverlay(String overlay) {
    setState(() {
      _selectedOverlay = overlay;
      _initMap();
    });
  }

  void _changeZoom(int delta) {
    final newZoom = (_zoomLevel + delta).clamp(4, 13);
    if (newZoom != _zoomLevel) {
      setState(() {
        _zoomLevel = newZoom;
        _initMap();
      });
    }
  }

  void _recenterFarm() {
    setState(() {
      _zoomLevel = 9;
      _initMap();
    });
  }

  void _toggleIndiaView() {
    setState(() {
      _zoomLevel = _zoomLevel > 5 ? 5 : 8;
      _initMap();
    });
  }

  void _changeModel(String model) {
    setState(() {
      _selectedModel = model;
      _initMap();
    });
  }

  void _openInAppFullScreen(BuildContext context) {
    final cleanName = widget.locationName.contains('(')
        ? widget.locationName.split('(').first.trim()
        : widget.locationName;

    WebViewController? fullScreenController;
    if (!kIsWeb) {
      final fullUrl = _buildEmbedUrl();
      fullScreenController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..loadRequest(Uri.parse(fullUrl));
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Windy In-App Fullscreen Map',
      pageBuilder: (context, anim1, anim2) {
        return StatefulBuilder(
          builder: (context, setFullState) {
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
                      '🗺️ $cleanName लाइव राडार व सैटेलाइट',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Windy • ${_selectedModel.toUpperCase()} • ज़ूम स्तर: $_zoomLevel',
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.zoom_in_rounded, color: Colors.white),
                    tooltip: 'ज़ूम इन',
                    onPressed: () {
                      _changeZoom(1);
                      if (!kIsWeb && fullScreenController != null) {
                        fullScreenController.loadRequest(Uri.parse(_buildEmbedUrl()));
                      }
                      setFullState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out_rounded, color: Colors.white),
                    tooltip: 'ज़ूम आउट',
                    onPressed: () {
                      _changeZoom(-1);
                      if (!kIsWeb && fullScreenController != null) {
                        fullScreenController.loadRequest(Uri.parse(_buildEmbedUrl()));
                      }
                      setFullState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location_rounded, color: Colors.white),
                    tooltip: 'मेरा खेत रीसेट',
                    onPressed: () {
                      _recenterFarm();
                      if (!kIsWeb && fullScreenController != null) {
                        fullScreenController.loadRequest(Uri.parse(_buildEmbedUrl()));
                      }
                      setFullState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    tooltip: 'नक्शा रीलोड करें',
                    onPressed: () {
                      _initMap();
                      if (!kIsWeb && fullScreenController != null) {
                        fullScreenController.loadRequest(Uri.parse(_buildEmbedUrl()));
                      }
                      setFullState(() {});
                    },
                  ),
                ],
              ),
              body: Column(
                children: [
                  // Overlays Selector in Fullscreen Modal
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _overlays.map((ov) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _buildFullLayerChip(
                              ov['id'] as String,
                              ov['label'] as String,
                              ov['icon'] as IconData,
                              ov['color'] as Color,
                              setFullState,
                              fullScreenController,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Fullscreen Map Rendering (Web / Mobile)
                  Expanded(
                    child: kIsWeb
                        ? HtmlElementView(
                            key: ValueKey('fullscreen-$_viewId'),
                            viewType: _viewId,
                          )
                        : (fullScreenController != null
                            ? WebViewWidget(controller: fullScreenController)
                            : const Center(child: CircularProgressIndicator())),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFullLayerChip(
    String value,
    String label,
    IconData icon,
    Color color,
    StateSetter setFullState,
    WebViewController? fullScreenController,
  ) {
    final isSelected = _selectedOverlay == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOverlay = value;
          _initMap();
        });
        if (!kIsWeb && fullScreenController != null) {
          fullScreenController.loadRequest(Uri.parse(_buildEmbedUrl(overlay: value)));
        }
        setFullState(() {});
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.mausamAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.satellite_alt_rounded, color: AppColors.mausamAccent, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🗺️ लाइव राडार व सैटेलाइट',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Windy • ${_selectedModel.toUpperCase()} • $cleanName',
                            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // Forecast Model Picker Menu
              PopupMenuButton<String>(
                initialValue: _selectedModel,
                tooltip: 'मौसम मॉडल बदलें',
                onSelected: _changeModel,
                itemBuilder: (context) => _models.map((m) {
                  return PopupMenuItem<String>(
                    value: m['id'],
                    child: Text(m['label']!, style: const TextStyle(fontSize: 12)),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mausamAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.mausamAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.tune_rounded, size: 11, color: AppColors.mausamAccent),
                      const SizedBox(width: 2),
                      Text(
                        _selectedModel.toUpperCase(),
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.mausamAccent),
                      ),
                      const Icon(Icons.arrow_drop_down_rounded, size: 13, color: AppColors.mausamAccent),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              // Fullscreen Button
              InkWell(
                onTap: () => _openInAppFullScreen(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mausamAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fullscreen_rounded, color: Colors.white, size: 13),
                      SizedBox(width: 2),
                      Text(
                        'फुल स्क्रीन',
                        style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 🎛️ Interactive Quick Control Bar (Zoom +, Zoom -, My Farm, India View, Reload)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Zoom In Button
                  _buildToolActionBtn(
                    icon: Icons.add_rounded,
                    label: 'ज़ूम +',
                    tooltip: 'नक्शा बड़ा करें',
                    onTap: () => _changeZoom(1),
                  ),
                  const SizedBox(width: 4),
                  // Zoom Out Button
                  _buildToolActionBtn(
                    icon: Icons.remove_rounded,
                    label: 'ज़ूम -',
                    tooltip: 'नक्शा छोटा करें',
                    onTap: () => _changeZoom(-1),
                  ),
                  const SizedBox(width: 4),
                  Container(width: 1, height: 18, color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(width: 4),
                  // My Farm Location Button
                  _buildToolActionBtn(
                    icon: Icons.my_location_rounded,
                    label: '📍 मेरा खेत',
                    tooltip: 'खेत पर केंद्रित करें',
                    color: Colors.green,
                    onTap: _recenterFarm,
                  ),
                  const SizedBox(width: 4),
                  // All India View Toggle
                  _buildToolActionBtn(
                    icon: Icons.public_rounded,
                    label: _zoomLevel <= 5 ? '🗺️ जिला व्यू' : '🇮🇳 पूरा भारत',
                    tooltip: 'भारत/जिला व्यू बदलें',
                    color: Colors.indigo,
                    onTap: _toggleIndiaView,
                  ),
                  const SizedBox(width: 4),
                  Container(width: 1, height: 18, color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(width: 4),
                  // Reload Button
                  _buildToolActionBtn(
                    icon: Icons.refresh_rounded,
                    label: 'रीलोड',
                    tooltip: 'नक्शा रीफ्रेश करें',
                    onTap: () => setState(_initMap),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Layer Switcher Chips (8 Comprehensive Weather Overlays)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _overlays.map((ov) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _buildLayerChip(
                    ov['id'] as String,
                    ov['label'] as String,
                    ov['icon'] as IconData,
                    ov['color'] as Color,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Dynamic Interactive Embedded Map (Web / Mobile Native WebView)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 330,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.mausamAccent.withValues(alpha: 0.2)),
              ),
              child: Stack(
                children: [
                  kIsWeb
                      ? HtmlElementView(
                          key: ValueKey(_viewId),
                          viewType: _viewId,
                        )
                      : (_webViewController != null
                          ? Stack(
                              children: [
                                WebViewWidget(controller: _webViewController!),
                                if (_isLoadingMobile)
                                  const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.mausamAccent,
                                    ),
                                  ),
                              ],
                            )
                          : const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.mausamAccent,
                              ),
                            )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Footer info
          Row(
            children: [
              const Icon(Icons.touch_app_rounded, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'ऊपर दिए बटनों से ज़ूम (+/-), मेरा खेत, पूरा भारत और आंधी/बारिश/बादल लेयर बदलें',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolActionBtn({
    required IconData icon,
    required String label,
    required String tooltip,
    required VoidCallback onTap,
    Color? color,
  }) {
    final effectiveColor = color ?? AppColors.mausamAccent;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: effectiveColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: effectiveColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: effectiveColor),
              const SizedBox(width: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
