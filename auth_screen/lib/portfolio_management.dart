// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class PortfolioManagementWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Portfolio Management',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          // need to add stuff here 
        ],
      ),
    );
  }
}
