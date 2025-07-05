
import 'dart:convert' show json;
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/components/chat_neo/chat_socket.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_event.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_http.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_storage.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/util/tuple.dart';

class ChatNotificationUtil{

  late DefaultNotificationHandler defaultNotificationHandler;
  late DefaultNotificationReconnectHandler defaultNotificationReconnectHandler;

  ChatNotificationUtil._internal(){
    defaultNotificationHandler = DefaultNotificationHandler();
    ChatSocket.addMessageHandler(defaultNotificationHandler);
    defaultNotificationReconnectHandler = DefaultNotificationReconnectHandler();
    ChatSocket.addReconnectHandler(defaultNotificationReconnectHandler);
  }
  
  static final ChatNotificationUtil _instance = ChatNotificationUtil._internal();
  factory ChatNotificationUtil(){
    return _instance;
  }

  Future<int> getUnreadCount() async{
    return await ChatNotificationStorage.getUnreadCount();
  }

  static Future getAllUnsent() async{
    return _instance._getAllUnsent();
  }

  Future _getAllUnsent() async{
    Tuple<List<ImNotification>, List<ImNotificationRoom>>? tuple = await ChatNotificationHttp.getUnsentData();
    if(tuple == null){
      return;
    }
    List<ImNotificationRoom> roomList = tuple.t2;
    List<ImNotification> notificationList = tuple.t1;
    await ChatNotificationStorage.saveRooms(roomList);
    await ChatNotificationStorage.saveNotifications(notificationList);
    // 发送接收成功回执
    Map<int, int> roomSentMap = {};
    for(ImNotification notification in notificationList){
      if(notification.roomId != null){
        int roomId = notification.roomId!;
        if(notification.id != null && (roomSentMap[roomId] == null || roomSentMap[roomId]! < notification.id!)){
          roomSentMap[roomId] = notification.id!;
        }
      }
    }
    for(MapEntry<int, int> entry in roomSentMap.entries){
      ImNotificationReply reply = prepareSentReply(entry.key, entry.value);
      MessageObject rawMessage = getRawMessage(reply);
      ChatSocket.sendMessage(rawMessage);
    }
  }

  Future<List<ImNotification>> getHistory({required int roomId, int? maxId, int limit = 10}) async{
    List<ImNotification>? list;
    list = await ChatNotificationStorage.getLocalNotificationByRoom(roomId: roomId, maxId: maxId, limit: limit);
    if(list.isNotEmpty){
      return list;
    }
    list = await ChatNotificationHttp.getHistory(roomId, maxId: maxId, limit: limit);
    if(list != null){
      for(ImNotification notification in list){
        notification.checked = true;
      }
      await ChatNotificationStorage.saveNotifications(list);
      return list;
    }
    return [];
  }

  ImNotificationReply prepareSentReply(int roomId, int lastSentId){
    ImNotificationReply<int> reply = ImNotificationReply();
    reply.roomId = roomId;
    reply.commandType = CommandType.sent.getNum();
    reply.commandValue = lastSentId;
    return reply;
  }

  ImNotificationReply prepareReadReply(int roomId){
    ImNotificationReply reply = ImNotificationReply();
    reply.roomId = roomId;
    reply.commandType = CommandType.read.getNum();
    return reply;
  }

  MessageObject getRawMessage(ImNotificationReply reply){
    MessageObject rawMessage = MessageObject();
    rawMessage.name = ChatSocket.MESSAGE_NOTIFICATION;
    rawMessage.body = json.encoder.convert(reply);
    return rawMessage;
  }

  Future readAll(int roomId) async{
    ImNotificationReply reply = ChatNotificationUtil().prepareReadReply(roomId);
    MessageObject rawMessage = ChatNotificationUtil().getRawMessage(reply);
    await ChatSocket.sendMessage(rawMessage);
    return ChatNotificationStorage.readAll(roomId);
  }
}

class DefaultNotificationReconnectHandler extends SocketReconnectHandler{

  DefaultNotificationReconnectHandler() :super(priority: 10);

  @override
  Future handle() async{
    await ChatNotificationUtil.getAllUnsent();
  }
  
}

class DefaultNotificationHandler extends ChatMessageHandler{

  DefaultNotificationHandler():super(priority: -1);

  @override
  Future handle(MessageObject rawObj) async{
    if(rawObj.name != ChatSocket.MESSAGE_NOTIFICATION){
      return;
    }
    if(rawObj.body == null){
      return;
    }
    ImNotification? notification = ImNotificationConverter.fromJson(json.decoder.convert(rawObj.body!));
    if(notification == null){
      return;
    }
    if(notification.id == null || notification.roomId == null){
      return;
    }
    await ChatNotificationStorage.saveNotifications([notification]);
    await ChatNotificationStorage.updateLatestNotification(notification);
    ImNotificationRoom? room = await ChatNotificationStorage.getRoom(notification.roomId!);
    room ??= await ChatNotificationHttp.getRoom(notification.roomId!);

    // 再次确认该通知房间是否存在，避免数据重复
    if(room != null && room.id != null && await ChatNotificationStorage.getRoom(room.id!) == null){
      await ChatNotificationStorage.saveRooms([room]);
      NotificationEventBus().triggerEvent(NotificationEventNewRoom(room.id!));
    }
    // 发送接收成功
    ImNotificationReply reply = ChatNotificationUtil().prepareSentReply(room!.id!, notification.id!);
    MessageObject rawReply = ChatNotificationUtil().getRawMessage(reply);
    ChatSocket.sendMessage(rawReply);
  }

}

class ImNotificationConverter{

  static ImNotification? fromJson(dynamic json, {bool? checked}){
    int? typeNum = json['type'];
    if(typeNum == null){
      return null;
    }
    NotificationType? type = NotificationTypeExt.getType(typeNum);
    if(type == null){
      return ImNotification.fromJson(json);
    }
    switch(type){
      case NotificationType.interactFriendApply:
        return ImNotificationInteractFriendApply.fromJson(json);
      case NotificationType.interactProductLiked:
        return ImNotificationInteractProductLiked.fromJson(json);
      case NotificationType.interactProductCommented:
        return ImNotificationInteractProductCommented.fromJson(json);
      case NotificationType.interactProductLikedMonument:
        return ImNotificationInteractProductLikedMonument.fromJson(json);
      case NotificationType.interactCommentCommented:
      case NotificationType.interactCommentSubCommented:
        return ImNotificationInteractCommentCommented.fromJson(json);
      case NotificationType.interactCommentLiked:
      case NotificationType.interactCommentSubLiked:
        return ImNotificationInteractCommentLiked.fromJson(json);
      case NotificationType.interactCircleActivityApplied:
        return ImNotificationInteractCircleActivityApplied.fromJson(json);
      case NotificationType.orderReceived:
      case NotificationType.orderRetracted:
        int? productTypeNum = json['subType'];
        if(productTypeNum == null){
          break;
        }
        ProductType? productType = ProductTypeExt.getType(productTypeNum);
        switch(productType){
          case ProductType.hotel:
            return ImNotificationOrderHotel.fromJson(json)..checked = checked;
          case ProductType.scenic:
            return ImNotificationOrderScenic.fromJson(json)..checked = checked;
          case ProductType.restaurant:
            return ImNotificationOrderRestaurant.fromJson(json)..checked = checked;
          case ProductType.travel:
            return ImNotificationOrderTravel.fromJson(json)..checked = checked;
          default:
        }
        break;
      case NotificationType.systemOrderSuccess:
      case NotificationType.systemOrderFail:
      case NotificationType.systemOrderConfirmed:
      case NotificationType.systemOrderCompleted:
        return ImNotificationSystemOrderStateChange.fromJson(json);
      case NotificationType.systemTipoffConfirmed:
        return ImNotificationSystemTipoffConfirmed.fromJson(json);
      case NotificationType.systemTipoffWarned:
        return ImNotificationSystemProductWarned.fromJson(json);
      case NotificationType.systemGetReward:
        return ImNotificationSystemGetReward.fromJson(json);
      case NotificationType.systemCashwithdrawResult:
        return ImNotificationSystemCashWithdrawResult.fromJson(json);
      case NotificationType.systemMerchantApplyResult:
        return ImNotificationSystemMerchantApplyResult.fromJson(json);
      default:
        return null;
    }
    return null;
  }
}
