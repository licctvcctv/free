
import 'package:lpinyin/lpinyin.dart';

class ChineseUtil{

  ChineseUtil._internal();
  static final ChineseUtil _instance = ChineseUtil._internal();
  factory ChineseUtil(){
    return _instance;
  }

  int getCodeForChinese(String str){
    int code = str.codeUnitAt(0);
    if(code >= 'a'.codeUnitAt(0) && code <= 'z'.codeUnitAt(0)){
      return code - 'a'.codeUnitAt(0);
    }
    if(code >= 'A'.codeUnitAt(0) && code <= 'Z'.codeUnitAt(0)){
      return code - 'A'.codeUnitAt(0);
    }
    String py = PinyinHelper.getFirstWordPinyin(str);
    code = py.codeUnitAt(0);
    int result = code - 'a'.codeUnitAt(0);
    if(result >= 0 && result < 26){
      return result;
    }
    return 26;
  }
}
