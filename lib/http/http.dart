
// const URL_BASE_HOST = 'http://192.168.1.157:9001/';
 const URL_BASE_HOST = 'https://service.freego.freemen.work/';
// const URL_BASE_HOST = 'https://dev.freego.freemen.work/';
// const URL_BASE_HOST = 'http://192.168.1.93:9001';
// const URL_BASE_HOST = 'http://192.168.1.144:9001';
// const URL_BASE_HOST = 'http://192.168.1.50:9001';
// const URL_BASE_HOST = 'http://192.168.24.2:9001/';
// const URL_BASE_HOST = 'http://192.168.0.113:9000/';
// const URL_BASE_HOST = 'http://192.168.1.185:9001';
// const URL_BASE_HOST = 'http://115.120.198.84:9001';

const HTTP_CODE_OK = 10200;
const URL_BASE_FILE_PATH = "$URL_BASE_HOST/file/view";
const URL_FILE_UPLOAD_URL = "$URL_BASE_HOST/file/upload";
const URL_FILE_DOWNLOAD = '$URL_BASE_HOST/file/download';

const URL_OBS_SERVER = "http://io.dev.freego.city";

typedef OnDataResponse = void Function(
    bool isSuccess, Object? data, String? msg, int? code);

class HttpResultObject<T>{
  int code;
  T? object;
  HttpResultObject(this.code, this.object);
}

String getFullUrl(String url){
  if(url.startsWith("http")){
    return url;
  }
  else{
    return '$URL_BASE_FILE_PATH/$url';
  }
}

String getDownloadU(String url){
  if(url.startsWith('http')){
    return url;
  }
  else{
    return '$URL_FILE_DOWNLOAD/$url';
  }
}
