
import 'package:dio/dio.dart';
import 'http.dart' show URL_BASE_HOST;

class HttpUtil{
  late Dio dio;
  HttpUtil(){
    var options = BaseOptions(
      baseUrl: URL_BASE_HOST,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json
    );
    dio = Dio(options);
  }
  Future get(url, {Map<String, dynamic>? data, String? token}){
    Options options = Options();
    if(token != null){
      options.headers = {};
      options.headers!.addAll({'token': token});
    }
    return dio.get(url, queryParameters: data, options: options);
  }
  Future post(url, {Map<String, dynamic>? data, String? token}){
    Options options = Options();
    if(token != null){
      options.headers = {};
      options.headers!.addAll({'token': token});
    }
    return dio.post(url, data: data, options: options);
  }
  Future put(url, {Map<String, dynamic>? data, String? token}){
    Options options = Options();
    if(token != null){
      options.headers = {};
      options.headers!.addAll({'token': token});
    }
    return dio.put(url, data: data, options: options);
  }
  Future delete(url, {Map<String, dynamic>? data, String? token}){
    Options options = Options();
    if(token != null){
      options.headers = {};
      options.headers!.addAll({'token': token});
    }
    return dio.delete(url, data: data, options: options);
  }
  Future download(url, String savePath, {Function(Response p1)? fail, Function(int p1, int p2)? onReceive, Function(Response p1)? success}){
    Options options = Options(
      responseType: ResponseType.bytes,
      followRedirects: false
    );
    return dio.get(url, options: options);
  }
}

final httpUtil = HttpUtil();

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
