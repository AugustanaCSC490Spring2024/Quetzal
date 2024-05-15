import 'dart:convert';
import 'package:auth_screen/money.dart';
import 'package:auth_screen/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class TradePage extends StatefulWidget {
  final String ticker;

  const TradePage({Key? key, required this.ticker}) : super(key: key);

  @override
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  bool tradeByQuantity = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trade ${widget.ticker}'),
      ),
      body: Center(
        child: Column(
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
                Text('Trade by quantity'),
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
                Text('Trade by price'),
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
            ElevatedButton(
              onPressed: () => handleTrade(context, 'Buying'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }

Future<void> handleTrade(BuildContext context, String action) async {
  String quantity = quantityController.text.trim();
  String price = priceController.text.trim();

  // Validate input
  if ((action == 'Buying' && quantity.isEmpty && price.isEmpty) || (action == 'Selling' && quantity.isEmpty)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter either quantity or price')),
    );
    return;
  }

  try {
    // Fetch current stock price
    final response = await http.get(Uri.parse('https://api.polygon.io/v2/aggs/ticker/${widget.ticker}/prev?unadjusted=true&apiKey=hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      double stockPrice = data['results'][0]['o']; // Fetch the open price

      double totalCost = 0;
      double requestedShares = 0;

      if (action == 'Buying') {
        if (tradeByQuantity) {
          requestedShares = double.parse(quantity);
          totalCost = stockPrice * requestedShares;
        } else {
          requestedShares = double.parse(price) / stockPrice;
          totalCost = double.parse(price);
        }
      } else if (action == 'Selling') {
        requestedShares = double.parse(quantity);
        totalCost = stockPrice * requestedShares;
      }

      String userId = FirebaseAuth.instance.currentUser!.uid;
      final currentUser = FirebaseAuth.instance.currentUser;

      var portfolioSnapshot = await FirebaseFirestore.instance.collection('portfolios').doc(userId).get();
      var portfolioData = portfolioSnapshot.data() ?? {};

      Money userFunds = Money(portfolioData.containsKey('money') ? portfolioData['money'] : 100000.0);

      if (action == 'Buying') {
        // Check if user has enough funds
        if (!userFunds.hasEnough(totalCost)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Not enough funds to buy $requestedShares ${widget.ticker}')),
          );
          return;
        }

        // Update user's portfolio to indicate that they bought the stock
        var stocks = portfolioData.containsKey('stocks') ? List<Map<String, dynamic>>.from(portfolioData['stocks']) : [];
        var existingStockIndex = stocks.indexWhere((stock) => stock['ticker'] == widget.ticker);
        if (existingStockIndex != -1) {
          stocks[existingStockIndex]['quantity'] += requestedShares.toInt();
        } else {
          stocks.add({'ticker': widget.ticker, 'quantity': requestedShares.toInt()});
        }

        // Deduct the cost from user's funds
        userFunds.deduct(totalCost);

        // Update user's portfolio in Firestore
        await FirebaseFirestore.instance.collection('portfolios').doc(userId).set({
          'stocks': stocks,
          'money': userFunds.starting_amount,
          'Name': currentUser?.displayName,
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bought $requestedShares ${widget.ticker}')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage())
        );
      } else if (action == 'Selling') {
        // Check if the user has the stock in their portfolio
        var stocks = portfolioData.containsKey('stocks') ? List<Map<String, dynamic>>.from(portfolioData['stocks']) : [];
        var existingStockIndex = stocks.indexWhere((stock) => stock['ticker'] == widget.ticker);
        int parsedQuantity = requestedShares.toInt();
        if (existingStockIndex != -1 && stocks[existingStockIndex]['quantity'] >= parsedQuantity) {
          // Calculate the earnings from selling
          double earnings = stockPrice * parsedQuantity;

          // Update user's portfolio to indicate that they sold the stock
          stocks[existingStockIndex]['quantity'] -= parsedQuantity;

          // Add the earnings to user's funds
          userFunds.add(earnings);

          // Update user's portfolio in Firestore
          await FirebaseFirestore.instance.collection('portfolios').doc(userId).set({
            'stocks': stocks,
            'money': userFunds.starting_amount,
          }, SetOptions(merge: true));

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sold $parsedQuantity ${widget.ticker}')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage())
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You do not own enough ${widget.ticker} to sell')),
          );
        }
      }
    } else {
      throw Exception('Failed to fetch stock price: ${response.statusCode}');
    }
  } catch (error) {
    print('Error handling trade: $error');
  }
}


}
