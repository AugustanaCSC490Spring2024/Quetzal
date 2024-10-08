//used chatgpt for some help and to debug this code 
// ignore_for_file: unnecessary_brace_in_string_interps, avoid_types_as_parameter_names

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

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
  SpeedrunState createState() => SpeedrunState();
}

class SpeedrunState extends State<Speedrun> {
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

  List<double> buyPrices = [];
  int totalBuys = 0;
  int maxBuys = 5;
  bool isVisualizationEnded = false;
  double gpoints = 0;

  @override
  void initState() {
    super.initState();
    randomIndex = random.nextInt(ticker.length);
    selectedTicker = ticker[randomIndex];
    stockDataFuture = Future.value([]); // Placeholder future
    // Show the instructions popup when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionsPopup();
    });
  }

  void _showInstructionsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Speedrun Game Instructions'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('1. You can buy a stock up to 5 times.'),
                Text('2. You can sell all your positions at once.'),
                Text('3. Try to maximize your profit.'),
                Text('4. You cannot trade after the visualization ends.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Play'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  stockDataFuture = fetchStockData(); // Start fetching stock data when the user clicks "Play"
                });
              },
            ),
          ],
        );
      },
    );
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
      logger.e('Failed to load stock data: ${response.body}');
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
    if (buyPrices.isNotEmpty) {
      showSnackBar("The visualization has ended. You can no longer trade.");
    }
    updateUserPointsInFirebase();
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void handleBuy() {
    if (isVisualizationEnded) {
      showSnackBar("You cannot buy after the visualization has ended.");
      return;
    }
    if (totalBuys < maxBuys) {
      buyPrices.add(currentPrice);
      totalBuys++;
      showSnackBar("Bought at \$${currentPrice.toStringAsFixed(2)} for $selectedTicker (${totalBuys}/$maxBuys)");
    } else {
      showSnackBar("You have reached the maximum number of buys.");
    }
  }

  void handleSell() {
    if (isVisualizationEnded) {
      showSnackBar("You cannot sell after the visualization has ended.");
      return;
    }
    if (buyPrices.isNotEmpty) {
      double sellPrice = currentPrice;
      double totalProfit = buyPrices.fold(0, (sum, buyPrice) => sum + (sellPrice - buyPrice));
      gpoints += totalProfit / 10;
      buyPrices.clear();
      showSnackBar(
          "Sold all positions at \$${sellPrice.toStringAsFixed(2)} for $selectedTicker. Total ${totalProfit >= 0 ? 'Profit' : 'Loss'}: \$${totalProfit.toStringAsFixed(2)}");
      addProfitToUserMoney(totalProfit);
    } else {
      showSnackBar("You need to buy $selectedTicker first.");
    }
  }

  Future<void> addProfitToUserMoney(double profit) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference portfolioDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('portfolio')
          .doc('details');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(portfolioDocRef);
        if (snapshot.exists) {
          double currentMoney = (snapshot.get('money') ?? 0).toDouble();
          double newMoney = currentMoney + profit;
          logger.i('Current money: $currentMoney, New money: $newMoney');
          transaction.update(portfolioDocRef, {'money': newMoney});
        } else {
          logger.w('Document does not exist.');
        }
      }).then((_) {
        logger.i('Money updated successfully');
        showSnackBar("Money updated in Firebase: ${profit.toStringAsFixed(2)}");
      }).catchError((error) {
        logger.e('Transaction failed: $error');
        showSnackBar("Failed to update money in Firebase.");
      });
    } else {
      showSnackBar("User not logged in.");
    }
  }

  Future<void> updateUserPointsInFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference portfolioDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('portfolio')
          .doc('details');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(portfolioDocRef);
        if (snapshot.exists) {
          double currentPoints = (snapshot.get('points') ?? 0).toDouble();
          double newPoints = currentPoints + gpoints;
          logger.i('Current points: $currentPoints, New points: $newPoints');
          transaction.update(portfolioDocRef, {'points': newPoints});
        } else {
          logger.w('Document does not exist.');
        }
      }).then((_) {
        logger.i('Points updated successfully');
        showSnackBar("Points updated in Firebase: ${gpoints.toStringAsFixed(2)}");
      }).catchError((error) {
        logger.e('Transaction failed: $error');
        showSnackBar("Failed to update points in Firebase.");
      });
    } else {
      showSnackBar("User not logged in.");
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

            if (displayedSpots.isEmpty) {
              return const Center(child: CircularProgressIndicator());
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
                    'Points: ${gpoints.toStringAsFixed(2)}',
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
