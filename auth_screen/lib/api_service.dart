// import 'dart:convert';                                               **** CHANGES MADE ON 5/18/24: 5:55pm
// import 'package:http/http.dart' as http;

// class ApiService {
//   static Future<List<String>> fetchTickerNews(String stockSymbol) async {
//     const apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';
//     const baseUrl = 'https://api.polygon.io/v2/reference/news';
//     final url = '$baseUrl?apiKey=$apiKey&ticker=$stockSymbol';

//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//         List<String> newsHeadlines = [];

//         for (var article in jsonData['results']) {
//           newsHeadlines.add(article['title']);
//         }

//         return newsHeadlines;
//       } else {
//         throw Exception('Failed to load news');
//       }
//     } catch (e) {
//       throw Exception('Error: $e');
//     }
//   }

 
// }

import 'dart:convert';  
import 'package:http/http.dart' as http;   

class ApiService {
  static const String apiKey = 'hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym';
  static const String baseUrl = 'https://api.polygon.io';   

  static Future<Map<String, dynamic>> fetchStockData(String stockSymbol) async {
    final url = '$baseUrl/v2/aggs/ticker/$stockSymbol/prev?apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['results'] != null && jsonData['results'].isNotEmpty) {
          return jsonData['results'][0];
        } else {
          throw Exception('No data available for $stockSymbol');
        }
      } else {
        throw Exception('Failed to load stock data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<List<String>> fetchTickerNews(String stockSymbol) async {
    final url = '$baseUrl/v2/reference/news?apiKey=$apiKey&ticker=$stockSymbol';

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
