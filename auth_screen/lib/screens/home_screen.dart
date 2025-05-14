import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/search_button.dart';
import 'package:auth_screen/portfolio_management.dart';
import 'package:auth_screen/widgets/stock_list_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getSelectedTitle(),
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        elevation: 0, // Remove elevation for a more modern look
        backgroundColor: theme.colorScheme.primary,
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
      backgroundColor: theme.colorScheme.background,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 8,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.sports_esports_rounded), label: "Game"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(), // Header with welcome message
          const SizedBox(height: 20),

          // Portfolio Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Portfolio Overview',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Portfolio Card with shadow and rounded corners
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: PortfolioManagementWidget(),
            ),
          ),

          const SizedBox(height: 20),

          // Money Information Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.attach_money_rounded,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildUserMoney()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Stocks Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'Your Stocks',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Stocks List - now using our StockListWidget
          const StockListWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Builds a header card with a welcome message and a refresh button.
  Widget _buildWelcomeHeader() {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? "Trader";

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary.withAlpha(204),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(230),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        var portfolioData =
            (snapshot.data!.data() as Map<String, dynamic>?) ?? {};
        double userMoney = portfolioData.containsKey('money')
            ? portfolioData['money'].toDouble()
            : 100000.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buying Power',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            Text(
              '\$${userMoney.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
          ],
        );
      },
    );
  }
}
