import 'package:flutter/material.dart';
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
          SizedBox(
            width: 150,
            height: 40,
            child: TextFormField(
              controller: TextEditingController(text: value),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}
