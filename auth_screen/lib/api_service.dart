import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<Map<String, String>>> fetchTickerNews(String stockSymbol) async {
    const apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';
    const baseUrl = 'https://api.polygon.io/v2/reference/news';
    final url = '$baseUrl?apiKey=$apiKey&ticker=$stockSymbol';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<Map<String, String>> news = [];

        for (var article in jsonData['results']) {
          news.add({
            'title': article['title'],
            'url': article['article_url'],
            'description': article['description'],
            'image_url': article['image_url'] ?? '',
          });
        }

        return news;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
