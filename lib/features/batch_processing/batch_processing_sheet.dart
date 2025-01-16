import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'batch_processor.dart';

class BatchProcessingSheet extends StatefulWidget {
  const BatchProcessingSheet({super.key});

  @override
  State<BatchProcessingSheet> createState() => _BatchProcessingSheetState();
}

class _BatchProcessingSheetState extends State<BatchProcessingSheet> {
  final _batchProcessor = BatchProcessor();
  bool _isProcessing = false;
  String _status = 'Ready';
  double _progress = 0;

  Future<void> _processFile() async {
    try {
      setState(() {
        _isProcessing = true;
        _status = 'Selecting file...';
        _progress = 0.1;
      });

      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        setState(() {
          _status = 'No file selected';
          _isProcessing = false;
        });
        return;
      }

      setState(() {
        _status = 'Processing CSV...';
        _progress = 0.3;
      });

      // Process CSV
      final file = File(result.files.single.path!);
      final data = await _batchProcessor.processCSV(file);

      setState(() {
        _status = 'Generating QR codes...';
        _progress = 0.6;
      });

      // Generate QR codes
      final qrCodes = await _batchProcessor.generateBulkQRCodes(data);

      setState(() {
        _status = 'Creating ZIP file...';
        _progress = 0.8;
      });

      // Export to ZIP
      final zipPath = await _batchProcessor.exportToZip(qrCodes);

      setState(() {
        _status = 'Sharing file...';
        _progress = 0.9;
      });

      // Share the ZIP file
      await Share.shareXFiles([XFile(zipPath)]);

      setState(() {
        _status = 'Complete!';
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

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
            onPressed: _isProcessing ? null : _processFile,
            child: Text(_isProcessing ? 'Processing...' : 'Select CSV File'),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress,
          ),
          const SizedBox(height: 16),
          Text(
            'Status: $_status',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}