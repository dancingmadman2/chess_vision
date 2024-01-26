import 'package:chess_vision/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';

void main() {
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
    return MaterialApp(
      home: Scaffold(

          //wrap this with Stack and add NoConnection() widget
          body: _screens.elementAt(selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            iconSize: 30,
            type: BottomNavigationBarType.fixed,
            backgroundColor: primary,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: 'HOME',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.chart_bar_fill),
                label: 'PUZZLES',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.search),
                label: 'GAMES',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz), label: 'MORE')
            ],
            currentIndex: selectedIndex,
            selectedItemColor: Colors.white,
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
