
import 'package:freego_flutter/local_storage/local_storage.dart';
import 'package:freego_flutter/local_storage/model/local_item.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageItem{

  LocalStorageItem._internal();
  static final LocalStorageItem _instance = LocalStorageItem._internal();
  factory LocalStorageItem(){
    return _instance;
  }

  Future<LocalItem?> get(int id) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_ITEM_TYPE, where: 'id = $id', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalItem.fromSqlMap(list.first);
  }

  Future save(LocalItem localItem) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_ITEM_TYPE, where: 'id = ${localItem.id}', limit: 1);
      if(list.isEmpty){
        await txn.insert(LocalStorage.TABLE_ITEM_TYPE, localItem.toSqlMap());
      }
      else{
        await txn.update(LocalStorage.TABLE_ITEM_TYPE, localItem.toSqlMap(), where: 'id = ${localItem.id}');
      }
    });
  }
}