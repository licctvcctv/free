
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';

class ImNotificationOrderHotelStateForMerchant extends ImNotification{

  int? orderId;
  String? orderSerial;
  int? customerId;
  int? amount;
  int? hotelId;
  int? chamberId;
  int? ratePlanId;
  String? hotelName;
  String? chamberName;
  String? ratePlanName;
  String? source;
  int? payStatus;
  int? orderStatus;
  DateTime? checkInDate;
  DateTime? checkOutDate;
  int? numberOfRooms;
  String? unfinishedReason;
  String? contactName;
  String? contactPhone;
  String? contactEmail;
  String? remark;
  List<OrderGuest>? guestList;

  ImNotificationOrderHotelStateForMerchant();
  
  @override
  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visitHotelOrderStateForMerchant(this);
  }
}
