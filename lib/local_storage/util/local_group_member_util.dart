
import 'package:freego_flutter/components/chat_group/api/group_api.dart';
import 'package:freego_flutter/components/chat_group/pojo/im_group_member.dart';
import 'package:freego_flutter/local_storage/local_storage_group_member.dart';
import 'package:freego_flutter/local_storage/model/local_group_member.dart';
import 'package:freego_flutter/local_storage/util/local_user_util.dart';

class LocalGroupMemberUtil{

  LocalGroupMemberUtil._internal();
  static final LocalGroupMemberUtil _instance = LocalGroupMemberUtil._internal();
  factory LocalGroupMemberUtil(){
    return _instance;
  }

  Future<LocalGroupMember?> get(int groupId, int memberId) async{
    return LocalStorageGroupMember().get(groupId, memberId);
  }

  Future<LocalGroupMemberVo?> getVo(int groupId, int memberId) async{
    LocalGroupMemberVo? vo = await LocalStorageGroupMember().getVo(groupId, memberId);
    return vo;
  }

  Future<LocalGroupMemberVo?> getRefreshed(int groupId, int memberId, {OnMemberHeadDownload? onMemberHeadDownload}) async{
    ImGroupMember? member = await GroupApi().member(groupId: groupId, memberId: memberId);
    if(member == null){
      return null;
    }
    LocalGroupMember localMember = LocalGroupMember.fromImGroupMember(member);
    await LocalStorageGroupMember().save(localMember);
    await LocalUserUtil().get(memberId, onDownloadHead: (count, total) {
      onMemberHeadDownload?.call(localMember, count, total);
    },);
    return LocalStorageGroupMember().getVo(groupId, memberId);
  }

  Future<LocalGroupMemberVo?> getVoIfNull(int groupId, int memberId, {OnMemberHeadDownload? onMemberHeadDownload}) async{
    LocalGroupMemberVo? vo = await LocalStorageGroupMember().getVo(groupId, memberId);
    if(vo == null){
      return getRefreshed(groupId, memberId, onMemberHeadDownload: onMemberHeadDownload);
    }
    return vo;
  }

  Future<List<LocalGroupMemberVo>> listVo(int groupId) async{
    return LocalStorageGroupMember().listVo(groupId);
  }

  Future<List<LocalGroupMemberVo>> listRefreshed(int groupId, {OnMemberHeadDownload? onMemberHeadDownload}) async{
    List<ImGroupMember>? members = await GroupApi().members(groupId: groupId);
    if(members == null){
      return [];
    }
    List<LocalGroupMember> list = [];
    for(ImGroupMember member in members){
      list.add(LocalGroupMember.fromImGroupMember(member));
    }
    await LocalStorageGroupMember().saveList(list);
    for(LocalGroupMember member in list){
      if(member.id == null){
        continue;
      }
      await LocalUserUtil().get(member.id!, onDownloadHead: (count, total){
        onMemberHeadDownload?.call(member, count, total);
      });
    }
    return LocalStorageGroupMember().listVo(groupId);
  }

  Future<List<LocalGroupMemberVo>> listIfEmpty(int groupId, {OnMemberHeadDownload? onMemberHeadDownload}) async{
    List<LocalGroupMemberVo> list = await LocalStorageGroupMember().listVo(groupId);
    if(list.isEmpty){
      return listRefreshed(groupId, onMemberHeadDownload: onMemberHeadDownload);
    }
    return list;
  }
}

typedef OnMemberHeadDownload = Function(LocalGroupMember member, int count, int total);
