import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math';

// Model for storing stock data points
class StockPoint {
  final double close;
  final int time;

  StockPoint({required this.close, required this.time});

  factory StockPoint.fromJson(Map<String, dynamic> json) {
    return StockPoint(
      close: json['c'].toDouble(),
      time: json['t'],
    );
  }
}

// Widget to fetch and display line chart
class Speedrun extends StatefulWidget {
  @override
  _SpeedrunState createState() => _SpeedrunState();
}

class _SpeedrunState extends State<Speedrun> {
  late Future<List<StockPoint>> stockData;

  @override
  void initState() {
    super.initState();
    stockData = fetchStockData();
  }

  Future<List<StockPoint>> fetchStockData() async {
    String apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym'; // Make sure to use your own API key
    String url = 'https://api.polygon.io/v2/aggs/ticker/AAPL/range/1/month/2020-01-09/2024-01-09?adjusted=true&apiKey=$apiKey';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<StockPoint> points = [];
      for (var result in data['results']) {
        points.add(StockPoint.fromJson(result));
      }
      return points;
    } else {
      print('Failed to load stock data: ${response.body}');
      throw Exception('Failed to load stock data');
    }
  }

  @override //chatgpt
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AAPL Stock Data'),
      ),
      body: FutureBuilder<List<StockPoint>>(
        future: stockData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final List<FlSpot> spots = snapshot.data!
                .map((e) => FlSpot(
                      e.time.toDouble(),
                      e.close,
                    ))
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                          final String dateString = DateFormat('MM/dd').format(date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(dateString, style: TextStyle(color: Colors.grey, fontSize: 10)),
                          );
                        },
                        interval: 1, // You may want to adjust this interval based on your data range and density
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('\$${value.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey, fontSize: 10));
                        },
                        interval: 10, // Adjust the interval to control how many y-axis labels you want to show
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color:Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  minX: spots.first.x,
                  maxX: spots.last.x,
                  minY: spots.map((spot) => spot.y).reduce(min),
                  maxY: spots.map((spot) => spot.y).reduce(max),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
