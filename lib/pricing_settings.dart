import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config.dart';
import 'package:frontend/pricing_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PricingSettings extends StatefulWidget {
  const PricingSettings({super.key});

  @override
  PricingSettingsState createState() => PricingSettingsState();
}

class PricingSettingsState extends State<PricingSettings> {
  final PricingService _pricingService = PricingService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _longBondPriceController = TextEditingController();
  final TextEditingController _shortBondPriceController = TextEditingController();
  final TextEditingController _coloredPriceController = TextEditingController();
  final TextEditingController _grayscalePriceController = TextEditingController();
  final TextEditingController _highResolutionPriceController = TextEditingController();
  final TextEditingController _mediumResolutionPriceController = TextEditingController();
  final TextEditingController _lowResolutionPriceController = TextEditingController();

  String _longBondPrice = '';
  String _shortBondPrice = '';
  String _coloredPrice = '';
  String _grayscalePrice = '';
  String _highResolutionPrice = '';
  String _mediumResolutionPrice = '';
  String _lowResolutionPrice = '';

  @override
  void initState() {
    super.initState();
    _loadPricing();
  }

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

  Future<void> _loadPricing() async {
    try {
      final pricingData = await _pricingService.fetchPricingData();
      setState(() {
        _longBondPrice = pricingData['longBondPrice'] ?? '';
        _shortBondPrice = pricingData['shortBondPrice'] ?? '';
        _coloredPrice = pricingData['coloredPrice'] ?? '';
        _grayscalePrice = pricingData['grayscalePrice'] ?? '';
        _highResolutionPrice = pricingData['highResolutionPrice'] ?? '';
        _mediumResolutionPrice = pricingData['mediumResolutionPrice'] ?? '';
        _lowResolutionPrice = pricingData['lowResolutionPrice'] ?? '';
        _longBondPriceController.text = _longBondPrice;
        _shortBondPriceController.text = _shortBondPrice;
        _coloredPriceController.text = _coloredPrice;
        _grayscalePriceController.text = _grayscalePrice;
        _highResolutionPriceController.text = _highResolutionPrice;
        _mediumResolutionPriceController.text = _mediumResolutionPrice;
        _lowResolutionPriceController.text = _lowResolutionPrice;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load pricing data')),
      );
    }
  }

  Future<void> _savePricing() async {
    if (_formKey.currentState!.validate()) {
      final pricing = {
        'longBondPrice': _longBondPriceController.text,
        'shortBondPrice': _shortBondPriceController.text,
        'coloredPrice': _coloredPriceController.text,
        'grayscalePrice': _grayscalePriceController.text,
        'highResolutionPrice': _highResolutionPriceController.text,
        'mediumResolutionPrice': _mediumResolutionPriceController.text,
        'lowResolutionPrice': _lowResolutionPriceController.text,
      };

      final response = await http.post(
        Uri.parse('http://${AppConfig.ipAddress}:3000/pricing/prices'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pricing),
      );

      if (response.statusCode == 200) {
        setState(() {
          _longBondPrice = _longBondPriceController.text;
          _shortBondPrice = _shortBondPriceController.text;
          _coloredPrice = _coloredPriceController.text;
          _grayscalePrice = _grayscalePriceController.text;
          _highResolutionPrice = _highResolutionPriceController.text;
          _mediumResolutionPrice = _mediumResolutionPriceController.text;
          _lowResolutionPrice = _lowResolutionPriceController.text;
        });

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pricing settings saved successfully')),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save pricing data')),
        );
      }
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Edit Pricing'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildPricingRow('Long Bond Paper', _longBondPriceController),
                  _buildPricingRow('Short Bond Paper', _shortBondPriceController),
                  _buildPricingRow('Colored', _coloredPriceController),
                  _buildPricingRow('Grayscale', _grayscalePriceController),
                  _buildPricingRow('Low Resolution', _lowResolutionPriceController),
                  _buildPricingRow('Medium Resolution', _mediumResolutionPriceController),
                  _buildPricingRow('High Resolution', _highResolutionPriceController),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: _savePricing,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              onPressed: _showEditDialog,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Edit Pricing'),
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
        _buildPricingDisplayRow('Long Bond Paper', _longBondPrice),
        _buildPricingDisplayRow('Short Bond Paper', _shortBondPrice),
        const SizedBox(height: 20),
        _buildSectionTitle('Color'),
        _buildPricingDisplayRow('Colored', _coloredPrice),
        _buildPricingDisplayRow('Grayscale', _grayscalePrice),
      ],
    );
  }

  Widget _buildPricingColumn2() {
    return ListView(
      children: <Widget>[
        _buildSectionTitle('Resolution'),
        _buildPricingDisplayRow('Low Resolution', _lowResolutionPrice),
        _buildPricingDisplayRow('Medium Resolution', _mediumResolutionPrice),
        _buildPricingDisplayRow('High Resolution', _highResolutionPrice),
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

  Widget _buildPricingDisplayRow(String label, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
          Container(
            width: 50,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              price.isEmpty ? '0' : price,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
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