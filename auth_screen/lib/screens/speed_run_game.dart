import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class Speedrun extends StatefulWidget {
  @override
  _SpeedrunState createState() => _SpeedrunState();
}

class _SpeedrunState extends State<Speedrun> {
  late Future<List<StockPoint>> stockDataFuture;
  List<FlSpot> displayedSpots = [];
  Timer? timer;
  int dataIndex = 0; // Index of the next data point to display

  @override
  void initState() {
    super.initState();
    stockDataFuture = fetchStockData();
  }

  Future<List<StockPoint>> fetchStockData() async {
    String apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym'; // Use your actual API key
    String url = 'https://api.polygon.io/v2/aggs/ticker/AAPL/range/1/month/2019-01-01/2024-12-31?adjusted=true&apiKey=$apiKey';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<StockPoint> points = List<StockPoint>.from(data['results'].map((result) {
        return StockPoint.fromJson(result);
      }));

      // Schedule the timer to update the chart at regular intervals
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (dataIndex < points.length) {
          setState(() {
            displayedSpots.add(FlSpot(
              points[dataIndex].time.toDouble(),
              points[dataIndex].close,
            ));
            dataIndex++;
          });
        } else {
          timer.cancel(); // All points have been plotted, no need for the timer anymore.
        }
      });

      return points;
    } else {
      print('Failed to load stock data: ${response.body}');
      throw Exception('Failed to load stock data');
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AAPL Stock Data'),
      ),
      body: FutureBuilder<List<StockPoint>>(
        future: stockDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: displayedSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
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
