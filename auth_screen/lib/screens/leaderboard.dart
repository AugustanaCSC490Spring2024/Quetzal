import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _pointsFormat = NumberFormat("#,##0.0", "en_US");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF3A5199), // Match the app's theme color
              const Color(0xFF2C74B3),
            ],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<QuerySnapshot>(
            future: _firestore.collection('users').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingView();
              }

              if (snapshot.hasError) {
                return _buildErrorView(snapshot.error.toString());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyView();
              }

              List<Map<String, dynamic>> leaderboardData = [];

              for (var doc in snapshot.data!.docs) {
                var userData = doc.data() as Map<String, dynamic>;
                var userId = doc.id;

                leaderboardData.add({
                  'userId': userId,
                  'name':
                      '${userData['FirstName'] ?? ''} ${userData['LastName'] ?? ''}',
                  'profilePictureUrl': userData['ProfileImageUrl'],
                });
              }

              return FutureBuilder<List<DocumentSnapshot>>(
                future: Future.wait(
                  leaderboardData
                      .map((data) => _firestore
                          .collection('users')
                          .doc(data['userId'])
                          .collection('portfolio')
                          .doc('details')
                          .get())
                      .toList(),
                ),
                builder: (context, detailsSnapshot) {
                  if (detailsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return _buildLoadingView();
                  }

                  if (detailsSnapshot.hasError) {
                    return _buildErrorView(detailsSnapshot.error.toString());
                  }

                  for (int i = 0; i < leaderboardData.length; i++) {
                    var detailsData = detailsSnapshot.data![i].data()
                        as Map<String, dynamic>?;
                    leaderboardData[i]['points'] = detailsData != null
                        ? (detailsData['points'] ?? 0.0).toDouble()
                        : 0.0;
                  }

                  // Sort by points in descending order
                  leaderboardData.sort((a, b) =>
                      (b['points'] as double).compareTo(a['points'] as double));

                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        'Top Traders',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Compete for the highest score',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Podium section for top 3
                      if (leaderboardData.isNotEmpty)
                        _buildPodium(leaderboardData),

                      const SizedBox(height: 20),

                      // Header for list
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Text(
                              'Full Rankings',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${leaderboardData.length} traders',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Remaining users list
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 20),
                            itemCount: leaderboardData.length,
                            itemBuilder: (context, index) {
                              if (index < 3) {
                                // Skip top 3 as they're in the podium
                                return const SizedBox.shrink();
                              }
                              return _buildRankListItem(
                                  context, leaderboardData[index], index + 1);
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> leaderboardData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 250, // Increased height to accommodate all elements
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Podium platforms - bottom layer
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd place platform
                  if (leaderboardData.length > 1)
                    Expanded(
                      child: _buildPodiumPlatform(
                        height: 70,
                        color: const Color(0xFFE0E0E0),
                        child: Text(
                          '2',
                          style: GoogleFonts.montserrat(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),

                  // 1st place platform (in center, slightly wider)
                  if (leaderboardData.isNotEmpty)
                    Expanded(
                      flex: 3,
                      child: _buildPodiumPlatform(
                        height: 100,
                        color: const Color(0xFFFFD700),
                        child: Text(
                          '1',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                  // 3rd place platform
                  if (leaderboardData.length > 2)
                    Expanded(
                      child: _buildPodiumPlatform(
                        height: 50,
                        color: const Color(0xFFCD7F32),
                        child: Text(
                          '3',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Users on podium - each centered over their platform
            Positioned(
              bottom: 10, // Start closer to bottom (just above platforms)
              left: 0,
              right: 0,
              top: 0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2nd place contestant
                  if (leaderboardData.length > 1)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 70), // Position above platform
                        child: _buildPodiumUser(
                          leaderboardData[1],
                          medalAsset: 'assets/images/2.png',
                        ),
                      ),
                    ),

                  // 1st place contestant
                  if (leaderboardData.isNotEmpty)
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 100), // Position above platform
                        child: _buildPodiumUser(
                          leaderboardData[0],
                          medalAsset: 'assets/images/1.png',
                          isFirst: true,
                        ),
                      ),
                    ),

                  // 3rd place contestant
                  if (leaderboardData.length > 2)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 50), // Position above platform
                        child: _buildPodiumUser(
                          leaderboardData[2],
                          medalAsset: 'assets/images/3.png',
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumPlatform({
    required double height,
    required Color color,
    required Widget child,
  }) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(
          horizontal: 2), // Small gap between platforms
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }

  Widget _buildPodiumUser(
    Map<String, dynamic> user, {
    required String medalAsset,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end, // Stack from bottom
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar with medal
        Stack(
          alignment: Alignment.center,
          children: [
            // Avatar
            CircleAvatar(
              radius: isFirst ? 40 : 30,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: isFirst ? 38 : 28,
                backgroundImage: user['profilePictureUrl'] != null
                    ? NetworkImage(user['profilePictureUrl'])
                    : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
              ),
            ),
            // Medal
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(
                    medalAsset,
                    width: 25,
                    height: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // User name
        Text(
          _shortenName(user['name']),
          style: GoogleFonts.montserrat(
            fontSize: isFirst ? 14 : 12,
            fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),

        // Points
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _pointsFormat.format(user['points']),
            style: GoogleFonts.montserrat(
              fontSize: isFirst ? 14 : 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankListItem(
      BuildContext context, Map<String, dynamic> user, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Rank number
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A5199).withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  rank.toString(),
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3A5199),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User avatar
              CircleAvatar(
                radius: 22,
                backgroundImage: user['profilePictureUrl'] != null
                    ? NetworkImage(user['profilePictureUrl'])
                    : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 12),

              // User name
              Expanded(
                child: Text(
                  user['name'],
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Points
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A5199),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _pointsFormat.format(user['points']),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortenName(String name) {
    if (name.length <= 10) return name;
    return '${name.substring(0, 8)}...';
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading leaderboard...',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: GoogleFonts.montserrat(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3A5199),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.people_outline,
            color: Colors.white,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'No data available',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start playing games to earn points!',
            style: GoogleFonts.montserrat(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
