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
      final response = await http.get(Uri.parse('http://${AppConfig.ipAddress}:3000/admin/getAdminDetails'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentEmail = data['email'];
          currentUsername = data['username'];
          currentPassword = data['password'];
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
        Uri.parse('http://${AppConfig.ipAddress}:3000/admin/updateAdminDetails'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': newEmail.isNotEmpty ? newEmail : currentEmail,
          'username': newUsername.isNotEmpty ? newUsername : currentUsername,
          'password': newPassword.isNotEmpty ? newPassword : currentPassword,
          'currentPassword': currentPassword,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentEmail = data['email'];
          currentUsername = data['username'];
          currentPassword = newPassword.isNotEmpty ? newPassword : currentPassword;
          emailSet = currentEmail.isNotEmpty;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully')),
        );
      } else {
        print('Failed to update admin details: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating admin details: $error');
    }
  }

  void _showChangeDetailsDialog(String title, String labelText, TextEditingController controller, Function(String) updateFunction) {
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
                icon: const Icon(Icons.close),
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
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_currentPasswordController.text == currentPassword) {
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

  void _showChangePasswordDialog(TextEditingController controller, Function(String) updateFunction) {
    final TextEditingController _currentPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Change Password'),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.close),
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
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
              ),
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
              ),
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_currentPasswordController.text == currentPassword) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 124.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Text(
                'Change Information Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Display all details first
              _buildDetailsDisplayRow('Email', currentEmail),
              _buildDetailsDisplayRow('Username', currentUsername),
              const SizedBox(height: 16),

              // Display the buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (emailSet)
                    ElevatedButton(
                      onPressed: () {
                        _showChangeDetailsDialog('Email', 'Email', _emailController, (newEmail) {
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
                  if (!emailSet)
                    ElevatedButton(
                      onPressed: () {
                        _showChangeDetailsDialog('Email', 'Email', _emailController, (newEmail) {
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
                  const SizedBox(width: 16),
                  
                  ElevatedButton(
                    onPressed: () {
                      _showChangeDetailsDialog('Username', 'Username', _usernameController, (newUsername) {
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
                ],
              ),
              // Change password
              const SizedBox(height: 20),
              const Text(
                'Password',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _showChangePasswordDialog(_passwordController, (newPassword) {
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsDisplayRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              height: 40,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
