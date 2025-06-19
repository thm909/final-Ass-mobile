import 'package:flutter/material.dart';
import 'tasklistscreen.dart';
import 'historyscreen.dart';
import 'profilescreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = [
    {'title': 'My Tasks', 'widget': TaskListScreen()},
    {'title': 'Submission History', 'widget': HistoryScreen()},
    {'title': 'My Profile', 'widget': ProfileScreen()},
  ];

  void _navigateTo(int i) {
    setState(() => _index = i);
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = _pages[_index];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 2,
        title: Text(currentPage['title'] as String),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              accountName: Text("Welcome!"),
              accountEmail: Text("Worker System"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.teal, size: 30),
              ),
            ),
            _buildDrawerItem(Icons.task, "Tasks", 0),
            _buildDrawerItem(Icons.history, "History", 1),
            _buildDrawerItem(Icons.person, "Profile", 2),
          ],
        ),
      ),
      body: currentPage['widget'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, int pageIndex) {
    return ListTile(
      leading: Icon(icon, color: _index == pageIndex ? Colors.teal : null),
      title: Text(
        title,
        style: TextStyle(
          color: _index == pageIndex ? Colors.teal : null,
          fontWeight: _index == pageIndex ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: _index == pageIndex,
      selectedTileColor: Colors.teal.withOpacity(0.1),
      onTap: () => _navigateTo(pageIndex),
    );
  }
}
