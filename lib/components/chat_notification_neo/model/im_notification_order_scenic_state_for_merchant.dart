
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';

class ImNotificationOrderScenicStateForMerchant extends ImNotification{
  
  int? orderId;
  String? orderSerial;
  int? customerId;
  int? scenicId;
  int? ticketId;
  String? scenicName;
  String? ticketName;
  String? source;
  int? payStatus;
  int? orderStatus;
  DateTime? travelDate;
  int? amount;
  int? quantity;
  String? unfinishedReason;
  String? contactName;
  String? contactPhone;
  int? contactCardType;
  String? contactCardNo;
  String? confirmOrderId;
  String? voucherCode;
  String? voucherUrl;
  List<OrderGuest>? guestList;

  ImNotificationOrderScenicStateForMerchant();

  @override
  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visitScenicOrderStateForMerchant(this);
  }
}
