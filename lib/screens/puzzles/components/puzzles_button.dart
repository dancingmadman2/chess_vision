import 'package:chess_vision/styles.dart';
import 'package:flutter/material.dart';

class PuzzlesButton extends StatelessWidget {
  const PuzzlesButton({
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
    return SizedBox(
      width: screenWidth - 15,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: mono,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
        onPressed: () {},
        child: Row(
          children: [
            Image.asset(
              image,
              height: 50,
              color: Colors.white,
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              children: [
                SizedBox(
                  width: screenWidth / 1.5,
                  child: Text(
                    title,
                    style: buttonText,
                  ),
                ),
                SizedBox(
                  width: screenWidth / 1.5,
                  child: Text(
                    description,
                    style: defTextGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
