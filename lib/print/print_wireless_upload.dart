import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:html' as html;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:frontend/widgets/custom_app_bar.dart';
import 'package:frontend/print/print_settings_screen.dart';

class PrintWirelessUploadScreen extends StatefulWidget {
  const PrintWirelessUploadScreen({super.key});

  @override
  PrintWirelessUploadScreenState createState() =>
      PrintWirelessUploadScreenState();
}

class PrintWirelessUploadScreenState extends State<PrintWirelessUploadScreen> {
  String? selectedFileName;
  int? pageCount;
  bool isLoading = false;
  bool isUploading = false;
  Uint8List? pdfBytes;
  late WebSocketChannel channel;
  bool showConfirmationButton = false;

  @override
  void initState() {
    super.initState();
    String ipAddress = dotenv.env['IP_ADDRESS']!;
    String wsUrl = 'ws://$ipAddress:3000';
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    channel.stream.listen((message) {
      final data = jsonDecode(message);

      // Check if the received file has a valid extension
      String fileName = data['fileName'];
      if (!['pdf', 'docx'].contains(fileName.split('.').last.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unsupported file type received.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit if the file is not a supported type
      }

      setState(() {
        selectedFileName = fileName;
        pageCount = data['pageCount'];
        pdfBytes = base64Decode(data['pdfBytes']);
        isLoading = false;
        isUploading = false;
        showConfirmationButton = true; // Show the confirmation button after receiving data
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void navigateToPrintSettingsScreen() {
    if (selectedFileName != null && pageCount != null && pdfBytes != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintSettingsScreen(
            fileName: selectedFileName!,
            pageCount: pageCount!,
            pdfBytes: pdfBytes!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentUrl = html.window.location.href;
    final Uri uri = Uri.parse(currentUrl);
    String ipAddress = dotenv.env['IP_ADDRESS']!;
    final String uploadUrl = '${uri.scheme}://$ipAddress:${uri.port}/#/upload';

    return MaterialApp(
      home: Scaffold(
        appBar: const CustomAppBar(
          titleText: 'BULSU HC VENDO PRINTING MACHINE',
        ),
        backgroundColor: const Color(0xFF2B2E4A),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'WIRELESS FILE UPLOAD',
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Scan the QR code to upload a file:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.all(10.0),
                        child: QrImageView(
                          data: uploadUrl,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 50.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: Colors.white,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (selectedFileName != null)
                            Column(
                              children: [
                                const Icon(
                                  Icons.file_copy_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Selected File: $selectedFileName',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (showConfirmationButton)
                                  ElevatedButton(
                                    onPressed: navigateToPrintSettingsScreen,
                                    style: ElevatedButton.styleFrom(
                                      textStyle: const TextStyle(fontSize: 20),
                                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                      minimumSize: const Size(100, 50),
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFF8D6E63),
                                    ),
                                    child: const Text('Confirm'),
                                  ),
                              ],
                            ),
                          if (selectedFileName == null && !isLoading && !isUploading)
                            const Text(
                              'No files selected.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
