import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/theme.dart';
import '../../utils/web_iframe.dart';

/// 100% In-App Web Viewer Modal - Never redirects the user outside the app
class InAppBrowserSheet extends StatefulWidget {
  final String url;
  final String title;

  const InAppBrowserSheet({
    super.key,
    required this.url,
    required this.title,
  });

  static Future<void> show(BuildContext context, {required String url, required String title}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: false,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InAppBrowserSheet(url: url, title: title),
    );
  }

  @override
  State<InAppBrowserSheet> createState() => _InAppBrowserSheetState();
}

class _InAppBrowserSheetState extends State<InAppBrowserSheet> {
  WebViewController? _controller;
  bool _isLoading = true;
  double _progress = 0.0;
  late String _webId;

  @override
  void initState() {
    super.initState();
    _webId = 'in-app-browser-${DateTime.now().millisecondsSinceEpoch}';

    if (kIsWeb) {
      registerWindyIframe(_webId, widget.url);
      _isLoading = false;
    } else {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              if (mounted) {
                setState(() {
                  _progress = progress / 100.0;
                });
              }
            },
            onPageStarted: (_) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (_) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 4),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.language_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.url,
                        style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'रीलोड करें',
                  onPressed: () {
                    if (!kIsWeb && _controller != null) {
                      _controller!.reload();
                    } else if (kIsWeb) {
                      setState(() {
                        _webId = 'in-app-browser-${DateTime.now().millisecondsSinceEpoch}';
                        registerWindyIframe(_webId, widget.url);
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'बंद करें',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Loading bar
          if (_isLoading && !kIsWeb)
            LinearProgressIndicator(
              value: _progress > 0 ? _progress : null,
              backgroundColor: Colors.transparent,
              color: AppColors.primary,
              minHeight: 2.5,
            )
          else
            const Divider(height: 1),

          // Web Page Content
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: kIsWeb
                  ? HtmlElementView(
                      key: ValueKey(_webId),
                      viewType: _webId,
                    )
                  : (_controller != null
                      ? WebViewWidget(controller: _controller!)
                      : const Center(child: CircularProgressIndicator())),
            ),
          ),
        ],
      ),
    );
  }
}
