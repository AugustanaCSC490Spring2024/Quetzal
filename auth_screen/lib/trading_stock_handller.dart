import 'dart:convert';
import 'package:auth_screen/money.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class TradePage extends StatelessWidget {
  final String ticker;

  const TradePage({Key? key, required this.ticker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController quantityController = TextEditingController();

    Future<void> _handleTrade(BuildContext context, String action) async {
      String quantity = quantityController.text.trim();

      if (quantity.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a quantity')),
        );
        return;
      }

      try {
        final response = await http.get(Uri.parse('https://api.polygon.io/v2/aggs/ticker/$ticker/prev?unadjusted=true&apiKey=K2C82obyi9y7AG7GOND0JTRt_j52UB4P'));
        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          double stockPrice = data['results'][0]['o']; // Fetch the open price
          double totalCost = stockPrice * double.parse(quantity);

          String userId = FirebaseAuth.instance.currentUser!.uid;

          var portfolioSnapshot = await FirebaseFirestore.instance.collection('portfolios').doc(userId).get();
          var portfolioData = portfolioSnapshot.data() ?? {};

          // Initialize user's funds using Money class, they start with 1000000
          Money userFunds = Money(portfolioData.containsKey('money') ? portfolioData['money'] : 1000000);

          if (action == 'Buying') {
            // Calculate the cost of buying
            if (!userFunds.hasEnough(totalCost)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Not enough funds to buy $quantity $ticker')),
              );
              return;
            }

            // Update user's portfolio to indicate that they bought the stock
            var stocks = portfolioData.containsKey('stocks') ? List<Map<String, dynamic>>.from(portfolioData['stocks']) : [];
            var existingStockIndex = stocks.indexWhere((stock) => stock['ticker'] == ticker);
            if (existingStockIndex != -1) {
              stocks[existingStockIndex]['quantity'] += int.parse(quantity);
            } else {
              stocks.add({'ticker': ticker, 'quantity': int.parse(quantity)});
            }

            // Deduct the cost from user's funds
            userFunds.deduct(totalCost);

            // Update user's portfolio in Firestore
            await FirebaseFirestore.instance.collection('portfolios').doc(userId).set({
              'stocks': stocks,
              'money': userFunds.starting_amount,
            }, SetOptions(merge: true));

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Bought $quantity $ticker')),
            );
          } else if (action == 'Selling') {
            // Check if the user has the stock in their portfolio
            var stocks = portfolioData.containsKey('stocks') ? List<Map<String, dynamic>>.from(portfolioData['stocks']) : [];
            var existingStockIndex = stocks.indexWhere((stock) => stock['ticker'] == ticker);
            if (existingStockIndex != -1 && stocks[existingStockIndex]['quantity'] >= int.parse(quantity)) {
              // Calculate the earnings from selling
              double earnings = stockPrice * int.parse(quantity);

              // Update user's portfolio to indicate that they sold the stock
              stocks[existingStockIndex]['quantity'] -= int.parse(quantity);

              // Add the earnings to user's funds
              userFunds.add(earnings);

              // Update user's portfolio in Firestore
              await FirebaseFirestore.instance.collection('portfolios').doc(userId).set({
                'stocks': stocks,
                'money': userFunds.starting_amount,
              }, SetOptions(merge: true));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sold $quantity $ticker')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You do not own enough $ticker to sell')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Trade $ticker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter quantity to trade:'),
            SizedBox(height: 20),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleTrade(context, 'Buying'),
              child: Text('Buy'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _handleTrade(context, 'Selling'),
              child: Text('Sell'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
