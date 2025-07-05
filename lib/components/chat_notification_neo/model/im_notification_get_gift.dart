
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';

class ImNotificationGetGift extends ImNotification{
  
  int? giver;
  int? itemId;
  int? count;
  int? giftNum;
  ProductType? productType;
  int? productId;

  ImNotificationGetGift();
  ImNotificationGetGift.fromOriginal(ImNotification notification){
    id = notification.id;
    roomId = notification.roomId;
    innerContent = notification.innerContent;
    createTime = notification.createTime;
  }

  @override
  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visitGetGift(this);
  }
}
