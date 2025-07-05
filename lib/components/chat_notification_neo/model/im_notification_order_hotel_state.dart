
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';

class ImNotificationOrderHotelState extends ImNotification{

  int? orderId;
  String? orderSerial;
  int? hotelId;
  String? hotelName;
  String? ratePlanName;
  String? outerHotelId;
  String? outerPlanId;
  String? source;
  int? payStatus;
  int? orderStatus;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int? numberOfRooms;
  String? unfinishedReason;

  ImNotificationOrderHotelState();
  ImNotificationOrderHotelState.fromOriginal(ImNotification notification){
    id = notification.id;
    roomId = notification.roomId;
    innerContent = notification.innerContent;
    createTime = notification.createTime;
  }

  @override
  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visitHotelOrderState(this);
  }
}
