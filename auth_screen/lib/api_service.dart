import 'dart:convert';

import 'package:http/http.dart' as http;

class APIService{
  Future<List<Map<String, dynamic>>> fetchStockMarketValues() async{
    final String apiUrl = 'https://api.polygon.io/v3/reference/tickers?active=true&apiKey=K2C82obyi9y7AG7GOND0JTRt_j52UB4P';

    try{
      final Uri uri = Uri.parse(apiUrl);
      final response = await http.get(uri);
      if (response.statusCode == 200 ){
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> res = List.from(data['results']);
        return res;
      }else{
        print('Failed to fetch tickers: ${response.statusCode}');
      throw Exception('Failed to fetch tickers');
      }
    }catch (e) {
    print('Error fetching tickers: $e');
    throw Exception('Error fetching tickers: $e');
  }

  }


}