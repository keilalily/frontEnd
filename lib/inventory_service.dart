import 'dart:convert';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;

class InventoryService {
  Future<Map<String, dynamic>> fetchInventoryData() async {
    final response = await http.get(
      Uri.parse('http://${AppConfig.ipAddress}:3000/inventory/paper'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load inventory data');
    }
  }
}
