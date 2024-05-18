import 'dart:convert';
import 'package:auth_screen/money.dart';
import 'package:auth_screen/screens/home_screen.dart';
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

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://api.polygon.io/v2/aggs/ticker/${widget.ticker}/prev?unadjusted=true&apiKey=hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym'));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        double stockPrice = data['results'][0]['o'];

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
        final currentUser = FirebaseAuth.instance.currentUser;

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
          'money': userFunds.starting_amount,
          'Name': currentUser?.displayName,
          'points': portfolioData.containsKey('points') ? portfolioData['points'] : 0, // Initialize points if not exists
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${action == 'Buying' ? 'Bought' : 'Sold'} $requestedShares ${widget.ticker}')),
          );
        }

      } else {
        throw Exception('Failed to fetch stock price: ${response.statusCode}');
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
