
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/product_question.dart';
import 'package:freego_flutter/util/pager.dart';

class HttpProductQuestion{

  static Future<Pager<ProductQuestion>?> getLatest(int productId, int productType, {int limit = 10, int offset = 0, int? endId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question/latest';
    Pager<ProductQuestion>? pager = await HttpTool.get(url, {
      'productId': productId,
      'productType': productType,
      'limit': limit,
      'offset': offset,
      'endId': endId
    }, (response){
      List<ProductQuestion> list = toQuestionList(response.data['data']['list']);
      int count = response.data['data']['total'];
      return Pager(list, count);
    }, fail: fail, success: success);
    return pager;
  }

  static Future<Pager<ProductQuestion>?> getOldest(int productId, int productType, {int limit = 10, int offset = 0, int? endId, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question/oldest';
    Pager<ProductQuestion>? pager = await HttpTool.get(url, {
      'productId': productId,
      'productType': productType,
      'limit': limit,
      'offset': offset
    }, (response){
      List<ProductQuestion> list = toQuestionList(response.data['data']['list']);
      int count = response.data['data']['total'];
      return Pager(list, count);
    }, fail: fail, success: success);
    return pager;
  }

  static Future<bool> createQuestion(ProductQuestion question, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question';
    bool? result = await HttpTool.post(url, question.toJson(), (response){
      int id = response.data['data'];
      question.id = id;
      return true;
    });
    return result ?? false;
  }

  static List<ProductQuestion> toQuestionList(dynamic json){
    List<ProductQuestion> list = [];
    for(dynamic item in json){
      list.add(ProductQuestion.fromJson(item));
    }
    return list;
  }
}
