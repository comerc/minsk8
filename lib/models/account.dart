import 'package:minsk8/import.dart';

class AccountModel implements EnumModel {
  AccountModel(value, name)
      : _value = value,
        _name = name;

  final AccountValue _value;
  final String _name;

  @override
  AccountValue get value => _value;
  @override
  String get name => _name;
}

// TODO: share link?
enum AccountValue { start, invite, unfreeze, freeze, limit, profit }

// final kAccounts = <AccountModel>[
//   AccountModel(AccountValue.start, ''),
//   AccountModel(AccountValue.invite, ''),
//   AccountModel(AccountValue.unfreeze, ''),
//   AccountModel(AccountValue.freeze, ''),
//   AccountModel(AccountValue.limit, ''),
//   AccountModel(AccountValue.profit, ''),
// ];
