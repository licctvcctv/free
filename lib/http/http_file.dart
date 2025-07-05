
import "package:dio/dio.dart";
import "http.dart";


class HttpFile{

  static final dio = Dio();
  static const fileUrl = URL_BASE_HOST + '/file/upload';

  static Future<String?> uploadFile(path, name, {ProgressCallback? onSend}) async {
    FormData formData = FormData.fromMap({
      "file":
      await MultipartFile.fromFile(path, filename:name),
    });
    var response = await dio.post(fileUrl, data: formData, onSendProgress: onSend);
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
      return response.data['data'];
    }
    catch(e) {
       return null;
    }
  }

}
