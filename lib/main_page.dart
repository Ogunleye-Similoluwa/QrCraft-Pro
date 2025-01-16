import 'package:flutter/material.dart';
import 'package:qr_master/scanner_page.dart';
import 'package:qr_master/setting_page.dart';


import 'app_theme.dart';
import 'generator_page.dart';
import 'history_screen.dart';
import 'features/business_card/business_card_page.dart';

import 'features/batch_processing/batch_processing_sheet.dart';
import 'features/analytics/analytics_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.padding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QR Hub',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                      );
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(Icons.settings, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                isScrollable: true,
                dividerColor: Colors.transparent,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  _buildTab(Icons.qr_code, 'Generate'),
                  _buildTab(Icons.qr_code_scanner, 'Scan'),
                  _buildTab(Icons.business, 'Business Card'),
                  _buildTab(Icons.analytics, 'Analytics'),
                  _buildTab(Icons.history, 'History'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  GeneratorPage(),
                  ScannerPage(),
                  BusinessCardPage(),
                  AnalyticsPage(),
                  HistoryPage(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildTab(IconData icon, String label) {
    return Tab(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_tabController.index == 0) {
      return FloatingActionButton(
        onPressed: () => _showBatchProcessingDialog(),
        child: const Icon(Icons.add_box),
      );
    }
    return null;
  }

  void _showBatchProcessingDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const BatchProcessingSheet(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}