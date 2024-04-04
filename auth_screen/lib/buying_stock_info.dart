import 'package:auth_screen/trading_stock_handller.dart';
import 'package:flutter/material.dart';

class BuyingStockInfoPage extends StatelessWidget {
  final String ticker;

  const BuyingStockInfoPage({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Information for $ticker', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20), 
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _handleTrade(context, ticker);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Trade'),
              ),
            ),
          ],
        ),
      ),
    );
  }

void _handleTrade(BuildContext context, String ticker) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TradePage(ticker: ticker),
    ),
  );
}
}


