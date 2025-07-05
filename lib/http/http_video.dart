
import "package:dio/dio.dart";
import "package:freego_flutter/components/video/download/video_download.dart";
import "package:freego_flutter/http/http_util.dart";
import "package:freego_flutter/model/user.dart";
import 'package:freego_flutter/components/video/video_model.dart';
import "package:freego_flutter/util/storage.dart";
import "package:freego_flutter/util/toast_util.dart";
import "http.dart";


class HttpVideo{

  static final dio = Dio();

  static const moreVideoUrl = URL_BASE_HOST + '/video/recommend';
 // static final  searchVideoUrl = URL_BASE_HOST + 'video/search';
  static const videoSaveUrl = URL_BASE_HOST + '/video/save';
  static const customerVideosUrl = URL_BASE_HOST + '/video/customerVideos';
  static const adminVideoUrl = URL_BASE_HOST + '/video/adminVideos';
  static const SEARCH_SIZE = 8;

  static Future<VideoModel?> getById(int id, {Function(Response)? fail, Function(Response)? success}) async{
    String url = '/video/$id';
    String? token = await UserModel.getUserToken();
    Response response = await httpUtil.get(url, token: token);
    if(response.statusCode != 200 || response.data == null || response.data['code'] != ResultCode.RES_OK){
      if(fail == null){
        ToastUtil.error('查询视频失败');
      }
      else{
        fail(response);
      }
      return null;
    }
    if(success != null){
      success(response);
    }
    VideoModel video = VideoModel.fromJson(response.data['data']);
    return video;
  }

  static Future<bool> reDownload(VideoOffline video, {Function(int, int)? onReceive, Function(Response)? fail, Function(Response)? success}) async{
    Response response = await dio.download(URL_FILE_DOWNLOAD + video.path!, video.localPath!,  onReceiveProgress: onReceive);
    if(response.statusCode != 200){
      if(fail == null){
        ToastUtil.error('下载失败');
      }
      else{
        fail(response);
      }
      return false;
    }
    if(success != null){
      success(response);
    }
    return true;
  }

  static Future<bool> download(VideoModel video, String path, {Function(int, int)? onReceive, Function(Response)? fail, Function(Response)? success}) async{
    Response response = await dio.download(URL_FILE_DOWNLOAD + video.path!, path,  onReceiveProgress: onReceive);
    if(response.statusCode != 200){
      if(fail == null){
        ToastUtil.error('下载失败');
      }
      else{
        fail(response);
      }
      return false;
    }
    if(success != null){
      success(response);
    }
    return true;
  }

  static more(String strategy,List<int>? excluded,OnDataResponse callback) async {
    String? userToken = await Storage.readInfo<String>('user_token');
    final response = await dio.post(
      moreVideoUrl, 
      data: {
        "size": SEARCH_SIZE, 
        'excluded':excluded, 
        "strategy":strategy
      },
      options: Options(
        headers: {
          'contentType': 'application/json',
          'token': userToken
        }
      )
    );
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      callback(true,response.data['data'],null,0);
    } catch(e){
      callback(false,null,e.toString(),0);
    }
  }

  static search(String? keyword, String? city, List<int>? excluded, OnDataResponse callback, {int? offset}) async {
    String? userToken = await Storage.readInfo<String>('user_token');
    final response = await dio.post(
      moreVideoUrl, 
      data:{
        "size": SEARCH_SIZE,
        "strategy": 'search', 
        'keyword': keyword, 
        'city': city, 
        'excluded': excluded,
        'offset': offset
      }, 
      options: Options(
        headers: {
          'contentType': 'application/json',
          'token': userToken
        }
      )
    );
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      // if(response.data[''])
    } catch(e) {
      callback(false,null,e.toString(),0);
    }
    callback(true,response.data['data'],null,0);
  }

  static customerVideos(int userId, OnDataResponse callback) async {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.get(
      customerVideosUrl,
      queryParameters: {'userId':userId},
      options: Options(
        headers: {
          'contentType': 'application/json','token':userToken
        }
      )
    );
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      // if(response.data[''])
    } catch(e) {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static adminVideos(int userId,OnDataResponse callback) async {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(adminVideoUrl, data:{"pageSize":1000,"userId":userId},options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      callback(true,response.data['data'],null,0);
      // if(response.data[''])
    } catch(e) {
      callback(false,null,e.toString(),0);
    }
  }

}
