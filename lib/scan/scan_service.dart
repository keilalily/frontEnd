import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:frontend/payment/payment_service.dart';
import 'package:frontend/pricing/pricing_service.dart';

class ScanService {
  final String ipAddress;

  ScanService(this.ipAddress);

  // Function to fetch total payment
  Future<double> fetchTotalPayment({
    required int colorIndex,
    required int resolutionIndex,
    required PricingService pricingService,
  }) async {
    double calculatedTotal = await calculateTotalPayment(
      colorIndex: colorIndex,
      resolutionIndex: resolutionIndex,
      pricingService: pricingService,
    );
    return calculatedTotal;
  }

  // Function to fetch pricing data
  Future<Map<String, double>> getPricing(PricingService pricingService) async {
    try {
      final pricing = await pricingService.fetchPricingData();
      return {
        'coloredPrice': double.tryParse(pricing['coloredPrice'] ?? '0') ?? 0,
        'grayscalePrice': double.tryParse(pricing['grayscalePrice'] ?? '0') ?? 0,
        'highResolutionPrice': double.tryParse(pricing['highRecolutionPrice'] ?? '0') ?? 0,
        'mediumResolutionPrice': double.tryParse(pricing['highRecolutionPrice'] ?? '0') ?? 0,
        'lowResolutionPrice': double.tryParse(pricing['highRecolutionPrice'] ?? '0') ?? 0,
      };
    } catch (e) {
      print('Error fetching pricing data: $e');
      return {
        'coloredPrice': 0,
        'grayscalePrice': 0,
        'highResolutionPrice': 0,
        'mediumResolutionPrice': 0,
        'lowResolutionPrice': 0,
      };
    }
  }

  // Function to calculate total payment
  Future<double> calculateTotalPayment({
    required int colorIndex,
    required int resolutionIndex,
    required PricingService pricingService,
  }) async {
    final pricing = await getPricing(pricingService);

    double coloredPrice = pricing['coloredPrice'] ?? 0;
    double grayscalePrice = pricing['grayscalePrice'] ?? 0;
    double highResolutionPrice = pricing['highResolutionPrice'] ?? 0;
    double mediumResolutionPrice = pricing['mediumResolutionPrice'] ?? 0;
    double lowResolutionPrice = pricing['lowResolutionPrice'] ?? 0;

    double price = 0.0;

    switch (resolutionIndex) {
      case 0:
        price = colorIndex == 0 ? (grayscalePrice + lowResolutionPrice): (coloredPrice + lowResolutionPrice);
        break;
      case 1:
        price = colorIndex == 0 ? (grayscalePrice + lowResolutionPrice): (coloredPrice + mediumResolutionPrice);
        break;
      case 2:
        price = colorIndex == 0 ? (grayscalePrice + lowResolutionPrice): (coloredPrice + highResolutionPrice);
        break;
      default:
        break;
    }

    return price;
  }

  Future<void> startScan({
    required int paperSizeIndex,
    required int colorIndex,
    required int resolutionIndex,
    required Function onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:3000/scan/scan'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paperSizeIndex': paperSizeIndex,
          'colorIndex': colorIndex,
          'resolutionIndex': resolutionIndex,
        }),
      );

      if (response.statusCode == 200) {
        onSuccess();
      } else {
        onError('Failed to start scanning: ${response.reasonPhrase}');
      }
    } catch (e) {
      onError('Error starting scan: $e');
    }
  }

  Future<Uint8List> fetchScannedImage({
    required int paperSizeIndex,
    required int colorIndex,
    required int resolutionIndex,
  }) async {
    final response = await http.post(
      Uri.parse('http://$ipAddress:3000/scan/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'paperSizeIndex': paperSizeIndex,
        'colorIndex': colorIndex,
        'resolutionIndex': resolutionIndex,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      String imageDataString = responseBody['imageData'];
      return base64Decode(imageDataString);
    } else {
      throw Exception('Failed to fetch scanned image');
    }
  }

  Future<void> uploadScannedImage({
    required String email,
    required Uint8List scannedImageData,
    required PaymentService paymentService,
    required VoidCallback onSuccess,
  }) async {
    try {
      final uri = Uri.parse('http://$ipAddress:3000/scan/sendScannedFile');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'imageData': base64Encode(scannedImageData),
        }),
      );

      if (response.statusCode == 200) {
        await paymentService.resetCounts();

        onSuccess();
      } else {
        print('Error sending scanned image: ${response.statusCode}');
        throw Exception('Error sending scanned image: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending scanned image: $e');
      throw Exception('Error sending scanned image: $e');
    }
  }

}