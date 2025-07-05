
class Customer{
  int userId;
  String? realName;
  int? sex;
  DateTime? birthday;
  String? description;
  String? identityNum;
  int? billType;
  String? billTitle;
  String? billAddress;
  String? billAccount;
  String? billAccountBank;
  String? billTaxNum;
  String? billNoticeEmail;
  int? verifyStatus;

  Customer(this.userId);
  Customer.fromJson(dynamic json): userId = json['userId']{
    realName = json['realName'];
    sex = json['sex'];
    if(json['birthday'] != null){
      birthday = DateTime.tryParse(json['birthday']);
    }
    description = json['description'];
    identityNum = json['identityNum'];
    billType = json['billType'];
    billTitle = json['billTitle'];
    billAddress = json['billAddress'];
    billAccount = json['billAccount'];
    billAccountBank = json['billAccountBank'];
    billTaxNum = json['billTaxNum'];
    billNoticeEmail = json['billNoticeEmail'];
    verifyStatus = json['verifyStatus'];
  }

  static const int SEX_MALE = 0;
  static const int SEX_FEMALE = 1;
  static const int BILL_TYPE_PERSONAL = 0;
  static const int BILL_TYPE_COMPANY = 1;
  static const int VERIFY_STATUS_NONE = 0;
  static const int VERIFY_STATUS_WAITING = 1;
  static const int VERITY_STATUS_SUCCESS = 2;
  static const int VERITY_STATUS_REJECTED = 3;
}

enum VerifyStatus{
  none,
  waiting,
  success,
  rejected
}

extension VerifyStatusExt on VerifyStatus{
  int getNum(){
    switch(this){
      case VerifyStatus.none:
        return Customer.VERIFY_STATUS_NONE;
      case VerifyStatus.waiting:
        return Customer.VERIFY_STATUS_WAITING;
      case VerifyStatus.success:
        return Customer.VERITY_STATUS_SUCCESS;
      case VerifyStatus.rejected:
        return Customer.VERITY_STATUS_REJECTED;
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

enum BillType{
  personal,
  company
}

extension BillTypeExt on BillType{
  int getNum(){
    switch(this){
      case BillType.personal:
        return Customer.BILL_TYPE_PERSONAL;
      case BillType.company:
        return Customer.BILL_TYPE_COMPANY;
    }
  }
  static BillType? getType(int num){
    for(BillType type in BillType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum Sex{
  male,
  female
}

extension SexExt on Sex{
  int getNum(){
    if(this == Sex.male){
      return Customer.SEX_MALE;
    }
    else{
      return Customer.SEX_FEMALE;
    }
  }
  static Sex? getSex(int num){
    if(num == Customer.SEX_MALE){
      return Sex.male;
    }
    else if(num == Customer.SEX_FEMALE){
      return Sex.female;
    }
    return null;
  }
}
