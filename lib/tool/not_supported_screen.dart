import 'package:flutter/material.dart';

class NotSupportedScreen extends StatelessWidget {
  const NotSupportedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_android,
              size: 80,
            ),
            SizedBox(height: 20),
            Text(
              "Mobile Device Only",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "This application is supported only on mobile phones.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}