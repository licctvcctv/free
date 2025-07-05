
import 'package:freego_flutter/components/product_neo/product_common.dart';

class StringUtil {
  static bool isNotEmpty(String? str) {
    return str != null && str.isNotEmpty;
  }

  static bool isEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  static String getSizeText(int size){
    if(size <= 0){
      return '0';
    }
    if(size < 1024){
      return '${size}B';
    }
    if(size < 1024 * 1024){
      return '${size ~/ 1024}KB';
    }
    if(size < 1024 * 1024 * 1024){
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  static String getLimitedText(String ori, int limit){
    if(ori.length > limit){
      return '${ori.substring(0, limit - 3)}...';
    }
    return ori;
  }

  static String getCountStr(int count){
    if(count < 10000){
      return count.toString();
    }
    if(count < 100000000){
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    if(count < 100000000 * 10){
      return '${(count / 100000000).toStringAsFixed(1)}亿';
    }
    return '9.9亿+';
  }

  static String getShortPrice(String ori){
    if(ori.endsWith('.00')){
      return ori.substring(0, ori.length - 3);
    }
    else if(ori.contains('.') && ori.endsWith('0')){
      return ori.substring(0, ori.length - 1);
    }
    return ori;
  }

  static String? getPriceStr(num? price) {
    if (price == null) {
      return null;
    }
    double priceD = price / 100.0;
    String val = priceD.toStringAsFixed(2);
    if(val.endsWith('.00')){
      val = val.substring(0, val.length - 3);
    }
    else if(val.contains('.') && val.endsWith('0')){
      val = val.substring(0, val.length - 1);
    }
    return val;
  }

  static String getBreakText(String text) {
    String result = '';
    text.runes.forEach((element) {
      result += String.fromCharCode(element);
      result += '\u200B';
    });
    return result;
  }

  static String getTimeText(int seconds){
    if(seconds < 60){
      return '$seconds秒';
    }
    if(seconds < 3600){
      return '${seconds ~/ 60}分钟';
    }
    if(seconds < 3600 * 24){
      int hours = seconds ~/ 3600;
      int minutes = (seconds % 3600) ~/ 60;
      return '$hours小时$minutes分钟';
    }
    int days = seconds ~/ (3600 * 24);
    int hours = (seconds % (3600 * 24)) ~/ 3600;
    return '$days天$hours小时';
  }

  static String getDistanceText(int meters){
    if(meters < 1000){
      return '$meters米';
    }
    double kms = meters / 1000;
    return '${kms.toStringAsFixed(1)}千米';
  }

  static String getLimitedTimeFromSeconds(int leftSeconds){
    int hours = leftSeconds ~/ 3600;
    int minutes = leftSeconds ~/ 60;
    int seconds = leftSeconds - minutes * 60;
    minutes = (leftSeconds % 3600) ~/ 60;
    String result = '';
    if(hours > 0){
      result += '$hours:';
    }
    if(minutes >= 10){
      result += '$minutes:';
    }
    else{
      result += '0$minutes:';
    }
    if(seconds >= 10){
      result += '$seconds';
    }
    else{
      result += '0$seconds';
    }
    return result;
  }

  static String getAuthorTag(ProductType type){
    String? ownnerTag;
    switch(type){
      case ProductType.guide:
      case ProductType.video:
      case ProductType.circle:
        ownnerTag = '作者';
        break;
      case ProductType.hotel:
      case ProductType.restaurant:
      case ProductType.scenic:
      case ProductType.travel:
        ownnerTag = '商家';
        break;
      default:
        ownnerTag = '作者';
    }
    return ownnerTag;
  }

  static String getScoreString(num score){
    String val = (score / 10).toStringAsFixed(1);
    if(val.endsWith('.0')){
      val = val.substring(0, val.length - 2);
    }
    return val;
  }
}
