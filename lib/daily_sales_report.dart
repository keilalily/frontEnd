import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DailySalesReport extends StatefulWidget {
  const DailySalesReport({super.key});

  @override
  DailySalesReportState createState() => DailySalesReportState();
}

class DailySalesReportState extends State<DailySalesReport> {
  String _printSales = '0';
  String _scanSales = '0';
  String _copySales = '0';
  String _totalSales = '0';
  String _remainingPapersLong = '0';
  String _remainingPapersShort = '0';
  String _remainingInkBlack = '0%';
  String _remainingInkColor = '0%';
  final String _date = DateFormat.yMMMMd().format(DateTime.now());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _longBondStockController = TextEditingController();
  final TextEditingController _shortBondStockController = TextEditingController();
  final TextEditingController _inkBlackStockController = TextEditingController();
  final TextEditingController _inkColorStockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    updateSalesData();
  }

  // Method to simulate data update (replace with actual data update logic)
  void updateSalesData() {
    setState(() {
      _printSales = '100'; // Example value, replace with actual data
      _scanSales = '50';   // Example value, replace with actual data
      _copySales = '20';   // Example value, replace with actual data
      _totalSales = '170'; // Example value, replace with actual data
    });
  }

  void updateInventoryData() {
    setState(() {
      _remainingPapersLong = _longBondStockController.text;
      _remainingPapersShort = _shortBondStockController.text;
      _remainingInkBlack = _inkBlackStockController.text;
      _remainingInkColor = _inkColorStockController.text;
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pricing settings saved successfully')),
    );
  }

  @override
  void dispose() {
    _longBondStockController.dispose();
    _shortBondStockController.dispose();
    _inkBlackStockController.dispose();
    _inkColorStockController.dispose();
    super.dispose();
  }

  void _showEditDialog() {
    // Initialize controllers with current values
    _longBondStockController.text = _remainingPapersLong;
    _shortBondStockController.text = _remainingPapersShort;
    _inkBlackStockController.text = _remainingInkBlack;
    _inkColorStockController.text = _remainingInkColor;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Edit Inventory'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildInventoryRow('Long Bond Paper', _longBondStockController),
                  _buildInventoryRow('Short Bond Paper', _shortBondStockController),
                  _buildInventoryRow('Black Ink', _inkBlackStockController),
                  _buildInventoryRow('Colored Ink', _inkColorStockController)
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: updateInventoryData,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF8D6E63),
              ),
              child: const Text('Save'),
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
                      _buildStatusRow('Print', _printSales),
                      _buildStatusRow('Scan', _scanSales),
                      _buildStatusRow('Copy', _copySales),
                      _buildStatusRow('Total', _totalSales),
                      const SizedBox(height: 16),
                      _buildStatusRow('Date', _date),
                    ],
                  ),
                ),
                const SizedBox(width: 100),
                Expanded(
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Printer Status',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20.0),
                      const Text('Remaining Papers:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8.0),
                      _buildStatusRow('Long', _remainingPapersLong),
                      _buildStatusRow('Short', _remainingPapersShort),
                      const SizedBox(height: 16.0),
                      const Text('Remaining Ink Levels:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8.0),
                      _buildStatusRow('Black', _remainingInkBlack),
                      _buildStatusRow('Color', _remainingInkColor),
                      const SizedBox(height: 8.0),
                      ElevatedButton(
                        onPressed: () {
                            _showEditDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF8D6E63),
                        ),
                        child: const Text('Edit Inventory'),
                      ),
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
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 150,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryRow(String label, TextEditingController controller) {
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
            width: 100,
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
                fontSize: 16,
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
}
