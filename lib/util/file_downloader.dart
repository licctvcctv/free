
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/mixin/listeners_mixin.dart';
import 'package:freego_flutter/util/local_file_util.dart';

class FileDownloader{

  FileDownloader._internal();
  static final FileDownloader _instance = FileDownloader._internal();
  factory FileDownloader(){
    return _instance;
  }

  List<FileDownloadTask> taskList = [];

  Future<String?> download(String url, String savePath, {ProgressCallback? onReceive, Function(Response)? fail, Function(Response)? success}) async{
    for(FileDownloadTask task in taskList){
      if(task.savePath == savePath){
        savePath = reformatSavePath(savePath);
      }
    }

    FileDownloadTask task = FileDownloadTask(url, savePath);
    taskList.add(task);
    if(onReceive != null){
      task.addListener(DefaultFileDownloadTaskListener(onReceive));
    }

    await HttpTool.download(
      URL_FILE_DOWNLOAD + url, 
      savePath, 
      onReceive: (int count, int total){
        task.count = count;
        task.total = total;
        List<FileDownloadTaskListener> listenerList = task.listenerList;
        for(FileDownloadTaskListener listener in listenerList){
          listener.handle(count, total);
        }
        if(count >= total){
          task.listenerList.clear();
          taskList.remove(task);
        }
      }, 
      fail: fail, 
      success: success
    );
    return savePath;
  }

  String reformatSavePath(String savePath){
    if(!File(savePath).existsSync()){
      return savePath;
    }
    String purePath = LocalFileUtil.getPathWithoutExtension(savePath);
    String ext = LocalFileUtil.getFileExtension(savePath);
    RegExp suffixExp = RegExp(r'(\d)$');
    if(!suffixExp.hasMatch(purePath)){
      return '$purePath(1).$ext';
    }
    String? match = suffixExp.stringMatch(purePath);
    if(match == null){
      return '$purePath(1).$ext';
    }
    String? numberStr = match.substring(1, match.length - 1);
    int? number = int.tryParse(numberStr);
    if(number == null){
      return '$purePath(1).$ext';
    }
    return '$purePath(${number + 1}).$ext';
  }
}

class FileDownloadTask with ListenersMixin<FileDownloadTaskListener>{

  String? url;
  String? savePath;

  int count = 0;
  int total = 1;

  FileDownloadTask(this.url, this.savePath);

}

abstract class FileDownloadTaskListener{

  void handle(int count, int total);
}

class DefaultFileDownloadTaskListener implements FileDownloadTaskListener{

  final ProgressCallback onReceive;

  const DefaultFileDownloadTaskListener(this.onReceive);
  
  @override
  void handle(int count, int total) {
    onReceive.call(count, total);
  }
}
