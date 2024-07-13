import 'package:flutter/material.dart';
import 'package:frontend/custom_app_bar.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  AdminSettingsScreenState createState() => AdminSettingsScreenState();
}

class AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _longBondColoredController = TextEditingController();
  TextEditingController _longBondGrayscaleController = TextEditingController();
  TextEditingController _shortBondColoredController = TextEditingController();
  TextEditingController _shortBondGrayscaleController = TextEditingController();

  @override
  void dispose() {
    _longBondColoredController.dispose();
    _longBondGrayscaleController.dispose();
    _shortBondColoredController.dispose();
    _shortBondGrayscaleController.dispose();
    super.dispose();
  }

  void _savePricing() {
    if (_formKey.currentState!.validate()) {
      // Save the pricing information to the backend or database
      // Example:
      // final longBondColoredPrice = double.parse(_longBondColoredController.text);
      // final longBondGrayscalePrice = double.parse(_longBondGrayscaleController.text);
      // final shortBondColoredPrice = double.parse(_shortBondColoredController.text);
      // final shortBondGrayscalePrice = double.parse(_shortBondGrayscaleController.text);
      // Send this data to the backend or save locally

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pricing settings saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2E4A),
      appBar: const CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paper and Ink Tracker',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    Text('Paper: 50 sheets remaining'),
                    SizedBox(height: 10),
                    Text('Ink: 75% remaining'),
                    // Add more tracking info here
                  ],
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      Text(
                        'Pricing Settings',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _longBondColoredController,
                        decoration: InputDecoration(labelText: 'Long Bond Paper (Colored) Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _longBondGrayscaleController,
                        decoration: InputDecoration(labelText: 'Long Bond Paper (Grayscale) Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _shortBondColoredController,
                        decoration: InputDecoration(labelText: 'Short Bond Paper (Colored) Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _shortBondGrayscaleController,
                        decoration: InputDecoration(labelText: 'Short Bond Paper (Grayscale) Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      // Add more TextFormFields for additional pricing settings if needed
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _savePricing,
                        style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          minimumSize: const Size(100, 50),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF8D6E63),
                        ),
                        child: Text('Save Pricing Settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
