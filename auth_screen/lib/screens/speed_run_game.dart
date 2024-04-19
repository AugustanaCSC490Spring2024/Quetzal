import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:math';

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
  late Future<List<StockPoint>> stockData;

  @override
  void initState() {
    super.initState();
    stockData = fetchStockData();
  }

  Future<List<StockPoint>> fetchStockData() async {
    String apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';  // Use your actual API key
    String url = 'https://api.polygon.io/v2/aggs/ticker/AAPL/range/1/month/2019-01-01/2019-12-31?adjusted=true&apiKey=$apiKey';
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

@override
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

          spots.sort((a, b) => a.x.compareTo(b.x));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: false,
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color:Colors.blue,
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
