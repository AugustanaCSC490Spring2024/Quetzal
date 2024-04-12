
import 'package:flutter/material.dart';

class StockDetailsPage extends StatelessWidget {
  final String ticker;

  const StockDetailsPage({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details - $ticker'),
      ),
      body: Center(
        child: Text('Details of stock $ticker'),
      ),
    );
  }
}