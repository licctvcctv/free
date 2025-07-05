
import 'package:freego_flutter/components/product_question/product_question_answer_http.dart';
import 'package:freego_flutter/components/product_question/product_question_common.dart';

class ProductQuestionAnswerUtil{

  ProductQuestionAnswerUtil._internal();
  static final ProductQuestionAnswerUtil _instance = ProductQuestionAnswerUtil._internal();
  factory ProductQuestionAnswerUtil(){
    return _instance;
  }

  List<AfterPostProductQuestionAnswerHandler> handlerList = [];
  bool addHandler(AfterPostProductQuestionAnswerHandler handler){
    if(handlerList.contains(handler)){
      return false;
    }
    handlerList.add(handler);
    return true;
  }
  bool removeHandler(AfterPostProductQuestionAnswerHandler handler){
    return handlerList.remove(handler);
  }

  Future<ProductQuestionAnswer?> post(ProductQuestionAnswer answer) async{
    ProductQuestionAnswer? result = await ProductQuestionAnswerHttp().post(answer);
    if(result == null){
      return null;
    }
    for(AfterPostProductQuestionAnswerHandler handler in handlerList){
      handler.handler(result);
    }
    return result;
  }
}

abstract class AfterPostProductQuestionAnswerHandler{

  void handler(ProductQuestionAnswer answer);
}
