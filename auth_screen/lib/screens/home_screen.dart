import 'package:auth_screen/search_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/screens/profile_screen.dart';
import 'package:auth_screen/portfolio_management.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
        
   
        
        backgroundColor:  Color.fromRGBO(43, 61, 65, 2),
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
        
        backgroundColor: Color.fromRGBO(218, 247, 220, 2),
        
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
        return _buildHomePage();
      case 1:
        return _buildGamePage();
      case 2:
        return ProfileScreen();
      default:
        return Container();
    }
  }
Widget _buildHomePage() {
  return Center(
    child: _isLoading
        ? CircularProgressIndicator()
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PortfolioManagementWidget(),
                 _buildUserMoney(),  // Display user's available money
                SizedBox(height: 20), // Add spacing 
                Text(
                  'Your Stocks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Add spacing below "Your Stocks"
                _buildUserStockList(), // Display user's stocks
                SizedBox(height: 20), // Add spacing
                
              ],
            ),
          ),
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
          style: TextStyle(fontSize: 16),
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}

Widget _buildUserStockList() {
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance.collection('portfolios').doc(FirebaseAuth.instance.currentUser!.uid).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        var portfolioData = (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        List<Map<String, dynamic>> userStocks = (portfolioData.containsKey('stocks') ? List<Map<String, dynamic>>.from(portfolioData['stocks']) : []);

        return ListView.builder(
          shrinkWrap: true,
          itemCount: userStocks.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(userStocks[index]['ticker']),
              subtitle: Text('Quantity: ${userStocks[index]['quantity']}'),
              // Add more information about the stock if needed
            );
          },
        );
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        return CircularProgressIndicator();
      }
    },
  );
}



  Widget _buildGamePage() {
    return Center(
      child: Text('Game Page'),
    );
  }
}
