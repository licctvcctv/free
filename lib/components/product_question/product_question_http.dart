
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/components/product_question/product_question_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

class ProductQuestionHttp{

  ProductQuestionHttp._internal();
  static final ProductQuestionHttp _instance = ProductQuestionHttp._internal();
  factory ProductQuestionHttp(){
    return _instance;
  }

  Future<List<ProductQuestion>?> listHistory({required int productId, required ProductType productType, String? keyword, int? maxId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question/list';
    List<ProductQuestion>? result = await HttpTool.get(url, {
      'productId': productId,
      'productType': productType.getNum(),
      'keyword': keyword,
      'maxId': maxId,
      'limit': limit,
      'isDesc': true
    }, (response){
      List<ProductQuestion> list = [];
      for(dynamic json in response.data['data']){
        list.add(ProductQuestion.fromJson(json));
      }
      return list;
    }, fail: fail, success: success);
    return result;
  }

  Future<List<ProductQuestion>?> listNew({required int productId, required ProductType productType, String? keyword, int? minId, int limit = 10, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question/list';
    List<ProductQuestion>? result = await HttpTool.get(url, {
      'productId': productId,
      'productType': productType.getNum(),
      'keyword': keyword,
      'minId': minId,
      'limit': limit,
      'isDesc': false,
    }, (response){
      List<ProductQuestion> list = [];
      for(dynamic json in response.data['data']){
        list.add(ProductQuestion.fromJson(json));
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
    return result;
  }

  Future<ProductQuestion?> post(ProductQuestion question, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/product/question';
    ProductQuestion? result = await HttpTool.post(url, question.toJson(), (response){
      return ProductQuestion.fromJson(response.data['data']);
    });
    return result;
  }

}
