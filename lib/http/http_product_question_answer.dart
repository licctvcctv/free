
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/product_question.dart';
import 'package:freego_flutter/util/pager.dart';

class HttpProductQuestionAnswer{

    static Future<Pager<ProductQuestionAnswer>?> getLatest(int questionId, {int limit = 10, int offset = 0, int? endId, Function(Response)? fail, Function(Response)? success}) async{
      const String url = '/product/question/answer/latest';
      Pager<ProductQuestionAnswer>? pager = await HttpTool.get(url, {
        'questionId': questionId,
        'limit': limit,
        'offset': offset,
        'endId': endId
      }, (response){
        List<ProductQuestionAnswer> list = toAnswerList(response.data['data']['list']);
        int count = response.data['data']['total'];
        return Pager(list, count);
      }, fail: fail, success: success);
      return pager;
    }

    static Future<Pager<ProductQuestionAnswer>?> getOldest(int questionId, {int limit = 10, int offset = 0, int? endId, Function(Response)? fail, Function(Response)? success}) async{
      const String url = '/product/question/answer/oldest';
      Pager<ProductQuestionAnswer>? pager = await HttpTool.get(url, {
        'questionId': questionId,
        'limit': limit,
        'offset': offset
      }, (response){
        List<ProductQuestionAnswer> list = toAnswerList(response.data['data']['list']);
        int count = response.data['data']['total'];
        return Pager(list, count);
      }, fail: fail, success: success);
      return pager;
    }

    static Future<bool> createAnswer(ProductQuestionAnswer answer, {Function(Response)? fail, Function(Response)? success}) async{
      const String url = '/product/question/answer';
      bool? result = await HttpTool.post(url, answer.toJson(), (response){
        answer.id = response.data['data'];
        return true;
      });
      return result ?? false;
    }

    static List<ProductQuestionAnswer> toAnswerList(dynamic json){
      List<ProductQuestionAnswer> list = [];
      for(dynamic item in json){
        list.add(ProductQuestionAnswer.fromJson(item));
      }
      return list;
    }
}
