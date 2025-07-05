import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileUtil{
  
  static final dio = Dio();
  static String? cacheDir;
  static getCacheDir() async{
    if(cacheDir != null){
      return cacheDir;
    }
    final directory = await getTemporaryDirectory();
    cacheDir = directory.path;
    return cacheDir;
  }

  static Future download(String url, String savePath) async {
    try {
      Response response = await dio.get(
        url,
        // onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) { return status! < 500; }
        ),
      );

      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      //
    }
  }

}