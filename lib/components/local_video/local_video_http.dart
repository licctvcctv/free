
import 'package:freego_flutter/http/http_tool.dart';
import 'package:freego_flutter/components/video/video_model.dart';

class LocalVideoHttp{

  LocalVideoHttp._internal();
  static final LocalVideoHttp _instance = LocalVideoHttp._internal();
  factory LocalVideoHttp(){
    return _instance;
  }

  Future<bool> create(VideoModel video) async{
    const String url = '/video';
    bool? result = await HttpTool.post(url, video.toJson(), (response){
      return true;
    });
    result ??= false;
    return result;
  }
}
