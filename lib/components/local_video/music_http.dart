
import 'package:freego_flutter/components/local_video/music_model.dart';
import 'package:freego_flutter/http/http_tool.dart';

class MusicHttp{

  MusicHttp._internal();
  static final MusicHttp _instance = MusicHttp._internal();
  factory MusicHttp(){
    return _instance;
  }

  Future<OnlineMusic?> upload(String path) async{
    const String url = '/online_music/upload';
    OnlineMusic? result = await HttpTool.upload(url, path, (response){
      return OnlineMusic.fromJson(response.data['data']);
    });
    return result;
  }

  Future<List<OnlineMusic>?> list({int? maxId, int limit = 10}) async{
    const String url = '/online_music/list';
    List<OnlineMusic>? result = await HttpTool.get(url, {
      'maxId': maxId,
      'limit': limit
    }, (response){
      List<OnlineMusic> list = [];
      for(dynamic item in response.data['data']){
        list.add(OnlineMusic.fromJson(item));
      }
      return list;
    });
    return result;
  }
  
  Future incUseNum(int id) async{
    const String url = '/online_music/inc_use_num';
    await HttpTool.put(url, {
      'id': id
    }, (response){});
  }
}
