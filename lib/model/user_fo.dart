
class UserFoModel {
  late int id;
  String? name;
  String? head;
  String? realName;
  String? phone;
  int? sex;
  String? birthday;
  String? description;
  int?  identityType;
  String? createTime;
  String? token;
  int? totalAmount;

  String? identityNum;
  int? billType;
  String? billTitle;
  String? billAccount;
  String? billAddress;
  String? billAccountBank;
  String? billTaxNum;
  String? billNoticeEmail;
  int? verifyStatus;
  int? merchantVerifyStatus;

  String? wxOpenId;
  String? wxUnionId;
  String? wxRealName;
  String? alipayUserId;
  String? alipayAlipayUserid;
  String? alipayRealName;

  int? likeNum;
  int? getLikedNum;
  int? favoriteNum;
  int? getFavoritedNum;
  int? getGiftNum;

  bool? isDeleted;

  UserFoModel(this.id);
  UserFoModel.fromJson(dynamic json) {
    id = json['id'] as int;
    name = json['name'];
    head = json['head'];
    phone = json['phone'];
    identityType = json['identityType'] as int;
    createTime = json['createTime'];
    token = json['token'];
    sex = json['sex'];
    birthday = json['birthday'];
    description = json['description'];
    totalAmount = json['totalAmount'];
    realName = json['realName'];
    identityNum = json['identityNum'];
    billType = json['billType'];
    billTitle = json['billTitle'];
    billAddress = json['billAddress'];
    billAccount = json['billAccount'];
    billAccountBank = json['billAccountBank'];
    billTaxNum = json['billTaxNum'];
    billNoticeEmail = json['billNoticeEmail'];
    verifyStatus = json['verifyStatus'];
    merchantVerifyStatus = json['merchantVerifyStatus'];

    likeNum = json['likeNum'];
    getLikedNum = json['getLikedNum'];
    favoriteNum = json['favoriteNum'];
    getFavoritedNum = json['getFavoritedNum'];
    getGiftNum = json['getGiftNum'];

    isDeleted = json['isDeleted'];
  }

}
