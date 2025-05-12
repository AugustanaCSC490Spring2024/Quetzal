//used chatgpt for some help and to debug this code
import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/models/stock_point.dart';
import 'package:auth_screen/services/stock_data_service.dart';
import 'package:auth_screen/services/trading_service.dart';

import 'package:auth_screen/widgets/speed_run/instruction_item.dart';
import 'package:auth_screen/widgets/speed_run/price_card.dart';
import 'package:auth_screen/widgets/speed_run/stock_chart.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class Speedrun extends StatefulWidget {
  const Speedrun({super.key});

  @override
  SpeedrunState createState() => SpeedrunState();
}

class SpeedrunState extends State<Speedrun>
    with SingleTickerProviderStateMixin {
  final List<String> ticker = [
    'MSFT', 'AAPL', 'NVDA', 'GOOG', 'AMZN', 'META', 'BRK.B', 'LLY',
    // ...existing code... (ticker list shortened for brevity)
  ];

  final Random random = Random();
  final StockDataService _stockDataService = StockDataService();
  final TradingService _tradingService = TradingService();

  late int randomIndex;
  late String selectedTicker;
  late double currentPrice;
  late double chartHeight;
  late AnimationController _animationController;

  // Game state variables
  late Future<List<StockPoint>> stockDataFuture;
  List<FlSpot> displayedSpots = [];
  List<double> buyPrices = [];
  List<Map<String, dynamic>> tradeHistory = [];
  Timer? timer;
  int dataIndex = 0;
  int totalBuys = 0;
  int maxBuys = 5;
  double gpoints = 0;
  bool isVisualizationEnded = false;
  bool isPriceIncreasing = false;
  double? previousPrice;
  Color priceColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    randomIndex = random.nextInt(ticker.length);
    selectedTicker = ticker[randomIndex];
    stockDataFuture = Future.value([]);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructionsPopup();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _showInstructionsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withAlpha(51), // Updated from withOpacity(0.2)
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3A5199),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.speed, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SpeedRun Trading Challenge',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF3A5199),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      InstructionItem(
                        icon: Icons.shopping_cart,
                        text: 'Buy up to 5 times at different prices',
                      ),
                      SizedBox(height: 10),
                      InstructionItem(
                        icon: Icons.sell,
                        text: 'Sell all positions at once for maximum profit',
                      ),
                      SizedBox(height: 10),
                      InstructionItem(
                        icon: Icons.timer,
                        text: 'Trading stops when the chart completes',
                      ),
                      SizedBox(height: 10),
                      InstructionItem(
                        icon: Icons.trending_up,
                        text: 'Earn more points with better trading decisions',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      stockDataFuture =
                          _stockDataService.fetchStockData(selectedTicker);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A5199),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'START TRADING',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void startDataTimer(List<StockPoint> points) {
    // Ensure we have at least 5 points to make the game playable
    if (points.length < 5) {
      // Using post-frame callback to fix the SnackBar during build error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showSnackBar(
              "Not enough market data available. Generating simulation...");
        }
      });
      points = _stockDataService.generateSimulatedData();
    }

    isVisualizationEnded = false;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (dataIndex < points.length) {
        setState(() {
          // Generate a sequential x-value (0, 1, 2, ...)
          double xValue = dataIndex.toDouble();
          displayedSpots.add(FlSpot(xValue, points[dataIndex].close));

          // Remove older spots if needed, but keep enough for nice visualization
          if (displayedSpots.length > 10) {
            displayedSpots.removeAt(0);

            // Normalize x values after removing the first spot
            for (int i = 0; i < displayedSpots.length; i++) {
              displayedSpots[i] = FlSpot(i.toDouble(), displayedSpots[i].y);
            }
          }

          // Update price color based on previous price
          if (previousPrice != null) {
            if (points[dataIndex].close > previousPrice!) {
              priceColor = Colors.green;
              isPriceIncreasing = true;
            } else if (points[dataIndex].close < previousPrice!) {
              priceColor = Colors.red;
              isPriceIncreasing = false;
            }
            _animationController.reset();
            _animationController.forward();
          }

          previousPrice = points[dataIndex].close;
          currentPrice = points[dataIndex].close;
          dataIndex++;
        });
      } else {
        timer.cancel();
        endGame();
      }
    });
  }

  void endGame() {
    if (isVisualizationEnded) return; // Prevent multiple calls

    isVisualizationEnded = true;

    // Only update Firebase if points were earned
    if (gpoints > 0) {
      _updateUserPoints();
    }

    // Only show result dialog if we're still mounted
    if (mounted) {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    // Check if player actually made any trades before showing results
    if (tradeHistory.isEmpty) {
      // If no trades were made, show a different message
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(51),
                    spreadRadius: 5,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Trades Made',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You didn\'t make any trades this round.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Give option to restart the game
                        _restartGame();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A5199),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'TRY AGAIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    // For trades that were made
    bool madeProfit = gpoints > 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withAlpha(51), // Updated from withOpacity(0.2)
                  spreadRadius: 5,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        madeProfit ? Colors.green.shade50 : Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    madeProfit ? Icons.emoji_events : Icons.trending_down,
                    size: 60,
                    color: madeProfit ? Colors.amber : Colors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  madeProfit ? 'Trading Success!' : 'Better Luck Next Time',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: madeProfit ? Colors.green : Colors.redAccent,
                  ),
                ),
                // ...existing code... (result dialog content)
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A5199),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                message.contains('Bought')
                    ? Icons.shopping_cart
                    : message.contains('Sold')
                        ? Icons.trending_up
                        : Icons.info_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: message.contains('Bought')
              ? Colors.green
              : message.contains('Sold')
                  ? Colors.blue
                  : null,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void handleBuy() {
    if (isVisualizationEnded) {
      showSnackBar("You cannot buy after the visualization has ended.");
      return;
    }
    if (totalBuys < maxBuys) {
      buyPrices.add(currentPrice);
      totalBuys++;

      // Add to trade history
      tradeHistory.add({
        'type': 'buy',
        'price': currentPrice,
        'time': DateTime.now().millisecondsSinceEpoch,
      });

      showSnackBar(
          "Bought at \$${currentPrice.toStringAsFixed(2)} for $selectedTicker (${totalBuys}/$maxBuys)");
    } else {
      showSnackBar("You have reached the maximum number of buys.");
    }
  }

  void handleSell() {
    if (isVisualizationEnded) {
      showSnackBar("You cannot sell after the visualization has ended.");
      return;
    }
    if (buyPrices.isNotEmpty) {
      double sellPrice = currentPrice;
      double totalProfit =
          buyPrices.fold(0, (sum, buyPrice) => sum + (sellPrice - buyPrice));
      double pointsGained = totalProfit / 10;
      gpoints += pointsGained;

      // Add to trade history
      tradeHistory.add({
        'type': 'sell',
        'price': sellPrice,
        'profit': totalProfit,
        'time': DateTime.now().millisecondsSinceEpoch,
      });

      buyPrices.clear();
      showSnackBar(
          "Sold all positions at \$${sellPrice.toStringAsFixed(2)}. Total ${totalProfit >= 0 ? 'Profit' : 'Loss'}: \$${totalProfit.toStringAsFixed(2)}");
      _addProfitToUserMoney(totalProfit);
    } else {
      showSnackBar("You need to buy $selectedTicker first.");
    }
  }

  Future<void> _addProfitToUserMoney(double profit) async {
    try {
      await _tradingService.updateMoney(profit);
      showSnackBar("Money updated in Firebase: ${profit.toStringAsFixed(2)}");
    } catch (error) {
      logger.e('Transaction failed: $error');
      showSnackBar("Failed to update money in Firebase.");
    }
  }

  Future<void> _updateUserPoints() async {
    try {
      await _tradingService.updatePoints(gpoints);
      showSnackBar("Points updated in Firebase: ${gpoints.toStringAsFixed(2)}");
    } catch (error) {
      logger.e('Transaction failed: $error');
      showSnackBar("Failed to update points in Firebase.");
    }
  }

  void _restartGame() {
    setState(() {
      // Reset all game state variables
      randomIndex = random.nextInt(ticker.length);
      selectedTicker = ticker[randomIndex];
      stockDataFuture = _stockDataService.fetchStockData(selectedTicker);
      displayedSpots = [];
      buyPrices = [];
      tradeHistory = [];
      dataIndex = 0;
      totalBuys = 0;
      gpoints = 0;
      isVisualizationEnded = false;
      previousPrice = null;
      priceColor = Colors.grey;
    });
  }

  @override
  Widget build(BuildContext context) {
    chartHeight = MediaQuery.of(context).size.height / 2.5;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('SpeedRun - $selectedTicker',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        elevation: 0,
        backgroundColor: const Color(0xFF3A5199)
            .withAlpha(179), // Updated from withOpacity(0.7)
        actions: [
          // Add restart button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (!isVisualizationEnded) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Restart Game?'),
                    content: const Text(
                        'Are you sure you want to restart? All current progress will be lost.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _restartGame();
                        },
                        child: const Text('RESTART'),
                      ),
                    ],
                  ),
                );
              } else {
                _restartGame();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              _showInstructionsPopup();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3A5199),
              const Color(0xFF2C74B3).withOpacity(0.8),
            ],
          ),
        ),
        child: FutureBuilder<List<StockPoint>>(
          future: stockDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return _buildErrorView(snapshot.error.toString());
              }

              if (displayedSpots.isEmpty && snapshot.data != null) {
                // Start the timer and create initial display spots
                startDataTimer(snapshot.data!);
              }

              if (displayedSpots.isEmpty) {
                return _buildLoadingView();
              }

              return Stack(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          // Price information card
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return PriceCard(
                                ticker: selectedTicker,
                                currentPrice: currentPrice,
                                priceColor: priceColor,
                                isPriceIncreasing: isPriceIncreasing,
                                previousPrice: previousPrice,
                                animation: _animationController,
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Stock chart
                          StockChart(
                            displayedSpots: displayedSpots,
                            isPriceIncreasing: isPriceIncreasing,
                            chartHeight: chartHeight,
                          ),

                          const SizedBox(height: 16),

                          // Trading actions row
                          _buildTradeActionButtons(),

                          const SizedBox(height: 16),

                          // Bottom info panel
                          _buildInfoPanel(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return _buildLoadingView();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTradeActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: handleBuy,
            icon: const Icon(Icons.add_shopping_cart),
            label: Text(
              'BUY (${totalBuys}/$maxBuys)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: handleSell,
            icon: const Icon(Icons.sell),
            label: const Text(
              'SELL ALL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPanel() {
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
          // Positions info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Positions',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                '${buyPrices.length} ${buyPrices.length == 1 ? "position" : "positions"}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Points info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Points Earned',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                gpoints.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A5199),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  randomIndex = random.nextInt(ticker.length);
                  selectedTicker = ticker[randomIndex];
                  stockDataFuture =
                      _stockDataService.fetchStockData(selectedTicker);
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(204), // 80% opacity
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3A5199)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading $selectedTicker data...',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF3A5199),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preparing the trading experience',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
