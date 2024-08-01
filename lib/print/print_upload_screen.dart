import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/widgets/custom_app_bar.dart';

class PrintUploadScreen extends StatefulWidget {
  const PrintUploadScreen({super.key});

  @override
  PrintUploadScreenState createState() => PrintUploadScreenState();
}

class PrintUploadScreenState extends State<PrintUploadScreen> {
  String? selectedFileName;
  List<int>? pdfBytes;
  bool fileUploaded = false;

  Future<void> _selectFile() async {
    var filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (filePickerResult != null && filePickerResult.files.isNotEmpty) {
      setState(() {
        selectedFileName = filePickerResult.files.first.name;
        pdfBytes = filePickerResult.files.first.bytes;
        fileUploaded = false;
      });
    }
  }

  Future<void> _uploadFile(BuildContext context) async {
    if (selectedFileName != null && pdfBytes != null) {
      try {
        var url = Uri.parse('http://${dotenv.env['IP_ADDRESS']!}:3000/file/upload');

        var request = http.MultipartRequest('POST', url)
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              pdfBytes!,
              filename: selectedFileName!,
            ),
          );

        var response = await request.send();

        if (response.statusCode == 200) {
          setState(() {
            fileUploaded = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File upload failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error uploading file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2E4A),
      appBar: const CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      body: Center(
        child: fileUploaded
            ? _buildUploadSuccessUI()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Upload Your File Here',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _selectFile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6E63),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      textStyle: const TextStyle(fontSize: 18),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Select File'),
                  ),
                  const SizedBox(height: 20),
                  if (selectedFileName != null)
                    Center (
                      child: Column(
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
                              fontSize: 20,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _uploadFile(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8D6E63),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              textStyle: const TextStyle(fontSize: 18),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Upload'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildUploadSuccessUI() {
    return Container(
      color: const Color(0xFF2B2E4A),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'File uploaded successfully',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
