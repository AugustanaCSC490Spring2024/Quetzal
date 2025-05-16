import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:auth_screen/money.dart';

/// Service for handling trading operations and portfolio updates
class TradingService {
  final Logger _logger;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Creates a new TradingService with optional custom Logger
  TradingService({Logger? logger}) : _logger = logger ?? Logger();

  /// Get current user ID or throw exception if not logged in
  String _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }
    return user.uid;
  }

  /// Get reference to user's portfolio document
  DocumentReference _getPortfolioDocRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .doc('details');
  }

  /// Update user's money balance
  /// Returns the new balance
  Future<double> updateMoney(double amount) async {
    try {
      final userId = _getCurrentUserId();
      final portfolioDocRef = _getPortfolioDocRef(userId);

      double newBalance = 0;
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(portfolioDocRef);
        if (snapshot.exists) {
          final currentMoney = (snapshot.get('money') ?? 0).toDouble();
          newBalance = currentMoney + amount;
          _logger.i('Updating money: $currentMoney → $newBalance');
          transaction.update(portfolioDocRef, {'money': newBalance});
        } else {
          newBalance = amount > 0 ? amount : 0;
          transaction.set(
              portfolioDocRef, {'money': newBalance}, SetOptions(merge: true));
        }
      });

      return newBalance;
    } catch (e) {
      _logger.e('Error updating money: $e');
      throw Exception("Failed to update money: $e");
    }
  }

  /// Update user's points
  /// Returns the new points total
  Future<double> updatePoints(double points) async {
    try {
      final userId = _getCurrentUserId();
      final portfolioDocRef = _getPortfolioDocRef(userId);

      double newPoints = 0;
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(portfolioDocRef);
        if (snapshot.exists) {
          final currentPoints = (snapshot.get('points') ?? 0).toDouble();
          newPoints = currentPoints + points;
          _logger.i('Updating points: $currentPoints → $newPoints');
          transaction.update(portfolioDocRef, {'points': newPoints});
        } else {
          newPoints = points > 0 ? points : 0;
          transaction.set(
              portfolioDocRef, {'points': newPoints}, SetOptions(merge: true));
        }
      });

      return newPoints;
    } catch (e) {
      _logger.e('Error updating points: $e');
      throw Exception("Failed to update points: $e");
    }
  }

  /// Execute a trade (buy or sell)
  /// Returns updated portfolio data
  Future<Map<String, dynamic>> executeTrade({
    required String ticker,
    required double quantity,
    required double price,
    required bool isBuy,
  }) async {
    try {
      final userId = _getCurrentUserId();
      final portfolioDocRef = _getPortfolioDocRef(userId);

      final totalCost = price * quantity;

      Map<String, dynamic> updatedPortfolio = {};

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(portfolioDocRef);
        // Cast portfolioData to Map<String, dynamic> to fix type errors
        final portfolioData = snapshot.data() as Map<String, dynamic>? ?? {};

        // Create Money object for validation and calculation
        Money userFunds = Money(portfolioData.containsKey('money')
            ? portfolioData['money'] as double
            : 100000.0);

        var stocks = portfolioData.containsKey('stocks')
            ? List<Map<String, dynamic>>.from(portfolioData['stocks'] as List)
            : [];

        int existingStockIndex =
            stocks.indexWhere((stock) => stock['ticker'] == ticker);

        if (isBuy) {
          // Buy operation
          if (!userFunds.hasEnough(totalCost)) {
            throw Exception('Insufficient funds to complete purchase');
          }

          if (existingStockIndex != -1) {
            // Update existing stock
            stocks[existingStockIndex]['quantity'] += quantity;
            stocks[existingStockIndex]['equity'] =
                stocks[existingStockIndex]['quantity'] * price;
          } else {
            // Add new stock to portfolio
            stocks.add({
              'ticker': ticker,
              'quantity': quantity,
              'equity': quantity * price,
              'isRealPrice': true
            });
          }

          userFunds.deduct(totalCost);
        } else {
          // Sell operation
          if (existingStockIndex == -1) {
            throw Exception('Cannot sell stock that is not in portfolio');
          }

          double currentQty = stocks[existingStockIndex]['quantity'];
          if (currentQty < quantity) {
            throw Exception('Insufficient shares to complete sale');
          }

          stocks[existingStockIndex]['quantity'] -= quantity;

          // Remove stock if quantity is 0
          if (stocks[existingStockIndex]['quantity'] <= 0) {
            stocks.removeAt(existingStockIndex);
          } else {
            stocks[existingStockIndex]['equity'] =
                stocks[existingStockIndex]['quantity'] * price;
          }

          userFunds.add(totalCost);
        }

        // Update portfolio in Firestore
        final updatedData = {
          'stocks': stocks,
          'money': userFunds.amount,
        };

        transaction.set(portfolioDocRef, updatedData, SetOptions(merge: true));
        updatedPortfolio = updatedData;
      });

      return updatedPortfolio;
    } catch (e) {
      _logger.e('Error executing trade: $e');
      throw Exception("Failed to execute trade: $e");
    }
  }

  /// Update equity values for all stocks in portfolio using current prices
  Future<void> updateEquityValues(Map<String, double> currentPrices) async {
    try {
      final userId = _getCurrentUserId();
      final portfolioDocRef = _getPortfolioDocRef(userId);

      final snapshot = await portfolioDocRef.get();
      if (!snapshot.exists) return;

      final portfolioData = snapshot.data() as Map<String, dynamic>;

      if (!portfolioData.containsKey('stocks')) return;

      var stocks = List<Map<String, dynamic>>.from(portfolioData['stocks']);
      bool hasUpdates = false;

      for (var stock in stocks) {
        final ticker = stock['ticker'];
        if (currentPrices.containsKey(ticker)) {
          final price = currentPrices[ticker]!;
          final quantity = stock['quantity'];

          stock['equity'] = quantity * price;
          stock['isRealPrice'] = true;
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await portfolioDocRef.update({'stocks': stocks});
        _logger.i('Updated equity values for ${currentPrices.length} stocks');
      }
    } catch (e) {
      _logger.e('Error updating equity values: $e');
    }
  }

  /// Get user's portfolio data
  Future<Map<String, dynamic>> getPortfolio() async {
    try {
      final userId = _getCurrentUserId();
      final portfolioDocRef = _getPortfolioDocRef(userId);

      final snapshot = await portfolioDocRef.get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};
    } catch (e) {
      _logger.e('Error getting portfolio: $e');
      return {};
    }
  }
}
