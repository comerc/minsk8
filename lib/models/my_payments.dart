import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:minsk8/import.dart';

part 'my_payments.g.dart';

@JsonSerializable()
class MyPaymentsModel extends ChangeNotifier {
  MyPaymentsModel({
    this.payments,
  });

  final List<PaymentModel> payments;

  int get balance =>
      payments.fold<int>(0, (value, element) => value + element.value);

  Future<void> update(List<PaymentModel> items) async {
    payments.clear();
    notifyListeners();
    // to show loading more clearly, in your app,remove this
    await Future.delayed(Duration(milliseconds: 400));
    payments.addAll(items);
    notifyListeners();
  }

  factory MyPaymentsModel.fromJson(Map<String, dynamic> json) =>
      _$MyPaymentsModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyPaymentsModelToJson(this);
}
