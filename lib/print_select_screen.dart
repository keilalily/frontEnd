import 'package:flutter/material.dart';
import 'package:frontend/print_wireless_upload.dart';
import 'package:frontend/upload_using_flashdrive.dart';
import 'custom_app_bar.dart';


class PrintSelectScreen extends StatelessWidget {
  const PrintSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2E4A),
      appBar: const CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40),
            const Text(
              'PRINT FORM',
              style: TextStyle(
                fontSize: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Choose a method to upload your file:',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Row (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PrintWirelessUploadScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(fontSize: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 60),
                        minimumSize: const Size(100, 50),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF8D6E63),
                      ),
                      icon: const Icon(Icons.qr_code, size: 90),
                      label: const Text('Wireless Upload'),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UploadUsingFlashdriveScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        textStyle: const TextStyle(fontSize: 40),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                        minimumSize: const Size(100, 50),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF8D6E63),
                      ),
                      icon: const Icon(Icons.usb, size: 90),
                      label: const Text('Upload via Flashdrive'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
