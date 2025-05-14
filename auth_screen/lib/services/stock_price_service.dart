import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:auth_screen/api_config.dart';

class StockPriceService {
  static final StockPriceService _instance = StockPriceService._internal();
  factory StockPriceService() => _instance;

  final logger = Logger();

  // Maps to store price data
  final Map<String, double> latestPrices = {};
  final Map<String, Color> priceColors = {};
  final Map<String, DateTime> lastFetchTime = {};
  final Map<String, double> previousPrices = {};

  // Request management
  final List<String> apiCallQueue = [];
  bool isProcessingQueue = false;
  Timer? _queueTimer;
  final Random _random = Random();

  // Notifiers for reactive UI updates
  final ValueNotifier<Map<String, double>> pricesNotifier = ValueNotifier({});
  final ValueNotifier<Map<String, Color>> colorsNotifier = ValueNotifier({});
  final ValueNotifier<Map<String, dynamic>> priceMetadataNotifier =
      ValueNotifier({});

  // Base prices for common stocks (for fallback)
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

  StockPriceService._internal() {
    _queueTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _processApiCallQueue();
    });
  }

  void dispose() {
    _queueTimer?.cancel();
  }

  // Process API calls one at a time with rate limiting
  void _processApiCallQueue() {
    if (apiCallQueue.isEmpty || isProcessingQueue) return;

    isProcessingQueue = true;
    String ticker = apiCallQueue.removeAt(0);

    // Only fetch if we haven't fetched recently (60 second cooldown)
    if (!_shouldFetchPrice(ticker)) {
      isProcessingQueue = false;
      return;
    }

    _fetchLatestPrice(ticker).then((_) {
      isProcessingQueue = false;
    });
  }

  // Check if we should fetch the price (to prevent frequent updates)
  bool _shouldFetchPrice(String ticker) {
    if (!lastFetchTime.containsKey(ticker)) return true;

    // Only fetch if it's been more than 60 seconds since last fetch
    final now = DateTime.now();
    final lastFetch = lastFetchTime[ticker]!;
    return now.difference(lastFetch).inSeconds > 60;
  }

  // Queue a price fetch request instead of fetching immediately
  Future<void> fetchStockPrice(String ticker) async {
    // Don't add to queue if already there
    if (!apiCallQueue.contains(ticker) && !_shouldFetchPrice(ticker)) {
      // If we already have a price, simulate small changes to keep UI fresh
      if (latestPrices.containsKey(ticker)) {
        _simulatePriceChange(ticker);
        return;
      }
    }

    // Add to queue if not already there
    if (!apiCallQueue.contains(ticker)) {
      apiCallQueue.add(ticker);
    }
  }

  // Main method to fetch the latest price from Polygon API
  Future<void> _fetchLatestPrice(String ticker) async {
    try {
      // Update last fetch time to prevent frequent calls
      lastFetchTime[ticker] = DateTime.now();

      // Store previous price for comparison
      if (latestPrices.containsKey(ticker)) {
        previousPrices[ticker] = latestPrices[ticker]!;
      }

      DateTime now = DateTime.now();
      String formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      bool marketOpen = _isMarketOpen(now);

      // Use ApiConfig's public method to get the URL instead of accessing private members
      Uri url = ApiConfig.getLatestStockPriceUrl(
        ticker: ticker,
        date: formattedDate,
        isMinuteData: marketOpen,
      );

      final response = await http.get(url, headers: ApiConfig.defaultHeaders);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        if (data['results'] != null && data['results'].isNotEmpty) {
          double currentPrice = data['results'].first['c'];

          // Add a small timestamp to know when this price was fetched
          final fetchTime = DateTime.now();

          // Mark this as real data, not simulated
          latestPrices[ticker] = currentPrice;

          // Create a map with additional metadata
          Map<String, dynamic> priceMetadata = {
            'price': currentPrice,
            'isReal': true,
            'fetchTime': fetchTime.toString(),
            'source': 'Polygon API'
          };

          // Set price color based on previous price
          if (previousPrices.containsKey(ticker)) {
            double previousPrice = previousPrices[ticker]!;
            if (currentPrice > previousPrice) {
              priceColors[ticker] = Colors.green;
            } else if (currentPrice < previousPrice) {
              priceColors[ticker] = Colors.red;
            } else {
              priceColors[ticker] = Colors.grey;
            }
          } else {
            priceColors[ticker] = Colors.grey;
          }

          // Notify listeners of price update
          pricesNotifier.value = Map.from(latestPrices);
          colorsNotifier.value = Map.from(priceColors);

          // Store metadata in a separate notifier
          priceMetadataNotifier.value[ticker] = priceMetadata;
          priceMetadataNotifier.notifyListeners();

          logger
              .i('Successfully fetched real price for $ticker: $currentPrice');
        }
      } else {
        logger.e('Failed to fetch price: ${response.statusCode}');
        _generateMockPrice(ticker, reason: 'API Error ${response.statusCode}');
      }
    } catch (error) {
      logger.e('Error fetching stock price for $ticker: $error');
      _generateMockPrice(ticker, reason: 'Exception: $error');
    }
  }

  // Generate small price changes for visual feedback between API calls
  void _simulatePriceChange(String ticker) {
    if (!latestPrices.containsKey(ticker)) return;

    double currentPrice = latestPrices[ticker]!;
    previousPrices[ticker] = currentPrice;

    // Small random change (-0.5% to +0.5%)
    double changePercent = (_random.nextDouble() - 0.5) * 0.01;
    double newPrice = currentPrice * (1 + changePercent);

    latestPrices[ticker] = newPrice;

    // Update color based on price change
    if (newPrice > currentPrice) {
      priceColors[ticker] = Colors.green;
    } else if (newPrice < currentPrice) {
      priceColors[ticker] = Colors.red;
    }

    // Notify listeners
    pricesNotifier.value = Map.from(latestPrices);
    colorsNotifier.value = Map.from(priceColors);
  }

  // Generate mock prices when API fails
  void _generateMockPrice(String ticker, {String reason = 'API unavailable'}) {
    double price = basePrices[ticker] ?? (50.0 + _random.nextDouble() * 150.0);
    price = price * (0.95 + (_random.nextDouble() * 0.1));

    latestPrices[ticker] = price;
    priceColors[ticker] = Colors.grey;

    // Create metadata showing this is simulated data
    Map<String, dynamic> priceMetadata = {
      'price': price,
      'isReal': false,
      'reason': reason,
      'source': 'Simulation'
    };

    priceMetadataNotifier.value[ticker] = priceMetadata;

    // Notify listeners
    pricesNotifier.value = Map.from(latestPrices);
    colorsNotifier.value = Map.from(priceColors);
    priceMetadataNotifier.notifyListeners();
  }

  // Check if market is currently open
  bool _isMarketOpen(DateTime now) {
    // Weekends are closed
    if (now.weekday > 5) return false;

    // Market hours 9:30 AM - 4:00 PM Eastern time
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

  // Schedule price updates for a list of stocks
  void schedulePriceUpdates(List<Map<String, dynamic>> stocks) {
    for (var stock in stocks) {
      if (stock['ticker'] != null) {
        fetchStockPrice(stock['ticker']);
      }
    }
  }
}
