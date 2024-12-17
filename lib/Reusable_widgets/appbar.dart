import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back), // Back button
        onPressed: () {
          Navigator.pop(context); // Navigate to the previous screen
        },
      ),
      title: Text(title), // Title of the page
      backgroundColor: Color(0xFF42A5F5), // You can customize the color
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
