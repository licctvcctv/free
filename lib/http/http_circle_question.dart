
import "package:dio/dio.dart";
import "package:freego_flutter/model/circle_question.dart";
import "package:freego_flutter/model/user.dart";
import "../model/circle_question.dart";
import "../model/circle_question_answer.dart";
import "http.dart";


class HttpCircleQuestion{

  static final dio = Dio();

  static final saveUrl = URL_BASE_HOST + '/circle/question/save';

  static final detailUrl = URL_BASE_HOST + '/circle/question/detail';

  static final anserUrl = URL_BASE_HOST + '/circle/question/answerSearch';

  static final saveAnswerUrl =  URL_BASE_HOST + '/circle/question/answerSave';

  static final delAnswerUrl =  URL_BASE_HOST + '/circle/question/delAnswer';


  static save(CircleQuestionModel question, OnDataResponse callback) async
  {

    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(saveUrl,data:{
           'cid': question.cid,
           'pics':question.pics,
           'title':question.title,
            'content':question.content,
            'tags':question.tags,
           'location':question.location,
           'lng':question.lng,
           'lat':question.lat,
           'status':question.status
        },
        options: Options(headers: {'contentType': 'application/json','token':userToken}));
    print(response);
    try{
      if(response.statusCode!=200)
      {
        throw "网络请求错误";
      }
      if(response.data==null)
      {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK)
      {
        throw response.data['message'];
      }

    }catch(e)
    {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static detail(int id,OnDataResponse callback) async
  {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.get(detailUrl,queryParameters: {'id':id},options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200)
      {
        throw "网络请求错误";
      }
      if(response.data==null)
      {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK)
      {
        throw response.data['message'];
      }
    }
    catch(e)
    {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static answerSearch(int id,int page, OnDataResponse callback) async
  {
    String? userToken = await UserModel.getUserToken();
    final response =  await dio.post(anserUrl,data:{
      'questionId': id,
      'page':page,

    });

    try{
      if(response.statusCode!=200)
      {
        throw "网络请求错误";
      }
      if(response.data==null)
      {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK)
      {
        throw response.data['message'];
      }
    }
    catch(e)
    {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static saveAnswer(CircleQuestionAnswerModel answer, OnDataResponse callback) async
  {

    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(saveAnswerUrl,data:{
      'content': answer.content,
      'questionId':answer.questionId,
    },
        options: Options(headers: {'contentType': 'application/json','token':userToken}));
    print(response);
    try{
      if(response.statusCode!=200)
      {
        throw "网络请求错误";
      }
      if(response.data==null)
      {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK)
      {
        throw response.data['message'];
      }

    }catch(e)
    {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }

  static delAnswer(int id,OnDataResponse callback) async
  {
    String? userToken = await UserModel.getUserToken();
    final response = await dio.get(delAnswerUrl,queryParameters: {'id':id},options: Options(headers: {'contentType': 'application/json','token':userToken}));
    try{
      if(response.statusCode!=200)
      {
        throw "网络请求错误";
      }
      if(response.data==null)
      {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK)
      {
        throw response.data['message'];
      }
    }
    catch(e)
    {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }


}