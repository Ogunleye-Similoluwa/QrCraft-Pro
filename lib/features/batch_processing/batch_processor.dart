import 'dart:io';
import 'package:csv/csv.dart';
import 'package:archive/archive.dart';

class QRCode {
  final String data;
  final String? path;

  const QRCode({
    required this.data,
    this.path,
  });
}

class BatchProcessor {
  Future<List<String>> processCSV(File csvFile) async {
    final input = await csvFile.readAsString();
    final rows = const CsvToListConverter().convert(input);
    return rows.map((row) => row[0].toString()).toList();
  }

  Future<List<QRCode>> generateBulkQRCodes(List<String> data) async {
    final qrCodes = <QRCode>[];
    final tempDir = await Directory.systemTemp.createTemp('qr_codes');
    
    for (var i = 0; i < data.length; i++) {
      final path = '${tempDir.path}/qr_$i.png';
      // Generate QR code image and save to path
      qrCodes.add(QRCode(data: data[i], path: path));
    }
    
    return qrCodes;
  }

  Future<void> exportToZip(List<QRCode> codes) async {
    final tempDir = await Directory.systemTemp.createTemp('qr_zip');
    final zipPath = '${tempDir.path}/qr_codes.zip';
    
    // Create ZIP archive
    final archive = Archive();
    
    for (final code in codes) {
      if (code.path != null) {
        final file = File(code.path!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final fileName = file.path.split('/').last;
          final archiveFile = ArchiveFile(fileName, bytes.length, bytes);
          archive.addFile(archiveFile);
        }
      }
    }
    
    // Encode and save the ZIP
    final encodedArchive = ZipEncoder().encode(archive);
    if (encodedArchive != null) {
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(encodedArchive);
    }
  }
} 