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
  url,
  email,
  phone,
  wifi,
  vCard,
  businessCard,
  socialMedia,
  location,
  calendar,
  cryptocurrency,
  menu,
  pdf,
  whatsapp,
  telegram
}

class QRTypeInfo {
  final QRType type;
  final IconData icon;
  final String label;
  final String hint;

  const QRTypeInfo({
    required this.type,
    required this.icon,
    required this.label,
    required this.hint,
  });
}

final List<QRTypeInfo> qrTypes = [
  QRTypeInfo(
    type: QRType.text,
    icon: Icons.text_fields,
    label: 'Text',
    hint: 'Enter any text',
  ),
  QRTypeInfo(
    type: QRType.url,
    icon: Icons.link,
    label: 'URL',
    hint: 'Enter website URL',
  ),
  QRTypeInfo(
    type: QRType.email,
    icon: Icons.email,
    label: 'Email',
    hint: 'Enter email address',
  ),
  QRTypeInfo(
    type: QRType.phone,
    icon: Icons.phone,
    label: 'Phone',
    hint: 'Enter phone number',
  ),
  QRTypeInfo(
    type: QRType.wifi,
    icon: Icons.wifi,
    label: 'WiFi',
    hint: 'Enter WiFi details',
  ),
  QRTypeInfo(
    type: QRType.businessCard,
    icon: Icons.contact_page,
    label: 'Business Card',
    hint: 'Create digital business card',
  ),
  QRTypeInfo(
    type: QRType.location,
    icon: Icons.location_on,
    label: 'Location',
    hint: 'Share a location',
  ),
  QRTypeInfo(
    type: QRType.whatsapp,
    icon: Icons.call_end_rounded,
    label: 'WhatsApp',
    hint: 'Share WhatsApp contact',
  ),
];

class QRStyle {
  final Color foregroundColor;
  final Color backgroundColor;
  final double cornerRadius;
  final double dotScale;
  final bool useGradient;
  final Color? gradientColor1;
  final Color? gradientColor2;
  final String? logoPath;
  final QrEyeStyle eyeStyle;
  final QrDataModuleStyle  dataModuleStyle;

   QRStyle({
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.cornerRadius = 0,
    this.dotScale = 1,
    this.useGradient = false,
    this.gradientColor1,
    this.gradientColor2,
    this.logoPath,
    this.eyeStyle = const QrEyeStyle(eyeShape: QrEyeShape.square),
    this.dataModuleStyle = const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square),
  });

  QRStyle copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    double? cornerRadius,
    double? dotScale,
    bool? useGradient,
    Color? gradientColor1,
    Color? gradientColor2,
    String? logoPath,
    QrEyeStyle? eyeStyle,
    QrDataModuleStyle? dataModuleStyle,
  }) {
    return QRStyle(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      dotScale: dotScale ?? this.dotScale,
      useGradient: useGradient ?? this.useGradient,
      gradientColor1: gradientColor1 ?? this.gradientColor1,
      gradientColor2: gradientColor2 ?? this.gradientColor2,
      logoPath: logoPath ?? this.logoPath,
      eyeStyle: eyeStyle ?? this.eyeStyle,
      dataModuleStyle: dataModuleStyle ?? this.dataModuleStyle,
    );
  }
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

  var qrStyle = QRStyle();

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

  void _showStyleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Style QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ColorPicker(
              pickerColor: qrStyle.foregroundColor,
              onColorChanged: (color) => setState(() {
                qrStyle = qrStyle.copyWith(foregroundColor: color);
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              value: qrStyle.dotScale,
              min: 0.5,
              max: 1.5,
              onChanged: (value) => setState(() {
                qrStyle = qrStyle.copyWith(dotScale: value);
              }),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
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
                  final typeInfo = qrTypes[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedQRType = typeInfo.type;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: selectedQRType == typeInfo.type
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            typeInfo.icon,
                            color: selectedQRType == typeInfo.type
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            typeInfo.label,
                            style: TextStyle(
                              color: selectedQRType == typeInfo.type
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
              _buildQRPreview(),
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

  Widget _buildQRPreview() {
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
                backgroundColor: qrStyle.backgroundColor,
                foregroundColor: qrStyle.foregroundColor,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
                eyeStyle: qrStyle.eyeStyle,
                dataModuleStyle: qrStyle.dataModuleStyle,
                embeddedImage: qrStyle.logoPath != null 
                  ? AssetImage(qrStyle.logoPath!) 
                  : null,
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(40, 40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.palette,
                  label: 'Style',
                  onTap: _showStyleDialog,
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
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  onTap: _showEditDialog,
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