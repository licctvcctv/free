
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class CommentHttp{

  CommentHttp._internal();
  static final CommentHttp _instance = CommentHttp._internal();
  factory CommentHttp(){
    return _instance;
  }

  Future<List<Comment>?> listHistoryComment({required int productId, required ProductType type, int? maxId, int? limit = 10, String? tagName}) async{
    const String url = '/comment/list';
    List<Comment>? result = await HttpTool.get(url, {
      'productId': productId,
      'typeId': type.getNum(),
      'maxId': maxId,
      'limit': limit,
      'isDesc': true,
      'tagName': tagName
    }, (response){
      List<Comment> list = [];
      for(dynamic json in response.data['data']){
        list.add(Comment.fromJson(json));
      }
      return list;
    });
    return result;
  }

  Future<List<Comment>?> listNewComment({required int productId, required ProductType type, int? minId, int? limit = 10, String? tagName}) async{
    const String url = '/comment/list';
    List<Comment>? result = await HttpTool.get(url, {
      'productId': productId,
      'typeId': type.getNum(),
      'minId': minId,
      'limit': limit,
      'isDesc': false,
      'tagName': tagName
    }, (response){
      List<Comment> list = [];
      for(dynamic json in response.data['data']){
        list.add(Comment.fromJson(json));
      }
      list.sort((a, b){
        if(a.id == null || b.id == null){
          return 0;
        }
        return b.id!.compareTo(a.id!);
      });
      return list;
    });
    return result;
  }

  Future<Comment?> postComment(Comment comment) async{
    const String url = '/comment';
    Comment? result = await HttpTool.post(url, comment.toJson(), (response){
      Comment comment = Comment.fromJson(response.data['data']);
      return comment;
    });
    return result;
  }

}
