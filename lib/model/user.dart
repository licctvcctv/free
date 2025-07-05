import 'package:freego_flutter/util/storage.dart';

class UserModel {
  late int id;
  String? name;
  String? head;
  String? phone;
  int?  identityType;
  String? createTime;
  String? token;

  String? wxOpenId;
  String? wxUnionId;
  String? wxNickName;

  String? alipayUserId;
  String? alipayAlipayUserId;
  String? alipayNickName;

  String? appleUserId;

  int? likeNum;
  int? getLikedNum;
  int? favoriteNum;
  int? getFavoritedNum;

  UserModel(this.id,this.name);

  UserModel.fromJson(dynamic json) {
    id = json['id'] as int;
    name = json['name'];
    head = json['head'];
    phone = json['phone'];
    identityType = json['identityType'] as int;
    createTime = json['createTime'];
    token = json['token'];
    
    wxOpenId = json['wxOpenId'];
    wxUnionId = json['wxUnionId'];
    wxNickName = json['wxNickName'];

    alipayUserId = json['alipayUserId'];
    alipayAlipayUserId = json['alipayAlipayUserId'];
    alipayNickName = json['alipayNickName'];

    appleUserId = json['appleUserId'];

    likeNum = json['likeNum'];
    getLikedNum = json['getLikedNum'];
    favoriteNum = json['favoriteNum'];
    getFavoritedNum = json['getFavoritedNum'];
  }

  static Future<bool> isLogin() async {
    String? token = await Storage.readInfo<String>("user_token");
    if(token!=null && token.isNotEmpty) {
      return true;
    }
    return false;
  }

  static Future<String?> getUserToken() async {
    String? token = await Storage.readInfo<String>("user_token");
    return token;
  }

  static Future<int> getUserId() async {
    int id = await Storage.readInfo<int>("user_id");
    return id;
  }

  static Future<int> getUserIdentityType() async {
    int type = await Storage.readInfo<int>('user_identity_type');
    return type;
  }

  static Future<void> logout() async{
    await Storage.remove('user_token');
    await Storage.remove('user_id');
    await Storage.remove('user_name');
    await Storage.remove('user_head');
    await Storage.remove('user_identity_type');
  }

  static Future<void> login(UserModel user) async{

  }
}

class UserMixin{
  String? userName;
  String? userHead;
}
