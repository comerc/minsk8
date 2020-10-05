import 'package:flutter/material.dart';
// import 'package:minsk8/import.dart';

class DeliveryLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <InlineSpan>[
          TextSpan(
            text: 'Самовывоз',
            style: DefaultTextStyle.of(context).style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.8),
                ),
          ),
          TextSpan(text: ' — в течении трёх дней'),
        ],
      ),
    );
  }
}
