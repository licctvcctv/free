
import 'package:freego_flutter/local_storage/local_storage.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageGroup{

  LocalStorageGroup._internal();
  static final LocalStorageGroup _instance = LocalStorageGroup._internal();
  factory LocalStorageGroup(){
    return _instance;
  }

  Future save(LocalGroup group) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_GROUP, where: 'id = ${group.id}', limit: 1);
      if(list.isEmpty){
        await txn.insert(LocalStorage.TABLE_GROUP, group.toSqlMap());
      }
      else{
        await txn.update(LocalStorage.TABLE_GROUP, group.toSqlMap(), where: 'id = ${group.id}',);
      }
    });
  }

  Future<LocalGroup?> get(int id) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_GROUP, where: 'id = $id', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalGroup.fromSqlMap(list.first);
  }
  
  Future<List<LocalGroup>> list() async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_GROUP);
    List<LocalGroup> groups = [];
    for(Map<String, Object?> map in list){
      groups.add(LocalGroup.fromSqlMap(map));
    }
    return groups;
  }

  Future replaceAll(List<LocalGroup> groups) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      Batch batch = txn.batch();
      for(LocalGroup group in groups){
        List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_GROUP, where: 'id = ${group.id}', limit: 1);
        if(list.isEmpty){
          batch.insert(LocalStorage.TABLE_GROUP, group.toSqlMap());
        }
        else{
          batch.update(LocalStorage.TABLE_GROUP, group.toSqlMap(), where: 'id = ${group.id}');
        }
      }
      return batch.commit();
    });
  }

  Future replaceTotal(List<LocalGroup> groups) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      Batch batch = txn.batch();
      for(LocalGroup group in groups){
        List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_GROUP, where: 'id = ${group.id}', limit: 1);
        if(list.isEmpty){
          batch.insert(LocalStorage.TABLE_GROUP, group.toSqlMap());
        }
        else{
          batch.update(LocalStorage.TABLE_GROUP, group.toSqlMap(), where: 'id = ${group.id}');
        }
      }
      StringBuffer where = StringBuffer('id not in (');
      for(LocalGroup group in groups){
        where.write(group.id);
        if(group == groups.last){
          where.write(')');
        }
        else{
          where.write(',');
        }
      }
      batch.delete(LocalStorage.TABLE_GROUP, where: where.toString());
      return batch.commit();
    });
  }
}
