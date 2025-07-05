
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freego_flutter/local_storage/api/local_user_api.dart';
import 'package:freego_flutter/local_storage/local_storage_user.dart';
import 'package:freego_flutter/local_storage/model/local_user.dart';
import 'package:freego_flutter/util/file_downloader.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:path_provider/path_provider.dart';

class LocalUserUtil{

  static const Duration duration = Duration(days: 1);

  LocalUserUtil._internal();
  static final LocalUserUtil _instance = LocalUserUtil._internal();
  factory LocalUserUtil(){
    return _instance;
  }

  Future<LocalUser?> get(int id, {ProgressCallback? onDownloadHead}) async{
    LocalUser? localUser = await LocalStorageUser().get(id);
    bool reget = false;
    if(localUser == null){
      reget = true;
    }
    if(localUser != null){
      DateTime? lastUpdateTime = localUser.lastUpdateTime;
      if(lastUpdateTime == null){
        reget = true;
      }
      if(lastUpdateTime != null){
        DateTime now = DateTime.now();
        if(now.subtract(duration).isAfter(lastUpdateTime)){
          reget = true;
        }
      }
    }
    if(reget){
      localUser = await LocalUserApi().getSimpleUser(id: id);
      if(localUser == null){
        return null;
      }
      await save(localUser, onDownloadHead: onDownloadHead);
    }
    return localUser;
  }

  Future<LocalUser?> getRefreshed(int id, {ProgressCallback? onDownloadHead}) async{
    LocalUser? localUser = await LocalUserApi().getSimpleUser(id: id);
    if(localUser == null){
      return null;
    }
    await save(localUser, onDownloadHead: onDownloadHead);
    return localUser;
  }

  Future<LocalUser?> getIfNull(int id, {ProgressCallback? onDownloadHead}) async{
    LocalUser? localUser = await LocalStorageUser().get(id);
    if(localUser == null){
      return getRefreshed(id, onDownloadHead: onDownloadHead);
    }
    return localUser;
  }

  Future save(LocalUser localUser, {ProgressCallback? onDownloadHead}) async{
    await LocalStorageUser().save(localUser);
    String? headPath = await prepareHeadPath(localUser);
    if(headPath != null && localUser.headUrl != null){
      FileDownloader().download(localUser.headUrl!, headPath, onReceive: (count, total) async{
        if(count >= total){
          localUser.headLocalPath = headPath;
          await LocalStorageUser().save(localUser);
        }
        onDownloadHead?.call(count, total);
      });
    }
  }

  Future<String?> prepareHeadPath(LocalUser user) async{
    if(user.headUrl == null){
      return null;
    }
    String ext = LocalFileUtil.getFileExtension(user.headUrl!);
    Directory dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/user/head_${user.id}${ext.isNotEmpty ? '.$ext' : ''}';
  }

}
