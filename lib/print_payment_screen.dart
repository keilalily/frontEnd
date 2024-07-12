import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/custom_app_bar.dart';
import 'package:pdfx/pdfx.dart';

class PrintPaymentScreen extends StatefulWidget {
  final String fileName;
  final int pageCount;
  final int paperSizeIndex;
  final int colorIndex;
  final int pagesIndex;
  final List<int> selectedPages;
  final int resolutionIndex;
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
    required this.resolutionIndex,
    required this.copies,
    required this.pdfBytes
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

  @override
  void initState() {
    super.initState();
    fetchTotalPayment();
    pdfController = PdfController(
      document: PdfDocument.openData(widget.pdfBytes),
      initialPage: widget.pagesIndex == 1 ? widget.selectedPages[0] : currentPage
    );
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

  void _previousPage() {
    if (widget.pagesIndex == 1) {
      if (currentPageIndex > 0) {
        setState(() {
          currentPageIndex--;
          pdfController.animateToPage(
            widget.selectedPages[currentPageIndex],
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeIn
          );
        });
      }
    } else {
      if (currentPage > 1) {
        pdfController.previousPage(
          duration: const Duration(milliseconds: 250), 
          curve: Curves.easeOut
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
            curve: Curves.easeIn
          );
        });
      }
    } else {
      if (currentPage < widget.pageCount) {
        pdfController.nextPage(
          duration: const Duration(milliseconds: 250), 
          curve: Curves.easeIn
        );                
        setState(() {
          currentPage++;
        });
      }
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
                            child: Padding (
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
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white
                                  ),
                                  onPressed: _previousPage
                                ),
                                Text(
                                  widget.pagesIndex == 0
                                    ? '$currentPage/${widget.pageCount}'
                                    : '${currentPageIndex + 1}/${widget.selectedPages.length}',
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.white
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white
                                  ),
                                  onPressed: _nextPage
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
                                    // Add print action here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    textStyle: const TextStyle(fontSize: 20),
                                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                    minimumSize: const Size(100, 50),
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF8D6E63),
                                  ),
                                  child: const Text(
                                    'PRINT',
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

  @override
  void dispose() {
    pdfController.dispose(); // Dispose of the PdfController
    super.dispose();
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

  String getPages() {
    if (widget.pagesIndex == 0) {
      return 'All Pages';
    } else {
      return widget.selectedPages.join(', ');
    }
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

    int totalPages = widget.pagesIndex == 0 ? widget.pageCount : widget.selectedPages.length;
    double totalPayment = totalPages * basePrice * multiplier * resolutionFactor * widget.copies;

    return totalPayment;
  }
}
