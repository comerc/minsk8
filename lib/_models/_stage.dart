// import 'package:minsk8/import.dart';

// class StageModel implements EnumModel {
//   StageModel(StageValue value, String name, this.text)
//       : _value = value,
//         _name = name;

//   final StageValue _value;
//   final String _name;
//   final String text;

//   @override
//   StageValue get value => _value;
//   @override
//   String get name => _name;
// }

// enum StageValue { ready, cancel, success }

// // TODO: [MVP] почему значение в messageText для .ready синим цветом - это ссылка?
// // TODO: [MVP] какое значение в messageText для .success

// final kStages = <StageModel>[
//   StageModel(
//     StageValue.ready,
//     'Договоритесь о встрече',
//     'Договоритесь о встрече',
//   ),
//   StageModel(
//     StageValue.cancel,
//     'Отменённые',
//     'Лот отдан другому',
//   ),
//   StageModel(
//     StageValue.success,
//     'Завершённые',
//     'Лот завершён',
//   ),
// ];
