import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/search_button.dart';
import 'package:auth_screen/portfolio_management.dart';
import 'package:auth_screen/screens/stocks_detail_page.dart';
import 'package:auth_screen/trading_stock_handller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:auth_screen/screens/game_screen.dart';
import 'package:auth_screen/screens/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  // Index of the selected BottomNavigationBar tab.
  int _selectedIndex = 0;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ...existing initialization code...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getSelectedTitle(),
          style: GoogleFonts.robotoMono(),
        ),
        backgroundColor: const Color.fromARGB(255, 203, 209, 211),
        actions: [
          // Search button widget to trigger search functionalities.
          SearchButton(
            onPressed: (query) {
              if (kDebugMode) {
                print('Search query: $query');
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      backgroundColor: const Color.fromRGBO(171, 200, 192, 1),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(218, 247, 220, 1),
        items: const [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Game", icon: Icon(Icons.gamepad)),
          BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person)),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // Returns title string based on the selected bottom navigation index.
  String _getSelectedTitle() {
    switch (_selectedIndex) {
      case 0:
        return "Home";
      case 1:
        return "Game";
      case 2:
        return "Profile";
      default:
        return "Home";
    }
  }

  // Builds the main content area for the currently selected tab.
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const GameScreen();
      case 2:
        return const ProfileScreen();
      default:
        return Container();
    }
  }

  // Constructs the Home Page with header, portfolio graph, and stock info.
  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildWelcomeHeader(), // Header with welcome message
          const SizedBox(height: 20),
          PortfolioManagementWidget(), // Embedded portfolio graph
          const SizedBox(height: 20),
          _buildUserMoney(), // Display user's buying power
          const SizedBox(height: 20),
          _buildStockWidgets(), // List of stocks from user portfolio
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Builds a header card with a welcome message and a refresh button.
  Widget _buildWelcomeHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "Trader";
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.greenAccent, Colors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Welcome back, $displayName!",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  // Trigger refresh of the homepage content if needed.
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Builds the widget that displays the user's portfolio stocks as a list.
  Widget _buildStockWidgets() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('portfolio')
          .doc('details')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();
        var portfolioData =
            (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        List<Map<String, dynamic>> userStocks =
            portfolioData.containsKey('stocks')
                ? List<Map<String, dynamic>>.from(portfolioData['stocks'])
                : [];
        return Column(
          children: userStocks.map((stock) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          StockDetailsPage(ticker: stock['ticker'])),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Display stock ticker, quantity, and equity.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock['ticker'],
                          style: GoogleFonts.robotoMono(
                              fontSize: 20, color: Colors.black),
                        ),
                        Text(
                          'Quantity: ${stock['quantity'].toStringAsFixed(2)}',
                          style: GoogleFonts.robotoMono(
                              fontSize: 20, color: Colors.black),
                        ),
                        Text(
                          'Equity: \$${stock['equity'].toStringAsFixed(2)}',
                          style: GoogleFonts.robotoMono(
                              fontSize: 20, color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    // Trade button navigates to the TradePage.
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  TradePage(ticker: stock['ticker'])),
                        );
                        if (result == 'updated') {
                          setState(() {}); // Refresh portfolio upon return.
                        }
                      },
                      icon: const Icon(Icons.show_chart),
                      label: const Text('Trade'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 88, 214, 141),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Displays the user's buying power as streamed data.
  Widget _buildUserMoney() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('portfolio')
          .doc('details')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('Error: ${snapshot.error}');
        if (snapshot.connectionState == ConnectionState.waiting)
          return const CircularProgressIndicator();
        var portfolioData =
            (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        double userMoney = portfolioData.containsKey('money')
            ? portfolioData['money'].toDouble()
            : 100000; // Default buying power if undefined.
        return Text(
          'Buying Power: \$${userMoney.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16),
        );
      },
    );
  }
}
