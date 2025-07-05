
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/components/video/download/video_download.dart';
import 'package:freego_flutter/components/video/download/video_sqflite.dart';
import 'package:freego_flutter/http/http_video.dart';
import 'package:freego_flutter/components/video/video_model.dart';
import 'package:freego_flutter/util/toast_util.dart';
import 'package:path_provider/path_provider.dart';

class VideoDownloadUtil{

  static Future getList(WidgetRef ref) async{
    List<VideoOffline> list = ref.read(videoOfflineListProvider);
    Directory saveDir = await getApplicationDocumentsDirectory();
    for(VideoOffline item in list){
      if(item.currentProgress! < item.totalProgress!){
        item.status = VideoOffline.STATUS_NOT_FINISHED;
        VideoSqflite.setStatus(item.id, VideoOffline.STATUS_NOT_FINISHED);
      }
      else if(item.status == VideoOffline.STATUS_DOWNLOADED){
        String path = '${saveDir.path}/video_download/${item.id}';
        File file = File(path);
        if(!file.existsSync()){
          item.status = VideoOffline.STATUS_INVALID;
          VideoSqflite.setStatus(item.id, VideoOffline.STATUS_INVALID);
        }
      }
    }
  }

  static Future reDownload(VideoOffline video, WidgetRef ref) async{
    Directory saveDir = await getApplicationDocumentsDirectory();
    String path = '${saveDir.path}/video_download/${video.id}';
    File file = File(path);
    if(file.existsSync()){
      file.deleteSync();
    }

    video.status = VideoOffline.STATUS_INITED;

    HttpVideo.reDownload(video, onReceive: (current, total){
      List<VideoOffline> list = ref.read(videoOfflineListProvider);
      for(VideoOffline item in list){
        if(item.id == video.id){
          item.currentProgress = current;
          item.totalProgress = total;
          if(current >= total){
            item.status = VideoOffline.STATUS_DOWNLOADED;
            VideoSqflite.finishDownload(item.id, total);
          }
          else{
            item.status = VideoOffline.STATUS_DOWNLOADING;
          }
          break;
        }
      }
      ref.refresh(videoOfflineListProvider.notifier).update((state) => list);
    });
  }

  static Future download(VideoModel video, WidgetRef ref) async{
    Directory saveDir = await getApplicationDocumentsDirectory();
    String path = '${saveDir.path}/video_download/${video.id}';
    File file = File(path);
    if(file.existsSync()){
      file.deleteSync();
    }
    if(video.id == null){
      ToastUtil.error('数据错误');
      return;
    }
    VideoOffline videoOffline = VideoOffline(video.id!);
    videoOffline.userId = video.userId;
    videoOffline.pic = video.pic;
    videoOffline.title = video.name;
    videoOffline.description = video.description;
    videoOffline.path = video.path;
    videoOffline.localPath = path;
    videoOffline.localSaveTime = DateTime.now();
    videoOffline.status = VideoOffline.STATUS_INITED;
    videoOffline.currentProgress = 0;
    videoOffline.totalProgress = 0;
    
    List<VideoOffline> list = ref.read(videoOfflineListProvider);
    list.insert(0, videoOffline);
    ref.refresh(videoOfflineListProvider.notifier).update((state) => list);

    VideoSqflite.saveVideo(videoOffline);

    HttpVideo.download(video, path, onReceive: (current, total){
      List<VideoOffline> list = ref.read(videoOfflineListProvider);
      for(VideoOffline item in list){
        if(item.id == video.id){
          item.currentProgress = current;
          item.totalProgress = total;
          if(current >= total){
            item.status = VideoOffline.STATUS_DOWNLOADED;
            VideoSqflite.finishDownload(item.id, total);
          }
          else{
            item.status = VideoOffline.STATUS_DOWNLOADING;
          }
          break;
        }
      }
      ref.refresh(videoOfflineListProvider.notifier).update((state) => list);
    });
  }

  static Future remove(Set<int> set, WidgetRef ref) async{
    List<VideoOffline> list = ref.read(videoOfflineListProvider);
    List<VideoOffline> result = [];
    for(VideoOffline item in list){
      if(!set.contains(item.id)){
        result.add(item);
      }
    }
    ref.refresh(videoOfflineListProvider.notifier).update((state) => result);

    Directory saveDir = await getApplicationDocumentsDirectory();
    for(int id in set){
      String path = '${saveDir.path}/video_download/$id';
      File file = File(path);
      if(!file.existsSync()){
        continue;
      }
      file.deleteSync();
    }

    VideoSqflite.removeBySet(set);
  }
}
