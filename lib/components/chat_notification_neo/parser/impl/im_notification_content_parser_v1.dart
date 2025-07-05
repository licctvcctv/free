
import 'dart:convert';

import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification_neo/enums/notification_type.dart' as v2;
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_get_gift.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_hotel_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_hotel_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_restaurant_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_restaurant_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_scenic_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_scenic_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_travel_state.dart';
import 'package:freego_flutter/components/chat_notification_neo/model/im_notification_order_travel_state_for_merchant.dart';
import 'package:freego_flutter/components/chat_notification_neo/parser/im_notification_content_parser.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';

class ImNotificationContentParserV1 extends ImNotificationContentParser{

  static const String _name = 'v1';

  static const String VERSION = 'version';
  static const String TYPE = 'type';
  static const String CONTENT = 'content';

  static const String GIVER = 'giver';
  static const String ITEM_ID = 'item_id';
  static const String COUNT = 'count';
  static const String GIFT_NUM = 'gift_num';
  static const String PRODUCT_TYPE = 'product_type';
  static const String PRODUCT_ID = 'product_id';

  static const String ORDER_ID = 'order_id';
  static const String ORDER_SERIAL = 'order_serial';
  static const String HOTEL_ID = 'hotel_id';
  static const String HOTEL_NAME = 'hotel_name';
  static const String RATE_PLAN_NAME = 'rate_plan_name';
  static const String OUTER_HOTEL_ID = 'outer_hotel_id';
  static const String OUTER_PLAN_ID = 'outer_plan_id';
  static const String SOURCE = 'source';
  static const String PAY_STATUS = 'pay_status';
  static const String ORDER_STATUS = 'order_status';
  static const String CHECK_IN_DATE = 'check_in_date';
  static const String CHECK_OUT_DATE = 'check_out_date';
  static const String NUMBER_OF_ROOMS = 'number_of_rooms';
  static const String UNFINISHED_REASON = 'unfinished_reason';

  static const String SCENIC_ID = 'scenic_id';
  static const String SCENIC_NAME = 'scenic_name';
  static const String TICKET_NAME = 'ticket_name';
  static const String OUTER_SCENIC_ID = 'outer_scenic_id';
  static const String OUTER_TICKET_ID = 'outer_ticket_id';
  static const String TRAVEL_DATE = 'travel_date';
  static const String QUANTITY = 'quantity';

  static const String CUSTOMER_ID = "customer_id";
  static const String AMOUNT = "amount";
  static const String CHAMBER_ID = "chamber_id";
  static const String CHAMBER_NAME = "chamber_name";
  static const String RATE_PLAN_ID = "rate_plan_id";
  static const String CONTACT_NAME = "contact_name";
  static const String CONTACT_PHONE = "contact_phone";
  static const String CONTACT_EMAIL = "contact_email";
  static const String REMARK = "remark";
  static const String GUEST_LIST = "guest_list";
  static const String GUEST_NAME = "name";
  static const String GUEST_PHONE = "phone";
  static const String GUEST_CARD_TYPE = "card_type";
  static const String GUEST_CARD_NO = "card_no";

  static const String TICKET_ID = "ticket_id";
  static const String CONFIRM_ORDER_ID = "confirm_order_id";
  static const String VOUCHER_CODE = "voucher_code";
  static const String VOUCHER_URL = "voucher_url";
  static const String CONTACT_CARD_TYPE = "contact_card_type";
  static const String CONTACT_CARD_NO = "contact_card_no";

  static const String RESTAURANT_ID = "restaurant_id";
  static const String RESTAURANT_NAME = 'restaurant_name';
  static const String RESTAURANT_ADDRESS = 'restaurant_address';
  static const String NUMBER_OF_PEOPLE = 'number_of_people';
  static const String DINING_TIME = 'dining_time';
  static const String DINING_TYPE = 'dining_type';
  static const String DISH_LIST = 'dish_list';
  static const String DISH_ID = 'dish_id';
  static const String DISH_NAME = 'name';
  static const String DISH_QUANTITY = 'quantity';
  static const String DISH_FLAVOUR = 'flavour';

  static const String TRAVEL_ID = 'travel_id';
  static const String TRAVEL_SUIT_ID = 'travel_suit_id';
  static const String TRAVEL_NAME = 'travel_name';
  static const String TRAVEL_SUIT_NAME = 'travel_suit_name';
  static const String NUMBER_OF_ADULT = 'number_of_adult';
  static const String NUMBER_OF_OLD = 'number_of_old';
  static const String NUMBER_OF_CHILD = 'number_of_chid';
  static const String START_DATE = 'start_date';
  static const String END_DATE = 'end_date';
  static const String DAY_NUM = 'day_num';
  static const String NIGHT_NUM = 'night_num';
  static const String PROVINCE = 'province';
  static const String CITY = 'city';
  static const String RENDEZVOUS_TIME = 'rendezvous_time';
  static const String RENDEZVOUS_LOCATION = 'rendezvous_location';
  static const String DEST_PROVINCE = 'dest_province';
  static const String DEST_CITY = 'dest_city';
  static const String DEST_ADDRESS = 'dest_address';
  static const String EMERGENCY_NAME = 'emergency_name';
  static const String EMERGENCY_PHONE = 'emergency_phone';

  ImNotificationContentParserV1():super(_name);

  @override
  ImNotification? parse(ImNotification original) {
    String? content = original.innerContent;
    if(content == null){
      return null;
    }
    dynamic node = json.decoder.convert(content);
    dynamic version = node[VERSION];
    if(version != _name){
      return null;
    }
    dynamic typeVal = node[TYPE];
    v2.NotificationType? type = v2.NotificationTypeExt.getType(typeVal);
    if(type == null){
      return null;
    }
    dynamic contentInner = node[CONTENT];

    switch(type){
      case v2.NotificationType.interactGiftReceived:
        ImNotificationGetGift notification = ImNotificationGetGift.fromOriginal(original);
    
        notification.giver = contentInner[GIVER];
        notification.itemId = contentInner[ITEM_ID];
        notification.count = contentInner[COUNT];
        notification.giftNum = contentInner[GIFT_NUM];
        dynamic productTypeVal = contentInner[PRODUCT_TYPE];
        notification.productType = ProductTypeExt.getTypeByVal(productTypeVal);
        notification.productId = contentInner[PRODUCT_ID];

        return notification;  

      case v2.NotificationType.systemOrderHotelState:
        ImNotificationOrderHotelState notification = ImNotificationOrderHotelState.fromOriginal(original);
        notification.orderId = contentInner[ORDER_ID];
        notification.orderSerial = contentInner[ORDER_SERIAL];
        notification.hotelId = contentInner[HOTEL_ID];
        notification.hotelName = contentInner[HOTEL_NAME];
        notification.ratePlanName = contentInner[RATE_PLAN_NAME];
        notification.outerHotelId = contentInner[OUTER_HOTEL_ID];
        notification.outerPlanId = contentInner[OUTER_PLAN_ID];
        notification.source = contentInner[SOURCE];
        notification.payStatus = contentInner[PAY_STATUS];
        notification.orderStatus = contentInner[ORDER_STATUS];
        if(contentInner[CHECK_IN_DATE] is String){
          notification.checkInDate = DateTime.tryParse(contentInner[CHECK_IN_DATE]);
        }
        if(contentInner[CHECK_OUT_DATE] is String){
          notification.checkOutDate = DateTime.tryParse(contentInner[CHECK_OUT_DATE]);
        }
        notification.numberOfRooms = contentInner[NUMBER_OF_ROOMS];
        notification.unfinishedReason = contentInner[UNFINISHED_REASON];

        return notification;

      case v2.NotificationType.systemOrderScenicState:
        ImNotificationOrderScenicState notification = ImNotificationOrderScenicState.fromOriginal(original);
        notification.orderId = contentInner[ORDER_ID];
        notification.orderSerial = contentInner[ORDER_SERIAL];
        notification.scenicId = contentInner[SCENIC_ID];
        notification.scenicName = contentInner[SCENIC_NAME];
        notification.ticketName = contentInner[TICKET_NAME];
        notification.outerScenicId = contentInner[OUTER_SCENIC_ID];
        notification.outerTicketId = contentInner[OUTER_TICKET_ID];
        notification.source = contentInner[SOURCE];
        notification.payStatus = contentInner[PAY_STATUS];
        notification.orderStatus = contentInner[ORDER_STATUS];
        if(contentInner[TRAVEL_DATE] is String){
          notification.travelDate = DateTime.tryParse(contentInner[TRAVEL_DATE]);
        }
        notification.quantity = contentInner[QUANTITY];
        notification.unFinishReason = contentInner[UNFINISHED_REASON];

        return notification;

      case v2.NotificationType.orderHotelStateForMerchant:
        ImNotificationOrderHotelStateForMerchant notification = ImNotificationOrderHotelStateForMerchant();
        notification.clone(original);
        notification.orderId = contentInner[ORDER_ID];
        notification.orderSerial = contentInner[ORDER_SERIAL];
        notification.customerId = contentInner[CUSTOMER_ID];
        notification.amount = contentInner[AMOUNT];
        notification.hotelId = contentInner[HOTEL_ID];
        notification.chamberId = contentInner[CHAMBER_ID];
        notification.ratePlanId = contentInner[RATE_PLAN_ID];
        notification.hotelName = contentInner[HOTEL_NAME];
        notification.chamberName = contentInner[CHAMBER_NAME];
        notification.ratePlanName = contentInner[RATE_PLAN_NAME];
        notification.source = contentInner[SOURCE];
        notification.payStatus = contentInner[PAY_STATUS];
        notification.orderStatus = contentInner[ORDER_STATUS];
        if(contentInner[CHECK_IN_DATE] is String){
          notification.checkInDate = DateTime.tryParse(contentInner[CHECK_IN_DATE]);
        }
        if(contentInner[CHECK_OUT_DATE] is String){
          notification.checkOutDate = DateTime.tryParse(contentInner[CHECK_OUT_DATE]);
        }
        notification.numberOfRooms = contentInner[NUMBER_OF_ROOMS];
        notification.unfinishedReason = contentInner[UNFINISHED_REASON];
        notification.contactName = contentInner[CONTACT_NAME];
        notification.contactPhone = contentInner[CONTACT_PHONE];
        notification.contactEmail = contentInner[CONTACT_EMAIL];
        
        if(contentInner[GUEST_LIST] != null){
          List<OrderGuest> list = [];
          for(dynamic json in contentInner[GUEST_LIST]){
            OrderGuest guest = OrderGuest();
            guest.name = json[GUEST_NAME];
            guest.phone = json[GUEST_PHONE];
            guest.cardType = json[GUEST_CARD_TYPE];
            guest.cardNo = json[GUEST_CARD_NO];
            list.add(guest);
          }
          notification.guestList = list;
        }
        return notification;
      
      case v2.NotificationType.orderScenicStateForMerchant:
        ImNotificationOrderScenicStateForMerchant notification = ImNotificationOrderScenicStateForMerchant();
        notification.clone(original);
        notification.orderId = contentInner[ORDER_ID];
        notification.orderSerial = contentInner[ORDER_SERIAL];
        notification.customerId = contentInner[CUSTOMER_ID];
        notification.scenicId = contentInner[SCENIC_ID];
        notification.ticketId = contentInner[TICKET_ID];
        notification.scenicName = contentInner[SCENIC_NAME];
        notification.ticketName = contentInner[TICKET_NAME];
        notification.source = contentInner[SOURCE];
        notification.payStatus = contentInner[PAY_STATUS];
        notification.orderStatus = contentInner[ORDER_STATUS];
        if(contentInner[TRAVEL_DATE] is String){
          notification.travelDate = DateTime.tryParse(contentInner[TRAVEL_DATE]);
        }
        notification.amount = contentInner[AMOUNT];
        notification.quantity = contentInner[QUANTITY];
        notification.unfinishedReason = contentInner[UNFINISHED_REASON];
        notification.contactName = contentInner[CONTACT_NAME];
        notification.contactPhone = contentInner[CONTACT_PHONE];
        notification.contactCardType = contentInner[CONTACT_CARD_TYPE];
        notification.contactCardNo = contentInner[CONTACT_CARD_NO];
        notification.confirmOrderId = contentInner[CONFIRM_ORDER_ID];
        notification.voucherCode = contentInner[VOUCHER_CODE];
        notification.voucherUrl = contentInner[VOUCHER_URL];
        if(contentInner[GUEST_LIST] != null){
          List<OrderGuest> list = [];
          for(dynamic json in contentInner[GUEST_LIST]){
            OrderGuest guest = OrderGuest();
            guest.name = json[GUEST_NAME];
            guest.phone = json[GUEST_PHONE];
            guest.cardType = json[GUEST_CARD_TYPE];
            guest.cardNo = json[GUEST_CARD_NO];
            list.add(guest);
          }
          notification.guestList = list;
        }
        return notification;

      case v2.NotificationType.systemOrderRestaurantState:
        ImNotificationOrderRestaurantState notification = ImNotificationOrderRestaurantState();
        notification.clone(original);
        notification.orderId = contentInner[ORDER_ID];
        notification.orderSerial = contentInner[ORDER_SERIAL];
        notification.restaurantId = contentInner[RESTAURANT_ID];
        notification.restaurantName = contentInner[RESTAURANT_NAME];
        notification.restaurantAddress = contentInner[RESTAURANT_ADDRESS];
        notification.payStatus = contentInner[PAY_STATUS];
        notification.orderStatus = contentInner[ORDER_STATUS];
        if(contentInner[DINING_TIME] is String){
          notification.diningTime = DateTime.tryParse(contentInner[DINING_TIME]);
        }
        notification.numberOfPeople = contentInner[NUMBER_OF_PEOPLE];
        notification.diningType = contentInner[DINING_TYPE];
        notification.remark = contentInner[REMARK];
        notification.unfinishedReason = contentInner[UNFINISHED_REASON];
        if(contentInner[DISH_LIST] != null){
          List<OrderRestaurantDish> list = [];
          for(dynamic json in contentInner[DISH_LIST]){
            OrderRestaurantDish dish = OrderRestaurantDish();
            dish.dishName = json[DISH_NAME];
            dish.restaurantDishId = json[DISH_ID];
            dish.dishNumber = json[DISH_QUANTITY];
            dish.flavour = json[DISH_FLAVOUR];
            list.add(dish);
          }
          notification.dishList = list;
        }
        return notification;

      case v2.NotificationType.orderRestaurantStateForMerchant:
        ImNotificationOrderRestaurantStateForMerchant notification = ImNotificationOrderRestaurantStateForMerchant();
        notification.clone(original);
        notification.orderId = contentInner[ORDER_ID];
        notification.orderSerial = contentInner[ORDER_SERIAL];
        notification.source = contentInner[SOURCE];
        notification.amount = contentInner[AMOUNT];
        notification.restaurantId = contentInner[RESTAURANT_ID];
        notification.restaurantName = contentInner[RESTAURANT_NAME];
        notification.restaurantAddress = contentInner[RESTAURANT_ADDRESS];
        notification.payStatus = contentInner[PAY_STATUS];
        notification.orderStatus = contentInner[ORDER_STATUS];
        notification.numberOfPeople = contentInner[NUMBER_OF_PEOPLE];
        if(contentInner[DINING_TIME] is String){
          notification.diningTime = DateTime.tryParse(contentInner[DINING_TIME]);
        }
        notification.diningType = contentInner[DINING_TYPE];
        notification.remark = contentInner[REMARK];
        notification.unfinishedReason = contentInner[UNFINISHED_REASON];
        notification.contactName = contentInner[CONTACT_NAME];
        notification.contactPhone = contentInner[CONTACT_PHONE];
        if(contentInner[DISH_LIST] != null){
          List<OrderRestaurantDish> list = [];
          for(dynamic json in contentInner[DISH_LIST]){
            OrderRestaurantDish dish = OrderRestaurantDish();
            dish.dishName = json[DISH_NAME];
            dish.restaurantDishId = json[DISH_ID];
            dish.dishNumber = json[DISH_QUANTITY];
            dish.flavour = json[DISH_FLAVOUR];
            list.add(dish);
          }
          notification.dishList = list;
        }

        return notification;

      case v2.NotificationType.systemOrderTravelState:
        ImNotificationOrderTravelState notification = ImNotificationOrderTravelState();
        notification.clone(original);
        notification.orderId = contentInner[ORDER_ID];
        notification.orderSerial = contentInner[ORDER_SERIAL];
        notification.source = contentInner[SOURCE];
        notification.amount = contentInner[AMOUNT];
        notification.travelId = contentInner[TRAVEL_ID];
        notification.travelSuitId = contentInner[TRAVEL_SUIT_ID];
        notification.travelName = contentInner[TRAVEL_NAME];
        notification.travelSuitName = contentInner[TRAVEL_SUIT_NAME];
        notification.payStatus = contentInner[PAY_STATUS];
        notification.orderStatus = contentInner[ORDER_STATUS];
        notification.numberOfAdult = contentInner[NUMBER_OF_ADULT];
        notification.numberOfOld = contentInner[NUMBER_OF_OLD];
        notification.numberOfChild = contentInner[NUMBER_OF_CHILD];
        if(contentInner[START_DATE] is String){
          notification.startDate = DateTime.tryParse(contentInner[START_DATE]);
        }
        if(contentInner[END_DATE] is String){
          notification.endDate = DateTime.tryParse(contentInner[END_DATE]);
        }
        notification.dayNum = contentInner[DAY_NUM];
        notification.nightNum = contentInner[NIGHT_NUM];
        notification.province = contentInner[PROVINCE];
        notification.city = contentInner[CITY];
        notification.rendezvousTime = contentInner[RENDEZVOUS_TIME];
        notification.rendezvousLocation = contentInner[RENDEZVOUS_LOCATION];
        notification.destProvince = contentInner[DEST_PROVINCE];
        notification.destCity = contentInner[DEST_CITY];
        notification.destAddress = contentInner[DEST_ADDRESS];
        notification.remark = contentInner[REMARK];
        notification.unfinishedReason = contentInner[UNFINISHED_REASON];

        return notification;
      case v2.NotificationType.orderTravelStateForMerchant:
        ImNotificationOrderTravelStateForMerchant notification = ImNotificationOrderTravelStateForMerchant();
        notification.clone(original);
        notification.orderId = contentInner[ORDER_ID];
        notification.orderSerial = contentInner[ORDER_SERIAL];
        notification.source = contentInner[SOURCE];
        notification.amount = contentInner[AMOUNT];
        notification.travelId = contentInner[TRAVEL_ID];
        notification.travelSuitId = contentInner[TRAVEL_SUIT_ID];
        notification.travelName = contentInner[TRAVEL_NAME];
        notification.travelSuitName = contentInner[TRAVEL_SUIT_NAME];
        notification.payStatus = contentInner[PAY_STATUS];
        notification.orderStatus = contentInner[ORDER_STATUS];
        notification.numberOfAdult = contentInner[NUMBER_OF_ADULT];
        notification.numberOfOld = contentInner[NUMBER_OF_OLD];
        notification.numberOfChild = contentInner[NUMBER_OF_CHILD];
        if(contentInner[START_DATE] is String){
          notification.startDate = DateTime.tryParse(contentInner[START_DATE]);
        }
        if(contentInner[END_DATE] is String){
          notification.endDate = DateTime.tryParse(contentInner[END_DATE]);
        }
        notification.dayNum = contentInner[DAY_NUM];
        notification.nightNum = contentInner[NIGHT_NUM];
        notification.province = contentInner[PROVINCE];
        notification.city = contentInner[CITY];
        notification.rendezvousTime = contentInner[RENDEZVOUS_TIME];
        notification.rendezvousLocation = contentInner[RENDEZVOUS_LOCATION];
        notification.destProvince = contentInner[DEST_PROVINCE];
        notification.destCity = contentInner[DEST_CITY];
        notification.destAddress = contentInner[DEST_ADDRESS];
        notification.remark = contentInner[REMARK];
        notification.unfinishedReason = contentInner[UNFINISHED_REASON];

        notification.contactName = contentInner[CONTACT_NAME];
        notification.contactPhone = contentInner[CONTACT_PHONE];
        notification.contactEmail = contentInner[CONTACT_EMAIL];
        notification.emergencyName = contentInner[EMERGENCY_NAME];
        notification.emergencyPhone = contentInner[EMERGENCY_PHONE];

        if(contentInner[GUEST_LIST] != null){
          List<OrderGuest> list = [];
          for(dynamic json in contentInner[GUEST_LIST]){
            OrderGuest guest = OrderGuest();
            guest.name = json[GUEST_NAME];
            guest.phone = json[GUEST_PHONE];
            guest.cardType = json[GUEST_CARD_TYPE];
            guest.cardNo = json[GUEST_CARD_NO];
          }
          notification.guestList = list;
        }

        return notification;
      default:
        return null;
    }
      
  }
  
}
