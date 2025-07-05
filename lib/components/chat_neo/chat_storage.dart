
import 'package:freego_flutter/components/chat_neo/chat_common.dart';
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class ChatStorageSingle{

  static const String _dbname = 'freego_chat_single';
  static const String _tableSingleMessage = 'im_single_message';
  static const String _tableSingleRoom = 'im_single_room';
  static Database? db;
  static final _MyAfterLogoutHandler _afterLogoutHandler = _MyAfterLogoutHandler();
  static int nextMidVal = 1;

  static int get nextMid {
    return nextMidVal++;
  }

  static Future<int> getUnreadCount() async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.rawQuery('select sum(unread_num) sum from $_tableSingleRoom');
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

  static Future<int?> getMaxReceiveId(int roomId) async{
    Database db = await database;
    List<Map<String, Object?>> results = await db.query(_tableSingleMessage, where: 'receive_room_id = $roomId', orderBy: 'id desc', limit: 1);
    if(results.isEmpty){
      return null;
    }
    ImSingleMessage message = ImSingleMessage.fromSqlMap(results[0]);
    return message.id;
  }

  static Future deleteMessage(int localId) async{
    Database db = await database;
    return await db.delete(_tableSingleMessage, where: 'local_id = $localId');
  }

  static Future<ImSingleRoom?> enterRoom(int partnerId) async{
    Database db = await database;
    List<Map<String, Object?>> results = await db.query(_tableSingleRoom, where: 'partner_id = $partnerId');
    if(results.isEmpty){
      return null;
    }
    return ImSingleRoom.fromSqlMap(results[0]);
  }

  static Future updateStatusByLocal(int localId, SendStatus status) async{
    Database db = await database;
    Map<String, Object?> value = {};
    value['send_status'] = status.getNum();
    return await db.update(_tableSingleMessage, value, where: 'local_id = $localId');
  }

  static Future updateStatus(int msgId, SendStatus status) async{
    Database db = await database;
    Map<String, Object?> value = {};
    value['send_status'] = status.getNum();
    return await db.update(_tableSingleMessage, value, where: 'id = $msgId');
  }

  static Future setLocalRead(int roomId) async{
    Database db = await database;
    Map<String, Object?> value = {};
    value['unread_num'] = 0;
    return db.update(_tableSingleRoom, value, where: 'id = $roomId');
  }

  static Future setRemoteRead(int roomId) async{
    Database db = await database;
    return await db.transaction((txn) async{
      List<Map<String, Object?>> msgList = await txn.query(_tableSingleMessage, where: 'send_room_id = $roomId', orderBy: 'id desc', limit: 1);
      int? lastReadId;
      if(msgList.isNotEmpty){
        if(msgList[0]['id'] is int?){
          lastReadId = msgList[0]['id'] as int?;
        }
      }
      Map<String, Object?> value = {};
      value['last_read_id'] = lastReadId;
      return txn.update(_tableSingleRoom, value, where: 'id = $roomId and (last_read_id is null or last_read_id < $lastReadId)');
    });
  }

  static Future setLocalPath(int msgId, String path) async{
    if(msgId == 0){
      return;
    }
    Database db = await database;
    Map<String, Object?> value = {};
    value['local_path'] = path;
    return await db.update(_tableSingleMessage, value, where: 'id = $msgId');
  }

  static Future setSending(int localId, int msgId, DateTime sendTime) async{
    Database db = await database;
    return await db.transaction((txn) async{
      List<Map<String, Object?>> msgList = await txn.query(_tableSingleMessage, where: 'local_id = $localId and id = 0', orderBy: 'local_id, send_time desc', limit: 1);
      if(msgList.isEmpty){
        return null;
      }
      ImSingleMessage message = ImSingleMessage.fromSqlMap(msgList[0]);
      message.id = msgId;
      message.sendTime = sendTime;
      message.sendStatus = SendStatus.sending.getNum();
      await txn.update(_tableSingleMessage, message.toSqlMap(), where: 'local_id = $localId and id = 0');
    });
  }

  static Future updateLatestMessage(ImSingleMessage message) async{
    Database db = await database;
    return await db.transaction((txn) async{
      List<Map<String, Object?>> roomList = await txn.query(_tableSingleRoom, where: '(id = ${message.sendRoomId} or id = ${message.receiveRoomId}) and (last_message_id is null or last_message_id < ${message.id})');
      if(roomList.isEmpty){
        return null;
      }
      ImSingleRoom room = ImSingleRoom.fromSqlMap(roomList[0]);
      room.lastMessageSender = message.sendRoomId == room.id ? SenderType.ownner.getNum() : SenderType.partner.getNum();
      room.lastMessageId = message.id;
      room.lastMessageType = message.type;
      room.lastMessageTime = message.sendTime;
      if(message.receiveRoomId == room.id){
        room.unreadNum = (room.unreadNum ?? 0) + 1;
      }
      String? brief;
      if(message.type == null){
        return null;
      }
      MessageType? messageType = MessageTypeExt.getType(message.type!);
      if(messageType == null){
        return null;
      }
      if(messageType == MessageType.text){
        const int BRIEF_SIZE = 15;
        if(message.content == null){
          return null;
        }
        if(message.content!.length > BRIEF_SIZE){
          brief = '${message.content!.substring(0, BRIEF_SIZE)}...';
        }
        else{
          brief = message.content;
        }
      }
      else if(messageType == MessageType.command || messageType == MessageType.notifyCommand){
        brief = message.content;
      }
      room.lastMessageBrief = brief;
      return await txn.update(_tableSingleRoom, room.toSqlMap(), where: 'id = ${room.id}');
    });
  }

  static Future saveMessage(ImSingleMessage message) async{
    Database db = await database;
    return await db.transaction((txn) async{
      if(message.id == 0){
        return await txn.insert(_tableSingleMessage, message.toSqlMap());
      }
      List<Map<String, Object?>> savedList = await txn.query(_tableSingleMessage, where: 'id = ${message.id}');
      if(savedList.isEmpty){
        return await txn.insert(_tableSingleMessage, message.toSqlMap());
      }
      else{
        return await txn.update(_tableSingleMessage, message.toSqlMap(), where: 'id = ${message.id}');
      }
    });
  }

  static Future saveMessages(List<ImSingleMessage> list) async{
    Database db = await database;
    return await db.transaction((txn) async{
      Batch batch = txn.batch();
      for(ImSingleMessage message in list){
        if(message.id == 0){
          batch.insert(_tableSingleMessage, message.toSqlMap());
          continue;
        }
        List<Map<String, Object?>> savedList = await txn.query(_tableSingleMessage, where: 'id = ${message.id}');
        if(savedList.isEmpty){
          batch.insert(_tableSingleMessage, message.toSqlMap());
        }
        else{
          batch.update(_tableSingleMessage, message.toSqlMap(), where: 'id = ${message.id}');
        }
      }
      await batch.commit();
    });
  }

  static Future saveRooms(List<ImSingleRoom> list) async{
    Database db = await database;
    return db.transaction((txn) async{
      Batch batch = txn.batch();
      for(ImSingleRoom room in list){
        List<Map<String, Object?>> savedList = await txn.query(_tableSingleRoom, where: 'id = ${room.id}', limit: 1);
        if(savedList.isEmpty){
          batch.insert(_tableSingleRoom, room.toSqlMap());
        }
        else{
          ImSingleRoom savedRoom = ImSingleRoom.fromSqlMap(savedList[0]);
          if(savedRoom.lastMessageId == null || room.lastMessageId != null && savedRoom.lastMessageId! < room.lastMessageId!){
            batch.update(_tableSingleRoom, room.toSqlMap(), where: "id = ${room.id}");
          }
        }
      }
      return batch.commit();
    });
  }

  static Future<ImSingleRoom?> getRoom(int roomId) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.query(_tableSingleRoom, where: 'id = $roomId', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return ImSingleRoom.fromSqlMap(list[0]);
  }

  static Future<ImSingleMessage?> getMessage(int msgId) async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.query(_tableSingleMessage, where: 'id = $msgId', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return ImSingleMessage.fromSqlMap(list[0]);
  }

  static Future<List<ImSingleMessage>> getNewReceiveMessageByRoom(int roomId, {int? minId}) async{
    Database db = await database;
    String where = '(receive_room_id = $roomId) and id > 0 ${minId == null ? '' : 'and id > $minId'} and type <> ${MessageType.command.getNum()} and send_status <> ${SendStatus.retracted.getNum()}';
    List<Map<String, Object?>> list = await db.query(_tableSingleMessage, where: where, orderBy: 'id');
    List<ImSingleMessage> result = [];
    for(Map<String, Object?> item in list){
      result.add(ImSingleMessage.fromSqlMap(item));
    }
    return result;
  }

  static Future<ImSingleMessage?> getMessageByLocalId(int localId) async{
    Database db = await database;
    String where = 'local_id = $localId';
    List<Map<String, Object?>> list = await db.query(_tableSingleMessage, where: where, limit: 1);
    if(list.isEmpty){
      return null;
    }
    return ImSingleMessage.fromSqlMap(list.first);
  }

  static Future<List<ImSingleMessage>> getLocalMessageByRoom(int roomId, {int? maxId, int limit = 10, DateTime? sendTime, int? unsentLocalId}) async{
    Database db = await database;
    String where = '''
      (send_room_id = $roomId or receive_room_id = $roomId) 
      and (
        (id > 0 ${maxId == null ? '' : 'and id < $maxId'})
        or (id = 0 ${unsentLocalId == null ? '' : ' and local_id < $unsentLocalId'})
      )
      ${sendTime == null ? '' : 'and send_time <= ${sendTime.millisecondsSinceEpoch}'} 
      and type <> ${MessageType.command.getNum()} 
      and send_status <> ${SendStatus.retracted.getNum()}''';
    List<Map<String, Object?>> list = await db.query(_tableSingleMessage, where: where, orderBy: "send_time desc, id desc", limit: limit);
    List<ImSingleMessage> result = [];
    for(Map<String, Object?> item in list){
      result.add(ImSingleMessage.fromSqlMap(item));
    }
    return result;
  }

  static Future<List<ImSingleRoom>> getLocalRooms() async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.query(_tableSingleRoom, where: 'exists (select id from im_single_message where im_single_message.send_room_id = im_single_room.id or im_single_message.receive_room_id = im_single_room.id limit 1)');
    List<ImSingleRoom> result = [];
    for(Map<String, Object?> item in list){
      result.add(ImSingleRoom.fromSqlMap(item));
    }
    return result;
  }

  static Future<int> getNextMid() async{
    Database db = await database;
    List<Map<String, dynamic>> list = await db.query(_tableSingleMessage, columns: ['local_id'], orderBy: 'local_id desc', limit: 1);
    if(list.isEmpty){
      return 1;
    }
    return list[0]['local_id'] + 1;
  }

  static Future<Database?> init() async{
    LocalUser.addAfterLogoutHandler(_afterLogoutHandler);
    int? userId = LocalUser.getUser()?.id;
    if(userId == null){
      throw Exception('用户未登录');
    }
    String path = (await getApplicationDocumentsDirectory()).path;
    path = '$path/database/${_dbname}_$userId';
    // await deleteDatabase(path);
    db = await openDatabase(path, version: 1, onCreate: (db, ver) async{
      await db.execute(''' 
        create table im_single_message(
          id integer,
          local_id integer,
          send_room_id integer,
          receive_room_id integer,
          sender_type integer,
          viewer_type integer,
          content text,
          type integer,
          url text,
          quote_msg_id integer,
          quote_type integer,
          quote_content text,
          quote_url text,
          send_time integer,
          send_status integer,
          local_path text
        )
      ''');
      await db.execute(''' 
        create index im_single_message_id on im_single_message(id)
      ''');
      await db.execute(''' 
        create index im_single_message_local_id on im_single_message(local_id)
      ''');
      await db.execute(''' 
        create index im_single_message_room on im_single_message(send_room_id, receive_room_id)
      ''');
      await db.execute(''' 
        create table im_single_room(
          id integer,
          ownner_id integer,
          partner_id integer,
          partner_name text,
          partner_head text,
          partner_remark text,
          last_message_sender integer,
          last_message_id integer,
          last_message_type integer,
          last_message_brief text,
          last_message_time integer,
          unread_num integer,
          not_disturb integer,
          last_read_id integer,
          last_sent_id integer,
          create_time integer,
          is_activated integer
        )
      ''');
      await db.execute(''' 
        create index im_single_room_id on im_single_room(id)
      ''');
    });
    // db!.delete(_tableSingleRoom);
    // db!.delete(_tableSingleMessage);
    nextMidVal = await getNextMid();
    return db;
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
    ChatStorageSingle.close();
  }

}
