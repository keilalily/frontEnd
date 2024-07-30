import 'dart:convert';
import 'dart:typed_data';
import 'package:frontend/pricing_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_app_bar.dart';
import 'package:frontend/payment_service.dart';

class CopyPaymentScreen extends StatefulWidget {
  final int paperSizeIndex;
  final int colorIndex;
  final int resolutionIndex;
  final int copies;

  const CopyPaymentScreen({
    super.key,
    required this.paperSizeIndex,
    required this.colorIndex,
    required this.resolutionIndex,
    required this.copies,
  });

  @override
  CopyPaymentScreenState createState() => CopyPaymentScreenState();
}

class CopyPaymentScreenState extends State<CopyPaymentScreen> {
  double totalPayment = 0.0;
  double paymentInserted = 0.0;
  bool proceedToPaymentClicked = false;
  Uint8List? scannedImageData;
  late PaymentService paymentService;
  late PricingService pricingService;

  @override
  void initState() {
    super.initState();

    paymentService = PaymentService(AppConfig.ipAddress);
    paymentService.listenToPaymentUpdates((amount) {
      setState(() {
        paymentInserted = amount;
      });
    });

    pricingService = PricingService();

    _fetchTotalPayment().catchError((e) {
      print('Error fetching total payment: $e');
    });
  }

  Future<void> _fetchTotalPayment() async {
    double calculatedTotal = await calculateTotalPayment(
      widget.colorIndex,
      widget.paperSizeIndex,
      widget.resolutionIndex,
      widget.copies,
    );
    setState(() {
      totalPayment = calculatedTotal;
    });
  }

  Future<Map<String, double>> getPricing() async {
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

  Future<double> calculateTotalPayment(int colorIndex, int paperSizeIndex, int resolutionIndex, int copies) async {
    final pricing = await getPricing();

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

  void fetchScannedImage() async {
    try {
      String apiUrl = 'http://${AppConfig.ipAddress}/scan/scan';

      // Make POST request to backend
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'paperSizeIndex': widget.paperSizeIndex,
          'colorIndex': widget.colorIndex,
          'resolutionIndex': widget.resolutionIndex,
        }),
      );

      // Handle response
      if (response.statusCode == 200) {
        // Decode the response body
        Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Extract scanned image data (assuming it's base64 encoded)
        String imageDataString = responseBody['imageData'];
        Uint8List decodedBytes = base64Decode(imageDataString);

        // Update state with scanned image data
        setState(() {
          scannedImageData = decodedBytes;
        });
      } else {
        // Handle error
        print('Error fetching scanned image: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error
      print('Error fetching scanned image: $error');
    }
  }

  @override
  void dispose() {
    paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      backgroundColor: const Color(0xFF2B2E4A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: totalPayment == 0.0
              ? const CircularProgressIndicator()
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: const Color(0xFF263238),
                        child: scannedImageData != null
                            ? Image.memory(
                                scannedImageData!,
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: Text(
                                  'No image available',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD8DEE9),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'COPY SETTINGS CONFIRMATION',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B2E4A),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSettingRow('Print Color:', getColor()),
                                    _buildSettingRow('Paper Size:', getPaperSize()),
                                    _buildSettingRow('Resolution:', getResolution()),
                                    _buildSettingRow('Number of Copies:', widget.copies.toString()),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD8DEE9),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Total Amount:',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B2E4A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '₱${totalPayment.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFF2B2E4A),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    proceedToPaymentClicked
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Payment Inserted:',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2B2E4A),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '₱${paymentInserted.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Color(0xFF2B2E4A),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              paymentInserted >= totalPayment
                                                  ? ElevatedButton(
                                                      onPressed: _sendToPrinter,
                                                      style: ElevatedButton.styleFrom(
                                                        foregroundColor: Colors.white,
                                                        backgroundColor: const Color(0xFF2B2E4A),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8.0),
                                                        ),
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 32.0,
                                                          vertical: 16.0,
                                                        ),
                                                      ),
                                                      child: const Text(
                                                        'PHOTOCOPY',
                                                        style: TextStyle(fontSize: 20.0),
                                                      ),
                                                    )
                                                  : const CircularProgressIndicator(),
                                            ],
                                          )
                                        : ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                proceedToPaymentClicked = true;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              textStyle: const TextStyle(fontSize: 20),
                                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                              minimumSize: const Size(100, 50),
                                              foregroundColor: Colors.white,
                                              backgroundColor: const Color(0xFF8D6E63),
                                            ),
                                            child: const Text(
                                              'PROCEED TO PAYMENT',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, color: Color(0xFF2B2E4A)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Color(0xFF2B2E4A)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String getPaperSize() {
    return widget.paperSizeIndex == 0 ? 'Letter (8.5" x 11")' : 'Legal (8.5" x 13")';
  }

  String getColor() {
    return widget.colorIndex == 0 ? 'Colored' : 'Grayscale';
  }

  String getResolution() {
    switch (widget.resolutionIndex) {
      case 0:
        return 'High';
      case 1:
        return 'Medium';
      case 2:
        return 'Low';
      default:
        return '';
    }
  }

  Future<void> _sendToPrinter() async {
    if (scannedImageData == null) {
      print('No scanned image data available.');
      return;
    }

    try {
      String apiUrl = 'http://${AppConfig.ipAddress}/copy/copy';

      String paperSize = widget.paperSizeIndex == 0 ? 'Letter' : 'Legal';

      // Make POST request to backend
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imageData': base64Encode(scannedImageData!),
          'copies': widget.copies,
          'paperSize': paperSize
        }),
      );

      // Handle response
      if (response.statusCode == 200) {
        print('Print request sent successfully.');
      } else {
        print('Error sending print request: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending print request: $error');
    }
  }
}
