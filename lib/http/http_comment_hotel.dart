
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/comment_hotel.dart';
import 'package:freego_flutter/util/pager.dart';

class HttpCommentHotel{

  static Future<HotelComment?> postComment(HotelComment hotelComment, {Function(Response)? fail, Function(Response)? success}) async{
    const url = '/hotel/comment';
    HotelComment? result = await HttpTool.post(url, hotelComment.toJson(), (response){
      HotelComment hotelComment = HotelComment.fromJson(response.data['data']);
      return hotelComment;
    });
    return result;
  }

  static Future<Pager<HotelComment>?> getLatest(int hotelId, {int limit = 10, int offset = 0, int? endId, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/hotel/comment/latest';
    Pager<HotelComment>? pager = await HttpTool.get(url, {
      'hotelId': hotelId,
      'limit': limit,
      'offset': offset,
      'endId': endId
    }, (response){
      List<HotelComment> list = toList(response.data['data']['list']);
      int total = response.data['data']['total'];
      return Pager(list, total);
    });
    return pager;
  }

  static Future<Pager<HotelComment>?> getOldest(int hotelId, {int limit = 10, int offset = 0, Function(Response)? fail, Function(Response)? success}) async{
    const url = '/hotel/comment/oldest';
    Pager<HotelComment>? pager = await HttpTool.get(url, {
      'hotelId': hotelId,
      'limit': limit,
      'offset': offset
    }, (response){
      List<HotelComment> list = toList(response.data['data']['list']);
      int total = response.data['data']['total'];
      return Pager(list, total);
    }, fail: fail, success: success);
    return pager;
  }

  static List<HotelComment> toList(dynamic data){
    List<HotelComment> list = [];
    for(dynamic item in data){
      list.add(HotelComment.fromJson(item));
    }
    return list;
  }
}
