import 'dart:async';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:flutter/material.dart';
import 'dart:math';

class TestLiveStockChart extends StatefulWidget {
  final String ticker;
  final double userStockPrice;

  const TestLiveStockChart({
    required this.ticker,
    required this.userStockPrice,
  });

  @override
  _TestLiveStockChartState createState() => _TestLiveStockChartState();
}

class _TestLiveStockChartState extends State<TestLiveStockChart> {
  List<FlSpot> _spots = [];
  bool _isLoading = true;
  late Timer _timer;
  final Random _random = Random();
  double _lastXValue = 0;

  @override
  void initState() {
    super.initState();
    _generateSimulatedData();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) { 
      _generateSimulatedData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _generateSimulatedData() {
    setState(() {
      _lastXValue += 1;
      double simulatedPrice = widget.userStockPrice + _random.nextDouble() * 10 - 5;
      _spots.add(FlSpot(_lastXValue, simulatedPrice));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Set a fixed height to avoid layout issues
      padding: EdgeInsets.all(16), // Add padding to prevent cut-off
      child: _isLoading
          ? const CircularProgressIndicator()
          : LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: Colors.red,
                        strokeWidth: 2,
                        strokeColor: Colors.red,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: [
                      if (_spots.isNotEmpty)
                        FlSpot(
                          _spots.last.x,
                          widget.userStockPrice,
                        ),
                    ],
                    isCurved: false,
                    color: Colors.green,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 5,
                        color: Colors.green,
                        strokeWidth: 2,
                        strokeColor: Colors.green,
                      ),
                    ),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        String text;
                        if (value >= 1000) {
                          text = (value / 1000).toStringAsFixed(1) + 'K';
                        } else {
                          text = value.toString();
                        }
                        return Text(
                          text,
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true),
              ),
            ),
    );
  }
}
