// это не EnumModel в бд, т.к. paymentValue может менять значение в будущем
// TODO: или это справочник, как другие enum-значения?
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
  PaymentStepModel(PaymentStepValue.pilot, 5, 5),
  PaymentStepModel(PaymentStepValue.start, 25, 10),
  PaymentStepModel(PaymentStepValue.optimum, 50, 15),
  PaymentStepModel(PaymentStepValue.ultimate, 100, 20),
];
