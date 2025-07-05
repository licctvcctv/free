
import 'package:freego_flutter/local_storage/local_storage.dart';
import 'package:freego_flutter/local_storage/model/local_group_room.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageGroupRoom{

  LocalStorageGroupRoom._internal();
  static final LocalStorageGroupRoom _instance = LocalStorageGroupRoom._internal();
  factory LocalStorageGroupRoom(){
    return _instance;
  }

  Future<LocalGroupRoomVo?> getVoByGroupId(int groupId) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.rawQuery('''
      select group_room.id, group_room.group_id, `group`.name group_name, `group`.remark group_remark, group_room.member_rank, group_room.member_id,
      group_room.member_remark, group_room.member_role, group_room.join_time, group_room.leave_time, group_room.is_left,
      group_room.last_message_id, group_room.last_message_sender_type, group_room.last_message_content, group_room.last_message_type,
      group_room.last_message_time, group_room.unread_num, group_room.not_disturb, group_room.last_update_time
      from group_room inner join `group` on (group_room.group_id = `group`.id)
      where `group`.id = $groupId limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return LocalGroupRoomVo.fromSqlMap(list.first);
  }

  Future<List<LocalGroupRoomVo>> listAllVo() async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.rawQuery('''
      select group_room.id, group_room.group_id, `group`.name group_name, `group`.remark group_remark, group_room.member_rank, group_room.member_id,
      group_room.member_remark, group_room.member_role, group_room.join_time, group_room.leave_time, group_room.is_left,
      group_room.last_message_id, group_room.last_message_sender_type, group_room.last_message_content, group_room.last_message_type,
      group_room.last_message_time, group_room.unread_num, group_room.not_disturb, group_room.last_update_time
      from group_room inner join `group` on (group_room.group_id = `group`.id)
    ''');
    List<LocalGroupRoomVo> rooms = [];
    for(Map<String, Object?> map in list){
      rooms.add(LocalGroupRoomVo.fromSqlMap(map));
    }
    return rooms;
  }

  Future save(LocalGroupRoom room) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_GROUP_ROOM, where: 'id = ${room.id}', limit: 1);
      if(list.isEmpty){
        await txn.insert(LocalStorage.TABLE_GROUP_ROOM, room.toSqlMap());
      }
      else{
        await txn.update(LocalStorage.TABLE_GROUP_ROOM, room.toSqlMap(), where: 'id = ${room.id}');
      }
    });
  }

  Future<LocalGroupRoom?> get(int id) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_GROUP_ROOM, where: 'id = $id', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalGroupRoom.fromSqlMap(list.first);
  }

  Future<LocalGroupRoom?> getByGroupId(int groupId) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_GROUP_ROOM, where: 'group_id = $groupId', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalGroupRoom.fromSqlMap(list.first);
  }

  Future left(int groupId) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_GROUP_ROOM, where: 'group_id = $groupId', limit: 1);
      if(list.isEmpty){
        return null;
      }
      LocalGroupRoom room = LocalGroupRoom.fromSqlMap(list.first);
      if(room.isLeft == true){
        return null;
      }
      room.isLeft = true;
      return txn.update(LocalStorage.TABLE_GROUP_ROOM, room.toSqlMap(), where: 'id = ${room.id}');
    });
  }

  Future delete(int id) async{
    Database db = await LocalStorage().getDb();
    return db.delete(LocalStorage.TABLE_GROUP_ROOM, where: 'id = $id');
  }
}
