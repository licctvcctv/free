
class RegularUtil{

  static bool checkPhone(String phone){
    final RegExp regExp = RegExp('^[1][^012][0-9]{9}\$');
    return regExp.hasMatch(phone);
  }

  static bool checkPassword(String password){
    final RegExp regExp = RegExp('^(?=.*[0-9])(?=.*[A-Za-z]+)[0-9A-Za-z]{6,20}\$');
    return regExp.hasMatch(password);
  }

  static bool checkCode(String code){
    final RegExp regExp = RegExp('^[0-9]{4,8}\$');
    return regExp.hasMatch(code);
  }

  /*static bool checkEmail(String email){
    final RegExp regExp = RegExp(r'^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,})$');
    return regExp.hasMatch(email);
  }*/

  static bool checkEmail(String email) {
    final RegExp regExp = RegExp(
      r'^[a-z0-9_-]+(\.[a-z0-9_-]+)*@([a-z0-9-]+\.)+[a-z]{2,}(\.[a-z]{2,})*$',
      caseSensitive: false, // 忽略大小写
    );
    return regExp.hasMatch(email.toLowerCase()); // 统一转小写匹配
  }

  static bool checkIdCard(String card){
    final RegExp regExp = RegExp(r'^[1-9]\d{5}(18|19|20)\d{2}((0[1-9])|(1[0-2]))(([0-2][1-9])|10|20|30|31)\d{3}[0-9Xx]$');
    if(!regExp.hasMatch(card)){
      return false;
    }
    List<int> factor = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2];
    List<Object> code = [1, 0, 'X', 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for(int i = 0; i < 17; ++i){
      sum += int.parse(card[i]) * factor[i];
    }
    return code[sum % 11].toString() == card[17];
  }

  static bool checkBankCard(String card){
    final RegExp regExp = RegExp(r'^([1-9]{1})(\d{11,18})$');
    return regExp.hasMatch(card);
  }

  static bool checkFixedPhone(String phone){
    final RegExp regExp = RegExp(r'^((\(0[1-9]\d{1,3}\))|(0[1-9]\d{1,3}))[-]?[2-9]\d{2,3}[-]?\d{4}$');
    return regExp.hasMatch(phone);
  }

  static bool checkChinese(String text){
    final RegExp regExp = RegExp(r'^(?:[\u3400-\u4DB5\u4E00-\u9FEA\uFA0E\uFA0F\uFA11\uFA13\uFA14\uFA1F\uFA21\uFA23\uFA24\uFA27-\uFA29]|[\uD840-\uD868\uD86A-\uD86C\uD86F-\uD872\uD874-\uD879][\uDC00-\uDFFF]|\uD869[\uDC00-\uDED6\uDF00-\uDFFF]|\uD86D[\uDC00-\uDF34\uDF40-\uDFFF]|\uD86E[\uDC00-\uDC1D\uDC20-\uDFFF]|\uD873[\uDC00-\uDEA1\uDEB0-\uDFFF]|\uD87A[\uDC00-\uDFE0])+$');
    return regExp.hasMatch(text);
  }

  static bool checkNumber(String text){
    final RegExp regExp = RegExp(r'^\d+$');
    return regExp.hasMatch(text);
  }
}
