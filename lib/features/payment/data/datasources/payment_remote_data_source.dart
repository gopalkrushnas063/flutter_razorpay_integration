import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter_integration/core/config/razorpay_config.dart';
import 'package:razorpay_flutter_integration/core/error/exceptions.dart';
import 'package:razorpay_flutter_integration/features/payment/data/models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentModel> createOrder({
    required double amount,
    required String currency,
  });

  Future<PaymentModel> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final http.Client client;

  PaymentRemoteDataSourceImpl({required this.client});

  String _getBasicAuth() {
    final auth = '${RazorpayConfig.keyId}:${RazorpayConfig.keySecret}';
    final bytes = utf8.encode(auth);
    return base64Encode(bytes);
  }

  @override
  Future<PaymentModel> createOrder({
    required double amount,
    required String currency,
  }) async {
    try {
      final amountInPaise = (amount * 100).toInt();
      debugPrint('Creating order with amount: $amountInPaise paise');

      final response = await client.post(
        Uri.parse('${RazorpayConfig.baseUrl}/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${_getBasicAuth()}',
        },
        body: jsonEncode({
          'amount': amountInPaise,
          'currency': currency,
          'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
          'notes': {'description': 'Payment for services'},
        }),
      );

      debugPrint('Order creation response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentModel(
          id: data['id'],
          amount: amount,
          currency: currency,
          status: 'created',
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error']?['description'] ?? 'Failed to create order';
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Error creating order: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Error creating order: $e');
    }
  }

  @override
  Future<PaymentModel> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final response = await client.get(
        Uri.parse('${RazorpayConfig.baseUrl}/payments/$paymentId'),
        headers: {'Authorization': 'Basic ${_getBasicAuth()}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PaymentModel(
          id: paymentId,
          amount: data['amount'] / 100, // Convert from paise to rupees
          currency: data['currency'],
          status: data['status'],
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['error']?['description'] ?? 'Failed to verify payment';
        throw ServerException(errorMessage);
      }
    } catch (e) {
      debugPrint('Error verifying payment: $e');
      if (e is ServerException) rethrow;
      throw ServerException('Error verifying payment: $e');
    }
  }
}
