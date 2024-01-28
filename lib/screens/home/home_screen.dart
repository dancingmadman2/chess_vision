import 'package:chess_vision/screens/home/components/radar_chart.dart';
import 'package:chess_vision/screens/home/components/recommendations.dart';

import 'package:flutter/material.dart';

import '../../styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: Column(
        children: [
          SizedBox(width: screenWidth - 15, child: RadarChartSample1()),
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
                '2768',
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
                '63%',
                style: subtitleGreen,
              ),
            ],
          ),
          const Spacer(),
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
            height: 7.5,
          ),
          SizedBox(
              width: screenWidth - 15,
              height: 65,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: green,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
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
          const SizedBox(
            height: 7.5,
          )
        ],
      ),
    );
  }
}
