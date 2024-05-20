// ignore_for_file: dangling_library_doc_comments, unnecessary_cast

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/live_stock_chart.dart';
import 'package:auth_screen/test_live_stock_chart.dart';
import 'package:auth_screen/search_button.dart';
import 'package:auth_screen/portfolio_management.dart';
import 'package:auth_screen/screens/stocks_detail_page.dart';
import 'package:auth_screen/trading_stock_handller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:auth_screen/screens/game_screen.dart';
import 'package:auth_screen/screens/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  double _currentMoney = 0.0;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fetchUserMoney();
  }

  Future<void> _fetchUserMoney() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('portfolio')
          .doc('details')
          .get();

      var portfolioData = doc.data() as Map<String, dynamic>? ?? {};
      double userMoney = portfolioData.containsKey('money')
          ? portfolioData['money'].toDouble()
          : 100000; // default value is 100000

      _animation = Tween<double>(begin: 0, end: userMoney).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeOut,
        ),
      )..addListener(() {
          setState(() {
            _currentMoney = _animation.value;
          });
        });

      _animationController.forward();
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching user money: $error');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('Test Live Stock Chart')),
                body: const TestLiveStockChart(ticker: 'AAPL', userStockPrice: 150.0), // Use your test chart here
              ),
            ),
          );
        },
        child: const Icon(Icons.show_chart),
      ),
    );
  }

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

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const GameScreen(); // Load the GameScreen
      case 2:
        return const ProfileScreen();
      default:
        return Container();
    }
  }

  Widget _buildHomePage() {
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LiveStockChart(ticker: 'AAPL', userStockPrice: 150.0), // Replace 'AAPL' with your stock ticker and set the user stock price
                  PortfolioManagementWidget(),
                  _buildUserMoney(),
                  const SizedBox(height: 20),
                  _buildStockWidgets(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStockWidgets() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('portfolio')
          .doc('details')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        var portfolioData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
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
                    builder: (context) => StockDetailsPage(ticker: stock['ticker']),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock['ticker'],
                          style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.black),
                        ),
                        Text(
                          'Quantity: ${stock['quantity'].toStringAsFixed(2)}', // Rounded to 2 decimal places
                          style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.black),
                        ),
                        Text(
                          'Equity: \$${stock['equity'].toStringAsFixed(2)}', // Rounded to 2 decimal places
                          style: GoogleFonts.robotoMono(fontSize: 20, color: Colors.black),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TradePage(ticker: stock['ticker']), // Updated to TradePage
                          ),
                        );
                        if (result == 'updated') {
                          _fetchUserMoney(); // Refresh the portfolio when coming back
                        }
                      },
                      icon: const Icon(Icons.show_chart),
                      label: const Text('Trade'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 88, 214, 141), // Match the earlier button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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

  Widget _buildUserMoney() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Text(
              'Buying Power: \$${_currentMoney.toStringAsFixed(2)}',
              style: GoogleFonts.robotoMono(fontSize: 16, color: Colors.black),
            );
          },
        ),
        const SizedBox(width: 5),
        if (_currentMoney > 0)
          const Image(
            image: AssetImage('assets/images/dollaros.webp'),
            height: 20,
          ),
      ],
    );
  }
}
