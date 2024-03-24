import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auth_screen/screens/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          late Map<String, dynamic> userData;
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty){
            userData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          }else{
            userData = {};
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Icon(Icons.person),
                ),
                const SizedBox(height: 10),
                Text(
                  '${userData['FirstName']} ${userData['LastName']}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  userData['Email'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    
                  },
                  child: const Text("Edit Profile"),
                ),
                const SizedBox(height: 20),
                const Divider(),

                
                ProfileMenuWidget(
                  title: 'Settings',
                  iconData: Icons.settings,
                  onPress: () {
                    
                  },
                ),
                const Divider(),

                
                ProfileMenuWidget(
                  title: 'Log Out',
                  iconData: Icons.logout,
                  textColor: Colors.red,
                  onPress: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      print("Signed Out.");
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const SignIn(),
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    Key? key,
    required this.title,
    required this.iconData,
    required this.onPress,
    this.textColor,
  }) : super(key: key);

  final String title;
  final IconData iconData;
  final VoidCallback onPress;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        child: Icon(
          iconData,
          color: Colors.black,
          size: 30,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
