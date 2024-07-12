import 'package:flutter/material.dart';
import 'package:frontend/custom_app_bar.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF2B2E4A),
      appBar: CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 60),
            Text(
              'ADMIN SETTINGS',
              style: TextStyle(
                fontSize: 48,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40),
          ]
        ),
      ),
    );
  }
}
