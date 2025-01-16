import 'package:flutter/material.dart';
import '../../app_theme.dart';
import 'business_card_generator.dart';

class BusinessCardPage extends StatefulWidget {
  const BusinessCardPage({super.key});

  @override
  State<BusinessCardPage> createState() => _BusinessCardPageState();
}

class _BusinessCardPageState extends State<BusinessCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.padding),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Digital',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Business Card ✨',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            _buildTextField(
              controller: _titleController,
              label: 'Job Title',
              icon: Icons.work,
            ),
            _buildTextField(
              controller: _companyController,
              label: 'Company',
              icon: Icons.business,
            ),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              icon: Icons.phone,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            _buildTextField(
              controller: _websiteController,
              label: 'Website',
              icon: Icons.language,
            ),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateBusinessCard,
              child: const Text('Generate Business Card QR'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }

  void _generateBusinessCard() {
    if (_formKey.currentState?.validate() ?? false) {
      final businessCard = BusinessCard(
        name: _nameController.text,
        title: _titleController.text,
        company: _companyController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text,
        address: _addressController.text,
      );
      
      // Generate QR code and show preview
      _showBusinessCardPreview(businessCard);
    }
  }

  void _showBusinessCardPreview(BusinessCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Business Card Preview',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            // QR code display
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: const Center(
                child: Text('QR Code Here'),
              ),
            ),
            const SizedBox(height: 20),
            // Business card details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.name, style: Theme.of(context).textTheme.titleLarge),
                    Text(card.title),
                    Text(card.company),
                    const SizedBox(height: 8),
                    Text(card.phone),
                    Text(card.email),
                    if (card.website.isNotEmpty) Text(card.website),
                    if (card.address.isNotEmpty) Text(card.address),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement save functionality
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 