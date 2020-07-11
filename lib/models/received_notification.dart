import 'package:flutter/material.dart';

class ReceivedNotificationModel {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotificationModel({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}
