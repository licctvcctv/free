
import 'package:dio/dio.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/model/spot_ticket.dart';

class HttpSpotTicket{

  static Future<List<SpotTicketModel>?> searchTickets({int? spotId, double? lat, double? lng, Function(Response)? fail, Function(Response)? success}) async{
    const String url = '/spot/ticket/search';
    List<SpotTicketModel>? list = await HttpTool.get(url, {
      'spotId': spotId,
      'lat': lat,
      'lng': lng
    }, (response){
      List<SpotTicketModel> list = [];
      for(dynamic json in response.data['data']){
        list.add(SpotTicketModel.fromJson(json));
      }
      return list;
    });
    return list;
  }
}
