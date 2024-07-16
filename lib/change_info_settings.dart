import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeInfoSettings extends StatefulWidget {
  const ChangeInfoSettings({super.key});

  @override
  ChangeInfoSettingsState createState() => ChangeInfoSettingsState();
}

class ChangeInfoSettingsState extends State<ChangeInfoSettings> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String currentEmail = ''; // Replace with actual current email
  String currentUsername = ''; // Replace with actual current username
  String currentPassword = ''; // Replace with actual current password
  bool emailSet = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminDetails();
  }

  void _fetchAdminDetails() async {
    // Fetch admin details from backend
    try {
      final response = await http.get(Uri.parse('http://192.168.100.33:3000/getAdminDetails'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentEmail = data['email'];
          currentUsername = data['username'];
          emailSet = currentEmail.isNotEmpty;
        });
      } else {
        print('Failed to fetch admin details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching admin details: $error');
    }
  }

  void _updateAdminDetails(String newEmail, String newUsername, String newPassword) async {
    // Update admin details in backend
    try {
      final response = await http.post(
        Uri.parse('http://${AppConfig.ipAddress}:3000/updateAdminDetails'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': newEmail,
          'username': newUsername,
          'password': newPassword,
          'currentPassword': currentPassword,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentEmail = data['email'];
          currentUsername = data['username'];
          emailSet = currentEmail.isNotEmpty;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Details updated successfully')),
        );
      } else {
        print('Failed to update admin details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating admin details: $error');
    }
  }

  void _showChangeDialog(String title, String labelText, TextEditingController controller, Function(String) updateFunction) {
    final TextEditingController _currentPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Change $title'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'New $labelText',
                ),
              ),
              if (emailSet) // Only show password confirmation if email is already set
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (!emailSet || _currentPasswordController.text == currentPassword) {
                  updateFunction(controller.text);
                  Navigator.of(context).pop();
                } else {
                  print('Incorrect current password');
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 124.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 32.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Change Info Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Display current email if set
              if (emailSet)
                Text(
                  'Email: $currentEmail',
                  style: TextStyle(fontSize: 20),
                ),
              const SizedBox(height: 16),
              if (emailSet)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _showChangeDialog('Email', 'Email', _emailController, (newEmail) {
                        _updateAdminDetails(newEmail, '', '');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF8D6E63),
                    ),
                    child: const Text('Change Email'),
                  ),
                ),
              if (!emailSet)
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _showChangeDialog('Email', 'Email', _emailController, (newEmail) {
                        _updateAdminDetails(newEmail, '', '');
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF8D6E63),
                    ),
                    child: const Text('Add Email'),
                  ),
                ),
              const SizedBox(height: 24),

              // Display current username
              Text(
                'Username: $currentUsername',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showChangeDialog('Username', 'Username', _usernameController, (newUsername) {
                      _updateAdminDetails('', newUsername, '');
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF8D6E63),
                  ),
                  child: const Text('Change Username'),
                ),
              ),
              const SizedBox(height: 24),

              // Change password
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _showChangeDialog('Password', 'Password', _passwordController, (newPassword) {
                      _updateAdminDetails('', '', newPassword);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF8D6E63),
                  ),
                  child: const Text('Change Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
