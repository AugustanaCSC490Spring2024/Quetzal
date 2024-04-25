import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<List<String>> fetchTickerNews(String stockSymbol) async {
    const apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';
    const baseUrl = 'https://api.polygon.io/v2/reference/news';
    final url = '$baseUrl?apiKey=$apiKey&ticker=$stockSymbol';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<String> newsHeadlines = [];

        for (var article in jsonData['results']) {
          newsHeadlines.add(article['title']);
        }

        return newsHeadlines;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

 
}
