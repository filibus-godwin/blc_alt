import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your vote has be cast successfully',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Go to '),
                TextSpan(
                  text: 'http://localhost:123',
                  style: TextStyle(color: Colors.blue.shade500),
                ),
                const TextSpan(text: ' to view the election updates.'),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
