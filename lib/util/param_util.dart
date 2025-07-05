
class ParamUtil{

  static Map urlParamToMap(String url){
    Map result = {};
    List<String> list = url.split('&');
    for(String item in list){
      List<String> tuple = item.split('=');
      if(tuple.length != 2){
        throw Exception('wrong format');
      }
      result[tuple[0]] = tuple[1];
    }
    return result;
  }
}
