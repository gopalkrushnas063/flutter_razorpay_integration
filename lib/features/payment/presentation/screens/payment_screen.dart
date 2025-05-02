import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter_integration/features/payment/presentation/providers/payment_providers.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Make Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isLoading ? Colors.grey : Colors.blue,
              ),
              onPressed:
                  state.isLoading
                      ? null
                      : () => ref
                          .read(paymentNotifierProvider.notifier)
                          .initiatePayment(amount: 100, currency: 'INR'),
              child: const Text(
                'Pay ₹100',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            if (state.isLoading) const CircularProgressIndicator(),
            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                  textAlign: TextAlign.center,
                ),
              ),
            state.orderCreationResult.fold(
              () => const SizedBox(),
              (result) => result.fold(
                (failure) => Text(
                  'Error: ${failure.toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
                (order) => Text(
                  'Order created: ${order.id}',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ),
            state.paymentVerificationResult.fold(
              () => const SizedBox(),
              (result) => result.fold(
                (failure) => Text(
                  'Payment failed: ${failure.toString()}',
                  style: const TextStyle(color: Colors.red),
                ),
                (payment) => Text(
                  'Payment successful: ${payment.id}',
                  style: const TextStyle(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
