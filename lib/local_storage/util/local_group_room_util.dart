
import 'package:freego_flutter/components/chat_group/api/group_room_api.dart';
import 'package:freego_flutter/components/chat_group/pojo/im_group_room.dart';
import 'package:freego_flutter/local_storage/local_storage_group_room.dart';
import 'package:freego_flutter/local_storage/model/local_group_room.dart';

class LocalGroupRoomUtil{

  LocalGroupRoomUtil._internal();
  static final LocalGroupRoomUtil _instance = LocalGroupRoomUtil._internal();
  factory LocalGroupRoomUtil(){
    return _instance;
  }

  Future<LocalGroupRoom?> get(int id) async{
    return LocalStorageGroupRoom().get(id);
  }

  Future<LocalGroupRoomVo?> getVo(int groupId) async{
    return LocalStorageGroupRoom().getVoByGroupId(groupId);
  }

  Future<List<LocalGroupRoomVo>> listVo() async{
    return LocalStorageGroupRoom().listAllVo();
  }

  Future save(LocalGroupRoom room) async{
    return LocalStorageGroupRoom().save(room);
  }

  Future<LocalGroupRoom?> getLocal(int groupId) async{
    return LocalStorageGroupRoom().getByGroupId(groupId);
  }

  Future<LocalGroupRoom?> getRefreshed(int groupId) async{
    ImGroupRoom? room = await GroupRoomApi().enter(groupId: groupId);
    if(room == null){
      return null;
    }
    LocalGroupRoom localRoom = LocalGroupRoom.fromImGroupRoom(room);
    await save(localRoom);
    return getLocal(groupId);
  }

  Future<LocalGroupRoom?> getIfNull(int groupId) async{
    LocalGroupRoom? room = await getLocal(groupId);
    if(room == null){
      return getRefreshed(groupId);
    }
    return room;
  }

  Future left(int groupId) async{
    return LocalStorageGroupRoom().left(groupId);
  }

  Future delete(int id) async{
    return LocalStorageGroupRoom().delete(id);
  }
}
