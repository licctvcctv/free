
import 'package:freego_flutter/components/video/download/video_download.dart';
import 'package:sqflite/sqflite.dart';

class VideoSqflite{
  static const String dbName = 'video_offline';
  static const String tableName = 'video_offline';
  static Database? db;

  static void close(){
    db?.close();
    db = null;
  }

  static Future<Database?> init() async{
    String path = await getDatabasesPath();
    path = '$path/$dbName';
    db = await openDatabase(path, version: 1, onCreate: (db, ver) async{
      await db.execute('''
        create table video_offline(
          id integer primary key,
          user_id integer,
          pic text,
          title text,
          description text,
          path text,
          local_path text,
          local_save_time integer,
          status integer,
          current_progress integer,
          total_progress integer
        )
      ''');
      await db.execute('''
        create index video_offline_local_save_time on video_offline(local_save_time)
      ''');
    });
    return db;
  }

  static Future<Database> get database async{
    if(db != null && db!.isOpen){
      return db!;
    }
    db = await init();
    return db!;
  }

  static Future<List<VideoOffline>> search(int pageNum, int pageSize, DateTime endTime) async{
    int timeStamp = endTime.millisecondsSinceEpoch;
    int offset = (pageNum - 1) * pageSize;
    Database db = await database;
    List<Map<String, dynamic>> list = await db.query(tableName, where: 'local_save_time < $timeStamp', orderBy: "local_save_time desc", limit: pageSize, offset: offset);
    List<VideoOffline> result = [];
    for(Map<String, dynamic> item in list){
      result.add(VideoOffline.fromSqfliteJson(item));
    }
    return result;
  }

  static Future saveVideo(VideoOffline videoOffline) async{
    Database db = await database;
    return db.insert(tableName, videoOffline.toSqfliteJson());
  }

  static Future<VideoOffline?> getById(int id) async{
    Database db = await database;
    List<Map<String, dynamic>> list = await db.query(tableName, where: 'id = $id', limit: 1);
    if(list.isEmpty){
      return null;
    }
    else{
      return VideoOffline.fromSqfliteJson(list[0]);
    }
  }

  static Future remove(int id) async{
    Database db = await database;
    return db.delete(tableName, where: 'id = $id');
  }

  static Future removeBySet(Set<int> set) async{
    if(set.isEmpty){
      return;
    }
    Database db = await database;
    String cond = set.join(',');
    return db.delete(tableName, where: 'id in ($cond)');
  }

  static Future setStatus(int id, int status) async{
    Database db = await database;
    Map<String, dynamic> map = {
      'status': status
    };
    return db.update(tableName, map, where: 'id = $id');
  }

  static Future finishDownload(int id, int total) async{
    Database db = await database;
    Map<String, dynamic> map = {
      'status': VideoOffline.STATUS_DOWNLOADED,
      'current_progress': total,
      'total_progress': total
    };
    return db.update(tableName, map, where: 'id = $id');
  }

}
