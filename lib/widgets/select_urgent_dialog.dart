import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:minsk8/import.dart';

// TODO: CheckboxListTile

Future<UrgentStatus> selectUrgentDialog(
    BuildContext context, UrgentStatus selected) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16, top: 32),
              child: Text(
                'Как срочно надо отдать?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
            GlowNotificationWidget(
              ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: urgents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Material(
                    color: selected == urgents[index].value
                        ? Colors.grey.withOpacity(0.2)
                        : Colors.white,
                    child: InkWell(
                      child: ListTile(
                        title: Text(urgents[index].name),
                        subtitle: Text(urgents[index].text),
                        // selected: selected == urgents[index].value,
                        trailing: selected == urgents[index].value
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.red,
                                  size: kButtonIconSize,
                                ),
                              )
                            : null,
                        dense: true,
                      ),
                      onLongPress:
                          () {}, // чтобы сократить время для splashColor
                      onTap: () {
                        Navigator.of(context).pop(urgents[index].value);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 8);
                },
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      );
    },
  );
}
