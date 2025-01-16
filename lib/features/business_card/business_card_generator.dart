enum SocialMediaType { linkedin, twitter, facebook, instagram, github }

class SocialMedia {
  final SocialMediaType type;
  final String username;

  const SocialMedia({
    required this.type,
    required this.username,
  });
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

  String generateVCard() {
    final vCard = '''BEGIN:VCARD
VERSION:3.0
FN:$name
TITLE:$title
ORG:$company
TEL:$phone
EMAIL:$email
URL:$website
ADR:;;$address;;;;
END:VCARD''';
    return vCard;
  }

  Future<void> exportToPDF() async {
    // Implementation for PDF export
  }
} 