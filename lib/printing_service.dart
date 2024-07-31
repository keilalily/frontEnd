import 'dart:convert';
import 'dart:ui';
import 'package:frontend/payment_service.dart';
import 'package:http/http.dart' as http;
import 'pricing_service.dart';

// Function to fetch total payment
Future<double> fetchTotalPayment({
  required int colorIndex,
  required int paperSizeIndex,
  required int pagesIndex,
  required int pageCount,
  required List<int> selectedPages,
  required int copies,
  required PricingService pricingService,
}) async {
  double calculatedTotal = await calculateTotalPayment(
    colorIndex: colorIndex,
    paperSizeIndex: paperSizeIndex,
    pagesIndex: pagesIndex,
    pageCount: pageCount,
    selectedPages: selectedPages,
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
    };
  } catch (e) {
    print('Error fetching pricing data: $e');
    return {
      'longBondPrice': 0,
      'shortBondPrice': 0,
      'coloredPrice': 0,
      'grayscalePrice': 0,
    };
  }
}

// Function to calculate total payment
Future<double> calculateTotalPayment({
  required int colorIndex,
  required int paperSizeIndex,
  required int pagesIndex,
  required int pageCount,
  required List<int> selectedPages,
  required int copies,
  required PricingService pricingService,
}) async {
  final pricing = await getPricing(pricingService);

  double shortBondPrice = pricing['shortBondPrice'] ?? 0;
  double longBondPrice = pricing['longBondPrice'] ?? 0;
  double coloredPrice = pricing['coloredPrice'] ?? 0;
  double grayscalePrice = pricing['grayscalePrice'] ?? 0;
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

  int totalPageCount = pagesIndex == 0 ? pageCount : selectedPages.length;
  return pricePerPage * totalPageCount * copies;
}

// Function to print document
Future<void> printDocument({
  required String ipAddress,
  required int paperSizeIndex,
  required int colorIndex,
  required int pagesIndex,
  required List<int> selectedPages,
  required int copies,
  required PaymentService paymentService,
  required VoidCallback onSuccess,
}) async {
  // Prepare print settings payload
  Map<String, dynamic> printSettings = {
    'pdfPath': '', // Fill this with the actual path received from the server after upload
    'paperSizeIndex': paperSizeIndex,
    'colorIndex': colorIndex,
    'pagesIndex': pagesIndex,
    'selectedPages': selectedPages,
    'copies': copies,
  };

  // Send POST request to backend /print endpoint
  try {
    final response = await http.post(
      Uri.parse('http://$ipAddress:3000/print/print'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(printSettings),
    );

    if (response.statusCode == 200) {
      // If printing is successful, reset coin count
      await paymentService.resetCounts();

      onSuccess();
    } else {
      // Handle error response
      print('Failed to print: ${response.reasonPhrase}');
      // Optionally, show error message to user
    }
  } catch (e) {
    // Handle network or server-side error
    print('Error printing document: $e');
    // Optionally, show error message to user
  }
}
