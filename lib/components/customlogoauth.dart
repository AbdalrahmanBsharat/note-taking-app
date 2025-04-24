import 'package:flutter/material.dart';

class CustomLogoAuth extends StatelessWidget {
  const CustomLogoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 150,
        child: Image.asset(
          "images/logo.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
