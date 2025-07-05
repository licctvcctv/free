
import 'package:freego_flutter/model/user.dart';
import 'package:freego_flutter/components/friend_neo/user_friend.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:sqflite/sqflite.dart';

class FriendStorage{

  static const String _dbname = 'freego_friend';
  static const String _tableFriend = 'user_friend';
  static Database? db;
  static final _MyAfterLogoutHandler _afterLogoutHandler = _MyAfterLogoutHandler();
  
  static Future saveFriends(List<UserFriend> friends) async{
    Database db = await database;
    return db.transaction((txn) async{
      await txn.delete(_tableFriend);
      Batch batch = txn.batch();
      for(UserFriend friend in friends){
        List<Map<String, Object?>> savedList = await txn.query(_tableFriend, where: 'friend_id = ${friend.friendId}');
        if(savedList.isEmpty){
          batch.insert(_tableFriend, friend.toSqlMap());
        }
        else{
          batch.update(_tableFriend, friend.toSqlMap(), where: 'friend_id = ${friend.friendId}');
        }
      }
      return batch.commit();
    });
  }

  static Future<List<UserFriend>> getFriends() async{
    Database db = await database;
    List<Map<String, Object?>> list = await db.query(_tableFriend,);
    List<UserFriend> result = [];
    for(Map<String, Object?> map in list){
      result.add(UserFriend.fromSqlMap(map));
    }
    return result;
  }

  static Future<Database?> init() async{
    LocalUser.addAfterLogoutHandler(_afterLogoutHandler);
    int? userId = LocalUser.getUser()?.id;
    if(userId == null){
      throw Exception('用户未登录');
    }
    String path = await getDatabasesPath();
    path = '$path/${_dbname}_$userId';
    db = await openDatabase(path, version: 1, onCreate: (db, ver) async{
      await db.execute('''
        create table user_friend(
          id integer,
          user_id integer,
          friend_id integer,
          friend_remark text,
          friend_group text,
          create_time integer,
          update_time integer,
          head text,
          name text
        )
      ''');
    });
    db!.delete(_tableFriend);
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
    db?.close();
    db = null;
  }
}

class _MyAfterLogoutHandler implements AfterLogoutHandler{

  @override
  void handle(UserModel user) {
    FriendStorage.close();
  }
  
}
