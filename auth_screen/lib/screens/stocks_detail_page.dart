// ignore_for_file: deprecated_member_use

import 'package:auth_screen/api_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auth_screen/trading_stock_handller.dart';

class StockDetailsPage extends StatefulWidget {
  final String ticker;
  const StockDetailsPage({super.key, required this.ticker});

  @override
  StockDetailsPageState createState() => StockDetailsPageState();
}

class StockDetailsPageState extends State<StockDetailsPage> {
  late Future<List<Map<String, String>>> newsFuture;

  @override
  void initState() {
    super.initState();
    newsFuture = ApiService.fetchTickerNews(widget.ticker);
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Details - ${widget.ticker}'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, String>>>(
                future: newsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No news available', style: TextStyle(color: Colors.white)));
                  } else {
                    List<Map<String, String>> news = snapshot.data!;
                    return ListView.builder(
                      itemCount: news.length,
                      itemBuilder: (context, index) {
                        final imageUrl = news[index]['image_url'];
                        final hasValidImage = imageUrl != null && imageUrl.isNotEmpty && imageUrl != 'null';

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.all(8.0),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    news[index]['title']!,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    news[index]['description'] ?? '',
                                    style: const TextStyle(color: Colors.white),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              trailing: hasValidImage
                                  ? Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/placeholder.jpg',
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        );
                                      },
                                    )
                                  : const SizedBox(width: 100, height: 100),
                              onTap: () {
                                final url = news[index]['url'];
                                if (url != null) {
                                  _launchUrl(url);
                                } else {
                                  throw 'Invalid URL';
                                }
                              },
                            ),
                            const Divider(color: Colors.white),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TradePage(ticker: widget.ticker),
                    ),
                  );
                },
                icon: const Icon(Icons.trending_up),
                label: const Text('Trade'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
