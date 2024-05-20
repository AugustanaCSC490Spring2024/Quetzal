import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
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

              return ListView.builder(
                itemCount: leaderboardData.length,
                itemBuilder: (context, index) {
                  var user = leaderboardData[index];
                  debugPrint('User: ${user['name']}, Points: ${user['points']}');
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['profilePictureUrl'] != null
                          ? NetworkImage(user['profilePictureUrl'])
                          : const AssetImage('assets/default_profile.png') as ImageProvider,
                    ),
                    title: Text(user['name']),
                    subtitle: Text('Points: ${user['points']}'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
