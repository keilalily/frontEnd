import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/config.dart';
import 'package:frontend/scan_settings_screen.dart';
import 'custom_app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:js' as js;

class ScanSelectDirectory extends StatefulWidget {
  const ScanSelectDirectory({super.key});

  @override
  ScanSelectDirectoryState createState() =>
      ScanSelectDirectoryState();
}

class ScanSelectDirectoryState
    extends State<ScanSelectDirectory> {
  static const platform = MethodChannel('com.example.app/usb');
  String? selectedFolderPath;
  String? selectedFileName;
  bool isLoading = false;
  bool isUploading = false;
  Uint8List? pdfBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2E4A),
      appBar: const CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20),
              const Icon(
                Icons.usb,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              const Text(
                'Please connect your flash drive to the machine.',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100.0),
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
                        const Text(
                          'Once connected, click below to choose a directory.',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _selectFolder,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            minimumSize: const Size(100, 50),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF8D6E63),
                          ),
                          icon: const Icon(Icons.folder),
                          label: const Text('Choose Directory'),
                        ),
                        const SizedBox(height: 20),
                        if (isLoading || isUploading)
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        const SizedBox(height: 20),
                        if (selectedFolderPath != null)
                          Column(
                            children: [
                              const Icon(
                                Icons.file_copy_outlined,
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Selected Directory: $selectedFolderPath',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ScanSettingsScreen()),
                                  );
                                },
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
                        if (selectedFolderPath == null && !isLoading && !isUploading)
                          const Text(
                            'No directory selected.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Future<void> _selectFolder() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Execute JavaScript code to prompt directory selection dialog
      js.context.callMethod('openDirectoryDialog').then((selectedPath) {
        if (selectedPath != null) {
          setState(() {
            selectedFolderPath = selectedPath;
            isLoading = false;
          });

          // Make API call to set the directory
          var uri = Uri.parse('http://${AppConfig.ipAddress}:3000/setScanDirectory');
          http.post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'directory': selectedFolderPath,
            }),
          ).then((response) {
            if (response.statusCode != 200) {
              print('Error setting directory: ${response.statusCode}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error setting directory: ${response.statusCode}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error picking folder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking folder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
