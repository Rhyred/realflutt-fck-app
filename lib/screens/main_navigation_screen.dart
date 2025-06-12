import 'package:flutter/material.dart';
import 'package:smart_parking_app/screens/dashboard_screen.dart';
import 'package:smart_parking_app/screens/account_settings_screen.dart';
import 'package:smart_parking_app/screens/about_screen.dart';
import 'package:smart_parking_app/theme_provider.dart'; // Import ThemeNotifier

class MainNavigationScreen extends StatefulWidget {
  final ThemeNotifier themeNotifier;

  const MainNavigationScreen({super.key, required this.themeNotifier});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const DashboardScreen(),
      AccountSettingsScreen(
          themeNotifier: widget.themeNotifier), // Teruskan notifier
      const AboutScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo, // Sesuaikan dengan tema
        unselectedItemColor: Colors.grey, // Sesuaikan dengan tema
        backgroundColor: Colors.black, // Sesuaikan dengan tema
        onTap: _onItemTapped,
      ),
    );
  }
}
