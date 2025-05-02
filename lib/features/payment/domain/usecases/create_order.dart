import 'package:dartz/dartz.dart' show Either;
import 'package:razorpay_flutter_integration/core/error/failures.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/entities/payment_entity.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/repositories/payment_repository.dart';

class CreateOrder {
  final PaymentRepository repository;

  CreateOrder(this.repository);

  Future<Either<Failure, PaymentEntity>> call({
    required double amount,
    required String currency,
  }) async {
    return await repository.createOrder(amount: amount, currency: currency);
  }
}
