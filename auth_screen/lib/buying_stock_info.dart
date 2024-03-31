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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    

                    
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Bought $ticker'),
                    ));
                  },
                  child: Text('Buy'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.green, 
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    


                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Sold $ticker'),
                    ));
                  },
                  child: Text('Sell'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.red, 
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
