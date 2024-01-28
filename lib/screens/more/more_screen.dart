import 'package:chess_vision/styles.dart';
import 'package:flutter/material.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        backgroundColor: primary,
        title: Text(
          'More',
          style: appbarTitle,
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: const Center(
          child: Column(
        children: [
          Icon(
            Icons.more_horiz,
            size: 60,
            color: Colors.white,
          ),
          SizedBox(
            height: 30,
          ),
        ],
      )),
    );
  }
}
