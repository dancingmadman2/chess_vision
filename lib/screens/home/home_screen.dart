import 'package:chess_vision/screens/home/components/radar_chart.dart';
import 'package:chess_vision/screens/home/components/recommendations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/helper.dart';
import '../../styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future _future;
  bool isDbInit = false;
  Future<User?> fetchUserStats() async {
    DatabaseHelper db = DatabaseHelper();
    User? user;
    user = await db.getUserStats();

    return user;
  }

  @override
  void initState() {
    super.initState();
    _future = fetchUserStats();
  }

  Future<void> isDatabaseInit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDbInit = prefs.getBool('isDatabaseInitialized')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: primary,
        appBar: AppBar(
          backgroundColor: primary,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icon_transparent.png',
                width: 35,
                height: 35,
              ),
              Text(
                'Chess Vision',
                style: appbarTitle,
              ),
            ],
          ),
        ),
        body: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                    child: defaultTargetPlatform == TargetPlatform.android
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const CupertinoActivityIndicator(
                            color: Colors.white,
                          ));
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                  'Error: ${snapshot.error}',
                  style: defText,
                ));
              } else {
                final User? userStats = snapshot.data;
                return Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                              width: screenWidth - 15,
                              child: RadarChartSample1()),
                          /*
                                      SizedBox(
                        width: screenWidth - 15,
                        height: 150,
                        child: RatingProgressChart()),*/
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Puzzle Rating: ',
                                style: defText,
                              ),
                              Text(
                                '${userStats?.rating ?? '31'}',
                                style: subtitleGreen,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Accuracy: ',
                                style: defText,
                              ),
                              Text(
                                userStats!.puzzlesPlayed != 0
                                    ? '${(userStats.puzzlesWon / userStats.puzzlesPlayed * 100).toStringAsFixed(2)} %'
                                    : '0 %',
                                style: subtitleGreen,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: screenWidth - 10,
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    LinearProgressIndicator(
                                      borderRadius: BorderRadius.circular(4),
                                      minHeight: 20,
                                      value: (userStats.rating - 1000) / 1500,
                                      color: green,
                                    ),
                                    Container(
                                      width: 5,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: green,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 5,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: primary,
                                          ),
                                        ),
                                        Container(
                                          width: 5,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: primary,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      'Beginner',
                                      style: defText,
                                    ),
                                    Text(
                                      'Intermediate ',
                                      style: defText,
                                    ),
                                    Text(
                                      'Expert',
                                      style: defText,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 7.5,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {},
                            child: Recommendations(
                              screenWidth: screenWidth,
                              image: 'assets/images/kesh.png',
                              title: 'Listen to Games',
                              description:
                                  'Listen to sample games to improve your overall blindfold skills.',
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: SizedBox(
                          width: screenWidth - 15,
                          height: 65,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: green,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                            onPressed: () {
                              // navigate to play against bot
                            },
                            child: Text(
                              'Play',
                              style: buttonText,
                            ),
                          )),
                    ),
                  ],
                );
              }
            }));
  }
}
