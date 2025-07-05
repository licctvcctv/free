
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/chat_group/api/group_room_api.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/local_storage/model/local_group_room.dart';
import 'package:freego_flutter/local_storage/util/local_group_room_util.dart';
import 'package:freego_flutter/local_storage/util/local_group_util.dart';
import 'package:freego_flutter/mixin/listeners_mixin.dart';

class GroupRoomHelper with ListenersMixin<GroupRoomMetaChangeHandler>{
  
  GroupRoomHelper._internal();
  static final GroupRoomHelper _instance = GroupRoomHelper._internal();
  factory GroupRoomHelper(){
    return _instance;
  }

  Future<bool> update({required int id, String? groupRemark, String? memberRemark, Function(Response)? fail, Function(Response)? success}) async{
    bool result = await GroupRoomApi().update(id: id, groupRemark: groupRemark, memberRemark: memberRemark, fail: fail, success: success);
    if(result){
      LocalGroupRoom? room = await LocalGroupRoomUtil().get(id);
      if(room != null && room.groupId != null){
        await LocalGroupRoomUtil().getRefreshed(room.groupId!);
        LocalGroup? group = await LocalGroupUtil().get(id);
        if(group != null){
          group.remark = groupRemark;
          group.lastUpdateTime = DateTime.now();
          await LocalGroupUtil().save(group);
        }
        LocalGroupRoomVo? vo = await LocalGroupRoomUtil().getVo(room.groupId!);
        if(vo != null){
          for(GroupRoomMetaChangeHandler handler in listenerList){
            handler.handle(vo);
          }
        }
      }
    }
    return result;
  }
}

abstract class GroupRoomMetaChangeHandler{

  void handle(LocalGroupRoomVo room);
}
