import 'package:flutter/material.dart';
import 'package:qr_master/scanner_page.dart';
import 'package:qr_master/setting_page.dart';


import 'app_theme.dart';
import 'generator_page.dart';
import 'history_screen.dart';


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
    _tabController = TabController(length: 3, vsync: this);
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
                    'QR Master',
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
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.qr_code), text: 'Generate'),
                Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan'),
                Tab(icon: Icon(Icons.history), text: 'History'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  GeneratorPage(),
                  ScannerPage(),
                  HistoryPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}