
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http.dart';
import 'package:freego_flutter/util/local_user.dart';
import 'package:intl/intl.dart';

enum FileDownloadState{
  prepare,
  suspend,
  downloading,
  done,
  error,
  deleted,
}

class HttpTool{

  late Dio _dio;
  static final HttpTool _httpUtil = HttpTool._internal();

  factory HttpTool(){
    return _httpUtil;
  }
  HttpTool._internal(){
    BaseOptions options = BaseOptions(
      baseUrl: URL_BASE_HOST,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json
    );
    _dio = Dio(options);
  }

  static Future<T?> upload<T>(String url, String path, T? Function(Response response) handler, {String? name,  ProgressCallback? onSend, Function(Response)? fail, Function(Response)? success}) async{
    FormData formData = FormData.fromMap({
      "file":
      await MultipartFile.fromFile(path, filename: name),
    });
    Options options = Options();
    String? token = await LocalUser.getSavedToken();
    if(token != null){
      options.headers = {};
      options.headers!.addAll({'token': token});
    }
    Response response = await _httpUtil._dio.post(url, data: formData, options: options, onSendProgress: onSend);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      fail?.call(response);
      return null;
    }
    else{
        success?.call(response);
      return handler(response);
    }
  } 

  static Future<bool> download(String url, String savePath, {ProgressCallback? onReceive, Function(Response)? fail, Function(Response)? success}) async{
    Response response = await _httpUtil._dio.download(url, savePath, onReceiveProgress: onReceive);
    if(response.statusCode != 200){
      fail?.call(response);
      return false;
    }
    success?.call(response);
    return true;
  }

  // 非本地服务器的GET请求
  static Future<T?> getRemote<T>(String url, Map<String, dynamic> data, T? Function(Response) handler, {Function(Response)? fail, Function(Response)? success}) async{
    return _service(url, 'GET', data, handler, local: false, fail: fail, success: success);
  }

  // 非本地服务器的POST请求
  static Future<T?> postRemote<T>(String url, Map<String, dynamic> data, T? Function(Response) handler, {Function(Response)? fail, Function(Response)? success}) async{
    return _service(url, 'POST', data, handler, local: false, fail: fail, success: success);
  }

  static Future<T?> delete<T>(String url, Map<String, dynamic> data, T? Function(Response response) handler, {Function(Response)? fail, Function(Response)? success}) async{
    return _service(url, 'DELETE', data, handler, fail: fail, success: success);
  }

  static Future<T?> put<T>(String url, Map<String, dynamic> data, T? Function(Response response) handler, {Function(Response)? fail, Function(Response)? success}) async{
    return _service(url, 'PUT', data, handler, fail: fail, success: success);
  }

  static Future<T?> post<T>(String url, Map<String, dynamic> data, T? Function(Response response) handler, {Function(Response)? fail, Function(Response)? success}) async{
    return _service(url, 'POST', data, handler, fail: fail, success: success);
  }

  static Future<T?> get<T>(String url, Map<String, dynamic> data, T? Function(Response response) handler, {Function(Response)? fail, Function(Response)? success}) async{
    return _service(url, 'GET', data, handler, fail: fail, success: success);
  }

  static Future<T?> _service<T>(String url, String method, Map<String, dynamic> data, T? Function(Response response) handler, {bool local = true, Function(Response)? fail, Function(Response)? success}) async{
    Options options = Options();
    String? token = await LocalUser.getSavedToken();
    if(token != null && local){
      options.headers = {};
      options.headers!.addAll({
        'token': token
      });
      options.contentType = "application/json";
    }
    method = method.toUpperCase();
    Response? response;
    switch(method){
      case 'GET':
        response = await _httpUtil._dio.get(url, queryParameters: data, options: options);
        break;
      case 'POST':
        response = await _httpUtil._dio.post(url, data: data, options: options);
        break;
      case 'PUT':
        response = await _httpUtil._dio.put(url, data: data, options: options);
        break;
      case 'DELETE':
        response = await _httpUtil._dio.delete(url, data: data, options: options);
        break;
    }
    if(response == null){
      return null;
    }
    if(response.statusCode != 200 || response.data == null || local && response.data['code'] != ResultCode.RES_OK){
      fail?.call(response);
      return null;
    }
    else{
      success?.call(response);
      return handler(response);
    }
  }
}

class ResultCode{
  static const RES_OK = 10200;
  static const RES_CREATED = 10201;
  static const RES_DOING = 10202;
  static const RES_WRONG_PARAM = 10400;
  static const RES_NOT_AUTHED = 10403;
  static const RES_NOT_FOUND = 10404;
  static const RES_SERVER_ERROR = 10500;
  static const RES_NOT_PRIVILEGED = 10501;
}

extension DateTimeExt on DateTime{

  String toFormat(String format){
    DateFormat formatObj = DateFormat(format);
    return formatObj.format(this);
  }
}
