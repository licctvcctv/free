
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freego_flutter/local_storage/api/local_item_api.dart';
import 'package:freego_flutter/local_storage/local_storage_item.dart';
import 'package:freego_flutter/local_storage/model/local_item.dart';
import 'package:freego_flutter/util/file_downloader.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:path_provider/path_provider.dart';

class LocalItemUtil{

  static const Duration duration = Duration(days: 1);

  LocalItemUtil._internal();
  static final LocalItemUtil _instance = LocalItemUtil._internal();
  factory LocalItemUtil(){
    return _instance;
  }

  Future<LocalItem?> get(int id, {ProgressCallback? onDownloadImage}) async{
    LocalItem? localItem = await LocalStorageItem().get(id);
    bool reget = false;
    if(localItem == null){
      reget = true;
    }
    else{
      DateTime? lastUpdateTime = localItem.lastUpdateTime;
      if(lastUpdateTime == null){
        reget = true;
      }
      else{
        DateTime now = DateTime.now();
        if(now.subtract(duration).isAfter(lastUpdateTime)){
          reget = true;
        }
      }
    }
    if(reget){
      localItem = await LocalItemApi().getSimple(id: id);
      if(localItem != null){
        await save(localItem, onDownloadImage: onDownloadImage);
      }
    }
    return localItem;
  }

  Future save(LocalItem item, {ProgressCallback? onDownloadImage}) async{
    await LocalStorageItem().save(item);
    String? imagePath = await prepareIamgePath(item);
    if(imagePath != null && item.imageUrl != null){
      FileDownloader().download(item.imageUrl!, imagePath, onReceive: (count, total) async{
        if(count >= total){
          item.imageLocalPath = imagePath;
          await LocalStorageItem().save(item);
        }
        onDownloadImage?.call(count, total);
      });
    }
  }

  Future<String?> prepareIamgePath(LocalItem item) async{
    if(item.imageUrl == null){
      return null;
    }
    String ext = LocalFileUtil.getFileExtension(item.imageUrl!);
    Directory dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/item/image_${item.id}${ext.isNotEmpty ? '.$ext' : ''}';
  }
}
