import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'custom_app_bar.dart';
import 'print_settings_screen.dart';
import 'package:http/http.dart' as http;

class UploadUsingFlashdriveScreen extends StatefulWidget {
  const UploadUsingFlashdriveScreen({super.key});

  @override
  UploadUsingFlashdriveScreenState createState() =>
      UploadUsingFlashdriveScreenState();
}

class UploadUsingFlashdriveScreenState
    extends State<UploadUsingFlashdriveScreen> {
  static const platform = MethodChannel('com.example.app/usb');
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
            mainAxisAlignment: MainAxisAlignment.start,
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
                          'Once connected, click below to choose a file.',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: _loadFilesFromStorage,
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                            minimumSize: const Size(100, 50),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF8D6E63),
                          ),
                          icon: const Icon(Icons.folder),
                          label: const Text('Choose File'),
                        ),
                        const SizedBox(height: 20),
                        if (isLoading || isUploading)
                          const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        const SizedBox(height: 20),
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
                              ElevatedButton(
                                onPressed: _confirmSelection,
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
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadFilesFromStorage() async {
    setState(() {
      isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        String extension = result.files.first.extension!;
        if (['pdf', 'docx'].contains(extension.toLowerCase())) {
          setState(() {
            selectedFileName = result.files.first.name;
            pdfBytes = result.files.first.bytes;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          // Show error message for unsupported file type
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unsupported file type selected. Please select a PDF or DOCX file.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        // User canceled the file picker
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error
      print('Error picking file: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmSelection() async {
    if (pdfBytes != null && selectedFileName != null) {
      setState(() {
        isLoading = true;
        isUploading = true;
      });

      try {
        var uri = Uri.parse('http://${dotenv.env['IP_ADDRESS']!}:3000/file/upload');
        var request = http.MultipartRequest('POST', uri)
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              pdfBytes!,
              filename: selectedFileName!,
            ),
          );

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(responseBody);

          String fileName = jsonResponse['fileName'];
          int pageCount = jsonResponse['pageCount'];
          Uint8List pdfBytes = base64Decode(jsonResponse['pdfBytes'] as String);

          setState(() {
            selectedFileName = null;
            this.pdfBytes = null;
            isLoading = false;
            isUploading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrintSettingsScreen(
                fileName: fileName,
                pageCount: pageCount,
                pdfBytes: pdfBytes,
              ),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
            isUploading = false;
          });
          print('Error: ${response.statusCode}');
          // Show error message to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload failed. Error: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
          isUploading = false;
        });
        print('Error uploading file: $e');
        // Show error message to user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() {
        isLoading = false;
        isUploading = false;
      });
      print('File bytes or selected file name is null.');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File bytes or selected file name is null.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
