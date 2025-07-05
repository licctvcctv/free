
import 'package:freego_flutter/model/user.dart';

class NotificationModel with UserMixin{
  int id;
  int? fromUserId;
  int? toUserId;
  int? targetId;
  int? type;
  int? subType;
  DateTime? createTime;
  String? title;
  String? content;

  NotificationModel(this.id);
  NotificationModel.fromJson(dynamic json): id = json['id']{
    fromUserId = json['fromUserId'];
    toUserId = json['toUserId'];
    targetId = json['targetId'];
    type = json['type'];
    subType = json['subType'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    title = json['title'];
    content = json['content'];

    userName = json['userName'];
    userHead = json['userHead'];
  }

  static const NOTIFICATION_TYPE_SYSTEM = 0;
  static const NOTIFICATION_TYPE_INTERACT = 1;
  static const NOTIFICATION_TYPE_ORDER = 2;
}

enum NotificationType{
  system,
  interact,
  order
}

extension NotificationTypeExt on NotificationType{
  int getNum(){
    switch(this){
      case NotificationType.system:
        return NotificationModel.NOTIFICATION_TYPE_SYSTEM;
      case NotificationType.interact:
        return NotificationModel.NOTIFICATION_TYPE_INTERACT;
      case NotificationType.order:
        return NotificationModel.NOTIFICATION_TYPE_ORDER;
    }
  }
  static NotificationType? getType(int num){
    for(NotificationType type in NotificationType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
