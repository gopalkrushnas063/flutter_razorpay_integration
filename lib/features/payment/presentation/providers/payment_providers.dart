import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_flutter_integration/core/network/http_client.dart';
import 'package:razorpay_flutter_integration/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:razorpay_flutter_integration/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/repositories/payment_repository.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/usecases/create_order.dart';
import 'package:razorpay_flutter_integration/features/payment/domain/usecases/verify_payment.dart';
import 'package:razorpay_flutter_integration/features/payment/presentation/providers/payment_notifier.dart';

final razorpayProvider = Provider<Razorpay>((ref) => Razorpay());

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>(
  (ref) => PaymentRemoteDataSourceImpl(client: ref.read(httpClientProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepositoryImpl(
    remoteDataSource: ref.read(paymentRemoteDataSourceProvider),
  ),
);

final createOrderProvider = Provider<CreateOrder>(
  (ref) => CreateOrder(ref.read(paymentRepositoryProvider)),
);

final verifyPaymentProvider = Provider<VerifyPayment>(
  (ref) => VerifyPayment(ref.read(paymentRepositoryProvider)),
);

final paymentNotifierProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>(
      (ref) => PaymentNotifier(
        createOrder: ref.read(createOrderProvider),
        verifyPayment: ref.read(verifyPaymentProvider),
        razorpay: ref.read(razorpayProvider),
      ),
    );
