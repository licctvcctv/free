
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';

class ImNotificationOrderTravelState extends ImNotification{

  int? orderId;
  String? orderSerial;
  String? source;
  int? amount;
  int? travelId;
  int? travelSuitId;
  String? travelName;
  String? travelSuitName;
  int? payStatus;
  int? orderStatus;
  int? numberOfAdult;
  int? numberOfOld;
  int? numberOfChild;
  DateTime? startDate;
  DateTime? endDate;
  int? dayNum;
  int? nightNum;
  String? province;
  String? city;
  DateTime? rendezvousTime;
  String? rendezvousLocation;
  String? destProvince;
  String? destCity;
  String? destAddress;
  String? remark;
  String? unfinishedReason;

  ImNotificationOrderTravelState();

  @override
  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visitTravelOrderState(this);
  }
}
