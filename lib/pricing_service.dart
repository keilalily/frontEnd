import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
class PricingService {
  Future<Map<String, dynamic>> fetchPricingData() async {
    final response = await http.get(
      Uri.parse('http://${dotenv.env['IP_ADDRESS']!}:3000/pricing/prices'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load pricing data');
    }
  }
}
