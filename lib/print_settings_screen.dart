import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:frontend/custom_app_bar.dart';
import 'package:frontend/print_payment_screen.dart';
import 'package:frontend/custom_button_row.dart';
import 'package:pdfx/pdfx.dart';

class PrintSettingsScreen extends StatefulWidget {
  const PrintSettingsScreen({
    super.key,
    required this.fileName,
    required this.pageCount,
    required this.pdfBytes,
  });

  final String fileName;
  final int pageCount;
  final Uint8List pdfBytes;

  @override
  PrintSettingsScreenState createState() => PrintSettingsScreenState();
}

class PrintSettingsScreenState extends State<PrintSettingsScreen> {
  int _paperSizeIndex = -1;
  int _colorIndex = -1;
  int _pagesIndex = -1;
  int _copies = 0;
  bool showSpecificPages = false;
  List<int> selectedPages = [];
  int currentPage = 1;
  late PdfController pdfController;

  @override
  void initState() {
    super.initState();

    pdfController = PdfController(
      document: PdfDocument.openData(widget.pdfBytes),
    );
  }

  bool get canProceed =>
      _paperSizeIndex != -1 &&
      _colorIndex != -1 &&
      _pagesIndex != -1 &&
      _copies > 0 &&
      (!showSpecificPages || selectedPages.isNotEmpty);

  void _previousPage() {
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

  void _nextPage() {
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

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      backgroundColor: const Color(0xFF2B2E4A),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white
                          ),
                          onPressed: _previousPage
                        ),
                        Text(
                          '$currentPage/${widget.pageCount}',
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
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFF63678E),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PRINT SETTINGS",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Customize your print options.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomButtonRow(
                            title: "Paper Size",
                            options: const ["Letter (8.5\" x 11\")", "Legal (8.5\" x 13\")"],
                            selectedIndex: _paperSizeIndex,
                            onSelected: (index) {
                              setState(() {
                                _paperSizeIndex = index;
                              });
                            },
                          ),
                          CustomButtonRow(
                            title: "Color",
                            options: const ["Colored", "Grayscale"],
                            selectedIndex: _colorIndex,
                            onSelected: (index) {
                              setState(() {
                                _colorIndex = index;
                              });
                            },
                          ),
                          CustomButtonRow(
                            title: "Pages",
                            options: const ["All Pages", "Specific Pages"],
                            selectedIndex: _pagesIndex,
                            onSelected: (index) {
                              setState(() {
                                _pagesIndex = index;
                                showSpecificPages = index == 1;
                              });
                            },
                          ),
                          if (showSpecificPages) ...[
                            const SizedBox(height: 8),
                            const Text(
                              "Select Pages",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ListView.builder(
                                itemCount: widget.pageCount,
                                itemBuilder: (context, index) {
                                  return CheckboxListTile(
                                    title: Text('Page ${index + 1}'),
                                    value: selectedPages.contains(index + 1),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedPages.add(index + 1);
                                        } else {
                                          selectedPages.remove(index + 1);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _copies = int.tryParse(value) ?? 0;
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Copies',
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Enter number of copies (1-10)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: canProceed
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PrintPaymentScreen(
                                            fileName: widget.fileName,
                                            pageCount: widget.pageCount,
                                            paperSizeIndex: _paperSizeIndex,
                                            colorIndex: _colorIndex,
                                            pagesIndex: _pagesIndex,
                                            selectedPages: selectedPages,
                                            copies: _copies,
                                            pdfBytes: widget.pdfBytes
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 20),
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF8D6E63),
                              ),
                              child: const Text(
                                "PROCEED",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}