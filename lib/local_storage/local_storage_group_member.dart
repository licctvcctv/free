
import 'package:freego_flutter/local_storage/local_storage.dart';
import 'package:freego_flutter/local_storage/model/local_group_member.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageGroupMember{

  LocalStorageGroupMember._internal();
  static final LocalStorageGroupMember _instance = LocalStorageGroupMember._internal();
  factory LocalStorageGroupMember(){
    return _instance;
  }

  Future<LocalGroupMember?> get(int groupId, int memberId) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_GROUP_MEMBER, where: 'group_id = $groupId and member_id = $memberId', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalGroupMember.fromSqlMap(list.first);
  }

  Future<List<LocalGroupMemberVo>> listVo(int groupId) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.rawQuery('''
      select group_member.id, group_member.group_id, group_member.member_rank, group_member.member_id,
      user.name member_name, user.head_local_path member_head_local_path, group_member.member_remark, group_member.member_role,
      group_member.join_time, group_member.leave_time, group_member.is_left, group_member.last_update_time
      from group_member left join user on (group_member.member_id = user.id)
      where group_member.group_id = $groupId and (is_left = 0 or is_left is null)
    ''');
    List<LocalGroupMemberVo> members = [];
    for(Map<String, Object?> map in list){
      members.add(LocalGroupMemberVo.fromSqlMap(map));
    }
    return members;
  }

  Future<LocalGroupMemberVo?> getVo(int groupId, int memberId) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.rawQuery('''
      select group_member.id, group_member.group_id, group_member.member_rank, group_member.member_id,
      user.name member_name, user.head_local_path member_head_local_path, group_member.member_remark, group_member.member_role,
      group_member.join_time, group_member.leave_time, group_member.is_left, group_member.last_update_time
      from group_member left join user on (group_member.member_id = user.id)
      where group_member.group_id = $groupId and group_member.member_id = $memberId
      limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return LocalGroupMemberVo.fromSqlMap(list.first);
  }

  Future save(LocalGroupMember member) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_GROUP_MEMBER, where: 'id = ${member.id}', limit: 1);
      if(list.isEmpty){
        return txn.insert(LocalStorage.TABLE_GROUP_MEMBER, member.toSqlMap());
      }
      else{
        return txn.update(LocalStorage.TABLE_GROUP_MEMBER, member.toSqlMap(), where: 'id = ${member.id}');
      }
    });
  }

  Future saveList(List<LocalGroupMember> members) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      Batch batch = txn.batch();
      for(LocalGroupMember member in members){
        List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_GROUP_MEMBER, where: 'id = ${member.id}', limit: 1);
        if(list.isEmpty){
          batch.insert(LocalStorage.TABLE_GROUP_MEMBER, member.toSqlMap());
        }
        else{
          batch.update(LocalStorage.TABLE_GROUP_MEMBER, member.toSqlMap(), where: 'id = ${member.id}');
        }
      }
      return batch.commit();
    });
  }

  Future left(LocalGroupMember member) async{
    if(member.groupId == null || member.memberId == null){
      return;
    }
    Database db = await LocalStorage().getDb();
    LocalGroupMember? saved = await get(member.groupId!, member.memberId!);
    if(saved == null){
      return;
    }
    member.isLeft = true;
    member.lastUpdateTime = DateTime.now();
    return db.update(LocalStorage.TABLE_GROUP_MEMBER, saved.toSqlMap(), where: 'id = ${saved.id}');
  }

}
