
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/local_file_util.dart';
import 'package:freego_flutter/util/md5_util.dart';

class HuaweiObsUtil{

  HuaweiObsUtil._internal();

  static final HuaweiObsUtil _instance = HuaweiObsUtil._internal();
  static final Dio _dio = Dio();

  factory HuaweiObsUtil(){
    return _instance;
  }

  Future<String?> getUploadUrl({String? contentType, String? contentMd5, int? contentLength, String? extension, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/file/obs/uploadUrl';
    String? signedUrl = await HttpTool.get(url, {
      'contentType': contentType,
      'contentMd5': contentMd5,
      'contentLength': contentLength,
      'extension': extension
    }, (response){
      return response.data['data'];
    }, fail: fail, success: success);
    return signedUrl;
  }

  Future<String?> uploadFile({required String uploadUrl, String? contentType, String? contentMd5, int? contentLength, required String path, ProgressCallback? onSend}) async{
    File file = File(path);
    contentMd5 ??= await MD5Util().getFileMd5Base64(file);
    Stream stream = file.openRead();

    Response response = await _dio.put(uploadUrl, data: stream, onSendProgress: onSend, options: Options(
      headers: {
        'Content-Type': contentType,
        'Content-MD5': contentMd5,
        'Content-Length': contentLength
      },
    ));

    int? statusCode = response.statusCode;
    if(statusCode != 200){
      return null;
    }
    
    String uriPath = getObjectKeyFromUrl(uploadUrl);
    return URL_OBS_SERVER + uriPath;
  }

  Future<String?> directUpload({Function(Response)? fail, Function(Response)? success, required String path, String? contentType, ProgressCallback? onSend}) async{
    String contentMd5 = await MD5Util().getFileMd5Base64FromPath(path);
    contentType ??= LocalFileUtil.getFileContentType(path);
    String extension = LocalFileUtil.getFileExtension(path);
    int contentLength = File(path).lengthSync();
    String? signedUrl = await getUploadUrl(contentType: contentType, contentMd5: contentMd5, contentLength: contentLength, extension: extension, fail: fail, success: success);
    if(signedUrl == null){
      return null;
    }
    return uploadFile(uploadUrl: signedUrl, path: path, contentType: contentType, contentMd5: contentMd5, contentLength: contentLength, onSend: onSend);
  }

  String getObjectKeyFromUrl(String url){
    Uri uri = Uri.parse(url);
    return uri.path;
  }
}
