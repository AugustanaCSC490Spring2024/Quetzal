// ignore_for_file: prefer_final_fields, avoid_print

import 'package:auth_screen/screens/quiz.dart';
import 'package:auth_screen/screens/speed_run_game.dart';
import 'package:auth_screen/screens/stocks_detail_page.dart';
import 'package:auth_screen/search_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/screens/profile_screen.dart';
import 'package:auth_screen/portfolio_management.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getSelectedTitle()),
        foregroundColor: Colors.white,
        
   
        
        backgroundColor:  const Color.fromRGBO(43, 61, 65, 2),
        actions: [
          SearchButton(
            onPressed: (query) {
              print('Search query: $query');
            },
          ),
        ],
      ),
      body:_buildBody(),
      backgroundColor: const Color.fromRGBO(171, 200, 192, 2),
      bottomNavigationBar: BottomNavigationBar(
        
        backgroundColor: const Color.fromRGBO(218, 247, 220, 2),
        
        items: const [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Game", icon: Icon(Icons.gamepad)),
          BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person))
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
        return _buildHomePage(context);
      case 1:
        return _buildGamePage(context);
      case 2:
        return const ProfileScreen();
      default:
        return Container();
    }
  }
Widget _buildHomePage(BuildContext context) {
  return Center(
    child: _isLoading
        ? const CircularProgressIndicator()
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PortfolioManagementWidget(),
                _buildUserMoney(),  
                const SizedBox(height: 20), 
                _buildStockWidgets(context), 
                const SizedBox(height: 20), 
              ],
            ),
          ),
  );
}


Widget _buildStockWidgets(BuildContext context) {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance.collection('portfolios').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        var portfolioData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        List<Map<String, dynamic>> userStocks = (portfolioData.containsKey('stocks') ? List<Map<String, dynamic>>.from(portfolioData['stocks']) : []);

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
                padding: const EdgeInsets.only(left: 10), 
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stock['ticker']}',
                        style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 1, 1, 1)),
                      ),
                      Text(
                        'Quantity: ${stock['quantity']}',
                        style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 1, 1, 1)),
                      ),
                      //ADD MORE STOCK INFO HERE MAYBE OR IN THE STOCK DETAIL SCREEN ?
                      const SizedBox(height: 20), 
                      
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}










Widget _buildUserMoney() {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance.collection('portfolios').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        var portfolioData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        double userMoney = (portfolioData.containsKey('money') ? portfolioData['money'] : 100000); // default value is 100000

        return Text(
          'Buying Power: \$${userMoney.toStringAsFixed(2)}', // Displaying user's available money
          style: const TextStyle(fontSize: 16),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return const CircularProgressIndicator();
      }
    },
  );
}




  Widget _buildGamePage(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuizScreen()),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Quiz',
              style: TextStyle(
                color: Color.fromARGB(255, 17, 1, 1),
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  Speedrun()),  
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Speed Run',
              style: TextStyle(
                color: Color.fromARGB(255, 25, 1, 1),
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}



      
}
