import 'package:flutter/material.dart';

class BuyingStockInfoPage extends StatelessWidget {
  final String ticker;

  const BuyingStockInfoPage({Key? key, required this.ticker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Implement your UI to display information about the selected stock ticker
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Information'),
      ),
      body: Center(
        child: Text('Information for $ticker'),
      ),
    );
  }
}
