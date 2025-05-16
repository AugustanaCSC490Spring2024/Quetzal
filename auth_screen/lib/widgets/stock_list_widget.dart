import 'package:flutter/material.dart';
import 'package:auth_screen/screens/stocks_detail_page.dart';
import 'package:auth_screen/trading_stock_handller.dart';
import 'package:auth_screen/api/api_module.dart'; // Updated import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class StockListWidget extends StatefulWidget {
  const StockListWidget({super.key});

  @override
  State<StockListWidget> createState() => _StockListWidgetState();
}

class _StockListWidgetState extends State<StockListWidget> {
  final ApiModule _api =
      ApiModule(); // Use API module instead of direct service

  @override
  void dispose() {
    _api.dispose(); // Clean up resources
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('portfolio')
          .doc('details')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorCard(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
            ),
          );
        }

        var portfolioData =
            (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        List<Map<String, dynamic>> userStocks =
            portfolioData.containsKey('stocks')
                ? List<Map<String, dynamic>>.from(portfolioData['stocks'])
                : [];

        if (userStocks.isEmpty) {
          return _buildEmptyStockCard();
        }

        // Schedule price updates for all stocks
        _api.stockService.schedulePriceUpdates(userStocks);

        return _buildStockList(userStocks);
      },
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 1,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildEmptyStockCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.info_outline,
                  size: 40, color: Colors.blueAccent),
              const SizedBox(height: 12),
              Text(
                'No stocks in your portfolio yet',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockList(List<Map<String, dynamic>> userStocks) {
    return ValueListenableBuilder<Map<String, double>>(
      valueListenable: _api.stockService.pricesNotifier,
      builder: (context, latestPrices, _) {
        return ValueListenableBuilder<Map<String, Color>>(
          valueListenable: _api.stockService.colorsNotifier,
          builder: (context, priceColors, _) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userStocks.length,
              itemBuilder: (context, index) {
                final stock = userStocks[index];
                final ticker = stock['ticker'];
                final hasLatestPrice = latestPrices.containsKey(ticker);
                final latestPrice =
                    hasLatestPrice ? latestPrices[ticker]! : 0.0;
                final Color priceColor = priceColors[ticker] ?? Colors.grey;
                final bool isRealPrice = stock['isRealPrice'] ?? false;

                return StockCard(
                  stock: stock,
                  ticker: ticker,
                  hasLatestPrice: hasLatestPrice,
                  latestPrice: latestPrice,
                  priceColor: priceColor,
                  isRealPrice: isRealPrice,
                );
              },
            );
          },
        );
      },
    );
  }
}

class StockCard extends StatelessWidget {
  final Map<String, dynamic> stock;
  final String ticker;
  final bool hasLatestPrice;
  final double latestPrice;
  final Color priceColor;
  final bool isRealPrice; // Add this field

  const StockCard({
    super.key,
    required this.stock,
    required this.ticker,
    required this.hasLatestPrice,
    required this.latestPrice,
    required this.priceColor,
    required this.isRealPrice,
  });

  @override
  Widget build(BuildContext context) {
    final stockQuantity = stock['quantity'].toDouble();
    final stockEquity = stock['equity'].toDouble();
    final latestEquity =
        hasLatestPrice ? latestPrice * stockQuantity : stockEquity;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StockDetailsPage(ticker: ticker)),
          );
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.green
                        .withAlpha(26), // Changed from withOpacity(0.1)
                    child: Text(
                      ticker.substring(0, 1),
                      style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticker,
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (hasLatestPrice)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Market Price',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 10,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '\$${latestPrice.toStringAsFixed(2)}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: priceColor,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Shares: ${stockQuantity.toStringAsFixed(2)}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Value: ',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '\$${latestEquity.toStringAsFixed(2)}',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: hasLatestPrice
                                    ? priceColor
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TradePage(ticker: ticker)),
                      );
                      if (result == 'updated') {
                        // The list will refresh automatically due to StreamBuilder
                      }
                    },
                    icon: const Icon(Icons.trending_up, size: 18),
                    label: const Text('Trade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            if (hasLatestPrice)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRealPrice
                        ? Colors.green
                            .withAlpha(51) // Changed from withOpacity(0.2)
                        : Colors.grey
                            .withAlpha(51), // Changed from withOpacity(0.2)
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isRealPrice ? "LIVE" : "EST",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isRealPrice ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
