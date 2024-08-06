import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/scan/scan_service.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/payment/payment_service.dart';
import 'package:frontend/pricing/pricing_service.dart';

class ScanPaymentScreen extends StatefulWidget {
  final int paperSizeIndex;
  final int colorIndex;
  final int resolutionIndex;

  const ScanPaymentScreen({
    super.key,
    required this.paperSizeIndex,
    required this.colorIndex,
    required this.resolutionIndex,
  });

  @override
  ScanPaymentScreenState createState() => ScanPaymentScreenState();
}

class ScanPaymentScreenState extends State<ScanPaymentScreen> {
  final ScanService _scanService = ScanService(dotenv.env['IP_ADDRESS']!);
  double totalPayment = 0.0;
  double paymentInserted = 0.0;
  bool isLoading = false;
  bool isSending = false;
  bool proceedToPaymentClicked = false;
  Uint8List? scannedImageData;
  String? email;
  late PaymentService paymentService;
  late PricingService pricingService;

  @override
  void initState() {
    super.initState();
    paymentService = PaymentService(dotenv.env['IP_ADDRESS']!);
    pricingService = PricingService();

    _fetchScannedImage().catchError((e) {
      print('Error fetching scanned image: $e');
    });

    _fetchTotalPayment().catchError((e) {
      print('Error fetching total payment: $e');
    });
  }

  Future<void> _fetchTotalPayment() async {
    double calculatedTotal = await _scanService.fetchTotalPayment(
      colorIndex: widget.colorIndex,
      resolutionIndex: widget.resolutionIndex,
      pricingService: pricingService,
    );
    setState(() {
      totalPayment = calculatedTotal;
    });
  }

  // void fetchScannedImage() async {
  //   try {
  //     String apiUrl = 'http://${dotenv.env['IP_ADDRESS']!}/scan/scan';

  //     // Make POST request to backend
  //     var response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'paperSizeIndex': widget.paperSizeIndex,
  //         'colorIndex': widget.colorIndex,
  //         'resolutionIndex': widget.resolutionIndex,
  //       }),
  //     );

  //     // Handle response
  //     if (response.statusCode == 200) {
  //       // Decode the response body
  //       Map<String, dynamic> responseBody = jsonDecode(response.body);

  //       // Extract scanned image data (assuming it's base64 encoded)
  //       String imageDataString = responseBody['imageData'];
  //       Uint8List decodedBytes = base64Decode(imageDataString);

  //       // Update state with scanned image data
  //       setState(() {
  //         scannedImageData = decodedBytes;
  //       });
  //     } else {
  //       // Handle error
  //       print('Error fetching scanned image: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     // Handle error
  //     print('Error fetching scanned image: $error');
  //   }
  // }

  Future<void> _fetchScannedImage() async {
    try {
      final imageData = await _scanService.fetchScannedImage(
        paperSizeIndex: widget.paperSizeIndex,
        colorIndex: widget.colorIndex,
        resolutionIndex: widget.resolutionIndex,
      );
      setState(() {
        scannedImageData = imageData;
      });
    } catch (e) {
      print('Error fetching scanned image: $e');
    }
  }

  Future<void> _uploadScannedImage() async {
    if (scannedImageData != null && email != null) {
      setState(() {
        isSending = true;
      });

      try {
        await _scanService.uploadScannedImage(
          email: email!, 
          scannedImageData: scannedImageData!,
          paymentService: paymentService,
          onSuccess: _handleScanSuccess
        );

        setState(() {
          isSending = false;
        });
        print('File sent to: $email');
      } catch (e) {
        setState(() {
          isSending = false;
        });
        print('Error sending scanned image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending scanned image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      print('Scanned image or email is null.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scanned image or email is null.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showEmailDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Email'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                email = value.trim();
              });
            },
            decoration: const InputDecoration(
              hintText: 'Enter your email',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                _uploadScannedImage();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleScanSuccess() {
    setState(() {
      paymentInserted = 0.0;
      proceedToPaymentClicked = false;
    });
  }

  @override
  void dispose() {
    // paymentService.stopFetchingStatus();
    // paymentService.dispose();
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
                                      'SCAN SETTINGS CONFIRMATION',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B2E4A),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSettingRow('Print Color:', getColor()),
                                    _buildSettingRow('Paper Size:', getPaperSize()),
                                    _buildSettingRow('Resolution:', getResolution())
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
                                                      onPressed: _showEmailDialog,
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
                                                        'UPLOAD',
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
                                                // paymentService.startFetchingStatus();
                                                paymentService.listenToPaymentUpdates((amount) {
                                                  setState(() {
                                                    paymentInserted = amount;
                                                  });
                                                });
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              textStyle: const TextStyle(fontSize: 20),
                                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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

  // Future<void> _uploadScannedImage() async {
  //   if (scannedImageData != null && email != null) {
  //     setState(() {
  //       isSending = true;
  //     });

  //     try {
  //       var uri = Uri.parse('http://${dotenv.env['IP_ADDRESS']!}:3000/scan/sendScannedFile');
  //       var response = await http.post(
  //         uri,
  //         headers: {'Content-Type': 'application/json'},
  //         body: jsonEncode({
  //           'email': email,
  //           'imageData': base64Encode(scannedImageData!), // Encode image data to base64
  //         }),
  //       );

  //       if (response.statusCode == 200) {
  //         var jsonResponse = json.decode(response.body);
  //         setState(() {
  //           isSending = false;
  //         });
  //         print('File sent to: ${jsonResponse['email']}');
  //       } else {
  //         setState(() {
  //           isSending = false;
  //         });
  //         print('Error sending scanned image: ${response.statusCode}');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Error sending scanned image: ${response.statusCode}'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     } catch (e) {
  //       setState(() {
  //         isSending = false;
  //       });
  //       print('Error sending scanned image: $e');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error sending scanned image: $e'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } else {
  //     print('Scanned image or email is null.');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Scanned image or email is null.'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

}
