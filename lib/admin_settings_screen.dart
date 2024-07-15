import 'package:flutter/material.dart';
import 'package:frontend/custom_app_bar.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  AdminSettingsScreenState createState() => AdminSettingsScreenState();
}

class AdminSettingsScreenState extends State<AdminSettingsScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _longBondPriceController = TextEditingController();
  TextEditingController _shortBondPriceController = TextEditingController();
  TextEditingController _coloredPriceController = TextEditingController();
  TextEditingController _grayscalePriceController = TextEditingController();
  TextEditingController _highResolutionPriceController = TextEditingController();
  TextEditingController _mediumResolutionPriceController = TextEditingController();
  TextEditingController _lowResolutionPriceController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _longBondPriceController.dispose();
    _coloredPriceController.dispose();
    _grayscalePriceController.dispose();
    _highResolutionPriceController.dispose();
    _mediumResolutionPriceController.dispose();
    _lowResolutionPriceController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _savePricing() {
    if (_formKey.currentState!.validate()) {
      // Save the pricing information to the backend or database
      // Example:
      // final longBondColoredPrice = double.parse(_longBondColoredController.text);
      // final longBondGrayscalePrice = double.parse(_longBondGrayscaleController.text);
      // final shortBondColoredPrice = double.parse(_shortBondColoredController.text);
      // final shortBondGrayscalePrice = double.parse(_shortBondGrayscaleController.text);
      // Send this data to the backend or save locally

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pricing settings saved successfully')),
      );
    }
  }

  void _updateAdminEmail(String email) {
    // Your email update logic here
    print('Updating admin email: $email');
  }

  void _updateAdminUsername(String username) {
    // Your username update logic here
    print('Updating admin username: $username');
  }

  void _updateAdminPassword(String password) {
    // Your password update logic here
    print('Updating admin password: $password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2B2E4A),
      appBar: const CustomAppBar(
        titleText: 'BULSU HC VENDO PRINTING MACHINE',
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white38, // TabBar background color
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.account_balance_wallet),
                  text: 'Pricing Settings',
                ),
                Tab(
                  icon: Icon(Icons.settings_applications),
                  text: 'Change Information'
                ),
                Tab(
                  icon: Icon(Icons.assignment),
                  text: 'Daily Sales Report',
                )
              ],
              labelColor: Colors.white,
              indicatorColor: Colors.white,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPricingSettings(),
                _buildChangeInfoSettings(),
                _buildDailySalesReport()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 124.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            const Text(
              'Pricing Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildPricingColumn1()),
                  const SizedBox(width: 100),
                  Expanded(child: _buildPricingColumn2()),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePricing,
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Save Pricing Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingColumn1() {
    return ListView(
      children: <Widget>[
        _buildSectionTitle('Sizes'),
        _buildPricingRow('Long Bond Paper', _longBondPriceController),
        _buildPricingRow('Short Bond Paper', _shortBondPriceController),
        const SizedBox(height: 20),
        _buildSectionTitle('Color'),
        _buildPricingRow('Colored', _coloredPriceController),
        _buildPricingRow('Grayscale', _grayscalePriceController),
      ],
    );
  }

  Widget _buildPricingColumn2() {
    return ListView(
      children: <Widget>[
        _buildSectionTitle('Resolution'),
        _buildPricingRow('Low Resolution', _lowResolutionPriceController),
        _buildPricingRow('Medium Resolution', _mediumResolutionPriceController),
        _buildPricingRow('High Resolution', _highResolutionPriceController),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPricingRow(String label, TextEditingController controller) {
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
          SizedBox(
            width: 50,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              style: const TextStyle(
                fontSize: 16, // Set the desired font size here
              ),
              textAlign: TextAlign.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeInfoSettings() {
    final _emailController = TextEditingController();
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 124.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Info Settings',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Email section
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final email = _emailController.text;
                if (email.isNotEmpty) {
                  _updateAdminEmail(email);
                } else {
                  print('Email field is empty');
                }
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Save Email'),
            ),
            const SizedBox(height: 16),
            
            // Username section
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final username = _usernameController.text;
                if (username.isNotEmpty) {
                  _updateAdminUsername(username);
                } else {
                  print('Username field is empty');
                }
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Save Username'),
            ),
            const SizedBox(height: 16),
            
            // Password section
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final password = _passwordController.text;
                if (password.isNotEmpty) {
                  _updateAdminPassword(password);
                } else {
                  print('Password field is empty');
                }
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Save Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySalesReport() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 124.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 32.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Sales',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),
                      _buildStatusRow('Print', '0'),
                      _buildStatusRow('Scan', '0'),
                      _buildStatusRow('Copy', '0'),
                      _buildStatusRow('Total', '0'),
                      const SizedBox(height: 16),
                      _buildStatusRow('Date', DateFormat.yMMMMd().format(DateTime.now())),
                    ],
                  ),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Printer Status',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),
                      const Text('Remaining Papers:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8.0),
                      _buildStatusRow('Long', '0'),
                      _buildStatusRow('Short', '0'),
                      const SizedBox(height: 16.0),
                      const Text('Remaining Ink Levels:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8.0),
                      _buildStatusRow('Black', '0%'),
                      _buildStatusRow('Color', '0%'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(width: 8),
          Container(
            width: 150,
            height: 40,
            child: TextFormField(
              controller: TextEditingController(text: value),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }

}