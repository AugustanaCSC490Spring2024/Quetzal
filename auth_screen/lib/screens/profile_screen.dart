
import 'package:auth_screen/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auth_screen/screens/sign_in_screen.dart';

class ProfileScreen extends StatelessWidget{
  const ProfileScreen({Key? key}) :super (key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {
                        
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
        }, icon: Icon(Icons.arrow_back),),
        title: Text('Profile',style: Theme.of(context).textTheme.headlineMedium),

        actions: [

        ],


      ),
  
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(2),
          child: Column(
            children: [
              SizedBox(
                width: 120,height: 120,
                child: Icon(Icons.person_2_sharp),
              ),
              const SizedBox(height: 3),
              Text('Username',style: Theme.of(context).textTheme.headlineMedium),
              Text('username@gmail.com',style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height:10),
              ElevatedButton(onPressed: (){}, child: const Text("Edit Profile") ),
              const SizedBox(height: 20),
              const Divider(),
            
              //Menu

              ProfileMenuWidget(title: 'Settings', iconData: Icons.settings,onPress: () {},),
              const Divider(),
              //logout button
              ProfileMenuWidget(
                title: 'Log Out', 
                iconData: Icons.light,
                textColor: Color.fromARGB(255, 228, 50, 14),
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
              },),
              
            ],
          ),
        ),
      ),

    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.iconData,
    required this.onPress,
    this.textColor,
  });

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
        child:  Icon(iconData, color:Colors.lime,size: 30,),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium?.apply(color: textColor),),
      
    );
  }
}