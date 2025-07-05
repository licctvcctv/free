
import 'package:freego_flutter/local_storage/local_storage.dart';
import 'package:freego_flutter/local_storage/model/local_user.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageUser{

  LocalStorageUser._internal();
  static final LocalStorageUser _instance = LocalStorageUser._internal();
  factory LocalStorageUser(){
    return _instance;
  }

  Future<LocalUser?> get(int id) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_USER, where: 'id = $id', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalUser.fromSqlMap(list.first);
  }

  Future save(LocalUser localUser) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_USER, where: 'id = ${localUser.id}', limit: 1);
      if(list.isEmpty){
        await txn.insert(LocalStorage.TABLE_USER, localUser.toSqlMap());
      }
      else{
        await txn.update(LocalStorage.TABLE_USER, localUser.toSqlMap(), where: 'id = ${localUser.id}');
      }
    });
  }
}