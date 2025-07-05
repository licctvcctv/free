
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/hotel_neo/comment/comment_hotel_model.dart';
import 'package:freego_flutter/http/http_tool.dart';

class CommentHotelHttp{

  CommentHotelHttp._internal();
  static final CommentHotelHttp _instance = CommentHotelHttp._internal();
  factory CommentHotelHttp(){
    return _instance;
  }
  
  Future<List<CommentHotel>?> listHistory({required int hotelId, int? maxId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/hotel/list';
    List<CommentHotel>? result = await HttpTool.get(url, {
      'hotelId': hotelId,
      'maxId': maxId,
      'limit': limit,
      'isDesc': true
    }, (response){
      List<CommentHotel> list = [];
      for(dynamic json in response.data['data']){
        list.add(CommentHotel.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<CommentHotel>?> listNew({required int hotelId, int? minId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/hotel/list';
    List<CommentHotel>? result = await HttpTool.get(url, {
      'hotelId': hotelId,
      'minId': minId,
      'limit': limit,
      'isDesc': false
    }, (response){
      List<CommentHotel> list = [];
      for(dynamic json in response.data['data']){
        list.add(CommentHotel.fromJson(json));
      }
      list.sort((a, b){
        if(b.id == null){
          return -1;
        }
        if(a.id == null){
          return 1;
        }
        if(a.id! > b.id!){
          return -1;
        }
        else if(a.id! < b.id!){
          return 1;
        }
        else{
          return 0;
        }
      });
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<Comment?> post({required Comment comment, required CommentHotelRaw raw, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/hotel';
    Comment? result = await HttpTool.post(url, {
      'comment': comment.toJson(),
      'commentHotel': raw.toJson()
    }, (response){
      Comment? result = Comment.fromJson(response.data['data']);
      return result;
    });
    return result;
  }
}
