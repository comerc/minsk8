import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class WantButton extends StatelessWidget {
  WantButton(this.unit);

  final UnitModel unit;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Want',
      child: Material(
        color: unit.isClosed ? null : Colors.red,
        // borderRadius: BorderRadius.all(kImageBorderRadius),
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.4),
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              _getText(),
              style: TextStyle(
                fontSize: 18,
                color: unit.isClosed
                    ? Colors.black.withOpacity(0.8)
                    : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // сначала isLocalDeleted, потом isBlocked
                if (unit.isLocalDeleted) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.ban,
                    title: 'Лот удалён',
                    description: 'Вы удалили этот лот',
                  );
                }
                if (unit.isBlocked ?? false) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.ban,
                    title: 'Лот заблокирован',
                    description:
                        'Когда всё хорошо начиналось,\nно потом что-то пошло не так',
                  );
                }
                if (unit.win != null) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.trophy,
                    title: 'Лот получил(а) — ${unit.win.member.nickname}. УРА!',
                    description:
                        'Следите за новыми лотами —\nзаберите тоже что-то крутое\n\nИли что-нибудь отдайте!',
                  );
                }
                if (unit.isExpired) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.frog,
                    title: 'Аукцион по лоту завершён',
                    description:
                        'Дождитесь объявления победителя,\nвозможно именно Вам повезёт!',
                  );
                }
                return WantDialog(unit);
              },
            );
          },
        ),
      ),
    );
  }

  String _getText() {
    if ((unit.isBlocked ?? false) || unit.isLocalDeleted) {
      return 'ЗАБЛОКИРОВАНО';
    }
    if (unit.win != null) {
      return 'УЖЕ ЗАБРАЛИ';
    }
    return unit.isExpired ? 'ЗАВЕРШЕНО' : 'ХОЧУ ЗАБРАТЬ';
  }
}
