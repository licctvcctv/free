
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalStorage{

  static const String TABLE_USER = 'user';
  static const String TABLE_ITEM_TYPE = 'purchase_item_type';
  static const String TABLE_GUIDE = 'guide';

  static const String TABLE_FRIEND = 'friend';
  static const String TABLE_GROUP = 'group';
  static const String TABLE_GROUP_MEMBER = 'group_member';

  static const String TABLE_SINGLE_ROOM = 'single_room';
  static const String TABLE_GROUP_ROOM = 'group_room';

  static const String TABLE_SINGLE_MESSAGE = 'single_message';
  static const String TABLE_GROUP_MESSAGE = 'group_message';

  static const String TABLE_NOTIFICATION_ROOM = 'notification_room';
  static const String TABLE_NOTIFICATION = 'notification';

  LocalStorage._internal();
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage(){
    return _instance;
  }

  static Database? db;

  Future init() async{
    String? path = (await getApplicationDocumentsDirectory()).path;
    path = '$path/database/common';
    db = await openDatabase(path, version: 1, onOpen: (db) async{
      await db.execute('''
        create table if not exists $TABLE_USER(
          id integer,
          name text,
          head_url text,
          head_local_path text,
          last_update_time integer
        )
      ''');
      await db.execute('''
        create index if not exists ${TABLE_USER}_id on $TABLE_USER(id)
      ''');
      await db.execute('''
        create index if not exists ${TABLE_USER}_last_update_time on $TABLE_USER(last_update_time)
      ''');
      await db.execute('''
        create table if not exists $TABLE_ITEM_TYPE(
          id integer,
          name text,
          image_url text,
          image_local_path text,
          last_update_time integer
        )
      ''');
      await db.execute('''
        create index if not exists ${TABLE_ITEM_TYPE}_id on $TABLE_ITEM_TYPE(id)
      ''');
      await db.execute('''
        create index if not exists ${TABLE_ITEM_TYPE}_last_update_time on $TABLE_USER(last_update_time)
      ''');
      await db.execute('''
        create table if not exists $TABLE_GUIDE(
          id integer,
          name text,
          cover_url text,
          cover_local_path text,
          last_update_time integer
        )
      ''');
      await db.execute('''
        create index if not exists ${TABLE_GUIDE}_id on $TABLE_GUIDE(id)
      ''');
      await db.execute('''
        create index if not exists ${TABLE_GUIDE}_last_update_time on $TABLE_GUIDE(last_update_time)
      ''');

      await db.execute('''
        create table if not exists $TABLE_FRIEND(
          id integer,
          user_id integer,
          friend_remark text,
          friend_group text,
          last_update_time integer
        )
      ''');
      await db.execute('''
        create index if not exists ${TABLE_FRIEND}_id on $TABLE_FRIEND(id)
      ''');
      await db.execute('''
        create index if not exists ${TABLE_FRIEND}_last_update_time on $TABLE_FRIEND(last_update_time)
      ''');

      await db.execute('''
        create table if not exists `$TABLE_GROUP`(
          id integer,
          ownner_id integer,
          type text,
          name text,
          description text,
          remark text,
          avatar_url text,
          avatar_local_path text,
          announce text,
          member_count integer,
          rank integer,
          is_banned integer,
          created_at integer,
          last_update_time integer
        )
      ''');
      await db.execute('''
        create index if not exists ${TABLE_GROUP}_id on `$TABLE_GROUP`(id)
      ''');
      await db.execute('''
        create index if not exists ${TABLE_GROUP}_last_update_time on `$TABLE_GROUP`(last_update_time)
      ''');

      await db.execute('''
        create table if not exists $TABLE_GROUP_ROOM(
          id integer,
          group_id integer,
          group_remark text,
          member_rank integer,
          member_id integer,
          member_remark text,
          member_role text,
          join_time integer,
          leave_time integer,
          is_left integer,
          last_message_id integer,
          last_message_sender_type integer,
          last_message_content text,
          last_message_type text,
          last_message_time integer,
          unread_num integer,
          not_disturb integer,
          last_update_time integer
        )
      ''');
      await db.execute('''
        create index if not exists ${TABLE_GROUP_ROOM}_id on $TABLE_GROUP_ROOM(id)
      ''');
      await db.execute('''
        create index if not exists ${TABLE_GROUP_ROOM}_last_update_time on $TABLE_GROUP_ROOM(last_update_time)
      ''');

      await db.execute('''
        create table if not exists $TABLE_GROUP_MEMBER(
          id integer,
          group_id integer,
          member_rank integer,
          member_id integer,
          member_remark text,
          member_role text,
          join_time integer,
          leave_time integer,
          is_left integer,
          last_update_time integer
        )
      ''');
      await db.execute('''
        create index if not exists ${TABLE_GROUP_MEMBER}_id on $TABLE_GROUP_MEMBER(id)
      ''');
      await db.execute('''
        create index if not exists ${TABLE_GROUP_MEMBER}_last_update_time on $TABLE_GROUP_MEMBER(last_update_time)
      ''');
    });
  }

  Future<Database> getDb() async{
    if(db == null){
      await init();
    }
    return db!;
  }
}
