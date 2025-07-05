
import 'package:freego_flutter/components/comment/comment_model.dart';
import 'package:freego_flutter/http/http_tool.dart';

class CommentSubHttp{

  CommentSubHttp._internal();
  static final CommentSubHttp _instance = CommentSubHttp._internal();
  factory CommentSubHttp(){
    return _instance;
  }

  Future<List<CommentSub>?> listHistory({required int commentId, int? maxId, int limit = 10}) async{
    const String url = '/comment_sub/list';
    List<CommentSub>? list = await HttpTool.get(url, {
      'commentId': commentId,
      'maxId': maxId,
      'limit': limit,
      'isDesc': true
    }, (response){
      List<CommentSub> list = [];
      for(dynamic json in response.data['data']){
        list.add(CommentSub.fromJson(json));
      }
      return list;
    });
    return list;
  }

  Future<List<CommentSub>?> listNew({required int commentId, int? minId, int limit = 10}) async{
    const String url = '/comment_sub/list';
    List<CommentSub>? list = await HttpTool.get(url, {
      'commentId': commentId,
      'minId': minId,
      'limit': limit,
      'isDesc': false
    }, (response){
      List<CommentSub> list = [];
      for(dynamic json in response.data['data']){
        list.add(CommentSub.fromJson(json));
      }
      list.sort((a, b){
        if(a.id == null || b.id == null){
          return 0;
        }
        return b.id!.compareTo(a.id!);
      });
      return list;
    });
    return list;
  }

  Future<CommentSub?> post(CommentSub commentSub) async{
    const String url = '/comment_sub';
    CommentSub? result = await HttpTool.post(url, commentSub.toJson(), (response){
      return CommentSub.fromJson(response.data['data']);
    });
    return result;
  }
}