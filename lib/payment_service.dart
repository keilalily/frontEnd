// import 'dart:convert';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class PaymentService {
//   final WebSocketChannel channel;
//   double paymentInserted = 0.0;

//   PaymentService(String ipAddress)
//       : channel = WebSocketChannel.connect(Uri.parse('ws://$ipAddress:3000'));

//   void listenToPaymentUpdates(void Function(double) onPaymentInserted) {
//     channel.stream.listen((message) {
//       final data = jsonDecode(message);
//       paymentInserted = data['amountInserted'].toDouble();
//       onPaymentInserted(paymentInserted);
//     });
//   }

//   void close() {
//     channel.sink.close();
//   }
// }

// payment_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  final String ipAddress;
  final StreamController<double> _paymentController = StreamController<double>.broadcast();
  Timer? _statusTimer; // Nullable Timer

  PaymentService(this.ipAddress);

  Stream<double> get paymentStream => _paymentController.stream;

  void listenToPaymentUpdates(Function(double) onUpdate) {
    paymentStream.listen(onUpdate);
  }

  Future<void> triggerCoinCounting() async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:3000/api/count'),
      );

      if (response.statusCode == 200) {
        print('Coin counting triggered successfully');
      } else {
        print('Failed to trigger coin counting');
      }
    } catch (e) {
      print('Error triggering coin counting: $e');
    }
  }

  Future<void> fetchStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://$ipAddress:3000/api/status'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final double amountInserted = data['amountInserted']?.toDouble() ?? 0.0;
        _paymentController.add(amountInserted);
      } else {
        print('Failed to fetch payment status');
      }
    } catch (e) {
      print('Error fetching status: $e');
    }
  }

  Future<void> resetCounts() async {
    try {
      final response = await http.post(
        Uri.parse('http://$ipAddress:3000/api/reset'),
      );

      if (response.statusCode == 200) {
        print('Counts reset successfully');
        _paymentController.add(0.0); // Reset the payment stream
      } else {
        print('Failed to reset counts');
      }
    } catch (e) {
      print('Error resetting counts: $e');
    }
  }

  void startFetchingStatus() {
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      fetchStatus();
    });
  }

  void stopFetchingStatus() {
    _statusTimer?.cancel();
    _statusTimer = null;
  }

  void dispose() {
    _paymentController.close();
    stopFetchingStatus();
  }
}
