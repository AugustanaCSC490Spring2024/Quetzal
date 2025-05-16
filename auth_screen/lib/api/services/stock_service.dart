import 'dart:async';
import 'dart:math';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import '../api_client.dart';
import '../api_config.dart';
import '../../models/stock_point.dart';

/// Service for fetching and managing stock data from Polygon API
class StockService {
  final ApiClient _apiClient;
  final Logger _logger;
  final Random _random = Random();

  // Request management
  final List<String> _apiCallQueue = [];
  bool _isProcessingQueue = false;
  Timer? _queueTimer;

  // For reactive UI updates
  final ValueNotifier<Map<String, double>> pricesNotifier = ValueNotifier({});
  final ValueNotifier<Map<String, Color>> colorsNotifier = ValueNotifier({});
  final ValueNotifier<Map<String, bool>> isRealPriceNotifier =
      ValueNotifier({});

  // Local cache
  final Map<String, double> latestPrices = {};
  final Map<String, Color> priceColors = {};
  final Map<String, DateTime> lastFetchTime = {};
  final Map<String, double> previousPrices = {};

  // Fallback prices for common stocks
  final Map<String, double> basePrices = {
    'AAPL': 170.0,
    'MSFT': 330.0,
    'AMZN': 130.0,
    'GOOG': 135.0,
    'META': 300.0,
    'NVDA': 440.0,
    'TSLA': 240.0,
    'V': 250.0,
  };

  /// Creates a new StockService with optional custom ApiClient and Logger
  StockService({ApiClient? apiClient, Logger? logger})
      : _apiClient = apiClient ?? ApiClient(),
        _logger = logger ?? Logger() {
    // Set up queue processing
    _queueTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _processApiCallQueue();
    });
  }

  /// Dispose of resources
  void dispose() {
    _queueTimer?.cancel();
  }

  /// Process API calls one at a time with rate limiting
  void _processApiCallQueue() {
    if (_apiCallQueue.isEmpty || _isProcessingQueue) return;

    _isProcessingQueue = true;
    String ticker = _apiCallQueue.removeAt(0);

    // Only fetch if we haven't fetched recently (60 second cooldown)
    if (!_shouldFetchPrice(ticker)) {
      _isProcessingQueue = false;
      return;
    }

    _fetchLatestPrice(ticker).then((_) {
      _isProcessingQueue = false;
    });
  }

  /// Check if we should fetch the price (to prevent frequent updates)
  bool _shouldFetchPrice(String ticker) {
    if (!lastFetchTime.containsKey(ticker)) return true;

    // Only fetch if it's been more than 60 seconds since last fetch
    final now = DateTime.now();
    final lastFetch = lastFetchTime[ticker]!;
    return now.difference(lastFetch).inSeconds > 60;
  }

  /// Public method to fetch the latest price directly (for external clients)
  Future<double> fetchLatestPrice(String ticker) async {
    // Add to queue to ensure we respect rate limiting
    if (!_apiCallQueue.contains(ticker)) {
      _apiCallQueue.add(ticker);
    }

    // If we need the price immediately, fetch it now
    return _fetchLatestPrice(ticker);
  }

  /// Queue a price fetch request instead of fetching immediately
  /// (this is for background updates)
  Future<void> fetchStockPrice(String ticker) async {
    // Don't add to queue if already there
    if (!_apiCallQueue.contains(ticker) && !_shouldFetchPrice(ticker)) {
      // If we already have a price, simulate small changes to keep UI fresh
      if (latestPrices.containsKey(ticker)) {
        _simulatePriceChange(ticker);
        return;
      }
    }

    // Add to queue if not already there
    if (!_apiCallQueue.contains(ticker)) {
      _apiCallQueue.add(ticker);
    }
  }

  /// Generate small price changes for visual feedback between API calls
  void _simulatePriceChange(String ticker) {
    if (!latestPrices.containsKey(ticker)) return;

    double currentPrice = latestPrices[ticker]!;
    previousPrices[ticker] = currentPrice;

    // Small random change (-0.5% to +0.5%)
    double changePercent = (_random.nextDouble() - 0.5) * 0.01;
    double newPrice = currentPrice * (1 + changePercent);

    latestPrices[ticker] = newPrice;
    isRealPriceNotifier.value[ticker] = false;

    // Update color based on price change
    if (newPrice > currentPrice) {
      priceColors[ticker] = Colors.green;
    } else if (newPrice < currentPrice) {
      priceColors[ticker] = Colors.red;
    }

    // Notify listeners
    pricesNotifier.value = Map.from(latestPrices);
    colorsNotifier.value = Map.from(priceColors);
    isRealPriceNotifier.value = Map.from(isRealPriceNotifier.value);
  }

  /// Fetches the latest price for a stock ticker
  Future<double> _fetchLatestPrice(String ticker) async {
    try {
      // Record the fetch time for rate limiting
      lastFetchTime[ticker] = DateTime.now();

      // Store previous price for comparison
      if (latestPrices.containsKey(ticker)) {
        previousPrices[ticker] = latestPrices[ticker]!;
      }

      // Determine the date and market status
      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final isMarketOpen = _isMarketOpen(now);

      // Build URL and make request
      final uri = ApiConfig.buildLatestPriceUrl(
        ticker: ticker,
        date: formattedDate,
        isMinuteData: isMarketOpen,
      );

      final data = await _apiClient.get(uri);

      // Parse response
      if (data['results'] != null && data['results'].isNotEmpty) {
        final double price = (data['results'][0]['c'] as num).toDouble();

        // Update price and color
        latestPrices[ticker] = price;
        isRealPriceNotifier.value[ticker] = true;
        _updatePriceColor(ticker, price);

        // Notify listeners of the change
        pricesNotifier.value = Map.from(latestPrices);
        colorsNotifier.value = Map.from(priceColors);
        isRealPriceNotifier.value = Map.from(isRealPriceNotifier.value);

        return price;
      }

      throw ApiException('No price data available');
    } catch (e) {
      _logger.e('Error fetching price for $ticker: $e');

      // Fallback to simulated price if API fails
      return _generateMockPrice(ticker);
    }
  }

  /// Generate a simulated price when the API fails
  double _generateMockPrice(String ticker) {
    double basePrice = basePrices[ticker] ?? 100.0;
    double price = basePrice * (0.95 + (_random.nextDouble() * 0.1));

    latestPrices[ticker] = price;
    priceColors[ticker] = Colors.grey;
    isRealPriceNotifier.value[ticker] = false;

    pricesNotifier.value = Map.from(latestPrices);
    colorsNotifier.value = Map.from(priceColors);
    isRealPriceNotifier.value = Map.from(isRealPriceNotifier.value);

    return price;
  }

  /// Fetches historical stock data points for a given period
  Future<List<StockPoint>> fetchHistoricalData(String ticker,
      {int days = 7}) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));

      final formattedToDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final formattedFromDate =
          "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";

      final uri = ApiConfig.buildAggregatesUrl(
        ticker: ticker,
        from: formattedFromDate,
        to: formattedToDate,
      );

      final data = await _apiClient.get(uri);

      if (data['results'] == null || (data['results'] as List).isEmpty) {
        throw ApiException('No historical data available');
      }

      // Convert API data to StockPoint objects
      final List<StockPoint> points = List<StockPoint>.from(
          (data['results'] as List)
              .map((result) => StockPoint.fromJson(result)));

      // Interpolate if we have few points
      if (points.length < 10) {
        return _interpolatePoints(points);
      }

      return points;
    } catch (e) {
      _logger.e('Error fetching historical data for $ticker: $e');
      // Fall back to simulated data
      return _generateSimulatedData();
    }
  }

  /// Generate simulated historical data
  List<StockPoint> _generateSimulatedData() {
    const int pointCount = 20;
    final now = DateTime.now().millisecondsSinceEpoch;
    final basePrice = 100.0 + _random.nextDouble() * 50;
    final List<StockPoint> simulatedPoints = [];

    double currentPrice = basePrice;
    for (int i = 0; i < pointCount; i++) {
      // Add random movement to the price
      final movement = (_random.nextDouble() - 0.5) * 5;
      currentPrice += movement;
      if (currentPrice < 10) currentPrice = 10; // Prevent negative price

      simulatedPoints.add(StockPoint(
        close: currentPrice,
        time: now + i * 86400000, // Add one day in milliseconds for each point
      ));
    }

    _logger.i('Using simulated data because API request failed');
    return simulatedPoints;
  }

  /// Interpolate points for smoother visualization
  List<StockPoint> _interpolatePoints(List<StockPoint> originalPoints) {
    if (originalPoints.length <= 1) return originalPoints;

    List<StockPoint> interpolatedPoints = [];
    const int desiredPoints = 20;

    for (int i = 0; i < originalPoints.length - 1; i++) {
      final StockPoint startPoint = originalPoints[i];
      final StockPoint endPoint = originalPoints[i + 1];

      // Add the starting point
      interpolatedPoints.add(startPoint);

      // Calculate number of points to add between these two
      final pointsToAdd = (desiredPoints - originalPoints.length) ~/
          (originalPoints.length - 1);

      if (pointsToAdd > 0) {
        final timeStep = (endPoint.time - startPoint.time) / (pointsToAdd + 1);
        final priceStep =
            (endPoint.close - startPoint.close) / (pointsToAdd + 1);

        for (int j = 1; j <= pointsToAdd; j++) {
          interpolatedPoints.add(StockPoint(
            time: startPoint.time + (timeStep * j).round(),
            close: startPoint.close + (priceStep * j),
          ));
        }
      }
    }

    // Add the final point
    interpolatedPoints.add(originalPoints.last);
    return interpolatedPoints;
  }

  /// Check if market is currently open (simplified)
  bool _isMarketOpen(DateTime now) {
    // Weekends are closed
    if (now.weekday > 5) return false;

    // Market hours 9:30 AM - 4:00 PM Eastern time (simplified)
    const marketOpenTime = TimeOfDay(hour: 9, minute: 30);
    const marketCloseTime = TimeOfDay(hour: 16, minute: 0);
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    return (currentTime.hour > marketOpenTime.hour ||
            (currentTime.hour == marketOpenTime.hour &&
                currentTime.minute >= marketOpenTime.minute)) &&
        (currentTime.hour < marketCloseTime.hour ||
            (currentTime.hour == marketCloseTime.hour &&
                currentTime.minute <= marketCloseTime.minute));
  }

  /// Update price color based on comparison with previous price
  void _updatePriceColor(String ticker, double newPrice) {
    if (previousPrices.containsKey(ticker)) {
      double previousPrice = previousPrices[ticker]!;
      if (newPrice > previousPrice) {
        priceColors[ticker] = Colors.green;
      } else if (newPrice < previousPrice) {
        priceColors[ticker] = Colors.red;
      } else {
        priceColors[ticker] = Colors.grey;
      }
    } else {
      priceColors[ticker] = Colors.grey;
    }
  }

  /// Schedule price updates for a list of stocks
  void schedulePriceUpdates(List<Map<String, dynamic>> stocks) {
    for (var stock in stocks) {
      if (stock['ticker'] != null) {
        fetchStockPrice(stock['ticker']);
      }
    }
  }
}
