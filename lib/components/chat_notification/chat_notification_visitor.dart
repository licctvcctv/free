
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_get_gift.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_hotel_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_hotel_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_restaurant_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_restaurant_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_scenic_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_scenic_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_travel_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_travel_state_for_merchant.dart';

class ChatNotificationVisitor<T>{

  T? visit(ImNotification notification){
    return null;
  }

  T? visitGetGift(ImNotificationGetGift notification){
    return null;
  }

  T? visitScenicOrderState(ImNotificationOrderScenicState notification){
    return null;
  }

  T? visitHotelOrderState(ImNotificationOrderHotelState notification){
    return null;
  }  

  T? visitScenicOrderStateForMerchant(ImNotificationOrderScenicStateForMerchant notification){
    return null;
  }

  T? visitHotelOrderStateForMerchant(ImNotificationOrderHotelStateForMerchant notification){
    return null;
  }

  T? visitRestaurantOrderState(ImNotificationOrderRestaurantState notification){
    return null;
  }

  T? visitRestaurantOrderStateForMerchant(ImNotificationOrderRestaurantStateForMerchant notification){
    return null;
  }

  T? visitTravelOrderState(ImNotificationOrderTravelState notification){
    return null;
  }

  T? visitTravelOrderStateForMerchant(ImNotificationOrderTravelStateForMerchant notification){
    return null;
  }
}
