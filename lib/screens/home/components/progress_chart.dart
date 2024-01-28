import 'dart:math';
import 'package:chess_vision/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RatingProgressChart extends StatelessWidget {
  final List<FlSpot> dataPoints;

  // Constructor generates 20 data points with the index as the x value and a random rating as the y value.
  RatingProgressChart({super.key})
      : dataPoints = List.generate(20, (index) {
          final randomRating = Random().nextInt(3000 - 900) +
              900; // Random rating between 900 and 3000
          return FlSpot(index.toDouble(), randomRating.toDouble());
        });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: const LineTouchData(
            touchTooltipData:
                LineTouchTooltipData(tooltipBgColor: Colors.white)),
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: bottomTitleWidgets,
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: leftTitleWidgets,
                reservedSize: 42,
                interval: 1,
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
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

Widget leftTitleWidgets(double value, TitleMeta meta) {
  String text;

  switch (value.toInt()) {
    case (1000):
      text = '1000';
      break;
    case 1500:
      text = '1500';
      break;
    case 2000:
      text = '2000';
      break;
    case 2500:
      text = '2500';

    case 3000:
      text = '3000';
    default:
      return Container();
  }

  return Text(text, style: defText, textAlign: TextAlign.left);
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  Widget text;
  switch (value.toInt()) {
    case 2:
      text = Text('MAR', style: defText);
      break;
    case 5:
      text = Text('JUN', style: defText);
      break;
    case 8:
      text = Text('SEP', style: defText);
      break;
    case 11:
      text = Text('DEC', style: defText);
      break;
    default:
      text = Text('', style: defText);
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}
