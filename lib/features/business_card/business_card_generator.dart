import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

enum SocialMediaType {
  linkedin,
  twitter,
  facebook,
  instagram,
  github;

  IconData get icon {
    switch (this) {
      case SocialMediaType.linkedin: return Icons.work;
      case SocialMediaType.twitter: return Icons.flutter_dash;
      case SocialMediaType.facebook: return Icons.facebook;
      case SocialMediaType.instagram: return Icons.camera_alt;
      case SocialMediaType.github: return Icons.code;
    }
  }
}

class SocialMedia {
  final SocialMediaType type;
  final String username;

  const SocialMedia({
    required this.type,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'username': username,
  };

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      type: SocialMediaType.values.byName(json['type']),
      username: json['username'],
    );
  }
}

class BusinessCard {
  final String name;
  final String title;
  final String company;
  final String phone;
  final String email;
  final String website;
  final String address;
  final List<SocialMedia> socialMedia;
  final String? logoUrl;
  final String? photoUrl;

  BusinessCard({
    required this.name,
    required this.title,
    required this.company,
    required this.phone,
    required this.email,
    this.website = '',
    this.address = '',
    this.socialMedia = const [],
    this.logoUrl,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'title': title,
    'company': company,
    'phone': phone,
    'email': email,
    'website': website,
    'address': address,
    'socialMedia': socialMedia.map((sm) => sm.toJson()).toList(),
    'logoUrl': logoUrl,
    'photoUrl': photoUrl,
  };

  String generateVCard() {
    final vCard = '''BEGIN:VCARD
VERSION:3.0
FN:$name
TITLE:$title
ORG:$company
TEL:$phone
EMAIL:$email
${website.isNotEmpty ? 'URL:$website\n' : ''}
${address.isNotEmpty ? 'ADR:;;$address;;;;\n' : ''}
${photoUrl != null ? 'PHOTO;VALUE=URL:$photoUrl\n' : ''}
${logoUrl != null ? 'LOGO;VALUE=URL:$logoUrl\n' : ''}
${socialMedia.map((sm) => 'X-SOCIAL-${sm.type.name.toUpperCase()}:${sm.username}').join('\n')}
END:VCARD''';
    return vCard;
  }

  Widget generateQRCode({double size = 200}) {
    final vCardData = generateVCard();
    return QrImageView(
      data: vCardData,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  Widget generatePreview(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (photoUrl != null) ...[
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(photoUrl!),
              ),
              const SizedBox(height: 8),
            ],
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            if (company.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (logoUrl != null) ...[
                    Image.network(logoUrl!, height: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(company),
                ],
              ),
            ],
            const Divider(height: 16),
            if (phone.isNotEmpty) _buildInfoRow(Icons.phone, phone),
            if (email.isNotEmpty) _buildInfoRow(Icons.email, email),
            if (website.isNotEmpty) _buildInfoRow(Icons.language, website),
            if (address.isNotEmpty) _buildInfoRow(Icons.location_on, address),
            if (socialMedia.isNotEmpty) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: socialMedia.map((sm) => Icon(
                  sm.type.icon,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
} 