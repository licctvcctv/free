
import 'package:freego_flutter/components/circle_neo/detail/circle_question_answer_http.dart';
import 'package:freego_flutter/components/circle_neo/detail/circle_question_answer_model.dart';

class CircleQuestionAnswerUtil{

  CircleQuestionAnswerUtil._internal();
  static final CircleQuestionAnswerUtil _instance = CircleQuestionAnswerUtil._internal();
  factory CircleQuestionAnswerUtil(){
    return _instance;
  }

  List<AfterPostCircleQuestionAnswerHandler> handlerList = [];
  bool addHandler(AfterPostCircleQuestionAnswerHandler handler){
    if(handlerList.contains(handler)){
      return false;
    }
    handlerList.add(handler);
    return true;
  }
  bool removeHandler(AfterPostCircleQuestionAnswerHandler handler){
    return handlerList.remove(handler);
  }

  Future<CircleQuestionAnswer?> post({required int questionId, required String content}) async{
    CircleQuestionAnswer? answer = await CircleQuestionAnswerHttp().post(questionId: questionId, content: content);
    if(answer != null){
      for(AfterPostCircleQuestionAnswerHandler handler in handlerList){
        handler.handle(answer);
      }
    }
    return answer;
  }
}

abstract class AfterPostCircleQuestionAnswerHandler{

  void handle(CircleQuestionAnswer answer);
}
