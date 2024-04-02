import 'package:auth_screen/trading_stock_handller.dart';
import 'package:flutter/material.dart';

class BuyingStockInfoPage extends StatelessWidget {
  final String ticker;

  const BuyingStockInfoPage({Key? key, required this.ticker}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Information for $ticker', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20), 
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _handleTrade(context, ticker);
                },
                child: Text('Trade'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                  textStyle: TextStyle(fontSize: 18),
                ),
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


