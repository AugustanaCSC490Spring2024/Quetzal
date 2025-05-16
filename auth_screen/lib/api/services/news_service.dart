import 'package:logger/logger.dart';
import '../api_client.dart';
import '../api_config.dart';

/// Service for fetching news from Polygon API
class NewsService {
  final ApiClient _apiClient;
  final Logger _logger;

  /// Creates a new NewsService with optional custom ApiClient and Logger
  NewsService({ApiClient? apiClient, Logger? logger})
      : _apiClient = apiClient ?? ApiClient(),
        _logger = logger ?? Logger();

  /// Fetches news articles for a given stock ticker
  /// Returns a list of news articles as maps
  Future<List<Map<String, String>>> fetchNews(String ticker) async {
    try {
      _logger.d('Fetching news for $ticker');

      final uri = ApiConfig.buildNewsUrl(ticker);
      final data = await _apiClient.get(uri);

      if (data['results'] == null) {
        return [];
      }

      // Convert API data to a list of maps with consistent structure
      List<Map<String, String>> news = [];

      for (var article in data['results']) {
        news.add({
          'title': _extractString(article['title']),
          'url': _extractString(article['article_url']),
          'description': _extractString(article['description']),
          'image_url': _extractString(article['image_url']),
          'published_at': _extractString(article['published_utc']),
          'source': _extractString(article['publisher']['name']),
        });
      }

      return news;
    } catch (e) {
      _logger.e('Error fetching news for $ticker: $e');
      return [];
    }
  }

  /// Helper method to safely extract string values from JSON
  String _extractString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
