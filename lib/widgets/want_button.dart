import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:minsk8/import.dart';

class WantButton extends StatelessWidget {
  WantButton(this.item);

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Want',
      child: Material(
        color: item.isClosed ? null : Colors.red,
        // borderRadius: BorderRadius.all(kImageBorderRadius),
        child: InkWell(
          splashColor: Colors.white,
          // borderRadius: BorderRadius.all(kImageBorderRadius),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              item.isBlocked ?? false
                  ? 'ЗАБЛОКИРОВАНО'
                  : item.win != null
                      ? 'УЖЕ ЗАБРАЛИ'
                      : item.isExpired ? 'ЗАВЕРШЕНО' : 'ХОЧУ ЗАБРАТЬ',
              style: TextStyle(
                fontSize: 18,
                color: item.isClosed
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
                if (item.isBlocked ?? false) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.ban,
                    title: 'Лот заблокирован\nза нарушение правил',
                    description:
                        'Когда всё хорошо начиналось,\nно потом что-то пошло не так',
                  );
                } else if (item.win != null) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.trophy,
                    title: 'Лот получил(а) — ${item.win.member.nickname}. УРА!',
                    description:
                        'Следите за новыми лотами —\nзаберите тоже что-то крутое\n\nИли что-нибудь отдайте!',
                  );
                } else if (item.isExpired) {
                  return InfoDialog(
                    icon: FontAwesomeIcons.frog,
                    title: 'Аукцион по лоту завершён',
                    description:
                        'Дождитесь объявления победителя,\nвозможно именно Вам повезёт!',
                  );
                }
                return BidDialog(item);
              },
            );
          },
        ),
      ),
    );
  }
}
