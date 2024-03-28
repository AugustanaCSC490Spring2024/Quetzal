import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchButton extends StatelessWidget {
  final Function(String) onPressed;

  const SearchButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
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
  final String apiKey ="K2C82obyi9y7AG7GOND0JTRt_j52UB4P" ; 

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
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }



  @override
@override
Widget buildSuggestions(BuildContext context) {
  if (query.isEmpty) {
    return Container();
  }

  return FutureBuilder(
    future: _fetchSuggestions(query),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else {
        final suggestions = snapshot.data as List<String>?; // Null-safe casting
        return suggestions != null ? _buildSuggestionsList(suggestions) : Container(); // Null check before calling _buildSuggestionsList
      }
    },
  );
}


   Widget _buildSuggestionsList(List<String> suggestions) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          title: Text(suggestion),
          onTap: () {
            close(context, suggestion);
          },
        );
      },
    );
  }
 Future<List<String>> _fetchSuggestions(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://api.polygon.io/v3/reference/tickers?search=$query&apiKey=$apiKey'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['results'];
      return List<String>.from(data.map((tickerData) => tickerData['ticker']));
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
          return Center(child: CircularProgressIndicator());
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
    Uri.parse('https://api.polygon.io/v3/reference/tickers/$ticker?date=$formattedDate&apiKey=K2C82obyi9y7AG7GOND0JTRt_j52UB4P'),
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
    return Center(child: Text('No information available for this ticker.'));
  }

  String ticker = tickerInfo['ticker'] ?? 'N/A';
  String name = tickerInfo['name'] ?? 'N/A';
  double marketCap = tickerInfo['market_cap'] ?? 0.0;

  return SingleChildScrollView(
    child: Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: $name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text('Ticker Symbol: $ticker'),
          Text('Market Cap: $marketCap'), // Display market cap
        ],
      ),
    ),
  );
}



}
