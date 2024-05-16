import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  const Speedrun({super.key});

  @override
  _SpeedrunState createState() => _SpeedrunState();
}

class _SpeedrunState extends State<Speedrun> {
  final List<String> ticker = [
    'MSFT', 'AAPL', 'NVDA', 'GOOG', 'AMZN', 'META', 'BRK.B', 'LLY', 'AVGO', 'V',
    'JPM', 'WMT', 'XOM', 'TSLA', 'UNH', 'MA', 'PG', 'JNJ', 'HD', 'MRK', 'COST',
    'ORCL', 'BAC', 'ABBV', 'CVX', 'CRM', 'KO', 'AMD', 'NFLX', 'PEP', 'TMO',
    'WFC', 'ADBE', 'DIS', 'MCD', 'CSCO', 'TMUS', 'ABT', 'DHR', 'CAT', 'QCOM',
    'INTU', 'GE', 'AXP', 'IBM', 'VZ', 'CMCSA', 'AMAT', 'NOW', 'TXN', 'COP',
    'MS', 'PM', 'PFE', 'INTC', 'UBER', 'AMGN', 'UNP', 'NKE', 'RTX', 'NEE',
    'SCHW', 'GS', 'SPGI', 'LOW', 'ISRG', 'HON', 'UPS', 'PGR', 'SYK', 'ELV',
    'MU', 'BKNG', 'T', 'C', 'LRCX', 'BLK', 'LMT', 'DE', 'TJX', 'VRTX', 'BA',
    'ADP', 'ABNB', 'CI', 'BSX', 'BMY', 'REGN', 'SBUX', 'MMC', 'PLD', 'MDLZ',
    'ADI', 'PANW', 'FI', 'BX', 'CVS', 'KLAC', 'KKR'
  ];
  final Random random = Random();
  late int randomIndex;
  late String selectedTicker;
  late double currentPrice;

  late Future<List<StockPoint>> stockDataFuture;
  List<FlSpot> displayedSpots = [];
  Timer? timer;
  int dataIndex = 0;
  late double chartHeight;

  double? buyPrice;
  bool hasBought = false;
  bool isVisualizationEnded = false;
  double points = 0;

  @override
  void initState() {
    super.initState();
    randomIndex = random.nextInt(ticker.length);
    selectedTicker = ticker[randomIndex];
    stockDataFuture = fetchStockData();
  }

  Future<List<StockPoint>> fetchStockData() async {
    String apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';
    String url =
        'https://api.polygon.io/v2/aggs/ticker/$selectedTicker/range/1/month/2019-01-01/2021-12-31?adjusted=true&apiKey=$apiKey';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<StockPoint> points = List<StockPoint>.from(
        data['results'].map((result) {
          return StockPoint.fromJson(result);
        }),
      );

      startDataTimer(points);
      return points;
    } else {
      if (kDebugMode) {
        print('Failed to load stock data: ${response.body}');
      }
      throw Exception('Failed to load stock data');
    }
  }

  void startDataTimer(List<StockPoint> points) {
    isVisualizationEnded = false;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (dataIndex < points.length) {
        setState(() {
          if (displayedSpots.length > 5) {
            displayedSpots.removeAt(0);
          }
          displayedSpots.add(
            FlSpot(
              points[dataIndex].time.toDouble(),
              points[dataIndex].close,
            ),
          );
          currentPrice = points[dataIndex].close;
          dataIndex++;
        });
      } else {
        timer.cancel();
        endGame();
      }
    });
  }

  void endGame() {
    isVisualizationEnded = true;
    if (hasBought) {
      showSnackBar("The visualization has ended. You can no longer trade.");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void handleBuy() {
    if (isVisualizationEnded) {
      showSnackBar("You cannot buy after the visualization has ended.");
      return;
    }
    if (!hasBought) {
      buyPrice = currentPrice;
      hasBought = true;
      showSnackBar("Bought at \$${currentPrice.toStringAsFixed(2)} for $selectedTicker");
    } else {
      showSnackBar("You have already bought $selectedTicker at \$${buyPrice!.toStringAsFixed(2)}.");
    }
  }

  void handleSell() {
    if (isVisualizationEnded) {
      showSnackBar("You cannot sell after the visualization has ended.");
      return;
    }
    if (hasBought) {
      double sellPrice = currentPrice;
      double profit = sellPrice - buyPrice!;
      points += profit / 10;
      hasBought = false;
      showSnackBar(
          "Sold at \$${sellPrice.toStringAsFixed(2)} for $selectedTicker. ${profit >= 0 ? 'Profit' : 'Loss'}: \$${profit.toStringAsFixed(2)}");
    } else {
      showSnackBar("You need to buy $selectedTicker first.");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    chartHeight = MediaQuery.of(context).size.height / 3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpeedRun'),
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
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: chartHeight,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: displayedSpots,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        selectedTicker,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: handleBuy,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Buy'),
                      ),
                      ElevatedButton(
                        onPressed: handleSell,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Sell'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Points: ${points.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
