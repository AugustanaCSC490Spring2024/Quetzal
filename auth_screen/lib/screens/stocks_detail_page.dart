import 'package:auth_screen/api_service.dart';
import 'package:flutter/material.dart';

class StockDetailsPage extends StatefulWidget {
  final String ticker;
  const StockDetailsPage({super.key, required this.ticker});

  @override
  StockDetailsPageState createState() => StockDetailsPageState();
}

class StockDetailsPageState extends State<StockDetailsPage> {
  late Future<List<String>> newsFuture;

  @override
  void initState() {
    super.initState();
    newsFuture = ApiService.fetchTickerNews(widget.ticker);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details - ${widget.ticker}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'News for ${widget.ticker}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder(
              future: newsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<String> news = snapshot.data as List<String>;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: news.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(news[index]),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
