import 'dart:convert';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;

class PricingService {

  Future<Map<String, String>> fetchPricingData() async {
    final response = await http.get(Uri.parse('http://${AppConfig.ipAddress}:3000/pricing/prices'));
    if (response.statusCode == 200) {
      final pricing = jsonDecode(response.body);
      return {
        'longBondPrice': pricing['longBondPrice'] ?? '0',
        'shortBondPrice': pricing['shortBondPrice'] ?? '0',
        'coloredPrice': pricing['coloredPrice'] ?? '0',
        'grayscalePrice': pricing['grayscalePrice'] ?? '0',
        'highResolutionPrice': pricing['highResolutionPrice'] ?? '0',
        'mediumResolutionPrice': pricing['mediumResolutionPrice'] ?? '0',
        'lowResolutionPrice': pricing['lowResolutionPrice'] ?? '0',
      };
    } else {
      throw Exception('Failed to load pricing data');
    }
  }
}
