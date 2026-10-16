import 'package:flutter/material.dart';
import 'package:motion_orbit/features/body_measurements/domain/entities/body_measurement.dart';
import 'package:motion_orbit/features/profile/presentation/profile_colors.dart';
import 'package:motion_orbit/features/profile/presentation/widgets/profile_module_widgets.dart';

import '../utils/body_measurement_formatters.dart';

class WeightTrendCard extends StatelessWidget {
  const WeightTrendCard({super.key, required this.items, required this.imperial});

  final List<BodyMeasurement> items;
  final bool imperial;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final points = items
        .where((item) => item.weightKg != null)
        .take(30)
        .toList()
        .reversed
        .toList();
    final values = points
        .map((item) => convertWeight(item.weightKg!, imperial))
        .toList();

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, size: 20, color: ProfileColors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '30-Day Weight Trend',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
              ),
              const Chip(
                label: Text('30D', style: TextStyle(fontSize: 10)),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            width: double.infinity,
            child: points.length < 2
                ? Center(
                    child: Text(
                      points.isEmpty
                          ? 'Add weight measurements to see your trend.'
                          : 'Add another weight measurement to see your trend.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : CustomPaint(painter: WeightTrendPainter(values)),
          ),
          if (points.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatShortMonthDay(points.first.date),
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatShortMonthDay(points.last.date),
                  style: TextStyle(
                    fontSize: 10,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class WeightTrendPainter extends CustomPainter {
  WeightTrendPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs();
    final path = Path();

    for (var index = 0; index < values.length; index++) {
      final point = _pointFor(index, size, minValue, range);
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = ProfileColors.blue
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    for (var index = 0; index < values.length; index++) {
      canvas.drawCircle(
        _pointFor(index, size, minValue, range),
        3,
        Paint()..color = ProfileColors.blue,
      );
    }
  }

  Offset _pointFor(int index, Size size, double minValue, double range) {
    final x = values.length == 1
        ? size.width / 2
        : index * size.width / (values.length - 1);
    final y =
        size.height -
        12 -
        ((values[index] - minValue) / (range == 0 ? 1 : range)) *
            (size.height - 24);
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(covariant WeightTrendPainter oldDelegate) =>
      oldDelegate.values != values;
}
