import 'dart:async';
import 'dart:convert';
import 'package:auth_screen/money.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class TradePage extends StatefulWidget {
  final String ticker;

  const TradePage({super.key, required this.ticker});

  @override
  TradePageState createState() => TradePageState();
}

class TradePageState extends State<TradePage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  bool tradeByQuantity = true;
  bool isLoading = false;
  Timer? _timer;
  double? currentStockPrice;

  @override
  void initState() {
    super.initState();
    // Initialize the timer to fetch the latest stock price every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchLatestStockPrice();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchLatestStockPrice() async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      bool marketOpen = isMarketOpen(now);

      String url = marketOpen
          ? 'https://api.polygon.io/v2/aggs/ticker/${widget.ticker}/range/1/minute/$formattedDate/$formattedDate?adjusted=true&sort=desc&limit=1&apiKey=hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym'
          : 'https://api.polygon.io/v2/aggs/ticker/${widget.ticker}/range/1/day/$formattedDate/$formattedDate?adjusted=true&sort=desc&limit=1&apiKey=hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            currentStockPrice = data['results'].first['c'];
          });
          updateEquityInPortfolio();
        } else {
          throw Exception('No stock data available for the given date range');
        }
      } else {
        throw Exception('Failed to fetch stock price: ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error fetching stock price: $error');
      await fetchPreviousDayStockPrice();
    }
  }

  Future<void> fetchPreviousDayStockPrice() async {
    try {
      DateTime now = DateTime.now();
      DateTime previousTradingDay = getPreviousTradingDay(now);

      String formattedDate = "${previousTradingDay.year}-${previousTradingDay.month.toString().padLeft(2, '0')}-${previousTradingDay.day.toString().padLeft(2, '0')}";

      String url = 'https://api.polygon.io/v2/aggs/ticker/${widget.ticker}/range/1/second/$formattedDate/$formattedDate?adjusted=true&sort=desc&limit=1&apiKey=hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          setState(() {
            currentStockPrice = data['results'].first['c'];
          });
          updateEquityInPortfolio();
        } else {
          throw Exception('No stock data available for the previous date');
        }
      } else {
        throw Exception('Failed to fetch stock price for the previous date: ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error fetching previous day stock price: $error');
    }
  }

  DateTime getPreviousTradingDay(DateTime now) {
    // Assuming market is closed on weekends (Saturday and Sunday)
    DateTime previousDay = now.subtract(const Duration(days: 1));

    if (previousDay.weekday == DateTime.sunday) {
      previousDay = previousDay.subtract(const Duration(days: 2)); // Move to Friday
    } else if (previousDay.weekday == DateTime.saturday) {
      previousDay = previousDay.subtract(const Duration(days: 1)); // Move to Friday
    }

    return previousDay;
  }

  bool isMarketOpen(DateTime now) {
    const marketOpenTime = TimeOfDay(hour: 9, minute: 30);
    const marketCloseTime = TimeOfDay(hour: 16, minute: 0);
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    return (currentTime.hour > marketOpenTime.hour ||
            (currentTime.hour == marketOpenTime.hour && currentTime.minute >= marketOpenTime.minute)) &&
        (currentTime.hour < marketCloseTime.hour ||
            (currentTime.hour == marketCloseTime.hour && currentTime.minute <= marketCloseTime.minute));
  }

  Future<void> updateEquityInPortfolio() async {
    if (currentStockPrice == null) return;

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      var portfolioDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .doc('details');
      var portfolioSnapshot = await portfolioDocRef.get();
      var portfolioData = portfolioSnapshot.data() ?? {};

      var stocks = portfolioData.containsKey('stocks') ? List<Map<String, dynamic>>.from(portfolioData['stocks']) : [];

      for (var stock in stocks) {
        if (stock['ticker'] == widget.ticker) {
          stock['equity'] = stock['quantity'] * currentStockPrice!;
        }
      }

      await portfolioDocRef.set({
        'stocks': stocks,
      }, SetOptions(merge: true));

    } catch (error) {
      logger.e('Error updating equity in portfolio: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trade ${widget.ticker}'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: true,
                        groupValue: tradeByQuantity,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              tradeByQuantity = value;
                              quantityController.clear();
                              priceController.clear();
                            });
                          }
                        },
                      ),
                      const Text('Trade by quantity'),
                      Radio(
                        value: false,
                        groupValue: tradeByQuantity,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              tradeByQuantity = value;
                              quantityController.clear();
                              priceController.clear();
                            });
                          }
                        },
                      ),
                      const Text('Trade by price'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  tradeByQuantity
                      ? TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Quantity',
                            border: OutlineInputBorder(),
                          ),
                        )
                      : TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Price',
                            border: OutlineInputBorder(),
                          ),
                        ),
                  const SizedBox(height: 20),
                  Text(
                    currentStockPrice != null
                        ? 'Current Stock Price: \$${currentStockPrice!.toStringAsFixed(2)}'
                        : 'Fetching current stock price...',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => handleTrade('Buying'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Buy'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => handleTrade('Selling'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Sell'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> handleTrade(String action) async {
    String quantity = quantityController.text.trim();
    String price = priceController.text.trim();

    if ((tradeByQuantity && quantity.isEmpty) || (!tradeByQuantity && price.isEmpty)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter either quantity or price')),
        );
      }
      return;
    }

    if (currentStockPrice == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fetching current stock price, please wait...')),
        );
      }
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      double stockPrice = currentStockPrice!;
      double totalCost = 0;
      double requestedShares = 0;

      if (tradeByQuantity) {
        requestedShares = double.parse(quantity);
        totalCost = stockPrice * requestedShares;
      } else {
        totalCost = double.parse(price);
        requestedShares = totalCost / stockPrice;
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;

      var portfolioDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('portfolio')
          .doc('details');
      var portfolioSnapshot = await portfolioDocRef.get();
      var portfolioData = portfolioSnapshot.data() ?? {};

      Money userFunds = Money(portfolioData.containsKey('money') ? portfolioData['money'] : 100000.0);

      var stocks = portfolioData.containsKey('stocks') ? List<Map<String, dynamic>>.from(portfolioData['stocks']) : [];
      var existingStockIndex = stocks.indexWhere((stock) => stock['ticker'] == widget.ticker);

      if (action == 'Buying') {
        if (!userFunds.hasEnough(totalCost)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Not enough funds to buy $requestedShares ${widget.ticker}')),
            );
          }
          return;
        }

        if (existingStockIndex != -1) {
          stocks[existingStockIndex]['quantity'] += requestedShares;
          stocks[existingStockIndex]['equity'] = stocks[existingStockIndex]['quantity'] * stockPrice;
        } else {
          stocks.add({'ticker': widget.ticker, 'quantity': requestedShares, 'equity': requestedShares * stockPrice});
        }

        userFunds.deduct(totalCost);

      } else if (action == 'Selling') {
        double parsedQuantity = requestedShares;
        if (existingStockIndex != -1 && stocks[existingStockIndex]['quantity'] >= parsedQuantity) {
          double earnings = stockPrice * parsedQuantity;

          stocks[existingStockIndex]['quantity'] -= parsedQuantity;
          if (stocks[existingStockIndex]['quantity'] == 0) {
            stocks.removeAt(existingStockIndex);
          } else {
            stocks[existingStockIndex]['equity'] = stocks[existingStockIndex]['quantity'] * stockPrice;
          }

          userFunds.add(earnings);

        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('You do not own enough ${widget.ticker} to sell')),
            );
          }
          return;
        }
      }

      await portfolioDocRef.set({
        'stocks': stocks,
        'money': userFunds.amount, // Correctly set the updated money value
        'points': portfolioData.containsKey('points') ? portfolioData['points'] : 0, // Initialize points if not exists
      }, SetOptions(merge: true));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${action == 'Buying' ? 'Bought' : 'Sold'} $requestedShares ${widget.ticker}')),
        );
      }

    } catch (error) {
      if (mounted) {
        logger.e('Error handling trade: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid input format')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
