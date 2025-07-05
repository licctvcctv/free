
import 'package:freego_flutter/local_storage/local_storage.dart';
import 'package:freego_flutter/local_storage/model/local_friend.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageFriend{

  LocalStorageFriend._internal();
  static final LocalStorageFriend _instance = LocalStorageFriend._internal();
  factory LocalStorageFriend(){
    return _instance;
  }

  Future<List<LocalFriendVo>> listAllVo() async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.rawQuery('''
      select friend.id, friend.user_id friend_id, user.name friend_name, user.head_local_path friend_head_local,
      friend.friend_remark, friend.friend_group, friend.last_update_time from friend inner join user on (friend.user_id = user.id)
    ''');
    List<LocalFriendVo> friends = [];
    for(Map<String, Object?> map in list){
      friends.add(LocalFriendVo.fromSqlMap(map));
    }
    return friends;
  }

  Future<LocalFriendVo?> getVo(int friendId) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.rawQuery('''
      select friend.id, friend.user_id friend_id, user.name friend_name, user.head_local_path friend_head_local,
      friend.friend_remark, friend.friend_group, friend.last_update_time from friend inner join user on (friend.user_id = user.id)
      where user.id = $friendId limit 1
    ''');
    if(list.isEmpty){
      return null;
    }
    return LocalFriendVo.fromSqlMap(list.first);
  }

  Future save(LocalFriend friend) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      List<Map<String, Object?>> savedList = await txn.query(LocalStorage.TABLE_FRIEND, where: 'id = ${friend.id}', limit: 1);
      if(savedList.isEmpty){
        await txn.insert(LocalStorage.TABLE_FRIEND, friend.toSqlMap());
      }
      else{
        await txn.update(LocalStorage.TABLE_FRIEND, friend.toSqlMap(), where: 'id = ${friend.id}');
      }
    });
  }

  Future<LocalFriend?> get(int id) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_FRIEND, where: 'id = $id', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalFriend.fromSqlMap(list.first);
  }

  Future<LocalFriend?> getByUserId(int userId) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_FRIEND, where: 'user_id = $userId', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalFriend.fromSqlMap(list.first);
  }

  Future remove(int id) async{
    Database db = await LocalStorage().getDb();
    return db.delete(LocalStorage.TABLE_FRIEND, where: 'id = $id');
  }

  Future replaceAll(List<LocalFriend> friends) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      Batch batch = txn.batch();
      for(LocalFriend friend in friends){
        List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_FRIEND, where: 'id = ${friend.id}', limit: 1);
        if(list.isEmpty){
          batch.insert(LocalStorage.TABLE_FRIEND, friend.toSqlMap());
        }
        else{
          batch.update(LocalStorage.TABLE_FRIEND, friend.toSqlMap(), where: 'id = ${friend.id}');
        }
      }
      return batch.commit();
    });
  }

  Future replaceTotal(List<LocalFriend> friends) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      Batch batch = txn.batch();
      for(LocalFriend friend in friends){
        List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_FRIEND, where: 'id = ${friend.id}', limit: 1);
        if(list.isEmpty){
          batch.insert(LocalStorage.TABLE_FRIEND, friend.toSqlMap());
        }
        else{
          batch.update(LocalStorage.TABLE_FRIEND, friend.toSqlMap(), where: 'id = ${friend.id}');
        }
      }
      StringBuffer where = StringBuffer('id not in (');
      for(LocalFriend friend in friends){
        where.write('${friend.id}');
        if(friend == friends.last){
          where.write(')');
        }
        else{
          where.write(',');
        }
      }
      batch.delete(LocalStorage.TABLE_FRIEND, where: where.toString());
      return batch.commit();
    });
  }

}
