import 'package:json_annotation/json_annotation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:minsk8/import.dart';

part 'payment.g.dart';

@JsonSerializable()
class PaymentModel {
  PaymentModel({
    this.id,
    this.account,
    this.textVariant,
    this.value,
    this.balance,
    this.createdAt,
    this.unit,
    this.invitedMember,
  });

  final String id;
  final AccountValue account;
  @JsonKey(nullable: true)
  final int textVariant;
  final int value;
  final int balance;
  final DateTime createdAt;
  @JsonKey(nullable: true)
  final UnitModel unit;
  @JsonKey(nullable: true)
  final MemberModel invitedMember;

  static AccountValue _accountFromString(String value) =>
      EnumToString.fromString(AccountValue.values, value);

  static String _accountToString(AccountValue account) =>
      EnumToString.parse(account);

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}
