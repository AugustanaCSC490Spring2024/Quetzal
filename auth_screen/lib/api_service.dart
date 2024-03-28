import 'dart:convert';
import 'package:http/http.dart' as http;

class APIService {
  final String apiKey = "K2C82obyi9y7AG7GOND0JTRt_j52UB4P";

  Future<Map<String, dynamic>> fetchTickerInfo(String ticker) async {
    try {
      final DateTime currentDate = DateTime.now();
      final String formattedDate =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      
      final response = await http.get(
        Uri.parse(
          'https://api.polygon.io/v3/reference/tickers/$ticker?date=$formattedDate&apiKey=$apiKey'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['results'];
      } else {
        print('Failed to fetch ticker info: ${response.statusCode}');
        throw Exception('Failed to fetch ticker info');
      }
    } catch (e) {
      print('Error fetching ticker info: $e');
      throw Exception('Error fetching ticker info: $e');
    }
  }
}