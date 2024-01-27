import 'dart:math';
import 'package:chess_vision/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RatingProgressChart extends StatelessWidget {
  final List<FlSpot> dataPoints;

  // Constructor generates 20 data points with the index as the x value and a random rating as the y value.
  RatingProgressChart({super.key})
      : dataPoints = List.generate(20, (index) {
          final randomRating = Random().nextInt(2400 - 1200) +
              1200; // Random rating between 1200 and 2400
          return FlSpot(index.toDouble(), randomRating.toDouble());
        });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(
          show: false,
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: dataPoints,
            isCurved: true,
            color: Colors.blue,
            barWidth: 5,
            belowBarData: BarAreaData(show: true),
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
