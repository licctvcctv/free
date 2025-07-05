
import 'package:freego_flutter/local_storage/local_storage.dart';
import 'package:freego_flutter/local_storage/model/local_guide.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorageGuide{

  LocalStorageGuide._internal();
  static final LocalStorageGuide _instance = LocalStorageGuide._internal();
  factory LocalStorageGuide(){
    return _instance;
  }

  Future<LocalGuide?> get(int id) async{
    Database db = await LocalStorage().getDb();
    List<Map<String, Object?>> list = await db.query(LocalStorage.TABLE_GUIDE, where: 'id = $id', limit: 1);
    if(list.isEmpty){
      return null;
    }
    return LocalGuide.fromSqlMap(list.first);
  }

  Future save(LocalGuide localGuide) async{
    Database db = await LocalStorage().getDb();
    return db.transaction((txn) async{
      List<Map<String, Object?>> list = await txn.query(LocalStorage.TABLE_GUIDE, where: 'id = ${localGuide.id}', limit: 1);
      if(list.isEmpty){
        await txn.insert(LocalStorage.TABLE_GUIDE, localGuide.toSqlMap());
      }
      else{
        await txn.update(LocalStorage.TABLE_GUIDE, localGuide.toSqlMap(), where: 'id = ${localGuide.id}');
      }
    });
  }
}