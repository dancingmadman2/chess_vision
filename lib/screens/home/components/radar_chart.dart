import 'package:chess_vision/styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RadarChartSample1 extends StatefulWidget {
  RadarChartSample1({super.key});

  final gridColor = Colors.white;
  final titleColor = Colors.white;

  final you = green;
  final avg = Colors.blue;

  @override
  State<RadarChartSample1> createState() => _RadarChartSample1State();
}

class _RadarChartSample1State extends State<RadarChartSample1> {
  int selectedDataSetIndex = -1;
  double angleValue = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: RadarChart(
                  RadarChartData(
                    radarTouchData: RadarTouchData(
                      touchCallback: (FlTouchEvent event, response) {
                        if (!event.isInterestedForInteractions) {
                          setState(() {
                            selectedDataSetIndex = -1;
                          });
                          return;
                        }
                        setState(() {
                          selectedDataSetIndex =
                              response?.touchedSpot?.touchedDataSetIndex ?? -1;
                        });
                      },
                    ),
                    dataSets: showingDataSets(),
                    radarBackgroundColor: Colors.transparent,
                    borderData: FlBorderData(show: false),
                    radarBorderData:
                        const BorderSide(color: Colors.transparent),
                    titlePositionPercentageOffset: 0.2,
                    titleTextStyle: defTextLight,
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0:
                          return const RadarChartTitle(
                            text: 'Tactical Awareness',
                          );
                        case 1:
                          return const RadarChartTitle(text: 'Speed', angle: 0);
                        case 2:
                          return const RadarChartTitle(
                            text: 'Visualization Accuracy',
                          );
                        case 3:
                          return const RadarChartTitle(
                              text: 'Memory', angle: 0);
                        default:
                          return const RadarChartTitle(text: '');
                      }
                    },
                    tickCount: 1,
                    ticksTextStyle: const TextStyle(
                        color: Colors.transparent, fontSize: 10),
                    tickBorderData: const BorderSide(color: Colors.transparent),
                    gridBorderData:
                        BorderSide(color: widget.gridColor, width: 2),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 400),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: rawDataSets()
                    .asMap()
                    .map((index, value) {
                      final isSelected = index == selectedDataSetIndex;
                      return MapEntry(
                        index,
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDataSetIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            height: 26,
                            decoration: BoxDecoration(
                              color: isSelected ? primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(46),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInToLinear,
                                  padding: EdgeInsets.all(isSelected ? 8 : 6),
                                  decoration: BoxDecoration(
                                    color: value.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInToLinear,
                                  style: TextStyle(
                                    color: isSelected
                                        ? value.color
                                        : widget.gridColor,
                                  ),
                                  child: Text(
                                    value.title,
                                    style: defText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                    .values
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<RadarDataSet> showingDataSets() {
    return rawDataSets().asMap().entries.map((entry) {
      final index = entry.key;
      final rawDataSet = entry.value;

      final isSelected = index == selectedDataSetIndex
          ? true
          : selectedDataSetIndex == -1
              ? true
              : false;

      return RadarDataSet(
        fillColor: isSelected
            ? rawDataSet.color.withOpacity(0.2)
            : rawDataSet.color.withOpacity(0.05),
        borderColor:
            isSelected ? rawDataSet.color : rawDataSet.color.withOpacity(0.25),
        entryRadius: isSelected ? 3 : 2,
        dataEntries:
            rawDataSet.values.map((e) => RadarEntry(value: e)).toList(),
        borderWidth: isSelected ? 2.3 : 2,
      );
    }).toList();
  }

  List<RawDataSet> rawDataSets() {
    return [
      RawDataSet(
        title: 'You',
        color: widget.you,
        values: [
          200,
          150,
          50,
          75,
        ],
      ),
      RawDataSet(
        title: 'Average',
        color: widget.avg,
        values: [150, 200, 150, 90],
      ),
    ];
  }
}

class RawDataSet {
  RawDataSet({
    required this.title,
    required this.color,
    required this.values,
  });

  final String title;
  final Color color;
  final List<double> values;
}
