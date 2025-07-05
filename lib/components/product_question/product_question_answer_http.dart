
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/product_question/product_question_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class ProductQuestionAnswerHttp{

  ProductQuestionAnswerHttp._internal();
  static final ProductQuestionAnswerHttp _instance = ProductQuestionAnswerHttp._internal();
  factory ProductQuestionAnswerHttp(){
    return _instance;
  }

  Future<List<ProductQuestionAnswer>?> listHistory({required int questionId, int? maxId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question/answer/list';
    List<ProductQuestionAnswer>? result = await HttpTool.get(url, {
      'questionId': questionId,
      'maxId': maxId,
      'limit': limit,
      'isDesc': true
    }, (response){
      List<ProductQuestionAnswer> list = [];
      for(dynamic json in response.data['data']){
        list.add(ProductQuestionAnswer.fromJson(json));
      }
      return list;
    });
    return result;
  }

  Future<List<ProductQuestionAnswer>?> listNew({required int questionId, int? minId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question/answer/list';
    List<ProductQuestionAnswer>? result = await HttpTool.get(url, {
      'questionId': questionId,
      'minId': minId,
      'limit': limit,
      'isDesc': false
    }, (response){
      List<ProductQuestionAnswer> list = [];
      for(dynamic json in response.data['data']){
        list.add(ProductQuestionAnswer.fromJson(json));
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
    });
    return result;
  }

  Future<ProductQuestionAnswer?> post(ProductQuestionAnswer answer, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question/answer';
    ProductQuestionAnswer? result = await HttpTool.post(url, answer.toJson(), (response){
      return ProductQuestionAnswer.fromJson(response.data['data']);
    });
    return result;
  }
}
