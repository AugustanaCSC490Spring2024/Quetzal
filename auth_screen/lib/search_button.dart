// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:auth_screen/buying_stock_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class SearchButton extends StatelessWidget {
 final Function(String) onPressed;


 const SearchButton({super.key, required this.onPressed});


 @override
 Widget build(BuildContext context) {
   return IconButton(
     icon: const Icon(Icons.search),
     onPressed: () => _showSearch(context),
   );
 }


 void _showSearch(BuildContext context) async {
   final String? result = await showSearch<String>(
     context: context,
     delegate: CustomSearch(),
   );
   if (result != null) {
     onPressed(result);
   }
 }
}


class CustomSearch extends SearchDelegate<String> {
 final String apiKey ="hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym" ;


 @override
 List<Widget> buildActions(BuildContext context) {
   return [
     //IconButton(
       //icon: Icon(Icons.clear),
       //onPressed: () {
         //query = '';
       //},
     //),
   ];
 }


 @override
 Widget buildLeading(BuildContext context) {
   return IconButton(
     icon: const Icon(Icons.arrow_back),
     onPressed: () {
       close(context, '');
     },
   );
 }




  //list of popular stock symbols
  final List<String> popularStocks = [
    'AAPL', // Apple
    'GOOGL', // Alphabet
    'AMZN', // Amazon
    'MSFT', // Microsoft
    'TSLA', // Tesla
    
  ];
  
@override
Widget buildSuggestions(BuildContext context) {
  if (query.isEmpty) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Future.wait(popularStocks.map(_fetchTickerInfo)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return _buildSuggestionsList(snapshot.data!);
        } else {
          return const Center(child: Text('No suggestions available.'));
        }
      },
    );
  } else {
    return FutureBuilder(
      future: _fetchSuggestions(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final suggestions = snapshot.data;
          return suggestions != null
              ? _buildSuggestionsList(suggestions)
              : Container();
        }
      },
    );
  }
}




Widget _buildSuggestionsList(List<Map<String, dynamic>> suggestions) {
  return ListView.separated(
    itemCount: suggestions.length,
    separatorBuilder: (context, index) => const Divider(color: Colors.grey),
    itemBuilder: (context, index) {
      final suggestion = suggestions[index];
      final ticker = suggestion['ticker'];
      final name = suggestion['name'];
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BuyingStockInfoPage(ticker: ticker),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black, padding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ), 
          
          backgroundColor:const Color.fromARGB(255, 9, 158, 106), // Button color
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $name',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black, // Name color
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Ticker Symbol: $ticker',
              style: const TextStyle(color: Colors.black), // Ticker color
            ),
          ],
        ),
      );
    },
  );
}





Future<List<Map<String, dynamic>>> _fetchSuggestions(String query) async {
  final response = await http.get(
    Uri.parse(
        'https://api.polygon.io/v3/reference/tickers?search=$query&apiKey=$apiKey'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body)['results'];
    return List<Map<String, dynamic>>.from(data.map((tickerData) => {
      'name': tickerData['name'],
      'ticker': tickerData['ticker']
    }));
  } else {
    throw Exception('Failed to fetch suggestions: ${response.statusCode}');
  }
}





 @override
 Widget buildResults(BuildContext context) {
   return FutureBuilder(
     future: _fetchTickerInfo(query),
     builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
         return const Center(child: CircularProgressIndicator());
       } else if (snapshot.hasError) {
         return Center(child: Text('Error: ${snapshot.error}'));
       } else {
         return _buildTickerInfo(context, snapshot.data);
       }
     },
   );
 }


Future<Map<String, dynamic>> _fetchTickerInfo(String ticker) async {
 ticker = ticker.toUpperCase();
 final DateTime currentDate = DateTime.now();
 final String formattedDate = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
  final response = await http.get(
   Uri.parse('https://api.polygon.io/v3/reference/tickers/$ticker?date=$formattedDate&apiKey=hDnp3QGn94ARKy0B8mzeEQyX9qY_Bwym'),
 );


 if (response.statusCode == 200) {
   final Map<String, dynamic> data = jsonDecode(response.body);
   if (data.containsKey('results')) {
     return data['results'] as Map<String, dynamic>;
   } else {
     throw Exception('Unexpected response format: ${response.body}');
   }
 } else {
   print('Failed to fetch tickers: ${response.statusCode}');
   throw Exception('Failed to fetch tickers');
 }
}






Widget _buildTickerInfo(BuildContext context, dynamic tickerInfo) {
 if (tickerInfo == null || tickerInfo.isEmpty) {
   return const Center(child: Text('No information available for this ticker.'));
 }


 String ticker = tickerInfo['ticker'] ?? 'N/A';
 String name = tickerInfo['name'] ?? 'N/A';
 double marketCap = tickerInfo['market_cap'] ?? 0.0;


 return SingleChildScrollView(
   child: Container(
     padding: const EdgeInsets.all(16.0),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           'Name: $name',
           style: const TextStyle(fontWeight: FontWeight.bold),
         ),
         const SizedBox(height: 8.0),
         Text('Ticker Symbol: $ticker'),
         Text('Market Cap: $marketCap'), // Display market cap
       ],
     ),
   ),
 );
}






}
