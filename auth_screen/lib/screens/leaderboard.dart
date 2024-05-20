import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<Leaderboard> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          // Background image with 70% opacity
          Positioned.fill(
            child: Opacity(
              opacity: 0.7,
              child: Image.asset(
                'assets/images/stage.jpg', // Ensure the path is correct
                fit: BoxFit.cover,
              ),
            ),
          ),
          FutureBuilder<QuerySnapshot>(
            future: _firestore.collection('users').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                debugPrint('Error loading leaderboard: ${snapshot.error}');
                return const Center(child: Text('Error loading leaderboard'));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                debugPrint('No data available');
                return const Center(child: Text('No data available'));
              }

              List<Map<String, dynamic>> leaderboardData = [];

              for (var doc in snapshot.data!.docs) {
                var userData = doc.data() as Map<String, dynamic>;
                var userId = doc.id;

                leaderboardData.add({
                  'userId': userId,
                  'name': '${userData['FirstName']} ${userData['LastName']}',
                  'profilePictureUrl': userData['ProfileImageUrl'],
                });
              }

              return FutureBuilder<List<DocumentSnapshot>>(
                future: Future.wait(
                  leaderboardData.map((data) => _firestore
                      .collection('users')
                      .doc(data['userId'])
                      .collection('portfolio')
                      .doc('details')
                      .get()).toList(),
                ),
                builder: (context, detailsSnapshot) {
                  if (detailsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (detailsSnapshot.hasError) {
                    debugPrint('Error loading leaderboard details: ${detailsSnapshot.error}');
                    return const Center(child: Text('Error loading leaderboard details'));
                  }

                  for (int i = 0; i < leaderboardData.length; i++) {
                    var detailsData = detailsSnapshot.data![i].data() as Map<String, dynamic>?;
                    leaderboardData[i]['points'] = detailsData != null ? detailsData['points'] ?? 0 : 0;
                  }

                  leaderboardData.sort((a, b) => b['points'].compareTo(a['points']));

                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Top three users with special display
                        if (leaderboardData.isNotEmpty) _buildTopUser(leaderboardData[0], 1, 'assets/images/1.png'),
                        if (leaderboardData.length > 1) _buildTopUser(leaderboardData[1], 2, 'assets/images/2.png'),
                        if (leaderboardData.length > 2) _buildTopUser(leaderboardData[2], 3, 'assets/images/3.png'),
                        const SizedBox(height: 20),
                        // Regular leaderboard list
                        Expanded(
                          child: ListView.builder(
                            itemCount: leaderboardData.length,
                            itemBuilder: (context, index) {
                              var user = leaderboardData[index];
                              if (index >= 3) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user['profilePictureUrl'] != null
                                        ? NetworkImage(user['profilePictureUrl'])
                                        : const AssetImage('assets/default_profile.png') as ImageProvider,
                                  ),
                                  title: Text(user['name']),
                                  subtitle: Text('Points: ${user['points']}'),
                                );
                              } else {
                                return Container(); // Skip top 3 as they are already displayed
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopUser(Map<String, dynamic> user, int rank, String medalAsset) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: user['profilePictureUrl'] != null
              ? NetworkImage(user['profilePictureUrl'])
              : const AssetImage('assets/default_profile.png') as ImageProvider,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(medalAsset, width: 40, height: 40),
            const SizedBox(width: 10),
            Text(
              user['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          'Points: ${user['points']}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
