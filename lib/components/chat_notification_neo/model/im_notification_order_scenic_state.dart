
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';

class ImNotificationOrderScenicState extends ImNotification{

  int? orderId;
  String? orderSerial;
  int? scenicId;
  String? scenicName;
  String? ticketName;
  String? outerScenicId;
  String? outerTicketId;
  String? source;
  int? payStatus;
  int? orderStatus;
  DateTime? travelDate;
  int? quantity;
  String? unFinishReason;

  ImNotificationOrderScenicState();
  ImNotificationOrderScenicState.fromOriginal(ImNotification notification){
    id = notification.id;
    roomId = notification.roomId;
    innerContent = notification.innerContent;
    createTime = notification.createTime;
  }

  @override
  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visitScenicOrderState(this);
  }
}
