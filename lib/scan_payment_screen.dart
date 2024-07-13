import 'package:flutter/material.dart';
import 'package:frontend/custom_app_bar.dart';

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
  double totalPayment = 0.0;
  double paymentInserted = 0.0;
  bool proceedToPaymentClicked = false;

  @override
  void initState() {
    super.initState();
    fetchTotalPayment();
  }

  void fetchTotalPayment() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        totalPayment = calculateTotalPayment();
      });
    });
  }

  void updatePaymentInserted(double amount) {
    setState(() {
      paymentInserted += amount; // Update payment inserted
    });
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
                        child: const Center(
                          child: Text(
                            'Scan Final Preview',
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
                                            ],
                                          )
                                        : ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                proceedToPaymentClicked = true;
                                              });
                                              // Call your backend to handle payment insertion
                                              // For demonstration, simulate payment insertion
                                              updatePaymentInserted(50.0); // Simulate an initial payment of 50
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
                            const SizedBox(height: 16),
                            if (paymentInserted >= totalPayment)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add photocopy action here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 20),
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                    minimumSize: const Size(100, 50),
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF8D6E63),
                                  ),
                                  child: const Text(
                                    'PHOTOCOPY',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
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

  double calculateTotalPayment() {
    double basePrice = 1.0;
    double multiplier = 1.0;
    double resolutionFactor = 1.0;

    if (widget.colorIndex == 1) {
      multiplier = 0.5;
    }

    switch (widget.resolutionIndex) {
      case 0:
        resolutionFactor = 1.5;
        break;
      case 2:
        resolutionFactor = 0.5;
        break;
      default:
        break;
    }

    double totalPayment = basePrice * multiplier * resolutionFactor;

    return totalPayment;
  }
}
