import 'package:auth_screen/search_button.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/screens/profile_screen.dart';
import 'package:auth_screen/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _marketValues = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getSelectedTitle()),
        actions: [
          SearchButton(
            onPressed: (query) {
              // Handle the search query here
              print('Search query: $query');
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
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
                children: [
 
                ],
              ),
            ),
    );
  }


  Widget _buildGamePage() {
    return Center(
      child: Text('Game Page'),
    );
  }
}
