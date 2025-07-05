
class Merchant{
  int? id;
  int? userId;
  String? shopName;
  String? shopsignPic;
  String? frontPic;
  String? address;
  double? addressLng;
  double? addressLat;
  String? fixedPhone;
  String? contactName;
  String? contactPhone;
  String? contactEmail;
  DateTime? contractDate;
  int? verifyStatus;
  DateTime? verifyTime;
  int? licType;
  String? licPic;
  int? isLicAddrSame;
  String? licAddrDes;
  String? identityFrontPic;
  String? identityBackPic;
  String? identityHandPic;
  int? isIdentityLegal;
  String? grantPic;
  int? payPeriod;
  int? payAccountType;
  String? payAccountName;
  String? payAccountProvince;
  String? payAccountCity;
  String? payAccountDist;
  String? payAccountBank;
  String? payAccountBankSub;
  String? payAccountNum;
  String? payAccountBankCode;
  int? businessType;
  DateTime? createTime;
  DateTime? updateTime;

  Merchant.fromJson(dynamic json){
    id = json['id'];
    userId = json['userId'];
    shopName = json['shopName'];
    shopsignPic = json['shopsignPic'];
    frontPic = json['frontPic'];
    address = json['address'];
    addressLng = json['addressLng'];
    addressLat = json['addressLat'];
    fixedPhone = json['fixedPhone'];
    contactName = json['contactName'];
    contactPhone = json['contactPhone'];
    contactEmail = json['contactEmail'];
    if(json['contractDate'] is String){
      contractDate = DateTime.tryParse(json['contractDate']);
    }
    verifyStatus = json['verifyStatus'];
    if(json['verifyTime'] is String){
      verifyTime = DateTime.tryParse(json['verifyTime']);
    }
    licType = json['licType'];
    licPic = json['licPic'];
    isLicAddrSame = json['isLicAddrSame'];
    licAddrDes = json['licAddrDes'];
    identityFrontPic = json['identityFrontPic'];
    identityBackPic = json['identityBackPic'];
    identityHandPic = json['identityHandPic'];
    isIdentityLegal = json['isIdentityLegal'];
    grantPic = json['grantPic'];
    payPeriod = json['payPeriod'];
    payAccountType = json['payAccountType'];
    payAccountName = json['payAccountName'];
    payAccountProvince = json['payAccountProvince'];
    payAccountCity = json['payAccountCity'];
    payAccountDist = json['payAccountDist'];
    payAccountBank = json['payAccountBank'];
    payAccountBankSub = json['payAccountBankSub'];
    payAccountNum = json['payAccountNum'];
    payAccountBankCode = json['payAccountBankCode'];
    businessType = json['businessType'];
    if(json['createTime'] is String){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] is String){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
  }
}

enum VerifyStatus{
  verifying,
  verified,
  verifyFail
}

extension VerifyStatusExt on VerifyStatus{
  int getNum(){
    switch(this){
      case VerifyStatus.verifying:
        return 0;
      case VerifyStatus.verified:
        return 2;
      case VerifyStatus.verifyFail:
        return 3;
    }
  }
  static VerifyStatus? getStatus(int num){
    for(VerifyStatus status in VerifyStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}

enum BusinessType{
  hotel,
  restaurant,
  scenic,
  travelAgency,
  other
}

extension BusinessTypeExt on BusinessType{
  int getNum(){
    switch(this){
      case BusinessType.hotel:
        return 1;
      case BusinessType.restaurant:
        return 2;
      case BusinessType.scenic:
        return 3;
      case BusinessType.travelAgency:
        return 4;
      case BusinessType.other:
        return 5;
    }
  }
  static BusinessType? getType(int num){
    for(BusinessType type in BusinessType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum LicType{ // 资质证件类型
  businessLicense,
  other
}

extension LicTypeExt on LicType{
  int getNum(){
    switch(this){
      case LicType.businessLicense:
        return 0;
      case LicType.other:
        return 1;
    }
  }
  static LicType? getType(int num){
    for(LicType type in LicType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum PayPeriodType{
  week,
  month
}

extension PayPeriodTypeExt on PayPeriodType{
  int getNum(){
    switch(this){
      case PayPeriodType.week:
        return 0;
      case PayPeriodType.month:
        return 1;
    }
  }
  static PayPeriodType? getType(int num){
    for(PayPeriodType type in PayPeriodType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum PayAccountType{
  person,
  company
}

extension PayAccountTypeExt on PayAccountType{
  int getNum(){
    switch(this){
      case PayAccountType.person:
        return 0;
      case PayAccountType.company:
        return 1;
    }
  }
  static PayAccountType? getType(int num){
    for(PayAccountType type in PayAccountType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}
