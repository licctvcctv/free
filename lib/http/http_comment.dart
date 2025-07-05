
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/comment.dart';
import 'package:freego_flutter/util/pager.dart';

class HttpComment{

  static Future<Pager<Comment>?> getLatest(int productId, int typeId, {int limit = 10, int offset = 0, int? endId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/latest';
    Pager<Comment>? pager = await HttpTool.get(url, {
      'productId': productId,
      'type': typeId,
      'limit': limit,
      'offset': offset,
      'endId': endId
    }, (response){
      List<Comment> list = toComment(response.data['data']['list']);
      int count = response.data['data']['total'];
      Pager<Comment> pager = Pager(list, count);
      return pager;
    }, fail: fail, success: success);
    return pager;
  }

  static Future<Pager<Comment>?> getOldest(int productId, int typeId, {int limit = 10, int offset = 0, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/oldest';
    Pager<Comment>? pager = await HttpTool.get(url, {
      'productId': productId,
      'type': typeId,
      'limit': limit,
      'offset': offset
    }, (response){
      List<Comment> list = toComment(response.data['data']['list']);
      int count = response.data['data']['total'];
      return Pager(list, count);
    }, fail: fail, success: success);
    return pager;
  }

  static Future<Comment?> create(Comment comment, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/';
    Comment? result = await HttpTool.post(url, comment.toJson(), (response){
      Comment result = Comment.fromJson(response.data['data']);
      return result;
    }, fail: fail, success: success);
    return result;
  } 

  static List<Comment> toComment(dynamic json){
    List<Comment> list = [];
    for(dynamic item in json){
      list.add(Comment.fromJson(item));
    }
    return list;
  }
}
