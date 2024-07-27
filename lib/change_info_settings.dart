import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangeInfoSettings extends StatefulWidget {
  final String username;
  const ChangeInfoSettings({
    super.key,
    required this.username
  });

  @override
  ChangeInfoSettingsState createState() => ChangeInfoSettingsState();
}

class ChangeInfoSettingsState extends State<ChangeInfoSettings> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? currentEmail;
  String? currentUsername;
  String? currentPassword;
  bool isLoading = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAdminDetails(widget.username);
  }

  String? validateGmail(String value) {
    final RegExp gmailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    if (value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!gmailRegex.hasMatch(value)) {
      return 'Please enter a valid Gmail address';
    }
    return null;
  }


  Future<void> _fetchAdminDetails(String username) async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(
        Uri.parse('http://${AppConfig.ipAddress}:3000/admin/getAdminDetails?username=$username'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          currentEmail = data['email'];
          currentUsername = data['username'];
          currentPassword = data['password'];
          isLoading = false;
        });
        print('Current password fetched: $currentPassword');

      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        print('Failed to fetch admin details: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      print('Error fetching admin details: $error');
    }
  }

  Future<void> updateAdminDetails({required String enteredPassword, String? newEmail, String? newUsername, String? newPassword}) async {
    // Update admin details in backend
    try {
      final response = await http.post(
        Uri.parse('http://${AppConfig.ipAddress}:3000/admin/updateAdminDetails'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': newEmail != null ? newEmail : currentEmail,
          'username': newUsername != null ? newUsername : currentUsername,
          'newPassword': newPassword != null ? newPassword : '',
          'currentPassword': enteredPassword,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          if (newEmail != null) currentEmail = data['email'];
          if (newUsername != null) currentUsername = data['username'];
          if (newPassword != null) currentPassword = newPassword;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Details updated successfully')),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update admin details: ${data['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating admin details: $error')),
      );
    }
  }

  void _showChangeDetailsDialog(String title, String labelText, TextEditingController controller) {
    final TextEditingController enteredPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'New $labelText',
                  ),
                  validator: (value) {
                    if (title == 'Email') {
                      return validateGmail(value ?? '');
                    }
                    return null;
                  },
                ),
                TextField(
                  controller: enteredPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  updateAdminDetails(
                    enteredPassword: enteredPasswordController.text,
                    newEmail: title == 'Email' ? controller.text : null,
                    newUsername: title == 'Username' ? controller.text : null,
                  );
                  Navigator.of(context).pop();
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

  void _showChangePasswordDialog(TextEditingController controller) {
    final TextEditingController enteredPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    
    final _formKey = GlobalKey<FormState>();

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
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: enteredPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length != 4) {
                      return 'Password must be 4 digits only';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  updateAdminDetails(
                    enteredPassword: enteredPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                  Navigator.of(context).pop();
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
      child: isLoading
        ? const CircularProgressIndicator()
        : hasError
          ? const Text(
            'Failed to load admin details. Please try again later.',
            style:  TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          )
          : Padding(
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
                    _buildDetailsDisplayRow('Email', currentEmail!),
                    _buildDetailsDisplayRow('Username', currentUsername!),
                    const SizedBox(height: 16),

                    // Display the buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showChangeDetailsDialog('Email', 'Email', _emailController);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF8D6E63),
                          ),
                          child: const Text('Change Email'),
                        ),
                        const SizedBox(width: 16),
                        
                        ElevatedButton(
                          onPressed: () {
                            _showChangeDetailsDialog('Username', 'Username', _usernameController);
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
                        _showChangePasswordDialog(_passwordController);
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
          )
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
