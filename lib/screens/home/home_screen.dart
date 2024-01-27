import 'package:chess_vision/screens/home/components/recommendations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../styles.dart';
import 'components/progress_chart.dart';

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
          const SizedBox(
            height: 15,
          ),
          // Put here some graphs and stats
          Container(
            //padding: const EdgeInsets.only(left: 5),
            alignment: Alignment.center,
            child: Text(
              'Stats',
              style: title,
            ),
          ),
          const SizedBox(
            height: 15,
          ),

          SizedBox(
            width: screenWidth - 15,
            height: 150,
            child: RatingProgressChart(),
          ),
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
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              Text(
                'Number of Attempts: ',
                style: defText,
              ),
              Text(
                '138',
                style: subtitleBlue,
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

          Container(
            width: screenWidth - 15,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8), // Rounded corners
              color: green, // Background color of the button
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color
                  offset: const Offset(0, 3), // Shadow position
                  blurRadius: 5, // Shadow blur
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: green,

                shadowColor:
                    Colors.transparent, // No shadow for the button itself
                elevation: 0, // No elevation for the button itself
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 20), // Padding inside the button
              ),
              child: Text(
                'Play',
                style: buttonText,
              ),
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }
}
