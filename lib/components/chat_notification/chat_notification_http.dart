
import 'package:freego_flutter/components/chat_notification/chat_notification_common.dart';
import 'package:freego_flutter/components/chat_notification/chat_notification_util.dart';
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/util/tuple.dart';

class ChatNotificationHttp{

  static Future<List<ImNotification>?> getHistory(int roomId, {int? maxId, int limit = 10}) async{
    const String url = '/im_notification/history';
    List<ImNotification>? list = await HttpTool.get(url, {
      'roomId': roomId,
      'maxId': maxId,
      'limit': limit
    }, (response){
      List<ImNotification> list = [];
      for(dynamic json in response.data['data']){
        ImNotification? item = ImNotificationConverter.fromJson(json, checked: true);
        if(item != null){
          list.add(item);
        }
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
    });
    return list;
  }

  static Future<Tuple<List<ImNotification>, List<ImNotificationRoom>>?> getUnsentData() async{
    const String url = '/im_notification/unsend_data';
    Tuple<List<ImNotification>, List<ImNotificationRoom>>? tuple = await HttpTool.get(url, {}, (response){
      if(response.data['data'] == null){
        return null;
      }
      List<ImNotificationRoom> roomList = [];
      if(response.data['data']['room'] != null){
        for(dynamic json in response.data['data']['room']){
          roomList.add(ImNotificationRoom.fromJson(json));
        }
      }
      List<ImNotification> notificationList = [];
      if(response.data['data']['notification'] != null){
        for(dynamic json in response.data['data']['notification']){
          ImNotification? item = ImNotificationConverter.fromJson(json);
          if(item != null){
            notificationList.add(item);
          }
        }
      }
      return Tuple(notificationList, roomList);
    });
    return tuple;
  }

  static Future<ImNotificationRoom?> getRoom(int roomId) async{
    const String url = '/im_notification_room';
    ImNotificationRoom? room = await HttpTool.get(url, {
      'id': roomId
    }, (response){
      ImNotificationRoom room = ImNotificationRoom.fromJson(response.data['data']);
      return room;
    });
    return room;
  }
}
