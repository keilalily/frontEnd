import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:frontend/payment/payment_service.dart';
import 'package:frontend/pricing/pricing_service.dart';

class CopyService {
  final String ipAddress;

  CopyService(this.ipAddress);

  // Function to fetch total payment
  Future<double> fetchTotalPayment({
    required int colorIndex,
    required int paperSizeIndex,
    required int resolutionIndex,
    required int copies,
    required PricingService pricingService,
  }) async {
    double calculatedTotal = await calculateTotalPayment(
      colorIndex: colorIndex,
      paperSizeIndex: paperSizeIndex,
      resolutionIndex: resolutionIndex,
      copies: copies,
      pricingService: pricingService,
    );
    return calculatedTotal;
  }

  // Function to fetch pricing data
  Future<Map<String, double>> getPricing(PricingService pricingService) async {
    try {
      final pricing = await pricingService.fetchPricingData();
      return {
        'longBondPrice': double.tryParse(pricing['longBondPrice'] ?? '0') ?? 0,
        'shortBondPrice': double.tryParse(pricing['shortBondPrice'] ?? '0') ?? 0,
        'coloredPrice': double.tryParse(pricing['coloredPrice'] ?? '0') ?? 0,
        'grayscalePrice': double.tryParse(pricing['grayscalePrice'] ?? '0') ?? 0,
        'highResolutionPrice': double.tryParse(pricing['highRecolutionPrice'] ?? '0') ?? 0,
        'mediumResolutionPrice': double.tryParse(pricing['highRecolutionPrice'] ?? '0') ?? 0,
        'lowResolutionPrice': double.tryParse(pricing['highRecolutionPrice'] ?? '0') ?? 0,
      };
    } catch (e) {
      print('Error fetching pricing data: $e');
      return {
        'longBondPrice': 0,
        'shortBondPrice': 0,
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
    required int paperSizeIndex,
    required int resolutionIndex,
    required int copies,
    required PricingService pricingService,
  }) async {
    final pricing = await getPricing(pricingService);

    double shortBondPrice = pricing['shortBondPrice'] ?? 0;
    double longBondPrice = pricing['longBondPrice'] ?? 0;
    double coloredPrice = pricing['coloredPrice'] ?? 0;
    double grayscalePrice = pricing['grayscalePrice'] ?? 0;
    double highResolutionPrice = pricing['highResolutionPrice'] ?? 0;
    double mediumResolutionPrice = pricing['mediumResolutionPrice'] ?? 0;
    double lowResolutionPrice = pricing['lowResolutionPrice'] ?? 0;
    double shortBondPriceColored = shortBondPrice + coloredPrice;
    double longBondPriceColored = longBondPrice + coloredPrice;
    double shortBondPriceGrayscale = shortBondPrice + grayscalePrice;
    double longBondPriceGrayscale = longBondPrice + coloredPrice;

    double pricePerPage = 0.0;

    if (colorIndex == 1) {
      pricePerPage = paperSizeIndex == 0 ? shortBondPriceColored : longBondPriceColored;
    } else {
      pricePerPage = paperSizeIndex == 0 ? shortBondPriceGrayscale : longBondPriceGrayscale;
    }

    switch (resolutionIndex) {
      case 0:
        pricePerPage += lowResolutionPrice;
        break;
      case 1:
        pricePerPage += mediumResolutionPrice;
        break;
      case 2:
        pricePerPage += highResolutionPrice;
        break;
      default:
        break;
    }

    return pricePerPage * copies;
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

  Future<void> sendToPrinter({
    required Uint8List imageData,
    required int copies,
    required String paperSize,
    required PaymentService paymentService,
    required VoidCallback onSuccess,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:3000/copy/copy'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imageData': base64Encode(imageData),
          'copies': copies,
          'paperSize': paperSize,
        }),
      );

      if (response.statusCode == 200) {
        // await paymentService.resetCounts();

        onSuccess();
        
      } else {
        print('Failed to print: ${response.reasonPhrase}');
        throw Exception('Failed to send print request');
      }
    } catch (e) {
      print('Error printing document: $e');
      throw Exception('Failed to send print request');
    }
  }

}