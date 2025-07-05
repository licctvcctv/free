
class UserCredit{
  int? userId;
  int? creditPoint;

  UserCredit();
  UserCredit.fromJson(Map<String, dynamic> json){
    userId = json['userId'];
    creditPoint = json['creditPoint'];
  }
}
