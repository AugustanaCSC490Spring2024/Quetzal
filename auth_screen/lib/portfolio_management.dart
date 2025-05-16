// This widget displays a portfolio graph with dynamic datasets based on the selected time range.
// The graph uses the fl_chart package. Detailed comments are provided to explain functionality.
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PortfolioManagementWidget extends StatefulWidget {
  const PortfolioManagementWidget({super.key});

  @override
  State<PortfolioManagementWidget> createState() =>
      PortfolioManagementWidgetState();
}

class PortfolioManagementWidgetState extends State<PortfolioManagementWidget> {
  // List of available time ranges to display.
  final List<String> timeRanges = ["Day", "Wk", "Mo", "3M", "YTD", "All"];
  // Index of the currently selected time range.
  int selectedIndex = 0;

  /// Returns dummy data (a map with a "spots" key containing list of FlSpot objects)
  /// depending on the currently selected time range.
  Map<String, List<FlSpot>> getData() {
    // Each case provides example data. In a real implementation, you would fetch
    // proper dataset based on user selection.
    switch (timeRanges[selectedIndex]) {
      case "Day":
        return {
          "spots": [
            const FlSpot(0, 100000),
            const FlSpot(1, 101000),
            const FlSpot(2, 102500),
            const FlSpot(3, 101500),
            const FlSpot(4, 103000),
            const FlSpot(5, 102000),
          ]
        };
      case "Wk":
        return {
          "spots": [
            const FlSpot(0, 100000),
            const FlSpot(1, 105000),
            const FlSpot(2, 103000),
            const FlSpot(3, 110000),
            const FlSpot(4, 108000),
            const FlSpot(5, 112000),
          ]
        };
      case "Mo":
        return {
          "spots": [
            const FlSpot(0, 100000),
            const FlSpot(1, 102000),
            const FlSpot(2, 104000),
            const FlSpot(3, 107000),
            const FlSpot(4, 111000),
            const FlSpot(5, 115000),
          ]
        };
      case "3M":
        return {
          "spots": [
            const FlSpot(0, 100000),
            const FlSpot(1, 104000),
            const FlSpot(2, 109000),
            const FlSpot(3, 113000),
            const FlSpot(4, 117000),
            const FlSpot(5, 120000),
          ]
        };
      case "YTD":
        return {
          "spots": [
            const FlSpot(0, 100000),
            const FlSpot(1, 106000),
            const FlSpot(2, 112000),
            const FlSpot(3, 118000),
            const FlSpot(4, 121000),
            const FlSpot(5, 125000),
          ]
        };
      case "All":
      default:
        return {
          "spots": [
            const FlSpot(0, 100000),
            const FlSpot(1, 105000),
            const FlSpot(2, 103000),
            const FlSpot(3, 110000),
            const FlSpot(4, 115000),
            const FlSpot(5, 112000),
            const FlSpot(6, 120000),
          ]
        };
    }
  }

  // Returns the maximum x-value from the current dataset.
  double get maxX {
    return getData()["spots"]!.last.x;
  }

  // Helper widget that builds the time range selector chips in a horizontal scroll view.
  Widget _buildTimeRangeSelector() {
    // Wrap in SingleChildScrollView to avoid overflow in small screens.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(timeRanges.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(timeRanges[index]),
              // Mark chip as selected based on the currently selected index.
              selected: selectedIndex == index,
              onSelected: (bool selected) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spots = getData()["spots"]!;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title for the portfolio management section.
          const Text(
            'Portfolio Management',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Display time range selector.
          _buildTimeRangeSelector(),
          const SizedBox(height: 20),
          // Dynamic graph showing portfolio progress based on selected time range.
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                // Titles configuration for axes.
                titlesData: FlTitlesData(
                  // Hide Y axis titles.
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  // Hide top axis titles.
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  // Build bottom axis labels; for simplicity, using index values.
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        // In a refined version, you could change the format here based on range.
                        String label = value.toInt().toString();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // No border box drawing.
                borderData: FlBorderData(show: false),
                // Line chart with below area effect.
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      // Use a custom dot painter for consistency.
                      getDotPainter: (FlSpot spot, double percent,
                          LineChartBarData bar, int index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blueAccent,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    // Create a gradient area below the line for visual appeal.
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent
                              .withAlpha(77), // Updated from withOpacity(0.3)
                          Colors.blueAccent
                              .withAlpha(0), // Updated from withOpacity(0.0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  )
                ],
                minX: 0,
                maxX: maxX,
                // Use fixed internal Y range; actual labels on Y axis are hidden.
                minY: 95000,
                maxY: 125000,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
