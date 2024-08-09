// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:frontend/custom_app_bar.dart';
// import 'package:pdfx/pdfx.dart';
// import 'package:http/http.dart' as http;
// import 'payment_service.dart';
// import 'pricing_service.dart';

// class PrintPaymentScreen extends StatefulWidget {
//   final String fileName;
//   final int pageCount;
//   final int paperSizeIndex;
//   final int colorIndex;
//   final int pagesIndex;
//   final List<int> selectedPages;
//   final int copies;
//   final Uint8List pdfBytes;

//   const PrintPaymentScreen({
//     super.key,
//     required this.fileName,
//     required this.pageCount,
//     required this.paperSizeIndex,
//     required this.colorIndex,
//     required this.pagesIndex,
//     required this.selectedPages,
//     required this.copies,
//     required this.pdfBytes,
//   });

//   @override
//   PrintPaymentScreenState createState() => PrintPaymentScreenState();
// }

// class PrintPaymentScreenState extends State<PrintPaymentScreen> {
//   double totalPayment = 0.0;
//   double paymentInserted = 0.0;
//   bool proceedToPaymentClicked = false;
//   int currentPageIndex = 0;
//   int currentPage = 1;
//   late PdfController pdfController;
//   late PaymentService paymentService;
//   late PricingService pricingService;

//   @override
//   void initState() {
//     super.initState();
//     try {
//       pdfController = PdfController(
//         document: PdfDocument.openData(widget.pdfBytes),
//         initialPage: widget.pagesIndex == 1 ? widget.selectedPages[0] : currentPage,
//       );
//     } catch (e) {
//       print('Error initializing PDF Controller: $e');
//     }

//     paymentService = PaymentService(dotenv.env['IP_ADDRESS']!);

//     pricingService = PricingService();

//     _fetchTotalPayment().catchError((e) {
//       print('Error fetching total payment: $e');
//     });
//   }

//   Future<void> _fetchTotalPayment() async {
//     double calculatedTotal = await calculateTotalPayment(
//       widget.colorIndex,
//       widget.paperSizeIndex,
//       widget.pagesIndex,
//       widget.pageCount,
//       widget.selectedPages,
//       widget.copies,
//     );
//     setState(() {
//       totalPayment = calculatedTotal;
//     });
//   }

//   Future<Map<String, double>> getPricing() async {
//     try {
//       final pricing = await pricingService.fetchPricingData();
//       return {
//         'longBondPrice': double.tryParse(pricing['longBondPrice'] ?? '0') ?? 0,
//         'shortBondPrice': double.tryParse(pricing['shortBondPrice'] ?? '0') ?? 0,
//         'coloredPrice': double.tryParse(pricing['coloredPrice'] ?? '0') ?? 0,
//         'grayscalePrice': double.tryParse(pricing['grayscalePrice'] ?? '0') ?? 0,
//       };
//     } catch (e) {
//       print('Error fetching pricing data: $e');
//       return {
//         'longBondPrice': 0,
//         'shortBondPrice': 0,
//         'coloredPrice': 0,
//         'grayscalePrice': 0,
//       };
//     }
//   }

//   Future<double> calculateTotalPayment(int colorIndex, int paperSizeIndex, int pagesIndex, int pageCount, List<int> selectedPages, int copies) async {
//     final pricing = await getPricing();

//     double shortBondPrice = pricing['shortBondPrice'] ?? 0;
//     double longBondPrice = pricing['longBondPrice'] ?? 0;
//     double coloredPrice = pricing['coloredPrice'] ?? 0;
//     double grayscalePrice = pricing['grayscalePrice'] ?? 0;
//     double shortBondPriceColored = shortBondPrice + coloredPrice;
//     double longBondPriceColored = longBondPrice + coloredPrice;
//     double shortBondPriceGrayscale = shortBondPrice + grayscalePrice;
//     double longBondPriceGrayscale = longBondPrice + coloredPrice;

//     double pricePerPage = 0.0;

//     if (colorIndex == 1) {
//       pricePerPage = paperSizeIndex == 0 ? shortBondPriceColored : longBondPriceColored;
//     } else {
//       pricePerPage = paperSizeIndex == 0 ? shortBondPriceGrayscale : longBondPriceGrayscale;
//     }

//     int totalPageCount = pagesIndex == 0 ? pageCount : selectedPages.length;
//     return pricePerPage * totalPageCount * copies;
//   }

//   void _previousPage() {
//     if (widget.pagesIndex == 1) {
//       if (currentPageIndex > 0) {
//         setState(() {
//           currentPageIndex--;
//           pdfController.animateToPage(
//             widget.selectedPages[currentPageIndex],
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeIn,
//           );
//         });
//       }
//     } else {
//       if (currentPage > 1) {
//         pdfController.previousPage(
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeOut,
//         );
//         setState(() {
//           currentPage--;
//         });
//       }
//     }
//   }

//   void _nextPage() {
//     if (widget.pagesIndex == 1) {
//       if (currentPageIndex < widget.selectedPages.length) {
//         setState(() {
//           currentPageIndex++;
//           pdfController.animateToPage(
//             widget.selectedPages[currentPageIndex],
//             duration: const Duration(milliseconds: 250),
//             curve: Curves.easeIn,
//           );
//         });
//       }
//     } else {
//       if (currentPage < widget.pageCount) {
//         pdfController.nextPage(
//           duration: const Duration(milliseconds: 250),
//           curve: Curves.easeIn,
//         );
//         setState(() {
//           currentPage++;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     pdfController.dispose();
//     paymentService.dispose();
//     super.dispose();
//   }

//   Future<void> printDocument() async {
//     // Prepare print settings payload
//     Map<String, dynamic> printSettings = {
//       'pdfPath': '', // Fill this with the actual path received from the server after upload
//       'paperSizeIndex': widget.paperSizeIndex,
//       'colorIndex': widget.colorIndex,
//       'pagesIndex': widget.pagesIndex,
//       'selectedPages': widget.selectedPages,
//       'copies': widget.copies,
//     };

//     // Send POST request to backend /print endpoint
//     try {
//       final response = await http.post(
//         Uri.parse('http://${dotenv.env['IP_ADDRESS']!}:3000/print/print'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(printSettings),
//       );

//       if (response.statusCode == 200) {
//         // If the printing is successful:
//         setState(() {
//           paymentInserted = 0.0;
//           proceedToPaymentClicked = false;
//         });

//         // Reset coin count in the backend
//         await paymentService.resetCounts();
//       } else {
//         // Handle error response
//         print('Failed to print: ${response.reasonPhrase}');
//         // Optionally, show error message to user
//       }
//     } catch (e) {
//       // Handle network or server-side error
//       print('Error printing document: $e');
//       // Optionally, show error message to user
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         titleText: 'BULSU HC VENDO PRINTING MACHINE',
//       ),
//       backgroundColor: const Color(0xFF2B2E4A),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: totalPayment == 0.0
//               ? const CircularProgressIndicator()
//               : Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       flex: 2,
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: Padding(
//                               padding: const EdgeInsets.only(left: 16.0, bottom: 32.0),
//                               child: PdfView(
//                                 controller: pdfController,
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 IconButton(
//                                   icon: const Icon(Icons.arrow_back, color: Colors.white),
//                                   onPressed: _previousPage,
//                                 ),
//                                 Text(
//                                   widget.pagesIndex == 0
//                                       ? '$currentPage/${widget.pageCount}'
//                                       : '${currentPageIndex + 1}/${widget.selectedPages.length}',
//                                   style: const TextStyle(fontSize: 18.0, color: Colors.white),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.arrow_forward, color: Colors.white),
//                                   onPressed: _nextPage,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       flex: 3,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 50.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(16.0),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFD8DEE9),
//                                 borderRadius: BorderRadius.circular(8.0),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     const Text(
//                                       'PRINT SETTINGS CONFIRMATION',
//                                       style: TextStyle(
//                                         fontSize: 24,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF2B2E4A),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 16),
//                                     _buildSettingRow('File Name:', widget.fileName),
//                                     _buildSettingRow('Page Count:', widget.pageCount.toString()),
//                                     _buildSettingRow('Print Color:', getColor()),
//                                     _buildSettingRow('Paper Size:', getPaperSize()),
//                                     _buildSettingRow('Pages to Print:', getPages()),
//                                     _buildSettingRow('Number of Copies:', widget.copies.toString()),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 16),
//                             Center(
//                               child: Container(
//                                 padding: const EdgeInsets.all(16.0),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFFD8DEE9),
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     const Text(
//                                       'Total Amount:',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF2B2E4A),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       '₱${totalPayment.toStringAsFixed(2)}',
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         color: Color(0xFF2B2E4A),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     proceedToPaymentClicked
//                                         ? Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               const Text(
//                                                 'Payment Inserted:',
//                                                 style: TextStyle(
//                                                   fontSize: 20,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Color(0xFF2B2E4A),
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Text(
//                                                 '₱${paymentInserted.toStringAsFixed(2)}',
//                                                 style: const TextStyle(
//                                                   fontSize: 18,
//                                                   color: Color(0xFF2B2E4A),
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 16),
//                                               paymentInserted >= totalPayment
//                                                   ? ElevatedButton(
//                                                       onPressed: printDocument,
//                                                       style: ElevatedButton.styleFrom(
//                                                         textStyle: const TextStyle(fontSize: 20),
//                                                         padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                                                         foregroundColor: Colors.white,
//                                                         backgroundColor: const Color(0xFF8D6E63),
//                                                       ),
//                                                       child: const Text(
//                                                         'PRINT',
//                                                         style: TextStyle(fontSize: 20.0),
//                                                       ),
//                                                     )
//                                                   : const CircularProgressIndicator(),
//                                             ],
//                                           )
//                                         : ElevatedButton(
//                                             onPressed: () {
//                                               setState(() {
//                                                 proceedToPaymentClicked = true;
//                                                 paymentService.listenToPaymentUpdates((amount) {
//                                                   setState(() {
//                                                     paymentInserted = amount;
//                                                   });
//                                                 });
//                                               });
//                                             },
//                                             style: ElevatedButton.styleFrom(
//                                               textStyle: const TextStyle(fontSize: 20),
//                                               padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                                               foregroundColor: Colors.white,
//                                               backgroundColor: const Color(0xFF8D6E63),
//                                             ),
//                                             child: const Text(
//                                               'PROCEED TO PAYMENT',
//                                               style: TextStyle(fontSize: 20.0),
//                                             ),
//                                           ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(fontSize: 16, color: Color(0xFF2B2E4A)),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 16, color: Color(0xFF2B2E4A)),
//           ),
//         ],
//       ),
//     );
//   }

//   String getPaperSize() {
//     switch (widget.paperSizeIndex) {
//       case 0:
//         return 'Short';
//       case 1:
//         return 'Long';
//       default:
//         return '';
//     }
//   }

//   String getColor() {
//     switch (widget.colorIndex) {
//       case 0:
//         return 'Grayscale';
//       case 1:
//         return 'Colored';
//       default:
//         return '';
//     }
//   }

//   String getPages() {
//     switch (widget.pagesIndex) {
//       case 0:
//         return 'All Pages';
//       case 1:
//         return 'Selected Pages';
//       default:
//         return '';
//     }
//   }
// }

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pdfx/pdfx.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/print/printing_service.dart';
import 'package:frontend/payment/payment_service.dart';
import 'package:frontend/pricing/pricing_service.dart';

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
  final PrintingService _printingService = PrintingService();
  double totalPayment = 0.0;
  double paymentInserted = 0.0;
  bool proceedToPaymentClicked = false;
  int currentPageIndex = 0;
  int currentPage = 1;
  late PdfController pdfController;
  late PaymentService paymentService;
  late PricingService pricingService;

  @override
  void initState() {
    super.initState();
    try {
      pdfController = PdfController(
        document: PdfDocument.openData(widget.pdfBytes),
        initialPage: widget.pagesIndex == 1 ? widget.selectedPages[0] : currentPage,
      );
    } catch (e) {
      print('Error initializing PDF Controller: $e');
    }

    paymentService = PaymentService(dotenv.env['IP_ADDRESS']!);
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
    double calculatedTotal = await _printingService.fetchTotalPayment(
      colorIndex: widget.colorIndex,
      paperSizeIndex: widget.paperSizeIndex,
      pagesIndex: widget.pagesIndex,
      pageCount: widget.pageCount,
      selectedPages: widget.selectedPages,
      copies: widget.copies,
      pricingService: pricingService,
    );
    setState(() {
      totalPayment = calculatedTotal;
    });
  }

  void _handlePrintSuccess() {
    setState(() {
      paymentInserted = 0.0;
      proceedToPaymentClicked = false;
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
                                                      onPressed: () async {
                                                        await _printingService.printDocument(
                                                          ipAddress: dotenv.env['IP_ADDRESS']!,
                                                          pdfBytes: widget.pdfBytes,
                                                          paperSizeIndex: widget.paperSizeIndex,
                                                          colorIndex: widget.colorIndex,
                                                          pagesIndex: widget.pagesIndex,
                                                          selectedPages: widget.selectedPages,
                                                          copies: widget.copies,
                                                          paymentService: paymentService,
                                                          onSuccess: _handlePrintSuccess
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        textStyle: const TextStyle(fontSize: 20),
                                                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                                        foregroundColor: Colors.white,
                                                        backgroundColor: const Color(0xFF8D6E63),
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
                                                // paymentService.startFetchingStatus();
                                                // paymentService.listenToPaymentUpdates((amount) {
                                                //   setState(() {
                                                //     paymentInserted = amount;
                                                //   });
                                                // });
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
        return 'Colored';
      case 1:
        return 'Grayscale';
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
}
