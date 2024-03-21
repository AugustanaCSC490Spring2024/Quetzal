import 'package:auth_screen/screens/profile_screen.dart';
import 'package:flutter/material.dart';



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // track the selected index


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
      ),

      //bottom nav bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: "Game",icon: Icon(Icons.gamepad),),
          BottomNavigationBarItem(label: "Profile", icon: Icon(Icons.person))
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (int index){
          setState(() {
            _selectedIndex = index;
            if (index == 2) {
               // Check if the "Profile" button is tapped
              Navigator.push(

                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );}
              
          });
        },
      ),
    );
  }
}
