import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder UI yang lebih cantik
    return Scaffold(
      appBar: AppBar(title: const Text('History Harian')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 64, color: Colors.blueGrey),
            const SizedBox(height: 16),
            const Text(
              'History Harian & Chart\n(coming soon)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}
