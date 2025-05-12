import 'package:flutter/material.dart';

class PriceCard extends StatelessWidget {
  final String ticker;
  final double currentPrice;
  final Color priceColor;
  final bool isPriceIncreasing;
  final double? previousPrice;
  final Animation<double> animation;

  const PriceCard({
    super.key,
    required this.ticker,
    required this.currentPrice,
    required this.priceColor,
    required this.isPriceIncreasing,
    this.previousPrice,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25), // Updated from withOpacity(0.1)
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticker,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Current Price',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (previousPrice != null && previousPrice! != currentPrice)
                Icon(
                  isPriceIncreasing ? Icons.arrow_upward : Icons.arrow_downward,
                  color: priceColor,
                  size: 16 + (animation.value * 4),
                ),
              const SizedBox(width: 4),
              Text(
                '\$${currentPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 24 + (animation.value * 2),
                  fontWeight: FontWeight.bold,
                  color: priceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
