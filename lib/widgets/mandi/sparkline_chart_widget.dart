import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/storage_service.dart';

class SparklineChartWidget extends StatelessWidget {
  final String state;
  final String commodity;
  final double modalPrice;
  final double minPrice;
  final double maxPrice;
  final bool compact;

  const SparklineChartWidget({
    super.key,
    required this.state,
    required this.commodity,
    required this.modalPrice,
    required this.minPrice,
    required this.maxPrice,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final points = StorageService.get7DayPriceHistory(
      state,
      commodity,
      fallbackPrice: modalPrice,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );

    if (points.isEmpty) return const SizedBox.shrink();

    final prices = points.map((p) => (p['price'] as num).toDouble()).toList();
    final firstPrice = prices.first;
    final lastPrice = prices.last;
    final diff = lastPrice - firstPrice;
    final pct = firstPrice > 0 ? (diff / firstPrice) * 100 : 0.0;
    final isUp = diff > 0;
    final isDown = diff < 0;

    final trendColor = isUp
        ? const Color(0xFF2E7D32)
        : (isDown ? const Color(0xFFC62828) : const Color(0xFF1565C0));

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 70,
            height: 28,
            child: CustomPaint(
              painter: _MiniSparklinePainter(
                prices: prices,
                lineColor: trendColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${isUp ? '+' : ''}${diff.toInt()} (${pct.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: trendColor,
            ),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isUp ? Icons.trending_up_rounded : (isDown ? Icons.trending_down_rounded : Icons.trending_flat_rounded),
                    color: trendColor,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '7 दिन का भाव ट्रेंड (Rolling 7D)',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isUp ? 'तेजी 📈 +' : (isDown ? 'मंदी 📉 ' : 'स्थिर ➖ ')}₹${diff.abs().toInt()} (${pct.abs().toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: trendColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(
              painter: _DetailedSparklinePainter(
                prices: prices,
                lineColor: trendColor,
                fillColor: trendColor.withValues(alpha: 0.15),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points.map((p) {
              return Text(
                p['date'].toString(),
                style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _MiniSparklinePainter extends CustomPainter {
  final List<double> prices;
  final Color lineColor;

  _MiniSparklinePainter({required this.prices, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final minVal = prices.reduce(min);
    final maxVal = prices.reduce(max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final stepX = size.width / (prices.length - 1);

    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final y = size.height - ((prices[i] - minVal) / range) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MiniSparklinePainter oldDelegate) =>
      oldDelegate.prices != prices || oldDelegate.lineColor != lineColor;
}

class _DetailedSparklinePainter extends CustomPainter {
  final List<double> prices;
  final Color lineColor;
  final Color fillColor;

  _DetailedSparklinePainter({
    required this.prices,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final minVal = prices.reduce(min);
    final maxVal = prices.reduce(max);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lineColor.withValues(alpha: 0.35), lineColor.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final stepX = size.width / (prices.length - 1);

    final List<Offset> points = [];

    for (int i = 0; i < prices.length; i++) {
      final x = i * stepX;
      final y = size.height - ((prices[i] - minVal) / range) * (size.height - 12) - 6;
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw Min and Max dots
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < points.length; i++) {
      if (prices[i] == maxVal) {
        dotPaint.color = Colors.green.shade700;
        canvas.drawCircle(points[i], 4.5, dotPaint);
        canvas.drawCircle(points[i], 2.0, Paint()..color = Colors.white);
      } else if (prices[i] == minVal) {
        dotPaint.color = Colors.red.shade700;
        canvas.drawCircle(points[i], 4.5, dotPaint);
        canvas.drawCircle(points[i], 2.0, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedSparklinePainter oldDelegate) =>
      oldDelegate.prices != prices || oldDelegate.lineColor != lineColor;
}
