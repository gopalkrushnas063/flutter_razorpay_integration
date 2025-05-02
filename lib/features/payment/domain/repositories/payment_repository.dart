import 'package:dartz/dartz.dart';
import 'package:razorpay_flutter_integration/core/error/failures.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/entities/payment_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentEntity>> createOrder({
    required double amount,
    required String currency,
  });

  Future<Either<Failure, PaymentEntity>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  });
}
