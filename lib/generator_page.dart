import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'app_theme.dart';

enum QRType {
  text,
  email,
  url,
  phone,
  wifi,
  vCard,
  // New Types
  calendar,
  location,
  cryptocurrency,
  socialMedia,
  menu,
  businessCard,
  pdf,
  audio,
  whatsapp,
  telegram,
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _wifiNameController = TextEditingController();
  final TextEditingController _wifiPasswordController = TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _cryptoAddressController = TextEditingController();
  String data = '';
  final GlobalKey _qrKey = GlobalKey();
  QRType selectedQRType = QRType.text;
  Color qrColor = Colors.black;
  Color backgroundColor = Colors.white;
  bool _obscurePassword = true;

  List<String> qrTemplates = [
    'Classic',
    'Modern',
    'Minimal',
    'Rounded',
    'Dotted',
    'Custom Logo',
    'Gradient',
    'Pattern',
  ];
  String selectedTemplate = 'Classic';

  double cornerRadius = 0.0;
  double dotScale = 1.0;
  bool useGradient = false;
  Color gradientColor1 = Colors.blue;
  Color gradientColor2 = Colors.purple;

  List<Map<String, dynamic>> qrTypes = [
    {'type': QRType.text, 'icon': Icons.text_fields, 'label': 'Text'},
    {'type': QRType.url, 'icon': Icons.link, 'label': 'URL'},
    {'type': QRType.email, 'icon': Icons.email, 'label': 'Email'},
    {'type': QRType.phone, 'icon': Icons.phone, 'label': 'Phone'},
    {'type': QRType.wifi, 'icon': Icons.wifi, 'label': 'WiFi'},
    {'type': QRType.vCard, 'icon': Icons.contact_page, 'label': 'vCard'},
  ];

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaver.saveImage(pngBytes);

      if (result['isSuccess']) {
        _saveToHistory();
        _showSnackBar('QR code saved to gallery');
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      _showSnackBar('Error saving QR code: ${e.toString()}');
    }
  }

  void _saveToHistory() {
    final box = Hive.box('qrHistory');
    box.add({
      'type': selectedQRType.toString(),
      'data': data,
      'timestamp': DateTime.now().toString(),
    });
  }

  Future<void> _shareQRCode() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_code.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Check out this QR Code!');
    } catch (e) {
      _showSnackBar('Error sharing QR code: ${e.toString()}');
    }
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Customize Colors'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('QR Code Color'),
                ColorPicker(
                  pickerColor: qrColor,
                  onColorChanged: (Color color) => setState(() => qrColor = color),
                ),
                const Divider(),
                const Text('Background Color'),
                ColorPicker(
                  pickerColor: backgroundColor,
                  onColorChanged: (Color color) => setState(() => backgroundColor = color),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDataBasedOnType() {
    switch (selectedQRType) {
      case QRType.email:
        return 'mailto:${_textController.text}';
      case QRType.url:
        return _textController.text.startsWith('http')
            ? _textController.text
            : 'https://${_textController.text}';
      case QRType.phone:
        return 'tel:${_textController.text}';
      case QRType.wifi:
        return 'WIFI:S:${_wifiNameController.text};T:WPA;P:${_wifiPasswordController.text};;';
      case QRType.vCard:
        return '''BEGIN:VCARD
VERSION:3.0
FN:${_textController.text}
TEL:${_wifiNameController.text}
EMAIL:${_wifiPasswordController.text}
END:VCARD''';
      default:
        return _textController.text;
    }
  }

  Future<void> _generateBulkQRCodes() async {
    // Implementation for bulk generation
  }

  Future<void> _exportAsVector() async {
    // Implementation for SVG export
  }

  Future<void> _addCustomLogo() async {
    // Implementation for custom logo
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create and customize',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'your QR code ✨',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: qrTypes.length,
                itemBuilder: (context, index) {
                  final type = qrTypes[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedQRType = type['type'];
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: selectedQRType == type['type']
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            type['icon'],
                            color: selectedQRType == type['type']
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            type['label'],
                            style: TextStyle(
                              color: selectedQRType == type['type']
                                  ? Theme.of(context).scaffoldBackgroundColor
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildInputFields(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  data = _formatDataBasedOnType();
                });
              },
              child: const Text('Generate QR Code'),
            ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 30),
              _buildQRCode(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    switch (selectedQRType) {
      case QRType.wifi:
        return Column(
          children: [
            _buildTextField(
              controller: _wifiNameController,
              label: 'Network Name (SSID)',
              icon: Icons.wifi,
              hint: 'Enter WiFi network name',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _wifiPasswordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter WiFi password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
              ),
            ),
          ],
        );
      case QRType.vCard:
        return Column(
          children: [
            _buildTextField(
              controller: _textController,
              label: 'Full Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _wifiNameController,
              label: 'Phone Number',
              icon: Icons.phone,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _wifiPasswordController,
              label: 'Email',
              icon: Icons.email,
            ),
          ],
        );
      default:
        return _buildTextField(
          controller: _textController,
          label: '${selectedQRType.toString().split('.').last} Content',
          icon: _getIconForType(selectedQRType),
        );
    }
  }

  IconData _getIconForType(QRType type) {
    switch (type) {
      case QRType.text:
        return Icons.text_fields;
      case QRType.email:
        return Icons.email;
      case QRType.url:
        return Icons.link;
      case QRType.phone:
        return Icons.phone;
      default:
        return Icons.qr_code;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String hint = '',
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    if (data.isEmpty) return const SizedBox.shrink();
    
    return Card(
      elevation: 8,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            RepaintBoundary(
              key: _qrKey,
              child: QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: backgroundColor,
                foregroundColor: qrColor,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                embeddedImage: const AssetImage('assets/app_icon.png'),
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: const Size(40, 40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.color_lens,
                  label: 'Style',
                  onTap: () => _showColorPicker(context),
                ),
                _buildActionButton(
                  icon: Icons.save_alt,
                  label: 'Save',
                  onTap: _captureAndSavePng,
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: _shareQRCode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: qrTemplates.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => selectedTemplate = qrTemplates[index]),
            child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selectedTemplate == qrTemplates[index]
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code),
                  Text(qrTemplates[index]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}