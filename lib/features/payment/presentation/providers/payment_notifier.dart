import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_flutter_integration/core/config/razorpay_config.dart';
import 'package:razorpay_flutter_integration/core/error/failures.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/entities/payment_entity.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/usecases/create_order.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/usecases/verify_payment.dart';

class PaymentState {
  final bool isLoading;
  final Option<Either<Failure, PaymentEntity>> orderCreationResult;
  final Option<Either<Failure, PaymentEntity>> paymentVerificationResult;
  final String? errorMessage;

  const PaymentState({
    required this.isLoading,
    required this.orderCreationResult,
    required this.paymentVerificationResult,
    this.errorMessage,
  });

  factory PaymentState.initial() {
    return PaymentState(
      isLoading: false,
      orderCreationResult: none(),
      paymentVerificationResult: none(),
      errorMessage: null,
    );
  }

  PaymentState copyWith({
    bool? isLoading,
    Option<Either<Failure, PaymentEntity>>? orderCreationResult,
    Option<Either<Failure, PaymentEntity>>? paymentVerificationResult,
    String? errorMessage,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      orderCreationResult: orderCreationResult ?? this.orderCreationResult,
      paymentVerificationResult:
          paymentVerificationResult ?? this.paymentVerificationResult,
      errorMessage: errorMessage,
    );
  }
}

class PaymentNotifier extends StateNotifier<PaymentState> {
  final CreateOrder createOrder;
  final VerifyPayment verifyPayment;
  final Razorpay razorpay;

  PaymentNotifier({
    required this.createOrder,
    required this.verifyPayment,
    required this.razorpay,
  }) : super(PaymentState.initial()) {
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> initiatePayment({
    required double amount,
    required String currency,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      debugPrint('Creating order for amount: $amount $currency');
      final orderResult = await createOrder(amount: amount, currency: currency);

      orderResult.fold(
        (failure) {
          debugPrint('Order creation failed: ${failure.toString()}');
          state = state.copyWith(
            isLoading: false,
            orderCreationResult: some(left(failure)),
            errorMessage: 'Failed to create order: ${failure.toString()}',
          );
        },
        (order) {
          debugPrint('Order created successfully: ${order.id}');
          state = state.copyWith(
            isLoading: false,
            orderCreationResult: some(right(order)),
          );
          _openRazorpay(order);
        },
      );
    } catch (e) {
      debugPrint('Unexpected error during order creation: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unexpected error during order creation: $e',
      );
    }
  }

  void _openRazorpay(PaymentEntity order) {
    try {
      final amountInPaise = (order.amount * 100).toInt();
      debugPrint(
        'Opening Razorpay with order ID: ${order.id}, amount: $amountInPaise paise',
      );

      final options = {
        'key': RazorpayConfig.keyId,
        'amount': amountInPaise.toString(),
        'name': 'Razorpay Integration',
        'order_id': order.id,
        'description': 'Payment for services',
        'prefill': {
          'name': 'John Doe',
          'contact': '9876543210',
          'email': 'user@example.com',
        },
        'theme': {'color': '#3399cc'},
        'notes': {'order_id': order.id},
      };

      debugPrint('Razorpay options: $options');
      razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to open payment sheet: $e',
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment success response: ${response.toString()}');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final verificationResult = await verifyPayment(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      );

      state = state.copyWith(
        isLoading: false,
        paymentVerificationResult: some(verificationResult),
      );
    } catch (e) {
      debugPrint('Payment verification error: $e');
      state = state.copyWith(
        isLoading: false,
        paymentVerificationResult: some(left(PaymentFailure())),
        errorMessage: 'Payment verification failed: $e',
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment error response: ${response.toString()}');
    String errorMessage = 'Payment failed';

    if (response.code != null) {
      errorMessage += ' (Code: ${response.code})';
    }
    if (response.message != null) {
      errorMessage += ': ${response.message}';
    }
    if (response.error != null) {
      errorMessage += ' - ${response.error.toString()}';
    }

    state = state.copyWith(
      isLoading: false,
      paymentVerificationResult: some(left(PaymentFailure())),
      errorMessage: errorMessage,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet selected: ${response.walletName}');
    state = state.copyWith(
      isLoading: false,
      errorMessage: 'External wallet selected: ${response.walletName}',
    );
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }
}
