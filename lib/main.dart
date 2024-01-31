import 'package:chess_vision/components/database.dart';
import 'package:chess_vision/screens/minigames/minigames_screen.dart';
import 'package:chess_vision/screens/more/more_screen.dart';
import 'package:chess_vision/screens/puzzles/puzzles_screen.dart';
import 'package:chess_vision/styles.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabase(); // Initialize the database

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static final List<Widget> _screens = <Widget>[
    const HomeScreen(),
    const PuzzlesScreen(),
    const MinigamesScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: primary,
          systemNavigationBarIconBrightness: Brightness.dark),
    );
    return GetMaterialApp(
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: green,
          selectionHandleColor: green,
        ),
      ),
      home: Scaffold(
          body: _screens.elementAt(selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            iconSize: 30,
            type: BottomNavigationBarType.fixed,
            backgroundColor: primary,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/icon_transparent.png',
                  width: 30,
                  height: 30,
                  color: selectedIndex == 0 ? Colors.white : properGrey,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/puzzle.png',
                  width: 30,
                  height: 30,
                  color: selectedIndex == 1 ? green : properGrey,
                ),
                label: 'Puzzles',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/images/target.png',
                  width: 30,
                  height: 30,
                  color: selectedIndex == 2 ? Colors.blue : properGrey,
                ),
                label: 'Minigames',
              ),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz), label: 'More')
            ],
            currentIndex: selectedIndex,
            selectedItemColor: selectedIndex == 1
                ? green
                : selectedIndex == 2
                    ? Colors.blue
                    : Colors.white,
            unselectedItemColor: properGrey,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            unselectedLabelStyle: navUnselected,
            selectedLabelStyle: navSelected,
            onTap: _onTappedBar,
          )),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      selectedIndex = value;
    });
  }
}
