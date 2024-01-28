import 'package:chess_vision/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KeshAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KeshAppBar({
    Key? key,
    this.height = kToolbarHeight,
    required this.title,
  }) : super(key: key);

  final double height;
  final String title;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      //height: preferredSize.height,

      backgroundColor: primary,

      leading: IconButton(
        icon: const Icon(
          CupertinoIcons.back,
          color: Colors.white,
        ),
        onPressed: () {
          // Define your custom back button behavior here.
          Navigator.of(context).pop();
        },
      ),
      title: Text(
        title,
        style: appbarTitle,
        textAlign: TextAlign.center,
      ),

      centerTitle: true,
    );
  }
}
