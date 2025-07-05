
import 'dart:io';

import 'package:freego_flutter/components/chat_group/api/group_api.dart';
import 'package:freego_flutter/components/chat_group/pojo/im_group.dart';
import 'package:freego_flutter/local_storage/local_storage_group.dart';
import 'package:freego_flutter/local_storage/model/local_group.dart';
import 'package:freego_flutter/util/file_downloader.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:path_provider/path_provider.dart';

class LocalGroupUtil{

  LocalGroupUtil._internal();
  static final LocalGroupUtil _instance = LocalGroupUtil._internal();
  factory LocalGroupUtil(){
    return _instance;
  }

  Future<LocalGroup?> get(int id) async{
    return LocalStorageGroup().get(id);
  }

  Future<LocalGroup?> getRefreshed(int id) async{
    ImGroup? imGroup = await GroupApi().get(id: id);
    if(imGroup == null){
      return null;
    }
    LocalGroup group = LocalGroup.fromImGroup(imGroup);
    await save(group);
    return get(id);
  }

  Future<LocalGroup?> getIfNull(int id) async{
    LocalGroup? group = await LocalStorageGroup().get(id);
    if(group == null){
      return getRefreshed(id);
    }
    return group;
  }

  Future<List<LocalGroup>> listLocal() async{
    return LocalStorageGroup().list();
  }

  Future save(LocalGroup group, {OnGroupAvatarDownload? onGroupAvatarDownload}) async{
    await LocalStorageGroup().save(group);
    if(group.avatarUrl == null){
      return;
    }
    String? avatarLocalPath = await prepareGroupAvatarPath(group);
    if(avatarLocalPath == null){
      return;
    }
    FileDownloader().download(group.avatarUrl!, avatarLocalPath, onReceive: (count, total) async{
      if(count >= total){
        group.avatarLocalPath = avatarLocalPath;
        await LocalStorageGroup().save(group);
      }
      onGroupAvatarDownload?.call(group, count, total);
    });
  }

  Future<List<LocalGroup>> listRefreshed({OnGroupAvatarDownload? onGroupAvatarDownload}) async{
    List<ImGroup>? groupList = await GroupApi().all();
    if(groupList != null){
      List<LocalGroup> groups = [];
      for(ImGroup group in groupList){
        groups.add(LocalGroup.fromImGroup(group));
      }
      for(LocalGroup group in groups){
        if(group.avatarUrl == null){
          continue;
        }
        String? avatarLocalPath = await prepareGroupAvatarPath(group);
        if(avatarLocalPath == null){
          continue;
        }
        FileDownloader().download(group.avatarUrl!, avatarLocalPath, onReceive: (count, total) async{
          if(count >= total){
            group.avatarLocalPath = avatarLocalPath;
            await LocalStorageGroup().save(group);
          }
          onGroupAvatarDownload?.call(group, count, total);
        });
      }
      await LocalStorageGroup().replaceTotal(groups);
    }
    return listLocal();
  }

  Future<List<LocalGroup>> listIfEmpty({OnGroupAvatarDownload? onGroupAvatarDownload}) async{
    List<LocalGroup> groups = await listLocal();
    if(groups.isEmpty){
      return listRefreshed(onGroupAvatarDownload: onGroupAvatarDownload);
    }
    else{
      return groups;
    }
  }

  Future<String?> prepareGroupAvatarPath(LocalGroup group) async{
    if(group.avatarUrl == null){
      return null;
    }
    String ext = LocalFileUtil.getFileExtension(group.avatarUrl!);
    Directory dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/group/avatar_${group.id}${ext.isNotEmpty ? '.$ext' : ''}';
  }
}

typedef OnGroupAvatarDownload = Function(LocalGroup group, int count, int total);