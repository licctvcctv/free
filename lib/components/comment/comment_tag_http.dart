
import 'package:dio/dio.dart';
import 'package:freego_flutter/components/product_neo/product_common.dart';
import 'package:freego_flutter/http/http_tool.dart';

import 'comment_model.dart';

class CommentTagHttp{

  CommentTagHttp._internal();
  static final CommentTagHttp _instance = CommentTagHttp._internal();
  factory CommentTagHttp(){
    return _instance;
  }

  Future<List<CommentTag>?> listTag({required int productId, required ProductType type, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/comment_tag/list';
    List<CommentTag>? result = await HttpTool.get(url, {
      'productId': productId,
      'productType': type.getNum()
    }, (response){
      List<CommentTag> list = [];
      for(dynamic item in response.data['data']){
        list.add(CommentTag.fromJson(item));
      }
      return list;
    });
    return result;
  } 
}
