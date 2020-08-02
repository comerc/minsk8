// это не EnumModel в бд, т.к. paymentValue может менять значение в будущем
class PaymentStepModel {
  PaymentStepModel(
    this.value,
    this.amount,
    this.price,
  );

  final PaymentStepValue value;
  final int amount;
  final double price;
}

enum PaymentStepValue { pilot, start, optimum, ultimate }

final kPaymentSteps = <PaymentStepModel>[
  PaymentStepModel(PaymentStepValue.pilot, 5, 2.95),
  PaymentStepModel(PaymentStepValue.start, 25, 9.95),
  PaymentStepModel(PaymentStepValue.optimum, 50, 14.95),
  PaymentStepModel(PaymentStepValue.ultimate, 100, 19.95),
];
