import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:auth_screen/models/stock_point.dart';

class StockDataService {
  final logger = Logger();
  final String apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';

  Future<List<StockPoint>> fetchStockData(String ticker) async {
    // Use a more limited timeframe that's available in the free tier
    // Get data from the last 7 days with daily resolution
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final formattedToDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final formattedFromDate =
        "${sevenDaysAgo.year}-${sevenDaysAgo.month.toString().padLeft(2, '0')}-${sevenDaysAgo.day.toString().padLeft(2, '0')}";

    String url =
        'https://api.polygon.io/v2/aggs/ticker/$ticker/range/1/day/$formattedFromDate/$formattedToDate?adjusted=true&sort=asc&apiKey=$apiKey';

    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['results'] == null || data['results'].isEmpty) {
          throw Exception('No data available for the selected ticker');
        }

        List<StockPoint> points = List<StockPoint>.from(
          data['results'].map((result) {
            return StockPoint.fromJson(result);
          }),
        );

        // If we have very few points, interpolate to create a better game experience
        if (points.length < 10) {
          points = interpolatePoints(points);
        }

        return points;
      } else {
        logger.e('Failed to load stock data: ${response.body}');
        throw Exception('Failed to load stock data: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching stock data: $e');
      // Fall back to simulated data when API fails
      return generateSimulatedData();
    }
  }

  // Helper method to generate simulated stock data when the API fails
  List<StockPoint> generateSimulatedData() {
    const int pointCount = 20;
    final now = DateTime.now().millisecondsSinceEpoch;
    final basePrice = 100.0 + Random().nextDouble() * 50;
    final List<StockPoint> simulatedPoints = [];

    double currentPrice = basePrice;
    for (int i = 0; i < pointCount; i++) {
      // Add some random movement to the price
      final movement = (Random().nextDouble() - 0.5) * 5;
      currentPrice += movement;
      if (currentPrice < 10) currentPrice = 10; // Prevent price going too low

      simulatedPoints.add(StockPoint(
        close: currentPrice,
        time: now + i * 86400000, // Add one day in milliseconds for each point
      ));
    }

    logger.i('Using simulated data because API request failed');
    return simulatedPoints;
  }

  // Helper method to interpolate points for smoother visualization
  List<StockPoint> interpolatePoints(List<StockPoint> originalPoints) {
    if (originalPoints.length <= 1) return originalPoints;

    List<StockPoint> interpolatedPoints = [];
    final int desiredPoints = 20;

    for (int i = 0; i < originalPoints.length - 1; i++) {
      final StockPoint startPoint = originalPoints[i];
      final StockPoint endPoint = originalPoints[i + 1];

      // Add the starting point
      interpolatedPoints.add(startPoint);

      // Calculate number of points to add between these two points
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
}
