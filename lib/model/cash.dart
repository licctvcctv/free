
class Cash{
  int userId;
  int? totalAmount;
  DateTime? updateTime;
  Cash(this.userId);
  Cash.fromJson(dynamic json): userId = json['userId']{
    totalAmount = json['totalAmount'];
    if(json['updateTime'] != null){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
  }
}

class CashLog{
  int id;
  int? userId;
  int? type;
  int? sourceType;
  int? sourceId;
  int? amount;
  String? description;
  DateTime? createTime;
  CashLog(this.id);
  CashLog.fromJson(dynamic json): id = json['id']{
    userId = json['userId'];
    type = json['type'];
    sourceType = json['sourceType'];
    sourceId = json['sourceId'];
    amount = json['amount'];
    description = json['description'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
  }

  static const int TYPE_ENTRY = 0;
  static const int TYPE_OUTGOINT = 1;
  static const int SOURCE_TYPE_LOCAL = 0;
  static const int SOURCE_TYPE_EXTERNAL = 1;
}

enum SourceType{
  local,
  external
}

extension SourceTypeExt on SourceType{
  int getNum(){
    switch(this){
      case SourceType.local:
        return CashLog.SOURCE_TYPE_LOCAL;
      case SourceType.external:
        return CashLog.SOURCE_TYPE_EXTERNAL;
    }
  }
  static SourceType? getType(int num){
    for(SourceType type in SourceType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum CashLogType{
  entry,
  outgoint
}

extension CashLogTypeExt on CashLogType{
  int getNum(){
    switch(this){
      case CashLogType.entry:
        return CashLog.TYPE_ENTRY;
      case CashLogType.outgoint:
        return CashLog.TYPE_OUTGOINT;
    }
  }
}

class CashWithdraw {
  int id;
  int? userId;
  int? amount;
  int? accountType;
  String? refuseReason;
  String? checkedPic;
  int? status;
  DateTime? createTime;
  DateTime? updateTime;
  CashWithdraw(this.id);
  CashWithdraw.fromJson(dynamic json): id = json['id']{
    userId = json['userId'];
    amount = json['amount'];
    accountType = json['accountType'];
    refuseReason = json['refuseReason'];
    checkedPic = json['checkedPic'];
    status = json['status'];
    if(json['createTime'] != null){
      createTime = DateTime.tryParse(json['createTime']);
    }
    if(json['updateTime'] != null){
      updateTime = DateTime.tryParse(json['updateTime']);
    }
  }

  static const int ACCOUNT_TYPE_BANK = 0;
  static const int ACCOUNT_TYPE_WECHAT = 1;
  static const int ACCOUNT_TYPE_ALIPAY = 2;

  static const int STATUS_WAITING = 0;
  static const int STATUS_SUCCESS = 1;
  static const int STATUS_REJECTED = 2;
}

enum AccountType{
  bank,
  wechat,
  alipay,
}

extension AccountTypeExt on AccountType{
  int getNum(){
    switch(this){
      case AccountType.bank:
        return CashWithdraw.ACCOUNT_TYPE_BANK;
      case AccountType.wechat:
        return CashWithdraw.ACCOUNT_TYPE_WECHAT;
      case AccountType.alipay:
        return CashWithdraw.ACCOUNT_TYPE_ALIPAY;
    }
  }
  static AccountType? getType(int num){
    for(AccountType type in AccountType.values){
      if(type.getNum() == num){
        return type;
      }
    }
    return null;
  }
}

enum CashWithdrawStatus{
  waiting,
  success,
  rejected,
}

extension CashWithdrawStatusExt on CashWithdrawStatus{
  int getNum(){
    switch(this){
      case CashWithdrawStatus.waiting:
        return CashWithdraw.STATUS_WAITING;
      case CashWithdrawStatus.success:
        return CashWithdraw.STATUS_SUCCESS;
      case CashWithdrawStatus.rejected:
        return CashWithdraw.STATUS_REJECTED;
    }
  }
  static CashWithdrawStatus? getType(int num){
    for(CashWithdrawStatus status in CashWithdrawStatus.values){
      if(status.getNum() == num){
        return status;
      }
    }
    return null;
  }
}
