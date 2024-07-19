import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class PaymentService {
  final WebSocketChannel channel;
  double paymentInserted = 0.0;

  PaymentService(String ipAddress)
      : channel = WebSocketChannel.connect(Uri.parse('ws://$ipAddress:3000'));

  void listenToPaymentUpdates(void Function(double) onPaymentInserted) {
    channel.stream.listen((message) {
      final data = jsonDecode(message);
      paymentInserted = data['amountInserted'].toDouble();
      onPaymentInserted(paymentInserted);
    });
  }

  void close() {
    channel.sink.close();
  }
}
