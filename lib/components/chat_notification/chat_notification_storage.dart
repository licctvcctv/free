
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/circle_neo/circle_common.dart';
import 'package:freego_flutter/components/order_neo/order_common.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ChatNotificationStorage{

  static const String _dbname = 'freego_chat_notification';

  static const String _tableNotificationRoom = 'im_notification_room';
  static const String _tableNotification = 'im_notification';

  static const String _tableNotificationInteractFriendApply = 'im_notification_interact_friend_apply';
  static const String _tableNotificationInteractProductLiked = 'im_notification_interact_product_liked';
  static const String _tableNotificationInteractProductCommented = 'im_notification_interact_product_commented';
  static const String _tableNotificationInteractProductLikedMonument = 'im_notification_interact_product_liked_monument';
  static const String _tableNotificationUser = 'im_notification_user';
  static const String _tableNotificationInteractCommentCommented = 'im_notification_interact_comment_commented';
  static const String _tableNotificationInteractCommentLiked = 'im_notification_interact_comment_liked';
  static const String _tableNotificationInteractCircleActivityApplied = 'im_notification_interact_circle_activity_applied';

  static const String _tableNotificationOrderHotel = 'im_notification_order_hotel';
  static const String _tableNotificationOrderScenic = 'im_notification_order_scenic';
  static const String _tableNotificationOrderRestaurant = 'im_notification_order_restaurant';
  static const String _tableNotificationOrderTravel = 'im_notification_order_travel';

  static const String _tableNotificationSystemOrderStateChange = 'im_notification_system_order_state_change';
  static const String _tableNotificationSystemProductWarned = 'im_notification_system_product_warned';
  static const String _tableNotificationSystemGetReward = 'im_notification_system_get_reward';

  static const String _tableNotificationSystemTipoffConfirmed = 'im_notification_system_tipoff_confirmed';
  static const String _tableNotificationSystemCashwithdrawResult = 'im_notification_system_cashwithdraw_result';
  static const String _tableNotificationSystemMerchantApplyResult = 'im_notification_system_merchant_apply_result';

  static Database? db;
  static final _MyAfterLogoutHandler _afterLogoutHandler = _MyAfterLogoutHandler();

  static Future<int> getUnreadCount() async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('select sum(unread_num) sum from $_tableNotificationRoom');
    if(list.isEmpty){
      return 0;
    }
    Map<String, Object?> result = list.first;
    Object? sum = result['sum'];
    if(sum is int){
      return sum;
    }
    return 0;
  }

  static Future setChecked(int nid, bool val) async{
    Database db = await database;
    Map<String, Object?> value = {};
    value['checked'] = val ? 1 : 0;
    return db.update(_tableNotification, value, where: 'id = $nid');
  }

  static Future updateOrderChecked(int nid, ProductType type, int checked) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['checked'] = checked;
    switch(type){
      case ProductType.hotel:
        return db.update(_tableNotificationOrderHotel, val, where: 'nid = $nid');
      case ProductType.scenic:
        return db.update(_tableNotificationOrderScenic, val, where: 'nid = $nid');
      case ProductType.restaurant:
        return db.update(_tableNotificationOrderRestaurant, val, where: 'nid = $nid');
      case ProductType.travel:
        return db.update(_tableNotificationOrderTravel, val, where: 'nid = $nid');
      default:
        return;
    }
  }

  static Future updateCircleActivityApplyStatus(int nid, CircleActivityApplyStatus status) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['apply_status'] = status.getNum();
    return db.update(_tableNotificationInteractCircleActivityApplied, val, where: 'nid = $nid');
  }

  static Future updateOrderScenicStatus(int nid, OrderScenicStatus status) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['order_status'] = status.getNum();
    return db.update(_tableNotificationOrderScenic, val, where: 'nid = $nid');
  }

  static Future updateOrderHotelStatus(int nid, OrderHotelStatus status) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['order_status'] = status.getNum();
    return db.update(_tableNotificationOrderHotel, val, where: 'nid = $nid');
  }

  static Future updateOrderRestaurantStatus(int nid, OrderRestaurantStatus status) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['order_status'] = status.getNum();
    return db.update(_tableNotificationOrderRestaurant, val, where: 'nid = $nid');
  }

  static Future updateOrderTravelStatus(int nid, OrderTravelStatus status) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['order_status'] = status.getNum();
    return db.update(_tableNotificationOrderTravel, val, where: 'nid = $nid');
  }

  static Future updateCommentSubIsLiked(int nid, bool isLiked) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['is_liked'] = isLiked ? 1 : 0;
    return db.update(_tableNotificationInteractCommentCommented, val, where: 'nid = $nid');
  }

  static Future updateCommentIsLiked(int nid, bool isLiked) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['is_liked'] = isLiked ? 1 : 0;
    return db.update(_tableNotificationInteractProductCommented, val, where: 'nid = $nid');
  }

  static Future updateLatestNotification(ImNotification notification) async{
    if(notification.id == null || notification.roomId == null){
      return;
    }
    Database db = await database;
    return await db.transaction((txn) async{
      List<Map<String, Object?>> roomList = await txn.query(_tableNotificationRoom, where: 'id = ${notification.roomId!}');
      if(roomList.isEmpty){
        return null;
      }
      ImNotificationRoom room = ImNotificationRoom.fromSqlMap(roomList.first);
      if(room.lastMessageId == null || room.lastMessageId! < notification.id!){
        room.lastMessageId = notification.id;
        room.lastMessageTime = notification.createTime;
        room.unreadNum = (room.unreadNum ?? 0) + 1;
      }
      return txn.update(_tableNotificationRoom, room.toSqlMap(), where: 'id = ${room.id}');
    });
  }

  static Future readAll(int roomId) async{
    Database db = await database;
    Map<String, Object?> val = {};
    val['unread_num'] = 0;
    return db.update(_tableNotificationRoom, val, where: 'id = $roomId');
  }

  static Future<ImNotificationRoom?> getRoom(int id) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.query(_tableNotificationRoom, where: 'id = $id');
    if(list.isEmpty){
      return null;
    }
    ImNotificationRoom room = ImNotificationRoom.fromSqlMap(list.first);
    return room;
  }

  static Future<ImNotification?> getNotification(int id) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.query(_tableNotification, where: 'id = $id');
    if(list.isEmpty){
      return null;
    }
    ImNotification notification = ImNotification.fromSqlMap(list[0]);
    return notification;
  }

  static Future<ImNotification?> getNotificationVo(ImNotification notification) async{
    if(notification.id == null){
      return null;
    }
    NotificationType? type;
    if(notification.type != null){
      type = NotificationTypeExt.getType(notification.type!);
    }
    if(type == null){
      return notification;
    }
    ImNotification? vo;
    switch(type){
      case NotificationType.interactFriendApply:
        vo = await getImNotificationInteractFriendApply(notification.id!);
        break;
      case NotificationType.interactProductLiked:
        vo = await getImNotificationInteractProductLiked(notification.id!);
        break;
      case NotificationType.interactProductCommented:
        vo = await getImNotificationInteractProductCommented(notification.id!);
        break;
      case NotificationType.interactProductLikedMonument:
        vo = await getImNotificationInteractProductLikedMonument(notification.id!);
        break;
      case NotificationType.interactCommentCommented:
      case NotificationType.interactCommentSubCommented:
        vo = await getImNotificationInteractCommentCommented(notification.id!);
        break;
      case NotificationType.interactCommentLiked:
      case NotificationType.interactCommentSubLiked:
        vo = await getImNotificationInteractCommentLiked(notification.id!);
        break;
      case NotificationType.interactCircleActivityApplied:
        vo = await getImNotificationInteractCircleActivityApplied(notification.id!);
        break;
      case NotificationType.orderReceived:
      case NotificationType.orderRetracted:
        if(notification.subType == null){
          break;
        }
        ProductType? type = ProductTypeExt.getType(notification.subType!);
        if(type == null){
          break;
        }
        switch(type){
          case ProductType.hotel:
            vo = await getImNotificationOrderHotel(notification.id!);
            break;
          case ProductType.scenic:
            vo = await getImNotificationOrderScenic(notification.id!);
            break;
          case ProductType.restaurant:
            vo = await getImNotificationOrderRestaurant(notification.id!);
            break;
          case ProductType.travel:
            vo = await getImNotificationOrderTravel(notification.id!);
            break;
          default: 
        }
        break;
      case NotificationType.systemOrderSuccess:
      case NotificationType.systemOrderFail:
      case NotificationType.systemOrderConfirmed:
      case NotificationType.systemOrderCompleted:
        vo = await getImNotificationSystemOrderStateChange(notification.id!);
        break;
      case NotificationType.systemTipoffWarned:
        vo = await getImNotificationSystemProductWarned(notification.id!);
        break;
      case NotificationType.systemGetReward:
        vo = await getImNotificationSystemGetReward(notification.id!);
        break;
      case NotificationType.systemTipoffConfirmed:
        vo = await getImNotificationSystemTipoffConfirmed(notification.id!);
        break;
      case NotificationType.systemCashwithdrawResult:
        vo = await getImNotificationSystemCashWithdrawResult(notification.id!);
        break;
      case NotificationType.systemMerchantApplyResult:
        vo = await getImNotificationSystemMerchantApplyResult(notification.id!);
        break;
      default:
        break;
    }
    return vo;
  }

  static Future<List<ImNotification>> getNewNotificationByRoom({required int roomId, int? minId}) async{
    Database db = await database;
    List<Map<String, Object?>> list;
    list = await db.query(_tableNotification, where: 'room_id = $roomId ${minId == null ? '' : 'and id > $minId'}', orderBy: 'id');
    List<ImNotification> resultList = [];
    for(Map<String, Object?> map in list.reversed){
      ImNotification notification = ImNotification.fromSqlMap(map);
      if(notification.id == null || notification.type == null){
        continue;
      }
      NotificationType? type = NotificationTypeExt.getType(notification.type!);
      if(type == null){
        continue;
      }
      ImNotification? vo = await getNotificationVo(notification);
      if(vo != null){
        resultList.add(vo);
      }
    }
    return resultList;
  }

  static Future<List<ImNotification>> getLocalNotificationByRoom({required int roomId, int ? maxId, int limit = 10}) async{
    Database db = await database;
    List<Map<String, Object?>> list;
    if(maxId == null){
      list = await db.query(_tableNotification, where: 'room_id = $roomId', orderBy: 'id desc', limit: limit);
    }
    else{
      list = await db.query(_tableNotification, where: 'room_id = $roomId and id < $maxId', orderBy: 'id desc', limit: limit);
    }
    List<ImNotification> resultList = [];
    for(Map<String, Object?> map in list){
      ImNotification notification = ImNotification.fromSqlMap(map);
      ImNotification? vo = await getNotificationVo(notification);
      if(vo != null){
        resultList.add(vo);
      }
    }
    return resultList;
  }

  static Future<ImNotificationSystemMerchantApplyResult?> getImNotificationSystemMerchantApplyResult(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_system_merchant_apply_result.*
      from im_notification inner join im_notification_system_merchant_apply_result
      on (im_notification.id = im_notification_system_merchant_apply_result.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationSystemMerchantApplyResult.fromSqlMap(list.first);
  }

  static Future<ImNotificationSystemCashWithdrawResult?> getImNotificationSystemCashWithdrawResult(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_system_cashwithdraw_result.*
      from im_notification inner join im_notification_system_cashwithdraw_result
      on(im_notification.id = im_notification_system_cashwithdraw_result.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationSystemCashWithdrawResult.fromSqlMap(list.first);
  }

  static Future<ImNotificationSystemTipoffConfirmed?> getImNotificationSystemTipoffConfirmed(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_system_tipoff_confirmed.*
      from im_notification inner join im_notification_system_tipoff_confirmed
      on(im_notification.id = im_notification_system_tipoff_confirmed.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationSystemTipoffConfirmed.fromSqlMap(list.first);
  }

  static Future<ImNotificationSystemGetReward?> getImNotificationSystemGetReward(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_system_get_reward.*
      from im_notification inner join im_notification_system_get_reward
      on(im_notification.id = im_notification_system_get_reward.nid)
      where im_notification.id = $nid
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationSystemGetReward.fromSqlMap(list.first);
  }

  static Future<ImNotificationSystemProductWarned?> getImNotificationSystemProductWarned(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_system_product_warned.*
      from im_notification inner join im_notification_system_product_warned
      on(im_notification.id = im_notification_system_product_warned.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationSystemProductWarned.fromSqlMap(list.first);
  }

  static Future<ImNotificationSystemOrderStateChange?> getImNotificationSystemOrderStateChange(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_system_order_state_change.*
      from im_notification inner join im_notification_system_order_state_change
      on (im_notification.id = im_notification_system_order_state_change.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationSystemOrderStateChange.fromSqlMap(list.first);
  }

  static Future<ImNotificationOrderScenic?> getImNotificationOrderScenic(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_order_scenic.*
      from im_notification inner join im_notification_order_scenic
      on (im_notification.id = im_notification_order_scenic.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationOrderScenic.fromSqlMap(list.first);
  }

  static Future<ImNotificationOrderHotel?> getImNotificationOrderHotel(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_order_hotel.*
      from im_notification inner join im_notification_order_hotel
      on (im_notification.id = im_notification_order_hotel.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationOrderHotel.fromSqlMap(list.first);
  }

  static Future<ImNotificationOrderRestaurant?> getImNotificationOrderRestaurant(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_order_restaurant.*
      from im_notification inner join im_notification_order_restaurant
      on (im_notification.id = im_notification_order_restaurant.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationOrderRestaurant.fromSqlMap(list.first);
  }

  static Future<ImNotificationOrderTravel?> getImNotificationOrderTravel(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_order_travel.*
      from im_notification inner join im_notification_order_travel
      on (im_notification.id = im_notification_order_travel.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationOrderTravel.fromSqlMap(list.first);
  }

  static Future<ImNotificationInteractCircleActivityApplied?> getImNotificationInteractCircleActivityApplied(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, im_notification_interact_circle_activity_applied.*
      from im_notification inner join im_notification_interact_circle_activity_applied
      on (im_notification.id = im_notification_interact_circle_activity_applied.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationInteractCircleActivityApplied.fromSqlMap(list.first);
  }

  static Future updateImNotificationInteractFriendApplyStatus(int nid, UserFriendApplyStatus status) async{
    Database db = await database;
    Map<String, Object?> values = {};
    values['status'] = status.getNum();
    return db.update(_tableNotificationInteractFriendApply, values, where: 'nid = $nid');
  }

  static Future<ImNotificationInteractFriendApply?> getImNotificationInteractFriendApply(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, partner_id, partner_name, partner_head, description, status 
      from im_notification inner join im_notification_interact_friend_apply
      on (im_notification.id = im_notification_interact_friend_apply.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationInteractFriendApply.fromSqlMap(list[0]);
  }

  static Future<ImNotificationInteractProductLiked?> getImNotificationInteractProductLiked(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, partner_id, partner_name, partner_head, product_id, product_name
      from im_notification inner join im_notification_interact_product_liked
      on (im_notification.id = im_notification_interact_product_liked.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationInteractProductLiked.fromSqlMap(list[0]);
  }

  static Future<ImNotificationInteractProductCommented?> getImNotificationInteractProductCommented(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, partner_id, partner_name, partner_head, content, product_id, product_name, is_liked
      from im_notification inner join im_notification_interact_product_commented
      on (im_notification.id = im_notification_interact_product_commented.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationInteractProductCommented.fromSqlMap(list[0]);
  }

  static Future<ImNotificationInteractProductLikedMonument?> getImNotificationInteractProductLikedMonument(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, product_id, product_name, product_type, count
      from im_notification inner join im_notification_interact_product_liked_monument
      on (im_notification.id = im_notification_interact_product_liked_monument.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    ImNotificationInteractProductLikedMonument notification = ImNotificationInteractProductLikedMonument.fromSqlMap(list[0]);
    if(notification.id != null){
      notification.users = await getImNotificationUsers(notification.id!);
    }
    return notification;
  }

  static Future<List<SimpleUser>> getImNotificationUsers(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.query(_tableNotificationUser, where: 'nid = $nid');
    List<SimpleUser> users = [];
    for(Map<String, Object?> map in list){
      users.add(SimpleUser.fromSqlMap(map));
    }
    return users;
  }

  static Future<ImNotificationInteractCommentLiked?> getImNotificationInteractCommentLiked(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, partner_id, partner_name, partner_head,
      product_id, product_name, content
      from im_notification inner join $_tableNotificationInteractCommentLiked
      on (im_notification.id = $_tableNotificationInteractCommentLiked.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return ImNotificationInteractCommentLiked.fromSqlMap(list.first);
  }

  static Future<ImNotificationInteractCommentCommented?> getImNotificationInteractCommentCommented(int nid) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('''
      select im_notification.*, partner_id, partner_name, partner_head,
      comment_id, user_content, partner_content,
      product_id, product_name, is_liked
      from im_notification inner join $_tableNotificationInteractCommentCommented
      on (im_notification.id = $_tableNotificationInteractCommentCommented.nid)
      where im_notification.id = $nid
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    ImNotificationInteractCommentCommented notification = ImNotificationInteractCommentCommented.fromSqlMap(list[0]);
    return notification;
  }

  static Future<List<ImNotificationRoom>> getLocalRooms() async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.query(_tableNotificationRoom, where: 'exists (select id from im_notification where im_notification.room_id = im_notification_room.id limit 1)');
    List<ImNotificationRoom> result = [];
    for(Map<String, Object?> map in list){
      result.add(ImNotificationRoom.fromSqlMap(map));
    }
    return result;
  }

  static Future saveNotifications(List<ImNotification> list) async{
    Database db = await database;
    return db.transaction((txn) async{
      Batch batch = txn.batch();
      for(ImNotification notification in list){
        ImNotificationAdapter? adapter = notification.getAdapter();
        await adapter?.save(notification, txn, batch);
      }
      return batch.commit();
    });
  }

  static Future saveRooms(List<ImNotificationRoom> list) async{
    Database db = await database;
    return db.transaction((txn) async{
      Batch batch = txn.batch();
      for(ImNotificationRoom room in list){
        List<Map<String, Object?>> savedList = await txn.query(_tableNotificationRoom, where: 'id = ${room.id}');
        if(savedList.isEmpty){
          batch.insert(_tableNotificationRoom, room.toSqlMap());
        }
        else{
          ImNotificationRoom savedRoom = ImNotificationRoom.fromSqlMap(savedList[0]);
          if(savedRoom.lastMessageId == null || room.lastMessageId != null && room.lastMessageId! > savedRoom.lastMessageId!){
            batch.update(_tableNotificationRoom, room.toSqlMap(), where: 'id = ${room.id}');
          }
        }
      }
      return batch.commit();
    });
  }

  static Future<Database?> init() async{
    LocalUser.addAfterLogoutHandler(_afterLogoutHandler);
    int? userId = LocalUser.getUser()?.id;
    if(userId == null){
      throw Exception('用户未登录');
    }
    String? path = (await getApplicationDocumentsDirectory()).path;
    path = '$path/database/${_dbname}_$userId';
    db = await openDatabase(
      path, 
      version: 4, 
      onUpgrade: (db, oldVersion, newVersion) async{
        if(oldVersion < 4){
          try{
            db.execute('''
              alter table im_notification add column checked integer
            ''');
          }
          catch(e){
            //
          }
        }
      },
      onCreate: (db, version) async{
        await db.execute('''
          create table if not exists im_notification_room(
            id integer,
            ownner_id integer,
            type integer,
            last_message_id integer,
            last_message_time integer,
            last_send_id integer,
            unread_num integer,
            create_time integer,
            checked integer
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_room_id on im_notification_room(id)
        ''');
        await db.execute('''
          create table if not exists im_notification(
            id integer,
            room_id integer,
            type integer,
            sub_type integer,
            linked_id integer,
            inner_content text,
            create_time integer,
            checked integer
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_id on im_notification(id)
        ''');
        await db.execute('''
          create table if not exists im_notification_interact_friend_apply(
            nid integer,
            partner_id integer,
            partner_name text,
            partner_head text,
            description text,
            status integer
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_interact_friend_apply_nid on im_notification_interact_friend_apply(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationInteractProductLiked(
            nid integer,
            partner_id integer,
            partner_name text,
            partner_head text,
            product_id integer,
            product_name text
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_interact_product_liked_nid on im_notification_interact_product_liked(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationInteractProductCommented(
            nid integer,
            partner_id integer,
            partner_name text,
            partner_head text,
            content text,
            product_id integer,
            product_name text,
            is_liked integer
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_interact_product_commented_nid on im_notification_interact_product_commented(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationInteractProductLikedMonument(
            nid integer,
            product_id integer,
            product_type integer,
            product_name text,
            count integer
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_interact_product_liked_monument_nid on im_notification_interact_product_liked_monument(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationUser(
            nid integer,
            user_id integer,
            name text,
            head text
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_user_nid on im_notification_user(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationInteractCommentCommented(
            nid integer,
            partner_id integer,
            partner_name text,
            partner_head text,
            comment_id integer,
            user_content text,
            partner_content text,
            product_id integer,
            product_name text,
            is_liked integer
          ) 
        ''');
        await db.execute('''
          create index if not exists im_notification_interact_comment_commented_nid on $_tableNotificationInteractCommentCommented(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationInteractCommentLiked(
            nid integer,
            partner_id integer,
            partner_name text,
            partner_head text,
            product_id integer,
            product_name text,
            content text
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_interact_comment_liked_nid on $_tableNotificationInteractCommentLiked(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationInteractCircleActivityApplied(
            nid integer,
            circle_id integer,
            circle_name text,
            applier_id integer,
            applier_name text,
            applier_head text,
            remark text,
            apply_status integer
          )
        ''');
        await db.execute('''
          create index if not exists im_notification_interact_circle_activity_applied_nid on $_tableNotificationInteractCircleActivityApplied(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationOrderHotel(
            nid integer,
            customer_id integer,
            customer_name text,
            customer_head integer,
            hotel_id integer,
            hotel_name text,
            plan_name text,
            quantity integer,
            check_in_date integer,
            check_out_date integer,
            order_status integer,
            contact_name text,
            contact_phone text,
            contact_email text,
            remark text,
            checked integer
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationOrderHotel}_nid on $_tableNotificationOrderHotel(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationOrderScenic(
            nid integer,
            customer_id integer,
            customer_name text,
            customer_head text,
            scenic_id integer,
            scenic_name text,
            ticket_name text,
            quantity integer,
            visit_date integer,
            order_status integer,
            contact_name text,
            contact_phone text,
            contact_card_no text,
            contact_card_type integer,
            checked integer
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationOrderScenic}_nid on $_tableNotificationOrderScenic(nid)
        ''');
        //await db.execute('DROP TABLE IF EXISTS $_tableNotificationOrderRestaurant');
        await db.execute('''
          create table if not exists $_tableNotificationOrderRestaurant(
            nid integer,
            customer_id integer,
            customer_name text,
            customer_head text,
            restaurant_id integer,
            restaurant_name text,
            restaurant_address text,
            number_people integer,
            arrival_date integer,
            dining_methods integer,
            contact_name text,
            contact_phone text,
            remark text,
            order_status integer,
            unfinished_reason text,
            checked integer
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationOrderRestaurant}_nid on $_tableNotificationOrderRestaurant(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationOrderTravel(
            nid integer,
            customer_id integer,
            customer_name text,
            customer_head text,
            travel_id integer,
            travel_suit_id integer,
            travel_name text,
            travel_suit_name text,
            number integer,
            old_number integer,
            child_number integer,
            start_date integer,
            end_date integer,
            day_num integer,
            night_num integer,
            province text,
            city text,
            rendezvous_time text,
            rendezvous_location text,
            dest_province text,
            dest_city text,
            dest_address text,
            cancel_rule_type integer,
            cancel_rule_desc text,
            cancel_latest_time integer,
            contact_name text,
            contact_phone text,
            contact_email text,
            emergency_name text,
            emergency_phone text,
            order_status integer,
            unfinished_reason text,
            remark text,
            checked integer
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationOrderTravel}_nid on $_tableNotificationOrderTravel(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationSystemOrderStateChange(
            nid integer,
            product_name text,
            sub_name text,
            product_id integer,
            product_type integer,
            quantity integer,
            start_date integer,
            end_date integer
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationSystemOrderStateChange}_nid on $_tableNotificationSystemOrderStateChange(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationSystemProductWarned(
            nid integer,
            product_id int,
            product_type int,
            product_name text
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationSystemProductWarned}_nid on $_tableNotificationSystemProductWarned(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationSystemGetReward(
            nid integer,
            product_name text,
            product_id integer,
            product_type integer,
            amount integer,
            user_id integer,
            user_head text,
            user_name text,
            pay_date integer
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationSystemGetReward}_nid on $_tableNotificationSystemGetReward(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationSystemTipoffConfirmed(
            nid integer,
            product_id int,
            product_type int,
            product_name text
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationSystemTipoffConfirmed}_nid on $_tableNotificationSystemTipoffConfirmed(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationSystemCashwithdrawResult(
            nid integer,
            amount integer,
            status integer,
            bank_account text,
            bank_name text,
            real_name text,
            refuse_reason text
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationSystemCashwithdrawResult}_nid on $_tableNotificationSystemCashwithdrawResult(nid)
        ''');
        await db.execute('''
          create table if not exists $_tableNotificationSystemMerchantApplyResult(
            nid integer,
            verify_status integer,
            shop_name text,
            business_type integer,
            address text
          )
        ''');
        await db.execute('''
          create index if not exists ${_tableNotificationSystemMerchantApplyResult}_nid on $_tableNotificationSystemMerchantApplyResult(nid)
        ''');
      }
    );
    return db!;
  }

  static Future<Database> get database async{
    if(db != null && db!.isOpen){
      return db!;
    }
    db = await init();
    return db!;
  }

  static void close(){
    // 不要调用close，否则无法再次打开
    db = null;
  }
}

class _MyAfterLogoutHandler implements AfterLogoutHandler{

  @override
  void handle(UserModel user) {
    ChatNotificationStorage.close();
  }

}

class ImNotificationAdapter{

  static final ImNotificationAdapter instance = ImNotificationAdapter();

  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotification, where: 'id = ${notification.id}', limit: 1);
    if(savedList.isEmpty){
      batch.insert(ChatNotificationStorage._tableNotification, notification.toSqlMap());
    }
    else{
      batch.update(ChatNotificationStorage._tableNotification, notification.toSqlMap(), where: 'id = ${notification.id}');
    }
  }

}

class ImNotificationInteractFriendApplyAdapter extends ImNotificationAdapter{

  ImNotificationInteractFriendApplyAdapter._internal();
  static final ImNotificationInteractFriendApplyAdapter _instance = ImNotificationInteractFriendApplyAdapter._internal();
  factory ImNotificationInteractFriendApplyAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationInteractFriendApply){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationInteractFriendApply, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationInteractFriendApply, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationInteractFriendApply, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }

}

class ImNotificationInteractProductLikedAdapter extends ImNotificationAdapter{

  ImNotificationInteractProductLikedAdapter._internal();
  static final ImNotificationInteractProductLikedAdapter _instance = ImNotificationInteractProductLikedAdapter._internal();
  factory ImNotificationInteractProductLikedAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationInteractProductLiked){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationInteractFriendApply, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationInteractProductLiked, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationInteractProductLiked, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationInteractCommentLikedAdapter extends ImNotificationAdapter{

  ImNotificationInteractCommentLikedAdapter._internal();
  static final ImNotificationInteractCommentLikedAdapter _instance = ImNotificationInteractCommentLikedAdapter._internal();
  factory ImNotificationInteractCommentLikedAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationInteractCommentLiked){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationInteractCommentLiked, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationInteractCommentLiked, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationInteractCommentLiked, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationInteractProductCommentedAdapter extends ImNotificationAdapter{

  ImNotificationInteractProductCommentedAdapter._internal();
  static final ImNotificationInteractProductCommentedAdapter _instance = ImNotificationInteractProductCommentedAdapter._internal();
  factory ImNotificationInteractProductCommentedAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationInteractProductCommented){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationInteractProductCommented, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationInteractProductCommented, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationInteractProductCommented, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationInteractCommentCommentedAdapter extends ImNotificationAdapter{

  ImNotificationInteractCommentCommentedAdapter._internal();
  static final ImNotificationInteractCommentCommentedAdapter _instance = ImNotificationInteractCommentCommentedAdapter._internal();
  factory ImNotificationInteractCommentCommentedAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationInteractCommentCommented){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationInteractCommentCommented, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationInteractCommentCommented, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationInteractCommentCommented, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationInteractProductLikedMonumentAdapter extends ImNotificationAdapter{

  ImNotificationInteractProductLikedMonumentAdapter._internal();
  static final ImNotificationInteractProductLikedMonumentAdapter _instance = ImNotificationInteractProductLikedMonumentAdapter._internal();
  factory ImNotificationInteractProductLikedMonumentAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationInteractProductLikedMonument){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationInteractProductLikedMonument, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationInteractProductLikedMonument, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationInteractProductLikedMonument, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
      for(Map<String, Object?> map in notification.toExtraUserList()){
        savedList = await txn.query(ChatNotificationStorage._tableNotificationUser, where: 'nid = ${notification.id} and user_id = ${map["user_id"]}');
        if(savedList.isEmpty){
          batch.insert(ChatNotificationStorage._tableNotificationUser, map);
        }
        else{
          batch.update(ChatNotificationStorage._tableNotificationUser, map, where: 'nid = ${notification.id} and user_id = ${map["user_id"]}');
        }
      }
    }
  }
}

class ImNotificationInteractCircleActivityAppliedAdapter extends ImNotificationAdapter{

  ImNotificationInteractCircleActivityAppliedAdapter._internal();
  static final ImNotificationInteractCircleActivityAppliedAdapter _instance = ImNotificationInteractCircleActivityAppliedAdapter._internal();
  factory ImNotificationInteractCircleActivityAppliedAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationInteractCircleActivityApplied){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationInteractCircleActivityApplied, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationInteractCircleActivityApplied, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationInteractCircleActivityApplied, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationOrderHotelAdapter extends ImNotificationAdapter{

  ImNotificationOrderHotelAdapter._internal();
  static final ImNotificationOrderHotelAdapter _instance = ImNotificationOrderHotelAdapter._internal();
  factory ImNotificationOrderHotelAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationOrderHotel){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationOrderHotel, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationOrderHotel, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationOrderHotel, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationOrderScenicAdapter extends ImNotificationAdapter{

  ImNotificationOrderScenicAdapter._internal();
  static final ImNotificationOrderScenicAdapter _instance = ImNotificationOrderScenicAdapter._internal();
  factory ImNotificationOrderScenicAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationOrderScenic){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationOrderScenic, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationOrderScenic, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationOrderScenic, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationOrderRestaurantAdapter extends ImNotificationAdapter{

  ImNotificationOrderRestaurantAdapter._internal();
  static final ImNotificationOrderRestaurantAdapter _instance = ImNotificationOrderRestaurantAdapter._internal();
  factory ImNotificationOrderRestaurantAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationOrderRestaurant){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationOrderRestaurant, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationOrderRestaurant, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationOrderRestaurant, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationOrderTravelAdapter extends ImNotificationAdapter{

  ImNotificationOrderTravelAdapter._internal();
  static final ImNotificationOrderTravelAdapter _instance = ImNotificationOrderTravelAdapter._internal();
  factory ImNotificationOrderTravelAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationOrderTravel){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationOrderTravel, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationOrderTravel, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationOrderTravel, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationSystemOrderStateChangeAdapter extends ImNotificationAdapter{

  ImNotificationSystemOrderStateChangeAdapter._internal();
  static final ImNotificationSystemOrderStateChangeAdapter _instance = ImNotificationSystemOrderStateChangeAdapter._internal();
  factory ImNotificationSystemOrderStateChangeAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationSystemOrderStateChange){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationSystemOrderStateChange, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationSystemOrderStateChange, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationSystemOrderStateChange, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationSystemProductWarnedAdapter extends ImNotificationAdapter{

  ImNotificationSystemProductWarnedAdapter._internal();
  static final ImNotificationSystemProductWarnedAdapter _instance = ImNotificationSystemProductWarnedAdapter._internal();
  factory ImNotificationSystemProductWarnedAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationSystemProductWarned){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationSystemProductWarned, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationSystemProductWarned, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationSystemProductWarned, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationSystemGetRewardAdapter extends ImNotificationAdapter{

  ImNotificationSystemGetRewardAdapter._internal();
  static final ImNotificationSystemGetRewardAdapter _instance = ImNotificationSystemGetRewardAdapter._internal();
  factory ImNotificationSystemGetRewardAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationSystemGetReward){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationSystemGetReward, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationSystemGetReward, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationSystemGetReward, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationSystemTipoffConfirmedAdapter extends ImNotificationAdapter{

  ImNotificationSystemTipoffConfirmedAdapter._internal();
  static final ImNotificationSystemTipoffConfirmedAdapter _instance = ImNotificationSystemTipoffConfirmedAdapter._internal();
  factory ImNotificationSystemTipoffConfirmedAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationSystemTipoffConfirmed){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationSystemTipoffConfirmed, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationSystemTipoffConfirmed, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationSystemTipoffConfirmed, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationSystemCashWithdrawResultAdapter extends ImNotificationAdapter{

  ImNotificationSystemCashWithdrawResultAdapter._internal();
  static final ImNotificationSystemCashWithdrawResultAdapter _instance = ImNotificationSystemCashWithdrawResultAdapter._internal();
  factory ImNotificationSystemCashWithdrawResultAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationSystemCashWithdrawResult){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationSystemCashwithdrawResult, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationSystemCashwithdrawResult, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationSystemCashwithdrawResult, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}

class ImNotificationSystemMerchantApplyResultAdapter extends ImNotificationAdapter{

  ImNotificationSystemMerchantApplyResultAdapter._internal();
  static final ImNotificationSystemMerchantApplyResultAdapter _instance = ImNotificationSystemMerchantApplyResultAdapter._internal();
  factory ImNotificationSystemMerchantApplyResultAdapter(){
    return _instance;
  }

  @override
  Future save(ImNotification notification, DatabaseExecutor txn, Batch batch) async{
    if(notification is ImNotificationSystemMerchantApplyResult){
      await super.save(notification, txn, batch);
      List<Map<String, Object?>> savedList = await txn.query(ChatNotificationStorage._tableNotificationSystemMerchantApplyResult, where: 'nid = ${notification.id}', limit: 1);
      if(savedList.isEmpty){
        batch.insert(ChatNotificationStorage._tableNotificationSystemMerchantApplyResult, notification.toExtraSqlMap());
      }
      else{
        batch.update(ChatNotificationStorage._tableNotificationSystemMerchantApplyResult, notification.toExtraSqlMap(), where: 'nid = ${notification.id}');
      }
    }
  }
}
