import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class BatchQRCode {
  final String data;
  final String filename;
  final GlobalKey qrKey = GlobalKey();

  BatchQRCode({
    required this.data,
    required this.filename,
  });
}

class BatchProcessor {
  Future<List<String>> processCSV(File csvFile) async {
    try {
      final input = await csvFile.readAsString();
      final rows = const CsvToListConverter().convert(input);
      // Assuming first column contains QR data
      return rows.map((row) => row[0].toString()).toList();
    } catch (e) {
      throw Exception('Failed to process CSV: ${e.toString()}');
    }
  }

  Future<List<BatchQRCode>> generateBulkQRCodes(List<String> data) async {
    return data.asMap().entries.map((entry) {
      return BatchQRCode(
        data: entry.value,
        filename: 'qr_${entry.key + 1}.png',
      );
    }).toList();
  }

  Future<String> exportToZip(List<BatchQRCode> codes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final archive = Archive();

      // Create QR code images and add to archive
      for (var code in codes) {
        final qrWidget = RepaintBoundary(
          key: code.qrKey,
          child: QrImageView(
            data: code.data,
            version: QrVersions.auto,
            size: 200,
            backgroundColor: Colors.white,
          ),
        );

        final image = await _captureQRCode(code.qrKey);
        final pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);
        
        if (pngBytes != null) {
          final archiveFile = ArchiveFile(
            code.filename,
            pngBytes.lengthInBytes,
            pngBytes.buffer.asUint8List(),
          );
          archive.addFile(archiveFile);
        }
      }

      // Save zip file
      final zipPath = '${tempDir.path}/qr_codes.zip';
      final zipFile = File(zipPath);
      final zipData = ZipEncoder().encode(archive);
      if (zipData != null) {
        await zipFile.writeAsBytes(zipData);
        return zipPath;
      }
      
      throw Exception('Failed to create zip file');
    } catch (e) {
      throw Exception('Failed to export QR codes: ${e.toString()}');
    }
  }

  Future<ui.Image> _captureQRCode(GlobalKey qrKey) async {
    final boundary = qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception('Failed to find QR code boundary');
    
    final image = await boundary.toImage(pixelRatio: 3.0);
    return image;
  }
} 