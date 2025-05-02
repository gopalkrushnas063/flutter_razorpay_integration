import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final double amount;
  final String currency;
  final String status;

  const PaymentEntity({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
  });

  @override
  List<Object?> get props => [id, amount, currency, status];
}