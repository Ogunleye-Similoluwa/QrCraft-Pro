import 'package:hive_flutter/hive_flutter.dart';
import '../features/analytics/qr_analytics.dart';

class AnalyticsService {
  static const String _boxName = 'qr_analytics';
  late Box<Map> _box;

  Future<void> init() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<QRAnalytics> getQRAnalytics(String qrId) async {
    try {
      final data = _box.get(qrId);
      if (data != null) {
        return QRAnalytics.fromJson(Map<String, dynamic>.from(data));
      }
      // Return mock data if no analytics exist yet
      return QRAnalytics.mockData();
    } catch (e) {
      // Fallback to mock data if there's an error
      return QRAnalytics.mockData();
    }
  }

  Future<void> trackScan(String qrId, {
    required String deviceType,
    required String location,
  }) async {
    final existing = await getQRAnalytics(qrId);
    final updatedData = {
      ...existing.toJson(),
      'scans': existing.scans + 1,
      'deviceTypes': {
        ...existing.deviceTypes,
        deviceType: (existing.deviceTypes[deviceType] ?? 0) + 1,
      },
      'locations': [...existing.locations, location],
      'lastScan': DateTime.now().toIso8601String(),
    };
    
    await _box.put(qrId, updatedData);
  }
} 