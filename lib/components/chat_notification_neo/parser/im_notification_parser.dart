
import 'dart:convert';

import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification_neo/parser/im_notification_content_parser.dart';
import 'package:freego_flutter/components/chat_notification_neo/parser/impl/im_notification_content_parser_v1.dart';

class ImNotificationParser{

  static const String VERSION = 'version';

  Map<String, ImNotificationContentParser> contentParserMap = {};

  ImNotificationParser._intenal(){
    ImNotificationContentParser parserV1 = ImNotificationContentParserV1();
    contentParserMap.putIfAbsent(parserV1.name, () => parserV1);
  }
  static final ImNotificationParser _instance = ImNotificationParser._intenal();
  factory ImNotificationParser(){
    return _instance;
  }

  ImNotification? parse(ImNotification original){
    String? content = original.innerContent;
    if(content == null){
      return null;
    }
    dynamic node = json.decoder.convert(content);
    dynamic version = node[VERSION];
    ImNotificationContentParser? parser = contentParserMap[version];
    if(parser == null){
      return null;
    }
    return parser.parse(original);
  }
}
