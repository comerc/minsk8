import 'package:minsk8/import.dart';

class AccountModel implements EnumModel {
  AccountModel(this.value, this.name);

  final AccountValue value;
  final String name;

  @override
  AccountValue get enumValue => value;
  @override
  String get enumName => name;
}

enum AccountValue { start, invite, unfreeze, freeze, limit, profit }

// final accounts = [
//   AccountModel(AccountValue.start, ''),
//   AccountModel(AccountValue.invite, ''),
//   AccountModel(AccountValue.unfreeze, ''),
//   AccountModel(AccountValue.freeze, ''),
//   AccountModel(AccountValue.limit, ''),
//   AccountModel(AccountValue.profit, ''),
// ];
