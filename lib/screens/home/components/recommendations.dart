import 'package:chess_vision/styles.dart';
import 'package:flutter/material.dart';

class Recommendations extends StatelessWidget {
  const Recommendations({
    super.key,
    required this.screenWidth,
    required this.image,
    required this.title,
    required this.description,
  });

  final double screenWidth;
  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 5,
            ),
            Stack(
              children: [
                Container(
                  width: screenWidth / 2 - 15,
                  height: 100,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), color: mono),
                ),
                Image.asset(
                  image,
                  width: 150,
                ),
              ],
            ),
            const SizedBox(
              width: 15,
            ),
            SizedBox(
              width: screenWidth / 2 - 15,
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth / 2 - 15,
                    child: Text(
                      title,
                      textAlign: TextAlign.start,
                      style: defText,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    width: screenWidth / 2 - 15,
                    child: Text(
                      description,
                      textAlign: TextAlign.start,
                      style: defTextLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
        ),
      ],
    );
  }
}
