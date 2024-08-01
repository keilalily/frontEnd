import 'package:flutter/material.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/admin/change_info_settings.dart';
import 'package:frontend/inventory/daily_sales_report.dart';
import 'package:frontend/pricing/pricing_settings.dart';

class AdminSettingsScreen extends StatefulWidget {
  final String username;
  const AdminSettingsScreen({
    super.key,
    required this.username
  });

  @override
  AdminSettingsScreenState createState() => AdminSettingsScreenState();
}

class AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2E4A),
      appBar: const CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white38, // TabBar background color
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.account_balance_wallet),
                  text: 'Pricing Settings',
                ),
                Tab(
                  icon: Icon(Icons.settings_applications),
                  text: 'Change Information',
                ),
                Tab(
                  icon: Icon(Icons.assignment),
                  text: 'Daily Sales Report',
                )
              ],
              labelColor: Colors.white,
              indicatorColor: Colors.white,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                PricingSettings(),
                ChangeInfoSettings(username: widget.username),
                DailySalesReport()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
