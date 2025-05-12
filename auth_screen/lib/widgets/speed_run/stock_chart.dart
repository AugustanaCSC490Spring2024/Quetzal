import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StockChart extends StatelessWidget {
  final List<FlSpot> displayedSpots;
  final bool isPriceIncreasing;
  final double chartHeight;

  const StockChart({
    super.key,
    required this.displayedSpots,
    required this.isPriceIncreasing,
    required this.chartHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: chartHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          minY: _getMinY(),
          maxY: _getMaxY(),
          minX: _getMinX(),
          maxX: _getMaxX(),
          clipData: FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: const FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: displayedSpots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: isPriceIncreasing ? Colors.green : Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              preventCurveOverShooting: true,
              belowBarData: BarAreaData(
                show: true,
                color: (isPriceIncreasing ? Colors.green : Colors.red)
                    .withOpacity(0.2),
                cutOffY: _getMinY(),
                applyCutOffY: true,
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  if (index == displayedSpots.length - 1) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: isPriceIncreasing ? Colors.green : Colors.red,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                    strokeWidth: 0,
                    strokeColor: Colors.transparent,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Calculate minimum Y value for chart with some padding
  double _getMinY() {
    if (displayedSpots.isEmpty) return 0;
    double minValue = displayedSpots.map((spot) => spot.y).reduce(min);
    // Add 5% padding below the minimum
    return minValue * 0.95;
  }

  // Calculate maximum Y value for chart with some padding
  double _getMaxY() {
    if (displayedSpots.isEmpty) return 100;
    double maxValue = displayedSpots.map((spot) => spot.y).reduce(max);
    // Add 5% padding above the maximum
    return maxValue * 1.05;
  }

  // Calculate minimum X value for chart
  double _getMinX() {
    if (displayedSpots.isEmpty) return 0;
    return 0; // Always start at 0 since we're using sequential indices
  }

  // Calculate maximum X value for chart
  double _getMaxX() {
    if (displayedSpots.isEmpty) return 10; // Default value for empty chart
    return displayedSpots.length - 1.0; // Use the last index as max X
  }
}
