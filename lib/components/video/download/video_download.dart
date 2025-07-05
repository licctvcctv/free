
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freego_flutter/components/video/download/video_download_util.dart';
import 'package:freego_flutter/components/video/download/video_sqflite.dart';
import 'package:freego_flutter/components/view/common_header.dart';
import 'package:freego_flutter/components/view/custom_indicator.dart';
import 'package:freego_flutter/components/view/notify_empty.dart';
import 'package:freego_flutter/components/view/notify_loading.dart';
import 'package:freego_flutter/components/view/video_player.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/model/user.dart';

final videoOfflineListProvider = StateProvider<List<VideoOffline>>((ref) => []);

class VideoDownloadPage extends ConsumerStatefulWidget{
  const VideoDownloadPage({super.key});
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return VideoDownloadState();
  }

}

class VideoDownloadState extends ConsumerState<VideoDownloadPage>{

  static const int DEFAULT_PAGE_SIZE = 10;
  int pageNum = 1;
  DateTime endTime = DateTime.now();
  bool isLoading = true;
  bool isEmpty = false;
  bool selectMode = false;
  Set<int> selectedVideo = {};

  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () async{
      List<VideoOffline> list = await VideoSqflite.search(pageNum, DEFAULT_PAGE_SIZE, endTime);
      ++pageNum;
      ref.refresh(videoOfflineListProvider.notifier).update((state) => list);
      isLoading = false;
      if(list.isEmpty){
        isEmpty = true;
      }
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0,),
      body: isLoading ?
      const NotifyLoadingWidget() :
      Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(242,245,250,1)
        ),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CommonHeader(
              center: Text('离线视频', style: TextStyle(fontSize: 16, color: Colors.white),),
            ),
            isEmpty ? 
            const NotifyEmptyWidget() : 
            Expanded(
              child: CustomIndicatorWidget(
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getContent(),
                ),
                touchBottom: () async{
                  List<VideoOffline> newList = await VideoSqflite.search(pageNum, DEFAULT_PAGE_SIZE, endTime);
                  ++pageNum;
                  List<VideoOffline> oldList = ref.read(videoOfflineListProvider);
                  oldList.addAll(newList);
                  ref.refresh(videoOfflineListProvider.notifier).update((state) => oldList);
                },
              )
            ),
            Visibility(
              visible: selectMode,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white
                ),
                height: 52,
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        backgroundColor: Colors.white
                      ),
                      onPressed: (){
                        selectMode = false;
                        selectedVideo = {};
                        setState(() {
                        });
                      }, 
                      child: const Text('取消')
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red
                      ),
                      onPressed: () async{
                        await VideoDownloadUtil.remove(selectedVideo, ref);
                        selectMode = false;
                        selectedVideo = {};
                        setState(() {
                        });
                      }, 
                      child: const Text('删除')
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String getSizeStr(int bytes){
    if(bytes < 1024){
      return '${bytes}B';
    }
    if(bytes < 1024 * 1024){
      double val = bytes / 1024.0;
      return '${val.toStringAsFixed(1)}KB';
    }
    if(bytes < 1024 * 1024 * 1024){
      double val = bytes / (1024 * 1024);
      return '${val.toStringAsFixed(1)}MB';
    }
    double val = bytes / (1024 * 1024 * 1024);
    return '${val.toStringAsFixed(1)}GB';
  }

  List<Widget> getContent(){
    List<Widget> widgets = [];
    List<VideoOffline> list = ref.watch(videoOfflineListProvider);
    for(VideoOffline item in list){
      widgets.add(
        getVideoWidget(item)
      );
    }
    return widgets;
  }

  Widget getVideoWidget(VideoOffline videoOffline){
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: (){
        if(selectMode){
          return;
        }
        if(videoOffline.status == VideoOffline.STATUS_DOWNLOADED){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return VideoPlayerPage(videoOffline.localPath!, sourceType: VideoSourceType.local,);
          }));
        }
      },
      onLongPress: (){
        selectMode = true;
        setState(() {
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0xee, 0xee, 0xee, 1),
              offset: Offset(0, 2),
              blurRadius: 2
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: selectMode,
              child: Container(
                height: size.width / 3.8,
                alignment: Alignment.center,
                child: IconButton(
                  style: IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap
                  ),
                  constraints: const BoxConstraints(),
                  onPressed: (){
                    if(selectedVideo.contains(videoOffline.id)){
                      selectedVideo.remove(videoOffline.id);
                    }
                    else{
                      selectedVideo.add(videoOffline.id);
                    }
                    setState(() {
                    });
                  },
                  icon: selectedVideo.contains(videoOffline.id) ?
                  const Icon(Icons.radio_button_checked, color: Colors.grey,) :
                  const Icon(Icons.radio_button_unchecked, color: Colors.grey,),
                )
              )
            ),
            Container(
              width: size.width / 3.8,
              height: size.width / 3.8,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8))
              ),
              child: Image.network(getFullUrl(videoOffline.pic!), fit: BoxFit.cover,),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                height: size.width / 3.8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(videoOffline.title!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis,),
                        const SizedBox(height: 8,),
                        Text(videoOffline.description!, maxLines: 1, overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                    getInfo(videoOffline)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getInfo(VideoOffline item){
    switch(item.status){
      case VideoOffline.STATUS_DOWNLOADED:
        return Text(getSizeStr(item.totalProgress ?? 0));
      case VideoOffline.STATUS_DOWNLOADING:
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(getSizeStr(item.currentProgress ?? 0)),
            const Text('/'),
            Text(getSizeStr(item.totalProgress ?? 0))
          ],
        );
      case VideoOffline.STATUS_NOT_FINISHED:
        return Row(
          children: [
            const Text('下载失败，请点击'),
            TextButton(
              onPressed: (){
                VideoDownloadUtil.reDownload(item, ref);
              }, 
              child: const Text('“重新下载”')
            )
          ],
        );
      case VideoOffline.STATUS_INVALID:
        return const Text('视频已失效');
      case VideoOffline.STATUS_INITED:
        return const Text('正在启动下载');
    }
    return const SizedBox();
  }
}

class VideoOffline with UserMixin{
  int id;
  int? userId;
  String? pic;
  String? title;
  String? description;
  String? path;
  String? localPath;
  DateTime? localSaveTime;
  int? status;
  int? currentProgress;
  int? totalProgress;
  VideoOffline(this.id);

  VideoOffline.fromSqfliteJson(dynamic json): id = json['id']{
    userId = json['user_id'];
    pic = json['pic'];
    title = json['title'];
    description = json['description'];
    path = json['path'];
    localPath = json['local_path'];
    localSaveTime = DateTime.fromMillisecondsSinceEpoch(json['local_save_time']);
    status = json['status'];
    currentProgress = json['current_progress'];
    totalProgress = json['total_progress'];
  }

  Map<String, Object?> toSqfliteJson(){
    Map<String, Object?> map = <String, Object?>{};
    map['id'] = id;
    map['user_id'] = userId;
    map['pic'] = pic;
    map['title'] = title;
    map['description'] = description;
    map['path'] = path;
    map['local_path'] = localPath;
    map['local_save_time'] = localSaveTime?.millisecondsSinceEpoch;
    map['status'] = status;
    map['current_progress'] = currentProgress;
    map['total_progress'] = totalProgress;
    return map;
  }

  static const int STATUS_INITED = 0;
  static const int STATUS_DOWNLOADING = 1;
  static const int STATUS_DOWNLOADED = 2;
  static const int STATUS_NOT_FINISHED = 3;
  static const int STATUS_INVALID = 4;
}

enum VideoOfflineStatus{
  downloading,
  downloaded,
  error,
  invalid
}

extension VideoOfflineStatusExt on VideoOfflineStatus{
  int getNum(){
    switch(this){
      case VideoOfflineStatus.downloading:
        return VideoOffline.STATUS_DOWNLOADING;
      case VideoOfflineStatus.downloaded:
        return VideoOffline.STATUS_DOWNLOADED;
      case VideoOfflineStatus.error:
        return VideoOffline.STATUS_NOT_FINISHED;
      case VideoOfflineStatus.invalid:
        return VideoOffline.STATUS_INVALID;
    }
  }
  static VideoOfflineStatus? getStatus(int num){
    for(VideoOfflineStatus status in VideoOfflineStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}
