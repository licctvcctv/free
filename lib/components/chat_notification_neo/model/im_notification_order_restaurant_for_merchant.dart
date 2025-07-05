
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_visitor.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';

class ImNotificationOrderRestaurantStateForMerchant extends ImNotification{

  int? orderId;
  String? orderSerial;
  String? source;
  int? amount;
  int? restaurantId;
  String? restaurantName;
  String? restaurantAddress;
  int? payStatus;
  int? orderStatus;
  int? numberOfPeople;
  DateTime? diningTime;
  int? diningType;
  String? remark;
  String? unfinishedReason;
  List<OrderRestaurantDish>? dishList;

  String? contactName;
  String? contactPhone;
  
  @override
  T? visitBy<T>(ChatNotificationVisitor<T> visitor){
    return visitor.visitRestaurantOrderStateForMerchant(this);
  }
}
