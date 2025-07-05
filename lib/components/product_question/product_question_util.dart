
import 'package:freego_flutter/components/product_question/product_question_common.dart';
import 'package:freego_flutter/components/product_question/product_question_http.dart';

class ProductQuestionUtil{

  ProductQuestionUtil._internal();
  static final ProductQuestionUtil _instance = ProductQuestionUtil._internal();
  factory ProductQuestionUtil(){
    return _instance;
  }

  List<AfterPostQuestionHandler> handlerList = [];
  bool addAfterPostQuestionHandler(AfterPostQuestionHandler handler){
    if(handlerList.contains(handler)){
      return false;
    }
    handlerList.add(handler);
    return true;
  }
  bool removeAfterPostQuestionHandler(AfterPostQuestionHandler handler){
    return handlerList.remove(handler);
  }

  Future<ProductQuestion?> post(ProductQuestion question) async{
    ProductQuestion? result = await ProductQuestionHttp().post(question);
    if(result == null){
      return null;
    }
    for(AfterPostQuestionHandler handler in handlerList){
      handler.handle(result);
    }
    return result;
  }
}

abstract class AfterPostQuestionHandler{

  void handle(ProductQuestion question);
}
