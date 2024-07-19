import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_app_bar.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'payment_service.dart';

class PrintPaymentScreen extends StatefulWidget {
  final String fileName;
  final int pageCount;
  final int paperSizeIndex;
  final int colorIndex;
  final int pagesIndex;
  final List<int> selectedPages;
  final int copies;
  final Uint8List pdfBytes;

  const PrintPaymentScreen({
    super.key,
    required this.fileName,
    required this.pageCount,
    required this.paperSizeIndex,
    required this.colorIndex,
    required this.pagesIndex,
    required this.selectedPages,
    required this.copies,
    required this.pdfBytes,
  });

  @override
  PrintPaymentScreenState createState() => PrintPaymentScreenState();
}

class PrintPaymentScreenState extends State<PrintPaymentScreen> {
  double totalPayment = 0.0;
  double paymentInserted = 0.0;
  bool proceedToPaymentClicked = false;
  late PdfController pdfController;
  int currentPageIndex = 0;
  int currentPage = 1;
  late PaymentService paymentService;

  @override
  void initState() {
    super.initState();
    fetchTotalPayment();
    pdfController = PdfController(
      document: PdfDocument.openData(widget.pdfBytes),
      initialPage: widget.pagesIndex == 1 ? widget.selectedPages[0] : currentPage,
    );

    paymentService = PaymentService(AppConfig.ipAddress);
    paymentService.listenToPaymentUpdates((amount) {
      setState(() {
        paymentInserted = amount;
      });
    });
  }

  void fetchTotalPayment() {
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        totalPayment = calculateTotalPayment();
      });
    });
  }

  void _previousPage() {
    if (widget.pagesIndex == 1) {
      if (currentPageIndex > 0) {
        setState(() {
          currentPageIndex--;
          pdfController.animateToPage(
            widget.selectedPages[currentPageIndex],
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
          );
        });
      }
    } else {
      if (currentPage > 1) {
        pdfController.previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
        setState(() {
          currentPage--;
        });
      }
    }
  }

  void _nextPage() {
    if (widget.pagesIndex == 1) {
      if (currentPageIndex < widget.selectedPages.length) {
        setState(() {
          currentPageIndex++;
          pdfController.animateToPage(
            widget.selectedPages[currentPageIndex],
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn,
          );
        });
      }
    } else {
      if (currentPage < widget.pageCount) {
        pdfController.nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeIn,
        );
        setState(() {
          currentPage++;
        });
      }
    }
  }

  @override
  void dispose() {
    pdfController.dispose();
    paymentService.close();
    super.dispose();
  }

  Future<void> printDocument() async {
    // Prepare print settings payload
    Map<String, dynamic> printSettings = {
      'pdfPath': '', // Fill this with the actual path received from the server after upload
      'paperSizeIndex': widget.paperSizeIndex,
      'colorIndex': widget.colorIndex,
      'pagesIndex': widget.pagesIndex,
      'selectedPages': widget.selectedPages,
      'copies': widget.copies,
    };

    // Send POST request to backend /print endpoint
    try {
      final response = await http.post(
        Uri.parse('http://${AppConfig.ipAddress}:3000/print/print'), // Replace with your backend URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(printSettings),
      );

      if (response.statusCode == 200) {
        // Handle success response
        print('Printing successful');
        // Optionally, handle UI updates or success messages
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
                      flex: 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
                              child: PdfView(
                                controller: pdfController,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                                  onPressed: _previousPage,
                                ),
                                Text(
                                  widget.pagesIndex == 0
                                      ? '$currentPage/${widget.pageCount}'
                                      : '${currentPageIndex + 1}/${widget.selectedPages.length}',
                                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                                  onPressed: _nextPage,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
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
                                      'PRINT SETTINGS CONFIRMATION',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B2E4A),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildSettingRow('File Name:', widget.fileName),
                                    _buildSettingRow('Page Count:', widget.pageCount.toString()),
                                    _buildSettingRow('Print Color:', getColor()),
                                    _buildSettingRow('Paper Size:', getPaperSize()),
                                    _buildSettingRow('Pages to Print:', getPages()),
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
                                        fontSize: 18,
                                        color: Color(0xFF2B2E4A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
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
                                                  fontSize: 18,
                                                  color: Color(0xFF2B2E4A),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              paymentInserted >= totalPayment
                                                  ? ElevatedButton(
                                                      onPressed: printDocument,
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
                                                        'PRINT',
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
                                              foregroundColor: Colors.white,
                                              backgroundColor: const Color(0xFF8D6E63),
                                            ),
                                            child: const Text(
                                              'PROCEED TO PAYMENT',
                                              style: TextStyle(fontSize: 20.0),
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
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF2B2E4A)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Color(0xFF2B2E4A)),
          ),
        ],
      ),
    );
  }

  String getPaperSize() {
    switch (widget.paperSizeIndex) {
      case 0:
        return 'Short';
      case 1:
        return 'Long';
      default:
        return '';
    }
  }

  String getColor() {
    switch (widget.colorIndex) {
      case 0:
        return 'Grayscale';
      case 1:
        return 'Colored';
      default:
        return '';
    }
  }

  String getPages() {
    switch (widget.pagesIndex) {
      case 0:
        return 'All Pages';
      case 1:
        return 'Selected Pages';
      default:
        return '';
    }
  }

  double calculateTotalPayment() {
    const double shortBondPriceColored = 5.0;
    const double longBondPriceColored = 10.0;
    const double shortBondPriceGrayscale = 2.0;
    const double longBondPriceGrayscale = 5.0;

    double pricePerPage = 0.0;

    if (widget.colorIndex == 1) {
      pricePerPage = widget.paperSizeIndex == 0 ? shortBondPriceColored : longBondPriceColored;
    } else {
      pricePerPage = widget.paperSizeIndex == 0 ? shortBondPriceGrayscale : longBondPriceGrayscale;
    }

    int totalPageCount = widget.pagesIndex == 0 ? widget.pageCount : widget.selectedPages.length;
    return pricePerPage * totalPageCount * widget.copies;
  }
}
