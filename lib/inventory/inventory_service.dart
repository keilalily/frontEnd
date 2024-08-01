import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryService {

  Future<Map<String, String>> fetchInventoryData() async {
    final response = await http.get(Uri.parse('http://${dotenv.env['IP_ADDRESS']!}:3000/data/inventory'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'remainingPapersLong': data['remainingPapersLong'],
        'remainingPapersShort': data['remainingPapersShort'],
        'remainingInkBlack': data['remainingInkBlack'],
        'remainingInkColor': data['remainingInkColor'],
      };
    } else {
      // Handle error
      print('Failed to fetch inventory data');
      return {};
    }
  }
  
  Future<void> updateInventoryData({
    required BuildContext context,
    required TextEditingController longBondStockController,
    required TextEditingController shortBondStockController,
    required TextEditingController inkBlackStockController,
    required TextEditingController inkColorStockController,
    required void Function(String, String, String, String) updateState,
  }) async {
    final response = await http.put(
      Uri.parse('http://${dotenv.env['IP_ADDRESS']!}:3000/data/inventory'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'remainingPapersLong': longBondStockController.text,
        'remainingPapersShort': shortBondStockController.text,
        'remainingInkBlack': inkBlackStockController.text,
        'remainingInkColor': inkColorStockController.text,
      }),
    );

    if (response.statusCode == 200) {
      updateState(
        longBondStockController.text,
        shortBondStockController.text,
        inkBlackStockController.text,
        inkColorStockController.text,
      );

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inventory settings saved successfully')),
      );
    } else {
      // Handle error
      print('Failed to update inventory');
    }
  }
}
