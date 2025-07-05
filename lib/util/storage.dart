import 'package:shared_preferences/shared_preferences.dart';

class Storage{

  static Future removeInfo(String key) async{
    final sp = await SharedPreferences.getInstance();
    sp.remove(key);
  }

  static Future saveInfo<T>(String key, T value) async {
    //需要通过await获取单例对象
    final sp =  await SharedPreferences.getInstance();
    //默认的使用只有如下几种
    switch(value.runtimeType){
      case double:
        return sp.setDouble(key, value as double);
      case int:
        return sp.setInt(key, value as int);
      case String:
        return sp.setString(key, value as String);
      case bool:
        return sp.setBool(key, value as bool);
      case List<String>:
        return sp.setStringList(key, value as List<String>);
    }
  }

  static Future saveString(String key, String value) async {
    //需要通过await获取单例对象
    final sp =  await SharedPreferences.getInstance();
    return sp.setString(key, value);
  }

  static Future readInfo<T>(String key) async {
    final sp = await SharedPreferences.getInstance();
    switch(T){
      case double:
        return sp.getDouble(key);
      case int:
        return sp.getInt(key);
      case String:
        return sp.getString(key);
      case bool:
        return sp.getBool(key);
      case List<String>:
        return sp.getStringList(key);
    }
  }

  static Future saveSearchHistory(String value) async {
    //需要通过await获取单例对象
    final sp =  await SharedPreferences.getInstance();
    List<String>? historyList = sp.getStringList('search_history');
    historyList = historyList ?? [];
    if(historyList.length >= 8) {
      historyList.removeLast();
    }
    if(historyList != null) {
      int existIndex = historyList.indexOf(value);
      if(existIndex!=-1) {
        historyList.removeAt(existIndex);
      }
    }
    historyList.insert(0, value);
    await sp.setStringList('search_history', historyList);
  }
  
  static Future<List<String>?> getSearchHistory() async {
    //需要通过await获取单例对象
    final sp =  await SharedPreferences.getInstance();
    List<String>? historyList =  sp.getStringList('search_history');
    return historyList;
  }

  static Future remove(String key) async {
    final sp =  await SharedPreferences.getInstance();
    sp.remove(key);
  }

}
