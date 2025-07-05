

import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';

abstract class ImNotificationContentParser {

  final String name;
  ImNotificationContentParser(this.name);

  ImNotification? parse(ImNotification original);
}
