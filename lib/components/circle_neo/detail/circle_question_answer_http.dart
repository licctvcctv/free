
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question_answer_model.dart';
import 'package:freego_flutter/http/http_tool.dart';

class CircleQuestionAnswerHttp{

  CircleQuestionAnswerHttp._internal();
  static final CircleQuestionAnswerHttp _instance = CircleQuestionAnswerHttp._internal();
  factory CircleQuestionAnswerHttp(){
    return _instance;
  }

  Future<List<CircleQuestionAnswer>?> listHistory({required int questionId, int? maxId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/circle/question/answer/list';
    List<CircleQuestionAnswer>? list = await HttpTool.get(url, {
      'questionId': questionId,
      'limit': limit,
      'maxId': maxId,
      'isDesc': true
    }, (response){
      List<CircleQuestionAnswer> list = [];
      for(dynamic json in response.data['data']){
        list.add(CircleQuestionAnswer.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<List<CircleQuestionAnswer>?> listNew({required int questionId, int? minId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/circle/question/answer/list';
    List<CircleQuestionAnswer>? list = await HttpTool.get(url, {
      'questionId': questionId,
      'limit': limit,
      'minId': minId,
      'isDesc': false
    }, (response){
      List<CircleQuestionAnswer> list = [];
      for(dynamic json in response.data['data']){
        list.add(CircleQuestionAnswer.fromJson(json));
      }
      list.sort((a, b){
        if(b.id == null){
          return -1;
        }
        if(a.id == null){
          return 1;
        }
        return b.id!.compareTo(a.id!);
      });
      return list;
    }, fail: fail, success: success);
    return list;
  }

  Future<CircleQuestionAnswer?> post({required int questionId, required String content, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/circle/question/answer';
    CircleQuestionAnswer? answer = await HttpTool.post(url, {
      'questionId': questionId,
      'content': content,
    }, (response){
      return CircleQuestionAnswer.fromJson(response.data['data']);
    });
    return answer;
  }
}
