import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/scan/scan_payment_screen.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/widgets/custom_button_row.dart';

class ScanSettingsScreen extends StatefulWidget {
  const ScanSettingsScreen({super.key});

  @override
  ScanSettingsScreenState createState() => ScanSettingsScreenState();
}

class ScanSettingsScreenState extends State<ScanSettingsScreen> {
  int _paperSizeIndex = -1; // Track selected index for Paper Size
  int _colorIndex = -1; // Track selected index for Color
  int _resolutionIndex = -1; // Track selected index for Resolution

  bool get canProceed =>
      _paperSizeIndex != -1 && _colorIndex != -1 && _resolutionIndex != -1;

  Future<void> startScan() async {
    // Construct the URL to your Node.js backend endpoint
    final url = Uri.parse('http://${dotenv.env['IP_ADDRESS']!}:3000//scan/scan');

    try {
      // Send a POST request to start scanning with selected settings
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paperSizeIndex': _paperSizeIndex,
          'colorIndex': _colorIndex,
          'resolutionIndex': _resolutionIndex,
        }),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Navigate to ScanPaymentScreen with selected settings
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanPaymentScreen(
              paperSizeIndex: _paperSizeIndex,
              colorIndex: _colorIndex,
              resolutionIndex: _resolutionIndex,
            ),
          ),
        );
      } else {
        // Handle error if the request fails
        throw Exception('Failed to start scanning: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle network or server errors
      print('Error starting scan: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to start scanning. Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: const CustomAppBar(
          titleText: 'BULSU HC VENDO PRINTING MACHINE',
        ),
        backgroundColor: const Color(0xFF2B2E4A),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    color: const Color(0xFF263238),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.scanner,
                          size: 60,
                          color: Colors.white,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Place your document on the scanner glass.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(14.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF63678E),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              "SCAN SETTINGS",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Customize your scan options.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            CustomButtonRow(
                              title: "Paper Size",
                              options: const [
                                "Letter (8.5\" x 11\")",
                                "Legal (8.5\" x 13\")"
                              ],
                              selectedIndex: _paperSizeIndex,
                              onSelected: (index) {
                                setState(() {
                                  _paperSizeIndex = index;
                                });
                              },
                            ),
                            CustomButtonRow(
                              title: "Color",
                              options: const ["Colored", "Grayscale"],
                              selectedIndex: _colorIndex,
                              onSelected: (index) {
                                setState(() {
                                  _colorIndex = index;
                                });
                              },
                            ),
                            CustomButtonRow(
                              title: "Resolution",
                              options: const ["High", "Medium", "Low"],
                              selectedIndex: _resolutionIndex,
                              onSelected: (index) {
                                setState(() {
                                  _resolutionIndex = index;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: ElevatedButton(
                                onPressed: canProceed ? startScan : null,
                                style: ElevatedButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF8D6E63),
                                ),
                                child: const Text(
                                  "SCAN",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
