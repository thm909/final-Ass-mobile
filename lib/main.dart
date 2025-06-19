import 'package:flutter/material.dart';
import 'loginscreen.dart';
import 'homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(WTMSApp());
}

class WTMSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WTMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (_, snap) {
          if (snap.hasData) {
            return snap.data! ? HomeScreen() : LoginScreen();
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('worker');
  }
}
