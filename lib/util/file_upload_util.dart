import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/huawei_obs_util.dart';
import 'package:video_compress/video_compress.dart'; // 替换为 video_compress

class FileUploadUtil {
  FileUploadUtil._internal();

  static final FileUploadUtil _instance = FileUploadUtil._internal();

  factory FileUploadUtil() => _instance;

  Future<String?> upload({
    required String path,
    String? name,
    ProgressCallback? onSend,
  }) async {
    try {
      // 添加Isolate实现（推荐）
      final compressedPath = await _compressWithIsolate(path);
      final result = await HuaweiObsUtil().directUpload(
        path: compressedPath ?? path,
        onSend: onSend,
      );
      
      // 删除临时文件
      if (compressedPath != null && await File(compressedPath).exists()) {
        await File(compressedPath).delete();
      }
      return result;
    } catch (e) {
      debugPrint('上传失败: $e');
      return null;
    } finally {
      // 清理 video_compress 的资源
      VideoCompress.dispose();
    }
  }

  // 使用Isolate的压缩方法
  Future<String?> _compressWithIsolate(String path) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_isolateCompress, {
      'path': path,
      'sendPort': receivePort.sendPort,
    });
    return await receivePort.first as String?;
  }

  // Isolate中执行的静态方法
  static void _isolateCompress(Map<String, dynamic> params) async {
    final sendPort = params['sendPort'] as SendPort;
    try {
      final result = await _compressVideo(params['path'] as String);
      sendPort.send(result);
    } catch (e) {
      sendPort.send(null);
    }
  }

  // 使用 video_compress 的压缩逻辑
  static Future<String?> _compressVideo(String path) async {
    try {
      // 初始化 video_compress
      await VideoCompress.setLogLevel(0); // 关闭日志
      
      final file = File(path);
      final mediaInfo = await VideoCompress.getMediaInfo(path);
      final isShortVideo = (mediaInfo.duration ?? 0) <= 60;
      // 压缩视频
      final compressedMedia = await VideoCompress.compressVideo(
        path,
        quality: isShortVideo ? VideoQuality.MediumQuality : VideoQuality.LowQuality,
        deleteOrigin: false, // 不删除原文件
      );

      return compressedMedia?.path;
    } catch (e) {
      debugPrint('压缩失败: $e');
      return null;
    }
  }
}


/*import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:freego_flutter/util/huawei_obs_util.dart';

class FileUploadUtil{

  FileUploadUtil._internal();

  static final FileUploadUtil _instance = FileUploadUtil._internal();

  factory FileUploadUtil(){
    return _instance;
  }

  Future<String?> upload({required String path, String? name, ProgressCallback? onSend}) async{
    return HuaweiObsUtil().directUpload(path: path, onSend: onSend);
    //debugPrint('[文件上传] 开始上传，本地路径: $path');
    //final result = await HuaweiObsUtil().directUpload(path: path, onSend: onSend);
    //debugPrint('[文件上传] 上传结果: $result');
    //return result;
  }
}*/
