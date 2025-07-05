
import "package:dio/dio.dart";
import "http.dart";


class HttpCustomer{

  static final dio = Dio();
  static const customerDetailUrl = '${URL_BASE_HOST}/customer/detail';

  static customerDetail(int userId,OnDataResponse callback) async {
    final response = await dio.get(customerDetailUrl, queryParameters:{'userId': userId}, options: Options(headers: {'contentType': 'application/json'}));
    try{
      if(response.statusCode!=200) {
        throw "网络请求错误";
      }
      if(response.data==null) {
        throw "网络请求错误";
      }
      if(response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
      // if(response.data[''])
    }
    catch(e) {
      callback(false,null,e.toString(),0);
      return;
    }
    callback(true,response.data['data'],null,0);
  }
}
