
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';

class ImNotificationOrderTravelStateForMerchant extends ImNotification{
  
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
  String? contactName;
  String? contactPhone;
  String? contactEmail;
  String? emergencyName;
  String? emergencyPhone;

  List<OrderGuest>? guestList;

  ImNotificationOrderTravelStateForMerchant();

  @override
  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visitTravelOrderStateForMerchant(this);
  }
}
