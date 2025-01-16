import 'package:flutter/material.dart';
import 'package:qr_master/services/analytics_service.dart';
import 'qr_analytics.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late Future<QRAnalytics> _analyticsFuture;
  final _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _analyticsService.getQRAnalytics('current_qr_id');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QRAnalytics>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final analytics = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QR Code Analytics',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              
              // Key Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Total Scans',
                      analytics.scans.toString(),
                      Icons.qr_code_scanner,
                      subtitle: '${analytics.averageDailyScans} daily avg',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      'Unique Visitors',
                      analytics.uniqueVisitors.toString(),
                      Icons.people,
                      subtitle: '${analytics.engagementRate}% engagement',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Conversion Funnel
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion Funnel',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...analytics.conversionRates.entries.map((entry) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: (entry.value * 100).round(),
                                child: Container(
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: (100 - entry.value * 100).round(),
                                child: const SizedBox(),
                              ),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  '${entry.value}%',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(entry.key),
                          const SizedBox(height: 16),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Device Distribution
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Distribution',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ...analytics.deviceTypes.entries.map((entry) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: LinearProgressIndicator(
                                  value: entry.value / analytics.scans,
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  '${(entry.value / analytics.scans * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(entry.key)),
                              Text('${entry.value} scans'),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Distribution
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time Distribution',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Most active: ${analytics.mostActiveTime}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...analytics.timeOfDay.entries.map((entry) => Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 140,
                                child: Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: entry.value / analytics.scans,
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  entry.value.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon, {
    String? subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}