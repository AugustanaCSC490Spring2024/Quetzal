import 'package:flutter/material.dart';

class TradePage extends StatelessWidget {
  final String ticker;

  const TradePage({Key? key, required this.ticker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController quantityController = TextEditingController();

    void _handleTrade(BuildContext context, String action) {
      String quantity = quantityController.text.trim();

      if (quantity.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a quantity')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$action $ticker x $quantity')),
      );

      // You can implement your buy/sell logic here
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
                backgroundColor: Colors.green, // Set the button background color to green
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _handleTrade(context, 'Selling'),
              child: Text('Sell'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Set the button background color to red
              ),
            ),
          ],
        ),
      ),
    );
  }
}
