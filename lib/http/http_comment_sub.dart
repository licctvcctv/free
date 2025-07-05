
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/comment.dart';

class HttpCommentSub{

  static Future<List<CommentSub>?> getLatest(int commentId, {int limit = 10, int offset = 0, int? endId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/sub/latest';
    List<CommentSub>? list = await HttpTool.get(url, {
      'commentId': commentId,
      'limit': limit,
      'offset': offset,
      'endId': endId
    }, (response){
      List<CommentSub> list = toCommentSub(response.data['data']);
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<List<CommentSub>?> getOldest(int commentId, {int limit = 10, int offset = 0, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/sub/oldest';
    List<CommentSub>? list = await HttpTool.get(url, {
      'commentId': commentId,
      'limit': limit,
      'offset': offset
    }, (response){
      List<CommentSub> list = toCommentSub(response.data['data']);
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<CommentSub?> create(CommentSub reply, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment/sub';
    CommentSub? result = await HttpTool.post(url, reply.toJson(), (response){
      CommentSub result = CommentSub.fromJson(response.data['data']);
      return result;
    }, fail: fail, success: success);
    return result;
  }

  static List<CommentSub> toCommentSub(dynamic json){
    List<CommentSub> list = [];
    for(dynamic item in json){
      list.add(CommentSub.fromJson(item));
    }
    return list;
  }
}
