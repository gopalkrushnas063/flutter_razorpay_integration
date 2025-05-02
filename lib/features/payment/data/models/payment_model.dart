import 'package:razorpay_flutter_integration/features/payment/domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required String id,
    required double amount,
    required String currency,
    required String status,
  }) : super(id: id, amount: amount, currency: currency, status: status);

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'amount': amount, 'currency': currency, 'status': status};
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      amount: amount,
      currency: currency,
      status: status,
    );
  }
}
