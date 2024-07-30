// import 'package:flutter/material.dart';
// import 'package:frontend/copy_settings_screen.dart';
// import 'package:frontend/print_select_screen.dart';
// import 'package:frontend/scan_settings_screen.dart';
// import 'package:frontend/print_upload_screen.dart';
// import 'package:frontend/admin_login_screen.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const VPM());
// }

// class VPM extends StatelessWidget {
//   const VPM({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Vendo Printing Machine',
//       initialRoute: '/',
//       onGenerateRoute: (settings) {
//         if (settings.name == '/') {
//           return MaterialPageRoute(builder: (_) => const HomePage());
//         } else if (settings.name == '/upload') {
//           return MaterialPageRoute(builder: (_) => const PrintUploadScreen());
//         }
//         return null;
//       },
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   HomePageState createState() => HomePageState();
// }

// class HomePageState extends State<HomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF2B2E4A),
//         automaticallyImplyLeading: false,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             IconButton(
//               icon: const Icon(
//                 Icons.settings,
//                 color: Colors.white,
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
//                 );
//               },
//             ),
//             Flexible(
//               child: Container(
//                 alignment: Alignment.centerRight,
//                 child: const Text(
//                   'BULSU HC VENDO PRINTING MACHINE',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: kToolbarHeight),
//           ],
//         ),
//         centerTitle: false,
//       ),
//       body: Container(
//         color: const Color(0xFF2B2E4A),
//         child: Center(
//           child: SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: BoxConstraints(
//                 minHeight: MediaQuery.of(context).size.height,
//               ),
//               child: IntrinsicHeight(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 40),
//                     const Text(
//                       'WELCOME!',
//                       style: TextStyle(
//                         fontSize: 80,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Current Available Papers:',
//                       style: TextStyle(
//                         fontSize: 24,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const Text(
//                       'Letter/Short:',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const Text(
//                       'Legal/Long:',
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 100),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const PrintSelectScreen()),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 textStyle: const TextStyle(fontSize: 25),
//                                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//                                 foregroundColor: Colors.white,
//                                 backgroundColor: const Color(0xFF8D6E63),
//                               ),
//                               icon: const Icon(Icons.print, size: 60),
//                               label: const Text('PRINT'),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const ScanSettingsScreen()),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 textStyle: const TextStyle(fontSize: 25),
//                                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//                                 foregroundColor: Colors.white,
//                                 backgroundColor: const Color(0xFF8D6E63),
//                               ),
//                               icon: const Icon(Icons.document_scanner, size: 60),
//                               label: const Text('SCAN'),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(builder: (context) => const CopySettingsScreen()),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                 ),
//                                 textStyle: const TextStyle(fontSize: 25),
//                                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
//                                 foregroundColor: Colors.white,
//                                 backgroundColor: const Color(0xFF8D6E63),
//                               ),
//                               icon: const Icon(Icons.file_copy, size: 60),
//                               label: const Text('PHOTOCOPY'),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/copy_settings_screen.dart';
import 'package:frontend/print_select_screen.dart';
import 'package:frontend/scan_settings_screen.dart';
import 'package:frontend/print_upload_screen.dart';
import 'package:frontend/admin_login_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VPM());
}

class VPM extends StatelessWidget {
  const VPM({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendo Printing Machine',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const HomePage());
        } else if (settings.name == '/upload') {
          return MaterialPageRoute(builder: (_) => const PrintUploadScreen());
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController longPaperController = TextEditingController(text: '0');
  final TextEditingController shortPaperController = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B2E4A),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                );
              },
            ),
            Flexible(
              child: Container(
                alignment: Alignment.centerRight,
                child: const Text(
                  'BULSU HC VENDO PRINTING MACHINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: kToolbarHeight),
          ],
        ),
        centerTitle: false,
      ),
      body: Container(
        color: const Color(0xFF2B2E4A),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'WELCOME!',
                      style: TextStyle(
                        fontSize: 80,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Current Available Papers:',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Long',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Short',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                longPaperController.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                shortPaperController.text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 100),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PrintSelectScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                textStyle: const TextStyle(fontSize: 25),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF8D6E63),
                              ),
                              icon: const Icon(Icons.print, size: 60),
                              label: const Text('PRINT'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ScanSettingsScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                textStyle: const TextStyle(fontSize: 25),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF8D6E63),
                              ),
                              icon: const Icon(Icons.document_scanner, size: 60),
                              label: const Text('SCAN'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CopySettingsScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                textStyle: const TextStyle(fontSize: 25),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF8D6E63),
                              ),
                              icon: const Icon(Icons.file_copy, size: 60),
                              label: const Text('PHOTOCOPY'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
