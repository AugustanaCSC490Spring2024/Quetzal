// import 'package:auth_screen/screens/leaderboard.dart';         **** CHANGES MADE ON 5/18/24: 5:55pm
// import 'package:flutter/material.dart';
// import 'package:auth_screen/screens/profile_screen.dart';
// import 'package:auth_screen/screens/quiz.dart';
// import 'package:auth_screen/screens/speed_run_game.dart';
// import 'package:auth_screen/search_button.dart';
// import 'package:auth_screen/portfolio_management.dart';
// import 'package:auth_screen/screens/stocks_detail_page.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   HomePageState createState() => HomePageState();
// }

// class HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;
//   final bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_getSelectedTitle()),
//         backgroundColor: const Color.fromARGB(255, 203, 209, 211),
//         actions: [
//           SearchButton(
//             onPressed: (query) {
//               if (kDebugMode) {
//                 print('Search query: $query');
//               }
//             },
//           ),
//         ],
//       ),
//       body: _buildBody(),
//       backgroundColor: const Color.fromRGBO(171, 200, 192, 1),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: const Color.fromRGBO(218, 247, 220, 1),
//         items: const [
//           BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
//           BottomNavigationBarItem(label: "Game", icon: Icon(Icons.gamepad)),
//           BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person))
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue,
//         onTap: (int index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//       ),
//     );
//   }

//   String _getSelectedTitle() {
//     switch (_selectedIndex) {
//       case 0:
//         return "Home";
//       case 1:
//         return "Game";
//       case 2:
//         return "Profile";
//       default:
//         return "Home";
//     }
//   }

//   Widget _buildBody() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildHomePage();
//       case 1:
//         return _buildGamePage();
//       case 2:
//         return const ProfileScreen();
//       default:
//         return Container();
//     }
//   }

//   Widget _buildHomePage() {
//     return Center(
//       child: _isLoading
//           ? const CircularProgressIndicator()
//           : SingleChildScrollView(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   PortfolioManagementWidget(),
//                   _buildUserMoney(),
//                   const SizedBox(height: 20),
//                   _buildStockWidgets(),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildStockWidgets() {
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .collection('portfolio')
//           .doc('details')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }

//         var portfolioData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
//         List<Map<String, dynamic>> userStocks =
//             portfolioData.containsKey('stocks')
//                 ? List<Map<String, dynamic>>.from(portfolioData['stocks'])
//                 : [];

//         return Column(
//           children: userStocks.map((stock) {
//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => StockDetailsPage(ticker: stock['ticker']),
//                   ),
//                 );
//               },
//               child: Padding(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: Align(
//                   alignment: Alignment.centerLeft,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${stock['ticker']}',
//                         style: const TextStyle(fontSize: 20, color: Colors.black),
//                       ),
//                       Text(
//                         'Quantity: ${stock['quantity']}',
//                         style: const TextStyle(fontSize: 20, color: Colors.black),
//                       ),
//                       Text(
//                         'Equity: \$${stock['equity'].toStringAsFixed(2)}',
//                         style: const TextStyle(fontSize: 20, color: Colors.black),
//                       ),
//                       const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildUserMoney() {
//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('users')
//           .doc(FirebaseAuth.instance.currentUser!.uid)
//           .collection('portfolio')
//           .doc('details')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Error: ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }

//         var portfolioData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
//         double userMoney = portfolioData.containsKey('money')
//             ? portfolioData['money'].toDouble()
//             : 100000; // default value is 100000

//         return Text(
//           'Buying Power: \$${userMoney.toStringAsFixed(2)}',
//           style: const TextStyle(fontSize: 16),
//         );
//       },
//     );
//   }

//   Widget _buildGamePage() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Expanded(
//           child: Center(
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const QuizScreen()),
//                 );
//               },
//               child: const Text(
//                 'Quiz',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontWeight: FontWeight.bold,
//                   fontStyle: FontStyle.italic,
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const Spacer(),
//         Expanded(
//           child: Center(
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const Speedrun()),
//                 );
//               },
//               child: const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10.0),
//                 child: Text(
//                   'Speed Run',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontStyle: FontStyle.italic,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const Spacer(),
//         Expanded(
//           child: Center(
//             child: GestureDetector(
//               onTap: () {
//                 _navigateToLeaderboard();
//               },
//               child: const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 10.0),
//                 child: Text(
//                   'Leaderboard',
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                     fontStyle: FontStyle.italic,
//                     decoration: TextDecoration.underline,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const Spacer(),
//       ],
//     );
//   }

//   void _navigateToLeaderboard() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const Leaderboard()),
//     );                                                                   **** CHANGES MADE ON 5/18/24: 5:55pm
//   }
// }



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 

import 'package:auth_screen/screens/leaderboard.dart';
import 'package:auth_screen/screens/profile_screen.dart';
import 'package:auth_screen/screens/quiz.dart';
import 'package:auth_screen/screens/speed_run_game.dart';
import 'package:auth_screen/search_button.dart';
import 'package:auth_screen/portfolio_management.dart';
import 'package:auth_screen/screens/stocks_detail_page.dart';
import 'package:auth_screen/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getSelectedTitle()),
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
        return _buildGamePage();
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
                  _buildStockWidgets(),
                  const SizedBox(height: 20),
                  PortfolioManagementWidget(),
                  _buildUserMoney(),
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
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        var userData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        List<Map<String, dynamic>> userStocks = userData.containsKey('stocks')
            ? List<Map<String, dynamic>>.from(userData['stocks'])
            : [];

        return Column(
          children: userStocks.map((stock) {
            return FutureBuilder<Map<String, dynamic>>(
              future: ApiService.fetchStockData(stock['symbol']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                var stockData = snapshot.data ?? {};
                double currentPrice = stockData['c'] ?? 0.0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StockDetailsPage(ticker: stock['symbol']),
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
                            '${stock['symbol']}',
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            'Current Price: \$${currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            'Quantity: ${stock['quantity']}',
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          Text(
                            'Equity: \$${(currentPrice * stock['quantity']).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 20, color: Colors.black),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUserMoney() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        var userData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        double userMoney = userData.containsKey('money')
            ? userData['money'].toDouble()
            : 100000; // default value is 100000

        return Text(
          'Buying Power: \$${userMoney.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16),
        );
      },
    );
  }

  Widget _buildGamePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
              },
              child: const Text(
                'Quiz',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Speedrun()),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Speed Run',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
        Expanded(
          child: Center(
            child: GestureDetector(
              onTap: () {
                _navigateToLeaderboard();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Leaderboard',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    decoration: TextDecoration.underline,  
                  ),
                ),
              ),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  void _navigateToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Leaderboard()),
    );
  }
}
