import 'dart:math';

class QRAnalytics {
  final String id;
  final DateTime createdAt;
  final int scans;
  final List<String> locations;
  final Map<String, int> deviceTypes;
  final Map<DateTime, int> scanHistory;
  final Map<String, int> timeOfDay;
  final Map<String, double> conversionRates;
  final int uniqueVisitors;

  QRAnalytics({
    required this.id,
    required this.createdAt,
    required this.scans,
    required this.locations,
    required this.deviceTypes,
    required this.scanHistory,
    required this.timeOfDay,
    required this.conversionRates,
    required this.uniqueVisitors,
  });

  factory QRAnalytics.mockData() {
    final now = DateTime.now();
    return QRAnalytics(
      id: 'qr_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: now.subtract(const Duration(days: 30)),
      scans: 12543,
      uniqueVisitors: 8976,
      locations: {
        'United States': 4521,
        'United Kingdom': 2341,
        'Germany': 1876,
        'France': 1234,
        'Canada': 987,
        'Australia': 876,
        'Japan': 543,
        'Brazil': 165,
      }.keys.toList(),
      deviceTypes: {
        'Android': 5432,
        'iOS': 4876,
        'Web': 1654,
        'Desktop': 581,
      },
      timeOfDay: {
        'Morning (6-12)': 3456,
        'Afternoon (12-17)': 4567,
        'Evening (17-22)': 3654,
        'Night (22-6)': 866,
      },
      conversionRates: {
        'Website Visits': 68.5,
        'Product Views': 45.2,
        'Add to Cart': 12.8,
        'Purchases': 5.4,
      },
      scanHistory: Map.fromEntries(
        List.generate(30, (index) {
          return MapEntry(
            now.subtract(Duration(days: index)),
            300 + (index % 7 * 50) + Random().nextInt(100),
          );
        }),
      ),
    );
  }

  factory QRAnalytics.fromJson(Map<String, dynamic> json) {
    return QRAnalytics(
      id: json['id'],
      createdAt: DateTime.parse(json['createdAt']),
      scans: json['scans'],
      uniqueVisitors: json['uniqueVisitors'],
      locations: List<String>.from(json['locations']),
      deviceTypes: Map<String, int>.from(json['deviceTypes']),
      timeOfDay: Map<String, int>.from(json['timeOfDay']),
      conversionRates: Map<String, double>.from(json['conversionRates']),
      scanHistory: (json['scanHistory'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(DateTime.parse(key), value as int),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'scans': scans,
        'uniqueVisitors': uniqueVisitors,
        'locations': locations,
        'deviceTypes': deviceTypes,
        'timeOfDay': timeOfDay,
        'conversionRates': conversionRates,
        'scanHistory': scanHistory.map((k, v) => MapEntry(k.toIso8601String(), v)),
      };

  double get engagementRate => (uniqueVisitors / scans * 100).roundToDouble();

  String get mostActiveTime {
    return timeOfDay.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  String get topLocation => locations.first;

  int get averageDailyScans {
    final days = DateTime.now().difference(createdAt).inDays;
    return (scans / days).round();
  }
} 