import 'package:dartz/dartz.dart';
import 'package:razorpay_flutter_integration/core/error/failures.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/entities/payment_entity.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/repositories/payment_repository.dart';

class VerifyPayment {
  final PaymentRepository repository;

  VerifyPayment(this.repository);

  Future<Either<Failure, PaymentEntity>> call({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    return await repository.verifyPayment(
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
    );
  }
}
