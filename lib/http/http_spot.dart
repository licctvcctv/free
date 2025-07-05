import "package:dio/dio.dart";
import "package:freego_flutter/http/http_tool.dart";
import "package:freego_flutter/model/order.dart";
import "package:freego_flutter/model/spot.dart";
import "package:freego_flutter/model/spot_ticket_price.dart";
import "package:freego_flutter/model/user.dart";
import "package:freego_flutter/util/date_time_util.dart";
import "package:freego_flutter/util/pager.dart";
import "../model/order_customer.dart";
import "http.dart";

class HttpSpot {

  static Future<Order?> bookTicket(int ticketId, {required DateTime visitDate, required int bookNum, required List<OrderCustomer> customerList, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/spot/ticket/book';
    List<Map<String, dynamic>> customerMap = [];
    for(OrderCustomer item in customerList){
      customerMap.add(item.toJson());
    }
    Order? order = await HttpTool.post(url, {
      'ticketId': ticketId,
      'visitDate': DateTimeUtil.toYMD(visitDate),
      'bookNum': bookNum,
      'customerList': customerMap
    }, (response){
      Order order = Order.fromJson(response.data['data']);
      return order;
    }, fail: fail, success: success);
    return order;
  }

  static Future<List<SpotTicketPriceModel>?> getTicketPriceList(int ticketId, {required DateTime startDate, required DateTime endDate, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/spot/ticket/price';
    List<SpotTicketPriceModel>? list = await HttpTool.get(url, {
      'ticketId': ticketId,
      'startDate': startDate,
      'endDate': endDate
    }, (response){
      List<SpotTicketPriceModel> list = [];
      for(dynamic item in response.data['data']){
        list.add(SpotTicketPriceModel.fromJson(item));
      }
      return list;
    }, fail: fail, success: success);
    return list;
  }

  static Future<Pager<SpotModel>?> searchSpot(String keyword, {int limit = 10, int offset = 0, DateTime? endTime, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/spot/search';
    Pager<SpotModel>? pager = await HttpTool.get(url, {
      'keyword': keyword,
      'limit': limit,
      'offset': offset,
      'endTime': endTime?.toFormat('yyyy-MM-dd HH:mm:ss')
    }, (response){
      List<SpotModel> list = [];
      for(dynamic item in response.data['data']['list']){
        list.add(SpotModel.fromJson(item));
      }
      return Pager(list, response.data['data']['total']);
    }, fail: fail, success: success);
    return pager;
  }

  static Future<SpotModel?> getDetail(int spotId, {Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/spot/detail';
    SpotModel? spot = await HttpTool.get(url, {
      'id': spotId
    }, (response){
      SpotModel spot = SpotModel.fromJson(response.data['data']);
      return spot;
    }, fail: fail, success: success);
    return spot;
  }

  static final dio = Dio();
  static const searchUrl = URL_BASE_HOST + '/spot/search';
  static const detailUrl = URL_BASE_HOST + '/spot/detail';
  static const ticketsUrl = URL_BASE_HOST + '/spot/tickets';
  static const ticketPricesUrl = URL_BASE_HOST + '/spot/ticketPrices';
  static const spotBook = URL_BASE_HOST + '/spot/book';

  static search(String? keyword, int page, OnDataResponse callback) async {
    final response = await dio.post(searchUrl,
        data: {'keyword': keyword, 'pageSize': 8, 'page': page},
        options: Options(headers: {'contentType': 'application/json'}));
    try {
      if (response.statusCode != 200) {
        throw "网络请求错误";
      }
      if (response.data == null) {
        throw "网络请求错误";
      }
      if (response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    } catch (e) {
      callback(false, null, e.toString(), 0);
      return;
    }
    callback(true, response.data['data'], null, 0);
  }

  static detail(int id, OnDataResponse callback) async {
    final response = await dio.get(detailUrl,
        queryParameters: {'id': id},
        options: Options(headers: {'contentType': 'application/json'}));
    try {
      if (response.statusCode != 200) {
        throw "网络请求错误";
      }
      if (response.data == null) {
        throw "网络请求错误";
      }
      if (response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    } catch (e) {
      callback(false, null, e.toString(), 0);
      return;
    }
    callback(true, response.data['data'], null, 0);
  }

  static tickets(int id, OnDataResponse callback) async {
    final response = await dio.get(ticketsUrl,
        queryParameters: {'id': id},
        options: Options(headers: {'contentType': 'application/json'}));
    try {
      if (response.statusCode != 200) {
        throw "网络请求错误";
      }
      if (response.data == null) {
        throw "网络请求错误";
      }
      if (response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    } catch (e) {
      callback(false, null, e.toString(), 0);
      return;
    }
    callback(true, response.data['data'], null, 0);
  }

  static getTicketPrices(int ticketId, OnDataResponse callback) async {
    final response = await dio.get(ticketPricesUrl,
        queryParameters: {'id': ticketId},
        options: Options(headers: {'contentType': 'application/json'}));
    try {
      if (response.statusCode != 200) {
        throw "网络请求错误";
      }
      if (response.data == null) {
        throw "网络请求错误";
      }
      if (response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    } catch (e) {
      callback(false, null, e.toString(), 0);
      return;
    }
    callback(true, response.data['data'], null, 0);
  }

  static book(int ticketId, String day, int bookNum,
      List<OrderCustomer> customerList, OnDataResponse callback) async {
    List<Map<String, dynamic>> customers = [];
    for (var i = 0; i < customerList.length; i++) {
      customers.add({
        'name': customerList[i].name,
        'identityNum': customerList[i].identityNum,
        'phone': customerList[i].phone
      });
    }

    String? userToken = await UserModel.getUserToken();
    final response = await dio.post(spotBook,
        data: {
          'ticketId': ticketId,
          'bookNum': bookNum,
          'day': day,
          'customerList': customers
        },
        options: Options(
            headers: {'contentType': 'application/json', 'token': userToken}));

    try {
      if (response.statusCode != 200) {
        throw "网络请求错误";
      }
      if (response.data == null) {
        throw "网络请求错误";
      }
      if (response.data['code'] != HTTP_CODE_OK) {
        throw response.data['message'];
      }
    } catch (e) {
      print(888);
      print(e);
      callback(false, null, e.toString(), 0);
      return;
    }
    callback(true, response.data['data'], null, 0);
  }
}
