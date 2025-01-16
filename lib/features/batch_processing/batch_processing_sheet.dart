import 'package:flutter/material.dart';

class BatchProcessingSheet extends StatelessWidget {
  const BatchProcessingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Batch Processing',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Add batch processing logic here
            },
            child: const Text('Start Processing'),
          ),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'Processing Status: Ready',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}