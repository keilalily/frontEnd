import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PricingSettings extends StatefulWidget {
  const PricingSettings({super.key});

  @override
  PricingSettingsState createState() => PricingSettingsState();
}

class PricingSettingsState extends State<PricingSettings> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _longBondPriceController = TextEditingController();
  final TextEditingController _shortBondPriceController = TextEditingController();
  final TextEditingController _coloredPriceController = TextEditingController();
  final TextEditingController _grayscalePriceController = TextEditingController();
  final TextEditingController _highResolutionPriceController = TextEditingController();
  final TextEditingController _mediumResolutionPriceController = TextEditingController();
  final TextEditingController _lowResolutionPriceController = TextEditingController();

  @override
  void dispose() {
    _longBondPriceController.dispose();
    _shortBondPriceController.dispose();
    _coloredPriceController.dispose();
    _grayscalePriceController.dispose();
    _highResolutionPriceController.dispose();
    _mediumResolutionPriceController.dispose();
    _lowResolutionPriceController.dispose();
    super.dispose();
  }

  void _savePricing() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pricing settings saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 124.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            const Text(
              'Pricing Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildPricingColumn1()),
                  const SizedBox(width: 100),
                  Expanded(child: _buildPricingColumn2()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePricing,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Save Pricing Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingColumn1() {
    return ListView(
      children: <Widget>[
        _buildSectionTitle('Sizes'),
        _buildPricingRow('Long Bond Paper', _longBondPriceController),
        _buildPricingRow('Short Bond Paper', _shortBondPriceController),
        const SizedBox(height: 20),
        _buildSectionTitle('Color'),
        _buildPricingRow('Colored', _coloredPriceController),
        _buildPricingRow('Grayscale', _grayscalePriceController),
      ],
    );
  }

  Widget _buildPricingColumn2() {
    return ListView(
      children: <Widget>[
        _buildSectionTitle('Resolution'),
        _buildPricingRow('Low Resolution', _lowResolutionPriceController),
        _buildPricingRow('Medium Resolution', _mediumResolutionPriceController),
        _buildPricingRow('High Resolution', _highResolutionPriceController),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPricingRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: const TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
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
          ),
        ],
      ),
    );
  }
}
