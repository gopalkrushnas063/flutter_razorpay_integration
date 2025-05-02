import 'package:dartz/dartz.dart';
import 'package:razorpay_flutter_integration/core/error/exceptions.dart';
import 'package:razorpay_flutter_integration/core/error/failures.dart';
import 'package:razorpay_flutter_integration/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/entities/payment_entity.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaymentEntity>> createOrder({
    required double amount,
    required String currency,
  }) async {
    try {
      final order = await remoteDataSource.createOrder(
        amount: amount,
        currency: currency,
      );
      return Right(order.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> verifyPayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final payment = await remoteDataSource.verifyPayment(
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );
      return Right(payment.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
